// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// FinishPage (16.10.2026): red flash before "BIG GAME!". The "Deine €" text is a
// code expression userMoney+teamMoney+siegMoney over page state `game`, which
// On Page Load loads after the first frames; its arguments were non-nullable,
// so the generated code read `_model.game!.userMoney!` and threw until the
// game arrived. The arguments become nullable and the expression treats a
// missing value as 0. Nothing else changes.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const oldExpression = 'userMoney+teamMoney+siegMoney';
const newExpression = '(userMoney ?? 0) + (teamMoney ?? 0) + (siegMoney ?? 0)';

final class FinishMoneyNullSafe extends FlutterFlowAITask {
  @override
  String get name => 'gg-finish-money-null-safe';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'FinishPage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    var changed = 0, done = 0;
    void walk(dynamic x) {
      if (x is Map) {
        final ce = x['codeExpression'];
        if (ce is Map) {
          if (ce['expression'] == oldExpression) {
            for (final a in (ce['arguments'] as List)) {
              (a['dataType'] as Map)['nonNullable'] = false;
            }
            ce['expression'] = newExpression;
            changed++;
          } else if (ce['expression'] == newExpression) {
            done++;
          }
        }
        x.values.forEach(walk);
      } else if (x is List) {
        x.forEach(walk);
      }
    }
    walk(w);
    if (changed == 0) {
      if (done > 0) {
        stdout.writeln('FinishPage: already null-safe');
        return;
      }
      throw StateError('FinishPage: expression $oldExpression not found');
    }
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('FinishPage: $changed expression(s) -> $newExpression, arguments nullable');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [FinishMoneyNullSafe()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'FinishPage: "Deine €" without the red frame before the game is loaded',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
