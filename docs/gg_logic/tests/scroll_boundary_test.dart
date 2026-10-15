// Runs in the disposable pfg_rpc_check Flutter harness, no backend access.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pfg_rpc_check/gg_scroll_boundary.dart';

void main() {
  testWidgets('iOS top is clamped but bottom bounce remains', (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(platform: TargetPlatform.iOS),
      home: Scaffold(body: GgScrollBoundary(
        content: () => SingleChildScrollView(
          controller: controller,
          child: const SizedBox(height: 2400, child: Text('Scroll content')),
        ),
      )),
    ));
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 200));
    expect(controller.offset, 0);
    await tester.pumpAndSettle();
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
    expect(controller.offset, greaterThan(controller.position.maxScrollExtent));
    await tester.pumpAndSettle();
    expect(controller.offset, closeTo(controller.position.maxScrollExtent, 0.01));
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('a fast fling cannot move the content past the top', (tester) async {
    final controller = ScrollController(initialScrollOffset: 200);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(platform: TargetPlatform.iOS),
      home: Scaffold(body: GgScrollBoundary(
        content: () => SingleChildScrollView(
          controller: controller,
          child: const ColoredBox(
            color: Colors.red,
            child: SizedBox(width: double.infinity, height: 2400),
          ),
        ),
      )),
    ));
    await tester.fling(find.byType(SingleChildScrollView), const Offset(0, 500), 3000);
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(controller.offset, greaterThanOrEqualTo(0));
    }
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
