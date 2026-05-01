// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class CustomDonationSlider extends StatefulWidget {
  // Required parameters
  final double currentValue;
  final Future Function(double? value)? update;

  // Size parameters
  final double? width;
  final double? height;

  // Color customization parameters
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final Color? thumbInnerColor;

  // Design parameters
  final double? trackHeight;
  final double? thumbSize;

  const CustomDonationSlider({
    Key? key,
    required this.currentValue,
    required this.update,
    this.width,
    this.height,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.thumbInnerColor,
    this.trackHeight,
    this.thumbSize,
  }) : super(key: key);

  @override
  State<CustomDonationSlider> createState() => _CustomDonationSliderState();
}

class _CustomDonationSliderState extends State<CustomDonationSlider> {
  // Define custom divisions: 0€, 1€, 3€, 5€, 10€, 20€
  final List<double> divisions = [0, 1, 3, 5, 10, 20];

  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.currentValue;
  }

  @override
  void didUpdateWidget(CustomDonationSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue) {
      _currentValue = widget.currentValue;
    }
  }

  // Find the closest division index for a given value
  int _getClosestDivisionIndex(double value) {
    double minDistance = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < divisions.length; i++) {
      double distance = (divisions[i] - value).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  // Convert division index to slider position (0.0 to 1.0)
  double _indexToSliderPosition(int index) {
    return index / (divisions.length - 1);
  }

  // Convert slider position to division index
  int _sliderPositionToIndex(double position) {
    double rawIndex = position * (divisions.length - 1);
    return rawIndex.round().clamp(0, divisions.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = _getClosestDivisionIndex(_currentValue);
    double sliderPosition = _indexToSliderPosition(currentIndex);

    return SizedBox(
      width: widget.width,
      height: widget.height ?? 60.0,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: widget.trackHeight ?? 4.0,
          activeTrackColor: widget.activeColor ?? const Color(0xFF4CAF50),
          inactiveTrackColor: widget.inactiveColor ?? const Color(0xFFE0E0E0),
          thumbColor: widget.thumbColor ?? const Color(0xFF4CAF50),
          overlayColor:
              (widget.activeColor ?? const Color(0xFF4CAF50)).withOpacity(0.2),
          // Use standard RoundSliderThumbShape
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: (widget.thumbSize ?? 24.0) / 2,
          ),
          trackShape: const RoundedRectSliderTrackShape(),
          showValueIndicator: ShowValueIndicator.never,
          // Remove tick marks
          tickMarkShape: SliderTickMarkShape.noTickMark,
          // Remove overlay radius to fix width issues
          overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
        ),
        child: Slider(
          value: sliderPosition,
          min: 0.0,
          max: 1.0,
          divisions: divisions.length - 1,
          onChanged: (newPosition) async {
            int newIndex = _sliderPositionToIndex(newPosition);
            double newValue = divisions[newIndex];

            print(
                'Slider changed: position=$newPosition, index=$newIndex, value=$newValue');

            setState(() {
              _currentValue = newValue;
            });

            // Call the update function
            if (widget.update != null) {
              try {
                await widget.update!(newValue);
                print(
                    'Update function called successfully with value: $newValue');
              } catch (e) {
                print('Error calling update function: $e');
              }
            } else {
              print('Update function is null');
            }
          },
        ),
      ),
    );
  }
}
