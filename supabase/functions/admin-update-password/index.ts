// admin-update-password — sets a new password after a verified reset OTP.
//
// Contract with the app (custom action updatePassword):
//   POST { email, new_password }  ->  200 { success: true }
//   anything else                 ->  4xx/5xx { success: false, error }
//
// Before (19.10.2026) the deployed function had no stored source and changed
// the password for any email sent with the public anon key. Now the password
// changes only when this email has a password_reset code that verify-otp has
// already confirmed (is_used = true) within RESET_WINDOW_MINUTES. That code is
// consumed (otp_type -> 'password_reset_done'), so it works once. Errors do not
// tell whether an email is registered.
//
// Deploy (owner): supabase functions deploy admin-update-password
// Uses SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY (provided by Supabase).
import { createClient } from "jsr:@supabase/supabase-js@2";

const RESET_WINDOW_MINUTES = 15;
const MIN_PASSWORD_LENGTH = 6;

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function reply(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

// Same answer for an unknown email and for a missing / old / used code.
const notAllowed = () =>
  reply(400, { success: false, error: "Password reset is not allowed. Request a new code." });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return reply(405, { success: false, error: "Method not allowed" });

  let email = "";
  let password = "";
  try {
    const body = await req.json();
    email = String(body?.email ?? "").trim().toLowerCase();
    password = String(body?.new_password ?? "");
  } catch {
    return reply(400, { success: false, error: "Invalid request" });
  }
  if (!email || !email.includes("@")) return reply(400, { success: false, error: "Invalid request" });
  if (password.length < MIN_PASSWORD_LENGTH) {
    return reply(400, { success: false, error: "Password is too short" });
  }

  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );

  // The user (public.users.id = auth user id).
  const { data: user, error: userError } = await admin
    .from("users")
    .select("id")
    .ilike("email", email)
    .maybeSingle();
  if (userError) {
    console.error("users lookup failed", userError.message);
    return reply(500, { success: false, error: "Server error" });
  }
  if (!user) return notAllowed();

  // A password_reset code of this email, confirmed by verify-otp, recent.
  const since = new Date(Date.now() - RESET_WINDOW_MINUTES * 60_000).toISOString();
  const { data: code, error: codeError } = await admin
    .from("user_otp_codes")
    .select("id")
    .ilike("email", email)
    .eq("otp_type", "password_reset")
    .eq("is_used", true)
    .gte("created_at", since)
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();
  if (codeError) {
    console.error("otp lookup failed", codeError.message);
    return reply(500, { success: false, error: "Server error" });
  }
  if (!code) return notAllowed();

  // Consume the code first (only one request can win it).
  const { data: consumed, error: consumeError } = await admin
    .from("user_otp_codes")
    .update({ otp_type: "password_reset_done" })
    .eq("id", code.id)
    .eq("otp_type", "password_reset")
    .select("id");
  if (consumeError) {
    console.error("otp consume failed", consumeError.message);
    return reply(500, { success: false, error: "Server error" });
  }
  if (!consumed || consumed.length === 0) return notAllowed();

  const { error: updateError } = await admin.auth.admin.updateUserById(user.id, { password });
  if (updateError) {
    // Give the code back so the user can retry within the window.
    await admin.from("user_otp_codes").update({ otp_type: "password_reset" }).eq("id", code.id);
    console.error("password update failed", updateError.message);
    const weak = /password/i.test(updateError.message);
    return reply(weak ? 400 : 500, {
      success: false,
      error: weak ? "Password does not meet the requirements" : "Server error",
    });
  }

  return reply(200, { success: true });
});
