// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Design shows German thousands separators (2.630, 12.560). The bound numbers
// used '#,##0' without locale (-> en "3,830"). Sets customLocale de_DE on every
// CUSTOM '#,##0…' number format in the given scopes; nothing else changes.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class NumberLocale extends FlutterFlowAITask {
  NumberLocale(this.scopes);
  final List<String> scopes;
  @override
  String get name => 'gg-number-locale';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final counts = <String, int>{};
    for (final scope in scopes) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json()));
      var n = 0;
      void walk(dynamic x) {
        if (x is Map) {
          final f = x['numberFormat'];
          if (f is Map && f['formatType'] == 'CUSTOM' &&
              (f['customFormat'] as String? ?? '').startsWith('#,##0') &&
              (f['customLocale'] as String? ?? '').isEmpty) {
            f['customLocale'] = 'de_DE';
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
      counts[scope] = n;
    }
    stdout.writeln('de_DE number formats: $counts');
  }
}

Future<void> main(List<String> args) async {
  final i = args.indexOf('--scopes');
  final scopes = (i < 0 ? 'GoodGamesPage,gamesUserComp' : args[i + 1]).split(',');
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [NumberLocale(scopes)],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games numbers: German thousands separator per design',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
