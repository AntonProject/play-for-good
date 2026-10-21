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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

Future<String> signUpWithOtp(
  String email,
  String password,
  String firstName,
  String displayName,
) async {
  try {
    final supabase = Supabase.instance.client;

    _log('=== signUpWithOtp (No Auto-Login) ===');
    _log('Email: $email');
    _log('FirstName: $firstName');
    _log('DisplayName: $displayName');

    // Check if email or display name are empty
    if (email.trim().isEmpty || displayName.trim().isEmpty) {
      _log('Empty email or display name');
      return 'error';
    }

    // Check if display_name already exists in auth.users metadata AND users table
    // First check in users table
    final existingDisplayNameInUsers = await supabase
        .from('users')
        .select('email, display_name')
        .ilike('display_name', displayName.trim())
        .maybeSingle();

    if (existingDisplayNameInUsers != null) {
      _log(
          'Display name already exists in users table: $displayName (found: ${existingDisplayNameInUsers['display_name']})');
      return 'name_exists';
    }

    _log(
        'Display name is available in users table, proceeding with user creation');

    // Create user through Edge Function WITHOUT auto-login
    // Email uniqueness will be checked by Supabase Auth automatically
    final requestBody = {
      'email': email.trim(),
      'password': password,
      'first_name': firstName.trim(),
      'display_name': displayName.trim(),
    };

    final response = await supabase.functions.invoke(
      'create-user-without-login',
      body: requestBody,
    );

    _log('Create user response status: ${response.status}');
    _log('Create user response data: ${response.data}');

    if (response.status == 200 &&
        response.data != null &&
        response.data['success'] == true) {
      return 'success';
    } else {
      _log('Edge function error: ${response.data}');

      // Check if error message contains email already exists
      String errorMessage = response.data?['error']?.toString() ?? '';
      if (errorMessage.toLowerCase().contains('email') &&
          errorMessage.toLowerCase().contains('already')) {
        return 'email_exists';
      }

      // Check if error message contains display name already exists
      if (errorMessage.toLowerCase().contains('display_name') ||
          errorMessage.toLowerCase().contains('name') &&
              errorMessage.toLowerCase().contains('exists')) {
        return 'name_exists';
      }

      return 'error';
    }
  } catch (e) {
    _log('signUpWithOtp error: $e');

    // Check if exception message contains email already exists
    String errorMessage = e.toString().toLowerCase();
    if (errorMessage.contains('email') && errorMessage.contains('already')) {
      return 'email_exists';
    }

    // Check if exception message contains display name already exists
    if (errorMessage.contains('display_name') ||
        (errorMessage.contains('name') && errorMessage.contains('exists'))) {
      return 'name_exists';
    }

    return 'error';
  }
}

// Logs only in debug builds; release builds print nothing (emails,
// responses). Passwords and OTP codes are never logged.
void _log(Object? message) {
  if (kDebugMode) print(message);
}
