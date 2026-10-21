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

Future<bool> ggWaitUntilOnTop(
  BuildContext context,
  int maxSeconds,
) async {
  // Waits until the page of [context] is the top route again (no dialog, sheet
  // or page above it). true = on top now; false = the page is gone or
  // [maxSeconds] passed. Home shows the guest welcome sheet only then, so it
  // no longer pops up over the sign-in dialog opened from another screen.
  final until = DateTime.now().add(Duration(seconds: maxSeconds));
  while (DateTime.now().isBefore(until)) {
    if (!context.mounted) return false;
    final route = ModalRoute.of(context);
    if (route == null || !route.isActive) return false;
    if (route.isCurrent) return true;
    await Future.delayed(const Duration(milliseconds: 500));
  }
  return false;
}
