// ggRefreshMe (HomePage, PlayPage) runs for guests too: ggMe() makes no request
// for a guest and clears App State ggMyPhotoUrl, so after a logout the header
// does not keep the previous user's photo. The signed-in condition is unwrapped.
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
final class MeForGuests extends FlutterFlowAITask {
  @override
  String get name => 'gg-me-for-guests';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    for (final page in ['HomePage', 'PlayPage']) {
      final w = ctx.project.widgetClasses.values.firstWhere((x) => x.name == page);
      final b = w.classModel.actionComponentsConfig.actionComponents.firstWhere((c) => c.identifier.name == 'ggRefreshMe');
      final root = b.actions.rootAction;
      if (!root.hasConditionActions()) throw StateError('$page: ggRefreshMe already unconditional');
      b.actions.rootAction = root.conditionActions.trueActions.single.trueAction;
      stdout.writeln('$page: ggRefreshMe unconditional');
    }
  }
}
Future<void> main(List<String> args) async {
  final r = await FlutterFlowAIPipeline(apiKey: Platform.environment['FF_API_KEY']!,
      project: PipelineProject.existing('play-for-good-o0lpcq'), tasks: [MeForGuests()],
      source: PipelineSource.paths([Platform.script.toFilePath()]),
      commitMessage: 'ggRefreshMe also for guests (clears the header photo after logout)',
      dryRun: !args.contains('--apply'), refreshContext: false).run();
  for (final t in r.taskResults) stdout.writeln(t.summary);
  for (final d in r.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${r.success} blocked=${r.validationBlocked} commit=${r.commitId}');
  if (!r.success || r.validationBlocked) exitCode = 1;
}
