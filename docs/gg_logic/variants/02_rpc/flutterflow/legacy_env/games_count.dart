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

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<int> gamesCount(String? userId) async {
  try {
    final supabase = Supabase.instance.client;

    var query = supabase
        .from('games')
        .select('*')
        .eq('status', 'completed')
        .eq('test', FFDevEnvironmentValues().test);

    // If userId is provided, filter by creator
    if (userId != null && userId.isNotEmpty) {
      query = query.eq('creator_user_id', userId);
    }

    final response = await query.count(CountOption.exact);
    return response.count;
  } catch (e) {
    print('Error counting games: $e');
    return 0;
  }
}
