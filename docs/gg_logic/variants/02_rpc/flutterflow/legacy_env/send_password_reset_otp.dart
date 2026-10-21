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

Future<String> sendPasswordResetOtp(String email) async {
  try {
    final supabase = Supabase.instance.client;

    _log('Sending password reset OTP to: $email');

    // Check if user exists
    final userResponse = await supabase
        .from('users')
        .select('id')
        .eq('email', email)
        .maybeSingle();

    if (userResponse == null) {
      _log('Error: User not found');
      return 'user_not_found';
    }

    _log('User found: ${userResponse['id']}');

    // Send OTP through Edge Function with password_reset type
    final otpResponse = await supabase.functions.invoke(
      'send-otp',
      body: {
        'email': email,
        'user_id': userResponse['id'],
        'type': 'password_reset', // This is the key difference
      },
    );

    _log('OTP Response status: ${otpResponse.status}');
    _log('OTP Response data: ${otpResponse.data}');

    if (otpResponse.status == 200 && otpResponse.data?['success'] == true) {
      _log('Success: Password reset OTP sent');
      return 'success';
    } else {
      _log('Error: Failed to send OTP - ${otpResponse.data?['error']}');
      return 'error';
    }
  } catch (e) {
    _log('Error: Exception in sendPasswordResetOtp - $e');
    return 'error';
  }
}

// Logs only in debug builds; release builds print nothing (emails,
// responses). Passwords and OTP codes are never logged.
void _log(Object? message) {
  if (kDebugMode) print(message);
}
