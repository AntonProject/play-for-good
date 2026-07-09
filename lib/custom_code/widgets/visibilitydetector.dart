// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:visibility_detector/visibility_detector.dart';

class Visibilitydetector extends StatefulWidget {
  const Visibilitydetector({
    super.key,
    this.width,
    this.height,
    this.action,
    required this.visibilityThreshold,
  });

  final double? width;
  final double? height;
  final Future Function(bool? visible, double? visibility)? action;
  final double visibilityThreshold;

  @override
  State<Visibilitydetector> createState() => _VisibilitydetectorState();
}

class _VisibilitydetectorState extends State<Visibilitydetector> {
  bool _isCurrentlyVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('visibility-detector1'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        debugPrint(
            'Widget ${visibilityInfo.key} is ${visiblePercentage}% visible');

        // Determine if widget is considered visible based on threshold
        bool isVisible =
            visibilityInfo.visibleFraction > widget.visibilityThreshold;

        widget.action!(isVisible, visiblePercentage);

        // Only call action if visibility state has changed
        if (isVisible != _isCurrentlyVisible) {
          _isCurrentlyVisible = isVisible;

          // Call the action function with the visibility state
          if (widget.action != null) {
            widget.action!(isVisible, visiblePercentage);
          }
        }
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        child: const SizedBox(), // Or any other child widget
      ),
    );
  }
}
