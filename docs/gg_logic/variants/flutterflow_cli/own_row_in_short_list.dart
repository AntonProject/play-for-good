// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 26.10.2026, owner: with one player in the list the own row (0 points) stood
// under the dotted divider. The divider + row under it are for "not in the top
// 10" only. Functions ggListIdsOf / ggShowMeRowOf / ggIsLastPlayerOf: the own
// row (signed in, 0 points) and the guest row (0 in the category) are the last
// row of the list while it has fewer than 10 rows; under the divider only when
// the list is full. No page change - transfer of the functions only.
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'gg_transfer.dart' show RegisterGgCode;

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-ownrow-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports)],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games: own / guest row in a short list, divider only when the list is full',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
