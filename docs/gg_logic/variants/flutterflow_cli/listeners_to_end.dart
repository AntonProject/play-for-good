// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// The 1x1 GgStatsListener instances were inserted as the FIRST child of the
// screens' columns (place_listeners.dart and later scripts); in a scroll column
// that starts with the red header this pushes the header down by 1 px and the
// white scaffold shows through above it. Each listener moves to the END of its
// column: same behaviour, the extra pixel is at the bottom of the content.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class ListenersToEnd extends FlutterFlowAITask {
  @override
  String get name => 'gg-listeners-to-end';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final moved = <String>[];
    for (final entry in p.widgetClasses.entries.toList()) {
      final json = jsonEncode(entry.value.toProto3Json());
      if (!json.contains('"name":"GgStatsListener"')) continue;
      final w = jsonDecode(json) as Map<String, dynamic>;
      var changed = false;
      void walk(Map<String, dynamic> n) {
        final children = n['children'] as List?;
        if (children != null && children.length > 1) {
          final first = children.first as Map<String, dynamic>;
          if (first['customWidgetIdentifier']?['name'] == 'GgStatsListener') {
            children
              ..removeAt(0)
              ..add(first);
            moved.add('${entry.value.name}/${first['key']} (end of ${n['key']})');
            changed = true;
          }
        }
        for (final c in (children ?? [])) walk(c as Map<String, dynamic>);
      }
      walk(w['node']);
      if (!changed) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }
    stdout.writeln('Moved ${moved.length}:\n  ${moved.join('\n  ')}');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [ListenersToEnd()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'GgStatsListener at the end of columns (no 1 px gap above headers)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
