// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Code review 15.10.2026: gamesUserComp parameters are Data Types now, their
// JSON names are renamed: playerJson -> player, rankingJson -> ranking.
// The parameter key stays; every reference (the component itself and the
// places that pass the values) is found by key and gets the new name.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const component = 'gamesUserComp';
const renames = {'playerJson': 'player', 'rankingJson': 'ranking'};

final class RenameJsonParams extends FlutterFlowAITask {
  @override
  String get name => 'gg-rename-json-params';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final comp = p.widgetClasses.values.firstWhere((w) => w.name == component);
    final cj = jsonDecode(jsonEncode(comp.toProto3Json())) as Map<String, dynamic>;
    final params = (cj['params'] as Map).values.cast<Map>();
    final existing = {for (final e in params) e['identifier']['name']};
    final byKey = <String, String>{};
    for (final e in params) {
      final next = renames[e['identifier']['name']];
      if (next == null) continue;
      if (existing.contains(next)) throw StateError('$component already has a parameter $next');
      byKey[e['identifier']['key'] as String] = next;
    }
    if (byKey.isEmpty) {
      stdout.writeln('$component: already renamed');
      return;
    }
    for (final entry in p.widgetClasses.entries.toList()) {
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      var n = 0;
      void walk(Object? x) {
        if (x is Map) {
          final k = x['key'];
          if (k is String && byKey.containsKey(k) && renames.containsKey(x['name'])) {
            x['name'] = byKey[k];
            n++;
          }
          x.values.forEach(walk);
        } else if (x is List) {
          x.forEach(walk);
        }
      }
      walk(w);
      if (n == 0) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      stdout.writeln('${entry.value.name}: $n reference(s) renamed');
    }
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RenameJsonParams()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'gamesUserComp: parameters player / ranking (Data Types, not JSON)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
