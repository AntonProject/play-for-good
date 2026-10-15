// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Ranking row height per Figma: 77 (stripe + content wrapper), content row
// without its own vertical padding (it is centred). Touches only these nodes.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class RowHeight77 extends FlutterFlowAITask {
  @override
  String get name => 'gg-row-height-77';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'gamesUserComp');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final all = <String, Map<String, dynamic>>{};
    void walk(Map<String, dynamic> n) {
      all[n['key'] as String] = n;
      for (final c in (n['children'] as List? ?? [])) walk(c as Map<String, dynamic>);
    }
    walk(w['node']);
    final row = all['Row_za59pjqz']!;
    final wrapper = (row['children'] as List)[1] as Map<String, dynamic>;
    if (wrapper['type'] != 'Container') throw StateError('Run row_divider_beside_stripe.dart first');
    for (final c in [all['Container_rzgvzjsq']!, wrapper]) {
      ((c['props']['container'] as Map)['dimensions'] as Map)['height'] = {'pixelsValue': {'inputValue': 77}};
    }
    final pad = (all['Row_bddabz8e']!['props'] as Map)['padding'] as Map;
    pad['topValue'] = {'inputValue': 0};
    pad['bottomValue'] = {'inputValue': 0};
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('Row height 77, content without vertical padding.');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RowHeight77()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games rows: height 77 per design',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
