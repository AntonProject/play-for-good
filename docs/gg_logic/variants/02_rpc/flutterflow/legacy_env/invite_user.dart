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

Future<String> inviteUser(String invitedEmail) async {
  try {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      return 'not_authenticated';
    }

    // Email validation - Simple and working regex
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(invitedEmail)) {
      return 'invalid_email';
    }

    // Check if user is trying to invite themselves
    final userProfile = await supabase
        .from('users')
        .select('email')
        .eq('id', currentUser.id)
        .single();

    if (userProfile['email'] == invitedEmail.toLowerCase()) {
      return 'cannot_invite_self';
    }

    _log('Inviting user: $invitedEmail');

    // Check if email is already invited
    final existingInvite = await supabase
        .from('invites')
        .select('id, was_used')
        .eq('invited_email', invitedEmail.toLowerCase())
        .maybeSingle();

    if (existingInvite != null) {
      if (existingInvite['was_used'] == true) {
        return 'already_registered';
      } else {
        return 'already_invited';
      }
    }

    // Create invitation
    await supabase.from('invites').insert({
      'test': FFDevEnvironmentValues().test,
      'inviter_user_id': currentUser.id,
      'invited_email': invitedEmail.toLowerCase().trim(),
    });

    _log('Invite created successfully');

    // Send invitation email via Edge Function
    try {
      _log('Sending invitation email...');
      final emailResponse = await supabase.functions.invoke(
        'send-invite-email',
        body: {
          'invited_email': invitedEmail.toLowerCase().trim(),
          'inviter_user_id': currentUser.id,
        },
      );

      _log('Email response status: ${emailResponse.status}');
      _log('Email response data: ${emailResponse.data}');

      if (emailResponse.status == 200 &&
          emailResponse.data?['success'] == true) {
        _log('Invitation email sent successfully');
      } else {
        _log(
            'Failed to send invitation email: ${emailResponse.data?['error']}');
        // Don't fail the whole invite process if email fails
      }
    } catch (emailError) {
      _log('Error sending invitation email: $emailError');
      // Don't fail the whole invite process if email fails
    }

    return 'success';
  } catch (e) {
    _log('Error inviting user: $e');
    return 'error';
  }
}

// Logs only in debug builds; release builds print nothing (emails,
// responses).
void _log(Object? message) {
  if (kDebugMode) print(message);
}
