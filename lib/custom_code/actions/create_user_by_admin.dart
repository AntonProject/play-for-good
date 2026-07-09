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

Future<String> createUserByAdmin(
  String email,
  String password,
  String? displayName,
  String? firstName,
  String? surname,
  String? instagramUrl,
  String? facebookUrl,
  String? youtubeUrl,
  String? land,
  String? plz,
  String? stadt,
  String? strae,
  String? hausNr,
  String? photoUrl,
  String? info,
  String? gender,
  String? role,
) async {
  // Add your function code here!

  try {
    final supabase = Supabase.instance.client;

    print('=== Creating user by admin ===');
    print('Email: $email');
    print('Display Name: $displayName');

    if (email.trim().isEmpty || password.trim().isEmpty) {
      print('Empty email or password');
      return 'empty_fields';
    }

    // Prepare request body with all optional fields
    final requestBody = <String, dynamic>{
      'email': email.trim(),
      'password': password.trim(),
    };

    // Add optional fields if provided
    if (displayName != null && displayName.trim().isNotEmpty) {
      requestBody['display_name'] = displayName.trim();
    }
    if (firstName != null && firstName.trim().isNotEmpty) {
      requestBody['first_name'] = firstName.trim();
    }
    if (surname != null && surname.trim().isNotEmpty) {
      requestBody['surname'] = surname.trim();
    }
    if (instagramUrl != null && instagramUrl.trim().isNotEmpty) {
      requestBody['instagram_url'] = instagramUrl.trim();
    }
    if (facebookUrl != null && facebookUrl.trim().isNotEmpty) {
      requestBody['facebook_url'] = facebookUrl.trim();
    }
    if (youtubeUrl != null && youtubeUrl.trim().isNotEmpty) {
      requestBody['youtube_url'] = youtubeUrl.trim();
    }
    if (land != null && land.trim().isNotEmpty) {
      requestBody['land'] = land.trim();
    }
    if (plz != null && plz.trim().isNotEmpty) {
      requestBody['plz'] = plz.trim();
    }
    if (stadt != null && stadt.trim().isNotEmpty) {
      requestBody['stadt'] = stadt.trim();
    }
    if (strae != null && strae.trim().isNotEmpty) {
      requestBody['strae'] = strae.trim();
    }
    if (hausNr != null && hausNr.trim().isNotEmpty) {
      requestBody['haus_nr'] = hausNr.trim();
    }
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      requestBody['photo_url'] = photoUrl.trim();
    }
    if (info != null && info.trim().isNotEmpty) {
      requestBody['info'] = info.trim();
    }
    if (gender != null && gender.trim().isNotEmpty) {
      requestBody['gender'] = gender.trim();
    }
    if (role != null && role.trim().isNotEmpty) {
      requestBody['role'] = role.trim();
    }

    print('Request body prepared with ${requestBody.length} fields');

    final response = await supabase.functions.invoke(
      'create-user-by-admin',
      body: requestBody,
    );

    print('Create user response status: ${response.status}');
    print('Create user response data: ${response.data}');

    if (response.status == 200 &&
        response.data != null &&
        response.data['success'] == true) {
      print('User created successfully by admin');
      return 'success';
    } else {
      print('Edge function error: ${response.data}');

      String errorMessage = response.data?['error']?.toString() ?? '';

      if (errorMessage.toLowerCase().contains('email') &&
          errorMessage.toLowerCase().contains('already')) {
        return 'email_exists';
      }

      if (errorMessage.toLowerCase().contains('display_name') ||
          (errorMessage.toLowerCase().contains('name') &&
              errorMessage.toLowerCase().contains('exists'))) {
        return 'name_exists';
      }

      return 'error';
    }
  } catch (e) {
    print('createUserByAdmin error: $e');

    String errorMessage = e.toString().toLowerCase();

    if (errorMessage.contains('email') && errorMessage.contains('already')) {
      return 'email_exists';
    }

    if (errorMessage.contains('display_name') ||
        (errorMessage.contains('name') && errorMessage.contains('exists'))) {
      return 'name_exists';
    }

    return 'error';
  }
}
