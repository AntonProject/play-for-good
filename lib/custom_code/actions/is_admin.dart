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

Future<bool> isAdmin(String? userId) async {
  try {
    if (userId == null || userId.isEmpty) {
      print('User ID is null or empty');
      return false;
    }

    final supabase = Supabase.instance.client;

    print('Checking admin role for user: $userId');

    final response = await supabase
        .from('users')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      print('User not found in users table');
      return false;
    }

    final role = response['role']?.toString();
    final isAdminUser = role == 'admin';

    print('User role: $role, isAdmin: $isAdminUser');

    return isAdminUser;
  } catch (e) {
    print('Error checking admin role: $e');
    return false;
  }
}
