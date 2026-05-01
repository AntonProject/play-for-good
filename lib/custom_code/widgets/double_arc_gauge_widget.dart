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

import 'index.dart'; // Imports other custom widgets

import 'dart:math' as math;

class DoubleArcGaugeWidget extends StatefulWidget {
  const DoubleArcGaugeWidget({
    super.key,
    this.width,
    this.height,
    required this.lowerMax,
    required this.lowerValue,
    required this.lowerActiveColor,
    required this.lowerInactiveColor,
    required this.lowerStrokeWidth,
    required this.upperMax,
    required this.upperValue,
    required this.upperActiveColor,
    required this.upperInactiveColor,
    required this.arcGap,
    required this.labelTextSize,
    required this.labelTextColor,
    required this.upperStrokeWidth,
  });

  final double? width;
  final double? height;
  final double lowerMax;
  final double lowerValue;
  final Color lowerActiveColor;
  final Color lowerInactiveColor;
  final double lowerStrokeWidth;
  final double upperMax;
  final double upperValue;
  final Color upperActiveColor;
  final Color upperInactiveColor;
  final double arcGap;
  final double labelTextSize;
  final Color labelTextColor;
  final double upperStrokeWidth;

  @override
  State<DoubleArcGaugeWidget> createState() => _DoubleArcGaugeWidgetState();
}

class _DoubleArcGaugeWidgetState extends State<DoubleArcGaugeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lowerAnim;
  late Animation<double> _upperAnim;
  double _oldLowerValue = 0.0;
  double _oldUpperValue = 0.0;
  final Duration _animationDuration = const Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _setupAnimations(initial: true);
    _controller.forward();
  }

  @override
  void didUpdateWidget(DoubleArcGaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lowerValue != widget.lowerValue ||
        oldWidget.upperValue != widget.upperValue ||
        oldWidget.lowerMax != widget.lowerMax ||
        oldWidget.upperMax != widget.upperMax) {
      _oldLowerValue = oldWidget.lowerValue;
      _oldUpperValue = oldWidget.upperValue;
      _setupAnimations();
      _controller.forward(from: 0.0);
    }
  }

  void _setupAnimations({bool initial = false}) {
    final double beginLower =
        initial ? 0.0 : (_oldLowerValue / widget.lowerMax).clamp(0.0, 1.0);
    final double endLower =
        (widget.lowerValue / widget.lowerMax).clamp(0.0, 1.0);
    final double beginUpper =
        initial ? 0.0 : (_oldUpperValue / widget.upperMax).clamp(0.0, 1.0);
    final double endUpper =
        (widget.upperValue / widget.upperMax).clamp(0.0, 1.0);
    _lowerAnim = Tween<double>(begin: beginLower, end: endLower).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _upperAnim = Tween<double>(begin: beginUpper, end: endUpper).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 320,
      height: widget.height ?? 320,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.width ?? 320, widget.height ?? 320),
            painter: _DoubleArcGaugePainter(
              lowerMax: widget.lowerMax,
              lowerValue: _lowerAnim.value * widget.lowerMax,
              lowerActiveColor: widget.lowerActiveColor,
              lowerInactiveColor: widget.lowerInactiveColor,
              lowerStrokeWidth: widget.lowerStrokeWidth,
              upperMax: widget.upperMax,
              upperValue: _upperAnim.value * widget.upperMax,
              upperActiveColor: widget.upperActiveColor,
              upperInactiveColor: widget.upperInactiveColor,
              upperStrokeWidth: widget.upperStrokeWidth,
              arcGap: widget.arcGap,
            ),
          );
        },
      ),
    );
  }
}

class _DoubleArcGaugePainter extends CustomPainter {
  final double lowerMax;
  final double lowerValue;
  final Color lowerActiveColor;
  final Color lowerInactiveColor;
  final double lowerStrokeWidth;
  final double upperMax;
  final double upperValue;
  final Color upperActiveColor;
  final Color upperInactiveColor;
  final double upperStrokeWidth;
  final double arcGap;

  _DoubleArcGaugePainter({
    required this.lowerMax,
    required this.lowerValue,
    required this.lowerActiveColor,
    required this.lowerInactiveColor,
    required this.lowerStrokeWidth,
    required this.upperMax,
    required this.upperValue,
    required this.upperActiveColor,
    required this.upperInactiveColor,
    required this.upperStrokeWidth,
    required this.arcGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double upperRadius = (size.width / 2) - upperStrokeWidth / 2 - 20;
    final double lowerRadius =
        upperRadius - upperStrokeWidth / 2 - arcGap - lowerStrokeWidth / 2;
    final double startAngle = math.pi * 0.7;
    final double sweepAngle = math.pi * 1.6;

    // Upper arc (outer)
    final Paint upperInactivePaint = Paint()
      ..color = upperInactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = upperStrokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: upperRadius),
      startAngle,
      sweepAngle,
      false,
      upperInactivePaint,
    );

    final Paint upperActivePaint = Paint()
      ..color = upperActiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = upperStrokeWidth
      ..strokeCap = StrokeCap.round;
    final double upperSweep = upperMax > 0
        ? (upperValue / upperMax).clamp(0.0, 1.0) * sweepAngle
        : 0.0;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: upperRadius),
      startAngle,
      upperSweep,
      false,
      upperActivePaint,
    );

    // Lower arc (inner) with shadow
    final double lowerSweep = lowerMax > 0
        ? (lowerValue / lowerMax).clamp(0.0, 1.0) * sweepAngle
        : 0.0;

    if (lowerSweep > 0) {
      final Paint shadowPaint = Paint()
        ..color = const Color(0xFF7CDAFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = lowerStrokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: lowerRadius),
        startAngle,
        lowerSweep,
        false,
        shadowPaint,
      );
    }

    final Paint lowerInactivePaint = Paint()
      ..color = lowerInactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lowerStrokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: lowerRadius),
      startAngle,
      sweepAngle,
      false,
      lowerInactivePaint,
    );

    final Paint lowerActivePaint = Paint()
      ..color = lowerActiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lowerStrokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: lowerRadius),
      startAngle,
      lowerSweep,
      false,
      lowerActivePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
