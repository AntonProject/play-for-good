// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom actions
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> updatePassword(
  String newPassword,
  String email, // Add email parameter for auto-login
) async {
  try {
    final supabase = Supabase.instance.client;

    print('=== Update Password via Admin API ===');
    print('Email: $email');
    print('New password length: ${newPassword.length}');

    // Call Edge Function to update password via admin API
    print('Calling Edge Function to update password...');

    final response = await supabase.functions.invoke(
      'admin-update-password',
      body: {
        'email': email,
        'new_password': newPassword,
      },
    );

    print('Update password response status: ${response.status}');
    print('Update password response data: ${response.data}');

    if (response.status == 200 && response.data?['success'] == true) {
      print('Password updated successfully via Edge Function');

      // Now sign in with new password
      print('Signing in with new password...');
      final signInResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: newPassword,
      );

      if (signInResponse.user == null) {
        print('Error: Failed to sign in with new password');
        return 'signin_failed';
      }

      print('Successfully signed in: ${signInResponse.user!.id}');
      return 'success';
    } else {
      print('Failed to update password: ${response.data?['error']}');
      return 'update_failed';
    }
  } catch (e) {
    print('Error in updatePassword: $e');

    String errorStr = e.toString().toLowerCase();

    if (errorStr.contains('invalid login credentials') ||
        errorStr.contains('invalid email or password')) {
      return 'signin_failed';
    } else if (errorStr.contains('network') ||
        errorStr.contains('connection')) {
      return 'network_error';
    } else if (errorStr.contains('password')) {
      return 'password_error';
    } else {
      return 'unknown_error';
    }
  }
}
