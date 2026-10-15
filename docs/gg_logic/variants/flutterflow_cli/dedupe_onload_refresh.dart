// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// On Load of a page ran the refresh action block up to three times in a row
// (after the tab/period state updates and at the end). Keeps only the last
// call in the On Load chain; filter/page/tab callbacks keep theirs.
//   dart run dsl/gg_dedupe_onload.dart --page GoodGamesPage --block ggRefreshGoodGames [--apply]
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';

final class DedupeOnLoad extends FlutterFlowAITask {
  DedupeOnLoad(this.page, this.block);
  final String page;
  final String block;
  @override
  String get name => 'dedupe-onload-$block';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  bool isRefresh(FFActionNode n) =>
      n.hasAction() &&
      n.action.hasExecuteActionComponent() &&
      n.action.executeActionComponent.actionComponentIdentifier.name == block;

  @override
  void run(TaskContext ctx) {
    final w = ctx.project.widgetClasses.values.firstWhere((w) => w.name == page);
    final trigger = w.node.triggerActions
        .firstWhere((t) => t.trigger.triggerType == FFActionTriggerType.ON_INIT_STATE);
    // The last refresh of the main follow-up chain stays.
    FFActionNode? keep;
    for (FFActionNode? n = trigger.rootAction; n != null;
        n = n.hasFollowUpAction() ? n.followUpAction : null) {
      if (isRefresh(n)) keep = n;
    }
    if (keep == null) throw StateError('No refresh call at the end of On Load');
    var removed = 0;
    // Remove every other refresh in the On Load tree by relinking its parent.
    void prune(FFActionNode n) {
      while (n.hasFollowUpAction() && isRefresh(n.followUpAction) &&
          !identical(n.followUpAction, keep)) {
        final skip = n.followUpAction;
        if (skip.hasFollowUpAction()) {
          n.followUpAction = skip.followUpAction;
        } else {
          n.clearFollowUpAction();
        }
        removed++;
      }
      if (n.hasConditionActions()) {
        for (final b in n.conditionActions.trueActions) prune(b.trueAction);
        if (n.conditionActions.hasFalseAction()) prune(n.conditionActions.falseAction);
      }
      if (n.hasFollowUpAction()) prune(n.followUpAction);
    }
    prune(trigger.rootAction);
    stdout.writeln('$page On Load: removed $removed duplicate $block calls, kept the last.');
  }
}

Future<void> main(List<String> args) async {
  String opt(String k) => args[args.indexOf(k) + 1];
  final apply = args.contains('--apply');
  final page = opt('--page');
  final block = opt('--block');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [DedupeOnLoad(page, block)],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: '$page: single $block call on load',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
