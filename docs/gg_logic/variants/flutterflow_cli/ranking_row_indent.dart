// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 21.10.2026, demo feedback 8 (# and Name aligned with the rows): the owner
// moved the header for the current season; rows of an ended season stayed
// shifted.
// gamesUserComp: the 12 px stripe on the left is shown only in the current
// layout (ggIsFinalOf(ranking) == false); the content's left padding was
// `period != 'season_25_26' ? 16 : 42` - the old season key, never true with
// season_2025_26, so an ended season got 16 without the stripe (12 px left of
// the header). Now: ggIsFinalOf(ranking) ? 28 : 16 (28 = stripe 12 + 16).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class RankingRowIndent extends FlutterFlowAITask {
  @override
  String get name => 'gg-ranking-row-indent';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'gamesUserComp');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    // ggIsFinalOf(ranking) from the stripe's visibility.
    Map? isFinal;
    Map? padding;
    var done = false;
    void walk(dynamic x) {
      if (x is Map) {
        if (isFinal == null &&
            x['source'] == 'FUNCTION_CALL' &&
            x['functionCall']?['customFunction']?['name'] == 'ggIsFinalOf') {
          isFinal = x;
        }
        final pad = x['padding'];
        if (pad is Map && jsonEncode(pad['leftValue'] ?? {}).contains('season_25_26')) padding = pad;
        if (pad is Map && jsonEncode(pad['leftValue'] ?? {}).contains('"ggIsFinalOf"')) done = true;
        x.values.forEach(walk);
      } else if (x is List) {
        x.forEach(walk);
      }
    }
    walk(w['node']);
    if (padding == null) {
      if (done) {
        stdout.writeln('gamesUserComp: row indent already follows ggIsFinalOf');
        return;
      }
      throw StateError('gamesUserComp: padding with season_25_26 not found');
    }
    final cond = jsonDecode(jsonEncode(isFinal ?? (throw StateError('gamesUserComp: ggIsFinalOf not found'))))
        as Map<String, dynamic>;
    cond.remove('operations');
    padding!['leftValue'] = {
      'variable': {
        'source': 'FUNCTION_CALL',
        'defaultValue': {'serializedValue': '16'},
        'functionCall': {
          'conditionalValue': {
            'ifConditionalValues': [
              {
                'condition': cond,
                'value': {'inputValue': {'serializedValue': '28'}},
              }
            ],
            'elseValue': {'inputValue': {'serializedValue': '16'}},
            'returnParameter': {'dataType': {'scalarType': 'Double', 'nonNullable': true}},
          },
        },
      },
    };
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('gamesUserComp: row indent = ggIsFinalOf(ranking) ? 28 : 16');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RankingRowIndent()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Ranking rows: same indent in the ended season (no stripe)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
