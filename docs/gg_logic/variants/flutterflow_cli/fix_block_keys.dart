// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Surgical fix for the first bindings push: nodes of the ggRefreshGoodGames
// action block shared keys, so FF codegen stopped after the first action.
// Re-keys only those nodes; action keys (used by ACTION_OUTPUTS) stay intact.
// Nothing else on the page is touched, so later edits in FF are preserved.
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';

final class FixRefreshBlockKeys extends FlutterFlowAITask {
  @override
  String get name => 'fix-gg-refresh-block-keys';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final w = ctx.project.widgetClasses.values.firstWhere((w) => w.name == 'GoodGamesPage');
    final block = w.classModel.actionComponentsConfig.actionComponents
        .firstWhere((c) => c.identifier.name == 'ggRefreshGoodGames');
    final nodes = <FFActionNode>[];
    void walk(FFActionNode n) {
      nodes.add(n);
      if (n.hasConditionActions()) {
        for (final b in n.conditionActions.trueActions) walk(b.trueAction);
        if (n.conditionActions.hasFalseAction()) walk(n.conditionActions.falseAction);
      }
      if (n.hasFollowUpAction()) walk(n.followUpAction);
    }
    walk(block.actions.rootAction);
    final actionKeys = {for (final n in nodes) if (n.hasAction()) n.action.key};
    final seen = <String>{};
    var i = 0;
    for (final n in nodes) {
      if (seen.contains(n.key) || actionKeys.contains(n.key)) {
        String k;
        do {
          k = generateRandomAlphaNumericString(seedString: 'pfg.gg.fix.node.${i++}');
        } while (seen.contains(k) || actionKeys.contains(k));
        n.key = k;
      }
      seen.add(n.key);
    }
    stdout.writeln('Block nodes: ${nodes.length}, unique keys: ${seen.length}, '
        'actions: ${nodes.where((n) => n.hasAction()).map((n) => n.action.whichAction().name).toList()}');
    if (seen.length != nodes.length) throw StateError('Keys still not unique');
    // Every call of the block must rebuild the page with the loaded JSON.
    var calls = 0;
    void visitAction(FFActionNode n) {
      if (n.hasAction() && n.action.hasExecuteActionComponent() &&
          n.action.executeActionComponent.actionComponentIdentifier.name == 'ggRefreshGoodGames') {
        n.action.executeActionComponent.shouldSetState = true;
        calls++;
      }
      if (n.hasConditionActions()) {
        for (final b in n.conditionActions.trueActions) visitAction(b.trueAction);
        if (n.conditionActions.hasFalseAction()) visitAction(n.conditionActions.falseAction);
      }
      if (n.hasFollowUpAction()) visitAction(n.followUpAction);
      if (n.hasAction() && n.action.hasBottomSheet()) {
        for (final pass in n.action.bottomSheet.passedParameters.parameterPasses.values) {
          if (pass.hasAction()) visitAction(pass.action.rootAction);
        }
      }
    }
    void visitNode(FFNode n) {
      for (final t in n.triggerActions) visitAction(t.rootAction);
      for (final pass in n.parameterValues.parameterPasses.values) {
        if (pass.hasAction()) visitAction(pass.action.rootAction);
      }
      for (final c in n.children) visitNode(c);
    }
    visitNode(w.node);
    stdout.writeln('Block calls set to rebuild the page: $calls');
  }
}

Future<void> main(List<String> args) async {
  final key = Platform.environment['FF_API_KEY'] ?? Platform.environment['FLUTTERFLOW_API_KEY'];
  if (key == null || key.isEmpty) throw StateError('FlutterFlow key missing');
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: key,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [FixRefreshBlockKeys()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Fix Good Games refresh block: unique action node keys',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
