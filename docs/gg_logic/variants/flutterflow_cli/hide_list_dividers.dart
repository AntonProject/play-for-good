// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// The old generator dividers (indent 16, above every row) must disappear now
// that the row draws its own divider. A literal `visible=false` is dropped by
// proto3 JSON (default value), so collapse them instead: height 0, thickness 0.
// Nodes are kept, nothing is deleted.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const dividers = ['Divider_p0etyffr', 'Divider_kly9xj62'];

final class HideListDividers extends FlutterFlowAITask {
  @override
  String get name => 'gg-hide-list-dividers';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'GoodGamesPage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    var done = 0;
    void walk(Map<String, dynamic> n) {
      if (dividers.contains(n['key'])) {
        final props = n['props'] as Map<String, dynamic>;
        final d = props['divider'] as Map<String, dynamic>;
        d['heightValue'] = {'inputValue': 0};
        d['thicknessValue'] = {'inputValue': 0};
        // thickness 0 still paints a hairline in Flutter: make it transparent
        // (0x00FFFFFF; plain 0 would be dropped as a proto3 default).
        d['colorValue'] = {'inputValue': {'value': '16777215'}};
        props.remove('visibility');
        done++;
      }
      for (final c in (n['children'] as List? ?? [])) walk(c as Map<String, dynamic>);
    }
    walk(w['node']);
    if (done != dividers.length) throw StateError('Found $done of ${dividers.length}');
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('Collapsed $done generator dividers.');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [HideListDividers()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games list: collapse old row dividers',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
