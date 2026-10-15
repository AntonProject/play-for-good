// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Good News cache follow-up to posts_paging.dart: FF App State cannot hold
// Supabase rows (List<PostsRow> is generated as RowRow), so the session cache
// lives in ggPostsPage itself. ggRefreshPosts reads it with ggPostsPage(0, 0)
// while ggPosts is empty; the App State writes and the field are removed.
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';

const page = 'GoodNewsPage';
String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.posts.memo.$seed');

final class PostsMemo extends FlutterFlowAITask {
  @override
  String get name => 'gg-posts-memo';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final wc = p.widgetClasses.values.firstWhere((w) => w.name == page);
    final root = wc.node.key;
    final blocks = {
      for (final b in wc.classModel.actionComponentsConfig.actionComponents) b.identifier.name: b
    };
    final refresh = blocks['ggRefreshPosts']!;
    final action = findCustomAction(p, name: 'ggPostsPage')!;
    bool writesCache(FFActionNode n) =>
        n.hasAction() && n.action.hasLocalStateUpdate() &&
        n.action.localStateUpdate.updates.any((u) => u.fieldIdentifier.name == 'ggPostsCache');
    var removed = 0;
    FFActionNode strip(FFActionNode n) {
      if (writesCache(n)) {
        removed++;
        return n.hasFollowUpAction() ? strip(n.followUpAction) : FFActionNode(key: n.key);
      }
      if (n.hasFollowUpAction()) n.followUpAction = strip(n.followUpAction);
      if (n.hasConditionActions()) {
        for (final t in n.conditionActions.trueActions) t.trueAction = strip(t.trueAction);
      }
      return n;
    }
    // Refresh: "ggPosts empty -> ggPosts = cache" becomes memo call + set.
    final head = refresh.actions.rootAction;
    if (!head.hasConditionActions() || !writesCache(head.conditionActions.trueActions.first.trueAction) &&
        !head.conditionActions.trueActions.first.trueAction.action.localStateUpdate.updates
            .any((u) => u.fieldIdentifier.name == 'ggPosts')) {
      throw StateError('ggRefreshPosts not as expected');
    }
    final values = FFFunctionCallValues();
    for (final a in action.arguments) {
      values.arguments[a.identifier.key] = FFFunctionCallValues_FFArgument(
          value: FFValue()..mergeFromProto3Json({'inputValue': {'serializedValue': '0'}}));
    }
    final memoCall = FFActionNode(
        key: key('call.node'),
        action: FFAction(
            key: key('call.action'),
            customAction: FFCustomActionCall(customActionIdentifier: action.identifier, argumentValues: values),
            outputVariableName: 'ggPostsMemoOut'));
    final out = varFromActionOutput(actionKey: memoCall.action.key, outputName: 'ggPostsMemoOut')
      ..actionComponentKeyRef = FFActionComponentKeyReference(key: refresh.identifier.key);
    memoCall.followUpAction = FFActionNode(
        key: key('set'),
        action: Actions.updatePageState(p, widgetClassName: page, updates: [
          StateFieldUpdate.setFromVariable('ggPosts', out),
        ]));
    head.conditionActions.trueActions.first.trueAction = memoCall;
    for (final b in [refresh, blocks['ggMorePosts']!]) {
      b.actions.rootAction = strip(b.actions.rootAction);
    }
    final before = p.appState.fields.length;
    p.appState.fields.removeWhere((f) => f.parameter.identifier.name == 'ggPostsCache');
    stdout.writeln('ggRefreshPosts reads ggPostsPage(0, 0); removed $removed App State writes, '
        '${before - p.appState.fields.length} App State field (root $root).');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PostsMemo()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good News: session cache inside ggPostsPage (no App State rows)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
