// Run inside the FlutterFlow AI workspace. Dry-run by default.
// Snack bars (19.10.2026, customer's components snackBar, snackBarLightError,
// snackBarWhiteSuccess): On Load waits 3 s and closes the dialog with
// Navigator.pop(context). When the snack bar was already closed or the screen
// left, that threw "This widget has been unmounted" (seen in the simulator log);
// with another dialog on top it would close that one. The close step becomes the
// custom action ggCloseIfOpen(context): closes only its own, still open route.
// ONE commit: transfer.dart (rpc, registers ggCloseIfOpen) + the swap.
// Copy into dsl/ as gg_snackbar_safe_close.dart next to gg_transfer.dart.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

const snackBars = ['snackBar', 'snackBarLightError', 'snackBarWhiteSuccess'];

final class SnackbarSafeClose extends FlutterFlowAITask {
  @override
  String get name => 'gg-snackbar-safe-close';
  @override
  Set<String> get dependsOn => {'register-gg-rpc'};
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final action = findCustomAction(p, name: 'ggCloseIfOpen') ??
        (throw StateError('ggCloseIfOpen missing (transfer first)'));
    final report = <String>[];
    for (final cls in snackBars) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls,
          orElse: () => throw StateError('$cls not found'));
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      final triggers = (w['node']['triggerActions'] as List?) ?? [];
      final load = triggers.firstWhere((t) => t['trigger']['triggerType'] == 'ON_INIT_STATE',
          orElse: () => throw StateError('$cls: no On Load'));
      var n = 0;
      Map? node = load['rootAction'] as Map?;
      while (node != null) {
        final a = node['action'] as Map?;
        if (a != null && a['navigate']?['closeDialog'] == true) {
          node['action'] = {
            'key': a['key'],
            'customAction': {
              'customActionIdentifier': {'name': action.identifier.name, 'key': action.identifier.key},
              'argumentValues': {'arguments': {}},
            },
          };
          n++;
        }
        node = node['followUpAction'] as Map?;
      }
      if (n == 0) {
        if (jsonEncode(load).contains('"ggCloseIfOpen"')) {
          report.add('$cls: already ggCloseIfOpen');
          continue;
        }
        throw StateError('$cls: close step not found');
      }
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      report.add('$cls: close -> ggCloseIfOpen');
    }
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-snackbar-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports), SnackbarSafeClose()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Snack bars close only their own, still open route',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
