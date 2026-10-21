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

Future<bool> resendOtp(
  String email,
  String actionType,
) async {
  try {
    final supabase = Supabase.instance.client;

    _log('=== resendOtp Debug ===');
    _log('Email: $email');
    _log('Action Type: $actionType');

    String? userId;

    // The user by email. public.user_otp_codes is closed to the app
    // (18_close_otp_codes.sql: it exposed every live code), so the lookup goes
    // to public.users only.
    try {
      final userQuery = await supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (userQuery != null) {
        userId = userQuery['id'];
        _log('Found user ID from users table: $userId');
      } else {
        _log('No user found for resend');
        return false;
      }
    } catch (e) {
      _log('Error finding user: $e');
      return false;
    }

    // Call the send-otp Edge Function
    final otpResponse = await supabase.functions.invoke(
      'send-otp',
      body: {
        'email': email,
        'user_id': userId,
        'type': actionType,
      },
    );

    _log('OTP Response status: ${otpResponse.status}');
    _log('OTP Response data: ${otpResponse.data}');

    if (otpResponse.status == 200 && otpResponse.data?['success'] == true) {
      _log('OTP resent successfully');
      return true;
    } else {
      _log('Failed to resend OTP: ${otpResponse.data?['error']}');
      return false;
    }
  } catch (e) {
    _log('resendOtp error: $e');
    return false;
  }
}

// Logs only in debug builds; release builds print nothing (emails,
// responses). Passwords and OTP codes are never logged.
void _log(Object? message) {
  if (kDebugMode) print(message);
}
