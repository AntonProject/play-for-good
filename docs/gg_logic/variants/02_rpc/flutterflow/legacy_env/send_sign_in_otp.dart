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
import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;

// Background function to send OTP (fire and forget)
void _sendOtpInBackground(SupabaseClient supabase, String email, String userId,
    String otpType) async {
  try {
    // Add small delay to ensure session is fully cleared (especially important on Android)
    await Future.delayed(Duration(milliseconds: 500));
    _log('Background: Starting OTP send for $email');

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

        _log('Background: OTP Response status: ${otpResponse.status}');

        if (otpResponse.status == 200) {
          final data = otpResponse.data;
          if (data is Map &&
              (data['success'] == true || data['message_id'] != null)) {
            _log('✅ Background: OTP sent successfully');
            return; // Success, exit
          }
          _log('⚠️ Background: Status 200 but unclear success state');
          return; // Assume success if status is 200
        } else {
          // Retry on non-200 status (except 400)
          if (otpResponse.status != 400) {
            retryCount++;
            if (retryCount < maxRetries) {
              _log(
                  '⚠️ Background: Retry $retryCount/$maxRetries: Status ${otpResponse.status}');
              await Future.delayed(Duration(milliseconds: 1000 * retryCount));
              continue;
            }
          }
          _log(
              '❌ Background: Failed to send OTP - status ${otpResponse.status}');
          return; // Give up after retries
        }
      } on TimeoutException catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          _log('⚠️ Background: Retry $retryCount/$maxRetries: Timeout');
          await Future.delayed(Duration(milliseconds: 1000 * retryCount));
          continue;
        }
        _log('❌ Background: OTP request timeout after $maxRetries attempts');
        return;
      } catch (otpError) {
        retryCount++;
        if (retryCount < maxRetries) {
          _log(
              '⚠️ Background: Retry $retryCount/$maxRetries: Error - $otpError');
          await Future.delayed(Duration(milliseconds: 1000 * retryCount));
          continue;
        }
        _log(
            '❌ Background: OTP function call failed after $maxRetries attempts - $otpError');
        return;
      }
    }
  } catch (e) {
    _log('❌ Background: Exception in OTP sending - $e');
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

    _log('Attempting ${isAdminSignin ? 'admin ' : ''}signin for: $email');

    if (email.isEmpty || password.isEmpty) {
      _log('Error: Email or password is empty');
      return 'empty_fields';
    }

    // Verify the credentials with a separate auth client (no stored session).
    // Signing in with the app's own client switched the whole app to
    // "signed in" and back for a moment: the router, the pages and their
    // listeners reacted while the sign-in dialog was open (20.10.2026: the
    // first attempt left the guest profile without the code screen, the
    // second attempt sent a second code).
    _log('Attempting signin...');
    final checker = GoTrueClient(
      url: '${supabase.rest.url.replaceFirst(RegExp(r'/rest/v1/?$'), '')}/auth/v1',
      // The project's public anon key, as the app's own client sends it.
      headers: {
        'apikey': '${supabase.realtime.params['apikey'] ?? supabase.functions.headers['apikey'] ?? ''}'
      },
      autoRefreshToken: false,
    );
    final String userId;
    try {
      final signInResponse = await checker.signInWithPassword(
        email: email,
        password: password,
      );
      if (signInResponse.user == null) {
        _log('Error: Invalid credentials');
        return 'invalid_credentials';
      }
      userId = signInResponse.user!.id;
      _log('Success: User found: $userId');
      // End the check session on the server (this session only).
      try {
        await checker.signOut();
      } catch (e) {
        _log('Check session sign-out failed - $e');
      }
    } finally {
      checker.dispose();
    }

    // Return success immediately after credentials verification
    // OTP sending will happen asynchronously in the background
    _log('✅ Credentials verified, returning success immediately');

    // Send OTP asynchronously in background (fire and forget)
    _sendOtpInBackground(supabase, email, userId, otpType);

    return 'success';
  } catch (e) {
    _log('❌ Error: Exception in sendSignInOtp - $e');
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

// Logs only in debug builds; release builds print nothing (emails,
// responses). Passwords and OTP codes are never logged.
void _log(Object? message) {
  if (kDebugMode) print(message);
}
