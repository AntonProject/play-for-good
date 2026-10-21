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

Future<String> verifyOtp(String email, String code) async {
  try {
    final supabase = Supabase.instance.client;

    _log('Verifying OTP for: $email');

    final response = await supabase.functions.invoke(
      'verify-otp',
      body: {
        'email': email,
        'code': code,
      },
    );

    _log('Verify response status: ${response.status}');
    _log('Verify response data: ${response.data}');

    if (response.status == 200 && response.data?['success'] == true) {
      _log('Success: OTP verified successfully');
      return 'success';
    } else {
      // Handle error response
      String errorMessage =
          response.data?['error']?.toString().toLowerCase() ?? '';
      return _parseError(errorMessage);
    }
  } catch (e) {
    _log('Caught exception: $e');

    // Handle FunctionException specifically
    if (e.toString().contains('FunctionException')) {
      String exceptionStr = e.toString().toLowerCase();

      if (exceptionStr.contains('invalid code')) {
        _log('Error: Invalid code');
        return 'invalid';
      } else if (exceptionStr.contains('already used')) {
        _log('Error: Code already used');
        return 'used';
      } else if (exceptionStr.contains('expired')) {
        _log('Error: Code expired');
        return 'expired';
      } else if (exceptionStr.contains('no code')) {
        _log('Error: No code found');
        return 'not_found';
      }
    }

    _log('Error: Exception in verifyOtp - $e');
    return 'error';
  }
}

String _parseError(String errorMessage) {
  if (errorMessage.contains('already used')) {
    _log('Error: Code already used');
    return 'used';
  } else if (errorMessage.contains('invalid') ||
      errorMessage.contains('mismatch')) {
    _log('Error: Invalid code');
    return 'invalid';
  } else if (errorMessage.contains('expired')) {
    _log('Error: Code expired');
    return 'expired';
  } else if (errorMessage.contains('no code') ||
      errorMessage.contains('not found')) {
    _log('Error: No code found');
    return 'not_found';
  } else {
    _log('Error: Unknown error - $errorMessage');
    return 'error';
  }
}

// Logs only in debug builds; release builds print nothing (emails,
// responses). Passwords and OTP codes are never logged.
void _log(Object? message) {
  if (kDebugMode) print(message);
}
