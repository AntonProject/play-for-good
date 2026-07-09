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

import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> resendOtp(
  String email,
  String actionType,
) async {
  try {
    final supabase = Supabase.instance.client;

    print('=== resendOtp Debug ===');
    print('Email: $email');
    print('Action Type: $actionType');

    String? userId;

    // Try to find user_id from the latest OTP record for this email
    try {
      final otpQuery = await supabase
          .from('user_otp_codes')
          .select('user_id')
          .eq('email', email)
          .order('expires_at', ascending: false) // Get the most recent
          .limit(1)
          .maybeSingle();

      if (otpQuery != null && otpQuery['user_id'] != null) {
        userId = otpQuery['user_id'];
        print('Found user ID from OTP records: $userId');
      } else {
        // Fallback: try users table
        final userQuery = await supabase
            .from('users')
            .select('id')
            .eq('email', email)
            .maybeSingle();

        if (userQuery != null) {
          userId = userQuery['id'];
          print('Found user ID from users table: $userId');
        } else {
          print('No user found for resend');
          return false;
        }
      }
    } catch (e) {
      print('Error finding user: $e');
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

    print('OTP Response status: ${otpResponse.status}');
    print('OTP Response data: ${otpResponse.data}');

    if (otpResponse.status == 200 && otpResponse.data?['success'] == true) {
      print('OTP resent successfully');
      return true;
    } else {
      print('Failed to resend OTP: ${otpResponse.data?['error']}');
      return false;
    }
  } catch (e) {
    print('resendOtp error: $e');
    return false;
  }
}
