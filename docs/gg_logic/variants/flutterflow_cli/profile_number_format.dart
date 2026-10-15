// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Profile page + dialog per design: places as "#3" (the '#' was part of the old
// bindings), German numbers with an optional decimal ("10,9", "12.560", "0").
//  * every RPC place (ggMetricRank / ggPlace) is prefixed with '#'
//  * CUSTOM '#,##0.0' -> '#,##0.#'; CUSTOM '#,##0…' formats get de_DE.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scopes = ['userProfilePage', 'userProfile'];

final class ProfileNumbers extends FlutterFlowAITask {
  @override
  String get name => 'gg-profile-number-format';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String, int>{};
    void count(String k) => report[k] = (report[k] ?? 0) + 1;
    for (final scope in scopes) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json()));
      bool isPlace(dynamic v) =>
          v is Map &&
          ['ggMetricRank', 'ggPlace'].contains((v['functionCall']?['customFunction'] as Map?)?['name']);
      bool isHashed(Map f) =>
          f['stringInterpolation'] != null &&
          ((f['values'] as List?)?.first as Map?)?['inputValue']?['serializedValue'] == '#';
      void walk(dynamic x, {bool inHash = false}) {
        if (x is Map) {
          final f = x['functionCall'];
          final hashed = f is Map && isHashed(f);
          final skip = <String>{};
          // Prefix places with '#', once (not inside an existing '#' interpolation).
          if (!inHash) {
            for (final k in x.keys.toList()) {
              final v = x[k];
              if (k == 'variable' && isPlace(v)) {
                x[k] = {
                  'source': 'FUNCTION_CALL',
                  'functionCall': {
                    'stringInterpolation': {},
                    'values': [
                      {'inputValue': {'serializedValue': '#'}},
                      {'variable': v},
                    ],
                  },
                };
                skip.add(k);
                walk(v, inHash: true);
                count('$scope #place');
              }
            }
          }
          final nf = x['numberFormat'];
          if (nf is Map && nf['formatType'] == 'CUSTOM' &&
              (nf['customFormat'] as String? ?? '').startsWith('#,##0')) {
            if (nf['customFormat'] == '#,##0.0') {
              nf['customFormat'] = '#,##0.#';
              count('$scope optional decimal');
            }
            if ((nf['customLocale'] as String? ?? '').isEmpty) {
              nf['customLocale'] = 'de_DE';
              count('$scope de_DE');
            }
          }
          for (final e in x.entries) {
            if (skip.contains(e.key)) continue;
            walk(e.value, inHash: inHash || (hashed && e.key == 'functionCall'));
          }
        } else if (x is List) {
          for (final v in x) walk(v, inHash: inHash);
        }
      }
      walk(w);
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }
    stdout.writeln('Profile number format: $report');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [ProfileNumbers()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Profile: #place and German number format per design',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
