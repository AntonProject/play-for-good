// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom actions
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

Future<String> updatePassword(
  String newPassword,
  String email, // Add email parameter for auto-login
) async {
  try {
    final supabase = Supabase.instance.client;

    _log('=== Update Password via Admin API ===');
    _log('Email: $email');
    _log('New password length: ${newPassword.length}');

    // Call Edge Function to update password via admin API
    _log('Calling Edge Function to update password...');

    final response = await supabase.functions.invoke(
      'admin-update-password',
      body: {
        'email': email,
        'new_password': newPassword,
      },
    );

    _log('Update password response status: ${response.status}');
    _log('Update password response data: ${response.data}');

    if (response.status == 200 && response.data?['success'] == true) {
      _log('Password updated successfully via Edge Function');

      // Now sign in with new password
      _log('Signing in with new password...');
      final signInResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: newPassword,
      );

      if (signInResponse.user == null) {
        _log('Error: Failed to sign in with new password');
        return 'signin_failed';
      }

      _log('Successfully signed in: ${signInResponse.user!.id}');
      return 'success';
    } else {
      _log('Failed to update password: ${response.data?['error']}');
      return 'update_failed';
    }
  } catch (e) {
    _log('Error in updatePassword: $e');

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

// Logs only in debug builds; release builds print nothing (emails,
// responses). Passwords and OTP codes are never logged.
void _log(Object? message) {
  if (kDebugMode) print(message);
}
