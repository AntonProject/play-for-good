// Prepared replacement for the EXISTING FF action. Not registered by prepare.sh.
// Add nullable Boolean parameter test and bind Environment.test in every caller.
// Only initial signup writes signup_test; normal login preserves its origin.
// After action success, invoke ggClaimSignupBonus(Environment.test) in the FF flow.
// Optional Dart argument preserves existing five-argument local calls.
import '/backend/supabase/supabase.dart';

Future<bool> signInAfterOtpVerification(
  String email,
  String password,
  String actionType,
  String? firstName,
  String? username, [
  bool? test,
]) async {
  try {
    final supabase = SupaFlow.client;

    print('=== First Sign In After OTP Verification ===');
    print('Email: $email');
    print('Action Type: $actionType');

    // This is the FIRST and ONLY sign in after OTP verification
    final signInResponse = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (signInResponse.user == null) {
      print('Failed to sign in after OTP verification');
      return false;
    }

    print('Successfully signed in: ${signInResponse.user!.id}');

    // Additional role check for admin signin
    if (actionType == 'adminSignin') {
      print('Verifying admin role after OTP...');
      final userRoleResponse = await supabase
          .from('users')
          .select('role')
          .eq('id', signInResponse.user!.id)
          .maybeSingle();

      if (userRoleResponse == null) {
        print('Error: User not found in users table');
        await supabase.auth.signOut();
        return false;
      }

      if (userRoleResponse['role'] != 'admin') {
        print('Error: User is not admin. Role: ${userRoleResponse['role']}');
        await supabase.auth.signOut();
        return false;
      }

      print('Admin role confirmed after OTP verification');
    }

    // Create user profile in 'users' table for signup
    if (actionType == 'signup' && firstName != null && username != null) {
      print('Creating user profile in users table...');

      try {
        // Check if profile exists
        final existingProfile = await supabase
            .from('users')
            .select('id')
            .eq('id', signInResponse.user!.id)
            .maybeSingle();

        if (existingProfile == null) {
          print('Creating new user profile');
          await supabase.from('users').insert({
            'id': signInResponse.user!.id,
            'email': email,
            'first_name': firstName,
            'display_name': username,
            'created_at': DateTime.now().toIso8601String(),
            'signup_test': test ?? false,
          });
          print('User profile created successfully');
        } else {
          print('User profile already exists, updating...');
          await supabase.from('users').update({
            'first_name': firstName,
            'display_name': username,
            'email': email,
            'signup_test': test ?? false,
          }).eq('id', signInResponse.user!.id);
          print('User profile updated successfully');
        }
      } catch (profileError) {
        print('Error with user profile: $profileError');
        // Don't fail the sign in because of profile issues
      }
    }

    return true;
  } catch (e) {
    print('signInAfterOtpVerification error: $e');
    return false;
  }
}
