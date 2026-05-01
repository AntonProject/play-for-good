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

Future<String> sendPasswordResetOtp(String email) async {
  try {
    final supabase = Supabase.instance.client;

    print('Sending password reset OTP to: $email');

    // Check if user exists
    final userResponse = await supabase
        .from('users')
        .select('id')
        .eq('email', email)
        .maybeSingle();

    if (userResponse == null) {
      print('Error: User not found');
      return 'user_not_found';
    }

    print('User found: ${userResponse['id']}');

    // Send OTP through Edge Function with password_reset type
    final otpResponse = await supabase.functions.invoke(
      'send-otp',
      body: {
        'email': email,
        'user_id': userResponse['id'],
        'type': 'password_reset', // This is the key difference
      },
    );

    print('OTP Response status: ${otpResponse.status}');
    print('OTP Response data: ${otpResponse.data}');

    if (otpResponse.status == 200 && otpResponse.data?['success'] == true) {
      print('Success: Password reset OTP sent');
      return 'success';
    } else {
      print('Error: Failed to send OTP - ${otpResponse.data?['error']}');
      return 'error';
    }
  } catch (e) {
    print('Error: Exception in sendPasswordResetOtp - $e');
    return 'error';
  }
}
