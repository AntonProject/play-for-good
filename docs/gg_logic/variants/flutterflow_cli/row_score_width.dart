// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Ranking row score was Flexible(1) next to the name block (flex 6), ~40 px,
// so "3.830" was cut to "3.83". The score now takes its natural width.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class RowScoreWidth extends FlutterFlowAITask {
  @override
  String get name => 'gg-row-score-width';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'gamesUserComp');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    var done = false;
    void walk(Map<String, dynamic> n) {
      if (n['key'] == 'Text_l3frcpxh') {
        (n['props'] as Map)['expanded'] = {'expandedType': 'UNEXPANDED'};
        done = true;
      }
      for (final c in (n['children'] as List? ?? [])) walk(c as Map<String, dynamic>);
    }
    walk(w['node']);
    if (!done) throw StateError('Text_l3frcpxh not found');
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('Score text: natural width.');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RowScoreWidth()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games rows: score not truncated',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
