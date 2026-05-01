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

Future<String> verifyOtp(String email, String code) async {
  try {
    final supabase = Supabase.instance.client;

    print('Verifying OTP for: $email with code: $code');

    final response = await supabase.functions.invoke(
      'verify-otp',
      body: {
        'email': email,
        'code': code,
      },
    );

    print('Verify response status: ${response.status}');
    print('Verify response data: ${response.data}');

    if (response.status == 200 && response.data?['success'] == true) {
      print('Success: OTP verified successfully');
      return 'success';
    } else {
      // Handle error response
      String errorMessage =
          response.data?['error']?.toString().toLowerCase() ?? '';
      return _parseError(errorMessage);
    }
  } catch (e) {
    print('Caught exception: $e');

    // Handle FunctionException specifically
    if (e.toString().contains('FunctionException')) {
      String exceptionStr = e.toString().toLowerCase();

      if (exceptionStr.contains('invalid code')) {
        print('Error: Invalid code');
        return 'invalid';
      } else if (exceptionStr.contains('already used')) {
        print('Error: Code already used');
        return 'used';
      } else if (exceptionStr.contains('expired')) {
        print('Error: Code expired');
        return 'expired';
      } else if (exceptionStr.contains('no code')) {
        print('Error: No code found');
        return 'not_found';
      }
    }

    print('Error: Exception in verifyOtp - $e');
    return 'error';
  }
}

String _parseError(String errorMessage) {
  if (errorMessage.contains('already used')) {
    print('Error: Code already used');
    return 'used';
  } else if (errorMessage.contains('invalid') ||
      errorMessage.contains('mismatch')) {
    print('Error: Invalid code');
    return 'invalid';
  } else if (errorMessage.contains('expired')) {
    print('Error: Code expired');
    return 'expired';
  } else if (errorMessage.contains('no code') ||
      errorMessage.contains('not found')) {
    print('Error: No code found');
    return 'not_found';
  } else {
    print('Error: Unknown error - $errorMessage');
    return 'error';
  }
}
