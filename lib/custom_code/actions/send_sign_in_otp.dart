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
import 'dart:async';

// Background function to send OTP (fire and forget)
void _sendOtpInBackground(SupabaseClient supabase, String email, String userId,
    String otpType) async {
  try {
    // Add small delay to ensure session is fully cleared (especially important on Android)
    await Future.delayed(Duration(milliseconds: 500));
    print('Background: Starting OTP send for $email');

    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final otpResponse = await supabase.functions.invoke(
          'send-otp',
          body: {
            'email': email,
            'user_id': userId,
            'type': otpType,
          },
        ).timeout(
          Duration(seconds: 45),
          onTimeout: () {
            throw TimeoutException('OTP request timed out');
          },
        );

        print('Background: OTP Response status: ${otpResponse.status}');

        if (otpResponse.status == 200) {
          final data = otpResponse.data;
          if (data is Map &&
              (data['success'] == true || data['message_id'] != null)) {
            print('✅ Background: OTP sent successfully');
            return; // Success, exit
          }
          print('⚠️ Background: Status 200 but unclear success state');
          return; // Assume success if status is 200
        } else {
          // Retry on non-200 status (except 400)
          if (otpResponse.status != 400) {
            retryCount++;
            if (retryCount < maxRetries) {
              print(
                  '⚠️ Background: Retry $retryCount/$maxRetries: Status ${otpResponse.status}');
              await Future.delayed(Duration(milliseconds: 1000 * retryCount));
              continue;
            }
          }
          print(
              '❌ Background: Failed to send OTP - status ${otpResponse.status}');
          return; // Give up after retries
        }
      } on TimeoutException catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          print('⚠️ Background: Retry $retryCount/$maxRetries: Timeout');
          await Future.delayed(Duration(milliseconds: 1000 * retryCount));
          continue;
        }
        print('❌ Background: OTP request timeout after $maxRetries attempts');
        return;
      } catch (otpError) {
        retryCount++;
        if (retryCount < maxRetries) {
          print(
              '⚠️ Background: Retry $retryCount/$maxRetries: Error - $otpError');
          await Future.delayed(Duration(milliseconds: 1000 * retryCount));
          continue;
        }
        print(
            '❌ Background: OTP function call failed after $maxRetries attempts - $otpError');
        return;
      }
    }
  } catch (e) {
    print('❌ Background: Exception in OTP sending - $e');
  }
}

Future<String> sendSignInOtp(
  String email,
  String password,
  String? signinType,
) async {
  try {
    final supabase = Supabase.instance.client;
    final isAdminSignin = signinType == 'adminSignin';
    final otpType = isAdminSignin ? 'adminSignin' : 'signin';

    print('Attempting ${isAdminSignin ? 'admin ' : ''}signin for: $email');

    if (email.isEmpty || password.isEmpty) {
      print('Error: Email or password is empty');
      return 'empty_fields';
    }

    // Sign in to verify credentials
    print('Attempting signin...');
    final signInResponse = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (signInResponse.user == null) {
      print('Error: Invalid credentials');
      return 'invalid_credentials';
    }

    print('Success: User found: ${signInResponse.user!.id}');

    // Store user ID before sign out
    final userId = signInResponse.user!.id;

    // Sign out immediately after verification
    await supabase.auth.signOut();
    print('Signed out successfully');

    // Return success immediately after credentials verification
    // OTP sending will happen asynchronously in the background
    print('✅ Credentials verified, returning success immediately');

    // Send OTP asynchronously in background (fire and forget)
    _sendOtpInBackground(supabase, email, userId, otpType);

    return 'success';
  } catch (e) {
    print('❌ Error: Exception in sendSignInOtp - $e');
    String errorStr = e.toString().toLowerCase();

    if (errorStr.contains('invalid login credentials') ||
        errorStr.contains('invalid email or password') ||
        errorStr.contains('invalid credentials')) {
      return 'invalid_credentials';
    } else if (errorStr.contains('user not found')) {
      return 'user_not_found';
    } else {
      return 'error';
    }
  }
}
