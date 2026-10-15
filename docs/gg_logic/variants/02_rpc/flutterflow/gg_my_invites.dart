// Custom Action ggMyInvites. Returns List<InvitesRow>: the signed-in user's
// used invites of the current environment (same filter as the former Home
// query: inviter_user_id = me, was_used = true, test = environment).
// Guest -> empty list, no request. Keep FF automatic imports above this code.
import '/backend/supabase/supabase.dart';

Future<List<InvitesRow>> ggMyInvites(bool test) async {
  final uid = SupaFlow.client.auth.currentUser?.id;
  if (uid == null || uid.isEmpty) return [];
  final rows = await SupaFlow.client
      .from('invites')
      .select()
      .eq('inviter_user_id', uid)
      .eq('was_used', true)
      .eq('test', test);
  return (rows as List)
      .map((r) => InvitesRow(Map<String, dynamic>.from(r as Map)))
      .toList();
}
