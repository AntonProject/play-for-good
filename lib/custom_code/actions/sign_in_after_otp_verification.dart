// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> signInAfterOtpVerification(
  String email,
  String password,
  String actionType,
  String? firstName,
  String? username,
) async {
  try {
    final supabase = Supabase.instance.client;

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
          });
          print('User profile created successfully');
        } else {
          print('User profile already exists, updating...');
          await supabase.from('users').update({
            'first_name': firstName,
            'display_name': username,
            'email': email,
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
