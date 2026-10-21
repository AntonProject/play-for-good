// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Pushes only the custom code of the rpc variant (transfer.dart), nothing in
// the pages. For changes inside existing functions / actions.
// 21.10.2026: own row under the Good Games list also without points (place
// after all ranked players, as Home), no "0" place, no podium look for it
// (ggShowMeRowOf, ggPlayerOf, ggRowStyleOf).
//   dart run dsl/gg_transfer_rpc_only.dart ["commit message"] [--apply]
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'gg_transfer.dart' show RegisterGgCode;

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final message = args.where((a) => !a.startsWith('--')).firstOrNull ??
      'Good Games: own row also without points, same place as Home';
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-rpc-only-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports)],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: message,
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
