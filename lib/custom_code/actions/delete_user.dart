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

Future<String> deleteUser(String userIdToDelete) async {
  try {
    final supabase = Supabase.instance.client;

    print('=== Admin deleting user ===');
    print('Target user ID: $userIdToDelete');

    if (userIdToDelete.trim().isEmpty) {
      print('Empty user ID');
      return 'empty_fields';
    }

    // Check if user is logged in
    if (supabase.auth.currentUser == null) {
      print('User not authenticated');
      return 'not_authenticated';
    }

    final response = await supabase.functions.invoke(
      'delete-user-completely',
      body: {
        'user_id_to_delete': userIdToDelete.trim(),
      },
    );

    print('Delete user response status: ${response.status}');
    print('Delete user response data: ${response.data}');

    if (response.status == 200 &&
        response.data != null &&
        response.data['success'] == true) {
      print('User deleted completely by admin');

      bool publicDeleted = response.data['public_deleted'] ?? false;
      bool authDeleted = response.data['auth_deleted'] ?? false;

      if (publicDeleted && authDeleted) {
        return 'success';
      } else if (publicDeleted && !authDeleted) {
        return 'partial_success';
      } else {
        return 'error';
      }
    } else {
      print('Edge function error: ${response.data}');

      String errorMessage = response.data?['error']?.toString() ?? '';

      if (errorMessage.toLowerCase().contains('access denied') ||
          errorMessage.toLowerCase().contains('admin role required')) {
        return 'not_admin';
      }

      if (errorMessage.toLowerCase().contains('cannot delete your own')) {
        return 'self_deletion_error';
      }

      if (errorMessage.toLowerCase().contains('not found')) {
        return 'user_not_found';
      }

      if (errorMessage.toLowerCase().contains('authentication')) {
        return 'not_authenticated';
      }

      return 'error';
    }
  } catch (e) {
    print('deleteUser error: $e');

    String errorStr = e.toString().toLowerCase();

    if (errorStr.contains('access denied') || errorStr.contains('admin')) {
      return 'not_admin';
    }

    if (errorStr.contains('authentication')) {
      return 'not_authenticated';
    }

    return 'error';
  }
}
