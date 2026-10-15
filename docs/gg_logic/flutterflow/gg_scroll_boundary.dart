// FlutterFlow Custom Widget GgScrollBoundary.
// width/height Double; content Widget Builder with no parameters.
// Wrap the existing scrollable content. A Custom Action cannot set its physics.
import 'package:flutter/material.dart';

class GgTopClampedScrollPhysics extends BouncingScrollPhysics {
  const GgTopClampedScrollPhysics({super.parent});

  @override
  GgTopClampedScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      GgTopClampedScrollPhysics(parent: buildParent(ancestor));

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Reject motion beyond the start, including motion from a position already
    // outside the start. Allow motion back into range and normal bottom bounce.
    if (value < position.pixels && position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      return value - position.minScrollExtent;
    }
    return 0;
  }
}

class GgTopScrollBehavior extends MaterialScrollBehavior {
  const GgTopScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final base = super.getScrollPhysics(context);
    if (base is BouncingScrollPhysics) {
      return GgTopClampedScrollPhysics(parent: base.parent);
    }
    return base;
  }
}

class GgScrollBoundary extends StatelessWidget {
  const GgScrollBoundary({
    super.key,
    this.width,
    this.height,
    required this.content,
  });

  final double? width;
  final double? height;
  final Widget Function() content;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: ScrollConfiguration(
      behavior: const GgTopScrollBehavior(),
      child: Builder(builder: (_) => content()),
    ),
  );
}
