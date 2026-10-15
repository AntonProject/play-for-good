// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
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
  // Each instance needs its own key: pages of the bottom navigation stay
  // mounted at the same time and a shared key mixes their visibility.
  final Key _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    // Default throttling is 500 ms, which made the app bar switch late.
    VisibilityDetectorController.instance.updateInterval =
        const Duration(milliseconds: 50);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted) return;
        var visiblePercentage = visibilityInfo.visibleFraction * 100;

        // Determine if widget is considered visible based on threshold
        bool isVisible =
            visibilityInfo.visibleFraction > widget.visibilityThreshold;

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
