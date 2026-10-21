// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 21.10.2026, owner: the TEST pill on Home a little lower.
// Sets the top padding of the pill layer (test_badge_home_and_total.dart).
//   dart run dsl/gg_test_badge_offset.dart [top=52] [--apply]
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.testbadge.$seed');

final class TestBadgeOffset extends FlutterFlowAITask {
  TestBadgeOffset(this.top);
  final num top;
  @override
  String get name => 'gg-test-badge-offset';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'HomePage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final layerKey = 'Container_${key('home.layer')}';
    Map? layer;
    void find(dynamic x) {
      if (x is Map) {
        if (x['key'] == layerKey) layer = x;
        x.values.forEach(find);
      } else if (x is List) {
        x.forEach(find);
      }
    }
    find(w['node']);
    if (layer == null) throw StateError('HomePage: TEST pill layer not found');
    final pad = (layer!['props'] as Map)['padding'] as Map;
    if (pad['topValue']?['inputValue'] == top) {
      stdout.writeln('HomePage: TEST pill already at $top');
      return;
    }
    pad['topValue'] = {'inputValue': top};
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('HomePage: TEST pill top padding -> $top');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final top = num.tryParse(args.where((a) => !a.startsWith('--')).firstOrNull ?? '') ?? 52;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [TestBadgeOffset(top)],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'TEST pill on Home: top $top',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
