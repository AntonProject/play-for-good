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

import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> signUpWithOtp(
  String email,
  String password,
  String firstName,
  String displayName,
) async {
  try {
    final supabase = Supabase.instance.client;

    print('=== signUpWithOtp (No Auto-Login) ===');
    print('Email: $email');
    print('FirstName: $firstName');
    print('DisplayName: $displayName');

    // Check if email or display name are empty
    if (email.trim().isEmpty || displayName.trim().isEmpty) {
      print('Empty email or display name');
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
      print(
          'Display name already exists in users table: $displayName (found: ${existingDisplayNameInUsers['display_name']})');
      return 'name_exists';
    }

    print(
        'Display name is available in users table, proceeding with user creation');

    // Create user through Edge Function WITHOUT auto-login
    // Email uniqueness will be checked by Supabase Auth automatically
    final requestBody = {
      'email': email.trim(),
      'password': password,
      'first_name': firstName.trim(),
      'display_name': displayName.trim(),
    };

    print('Request body: $requestBody');

    final response = await supabase.functions.invoke(
      'create-user-without-login',
      body: requestBody,
    );

    print('Create user response status: ${response.status}');
    print('Create user response data: ${response.data}');

    if (response.status == 200 &&
        response.data != null &&
        response.data['success'] == true) {
      return 'success';
    } else {
      print('Edge function error: ${response.data}');

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
    print('signUpWithOtp error: $e');

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
