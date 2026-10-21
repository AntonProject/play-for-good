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

Future ggCloseIfOpen(BuildContext context) async {
  // Closes the dialog / sheet this widget is in, if it is still open.
  // Snack bars close themselves after 3 s; by then the user may have closed
  // them or left the screen (Navigator.pop on an unmounted context threw), or
  // another dialog may be on top (pop would close that one instead).
  if (!context.mounted) return;
  final route = ModalRoute.of(context);
  if (route == null || !route.isActive) return;
  if (route.isCurrent) {
    Navigator.of(context).pop();
  } else {
    // Something else is on top: remove only this route.
    Navigator.of(context).removeRoute(route);
  }
}
