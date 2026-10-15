// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// GoodGamesPage loading in parallel:
//  * ggRefreshGoodGames: ranking || (signed in: my stats || my games history)
//    instead of three RPC calls one after another;
//  * On Load: state updates first (tab, periods, app refresh date), then
//    setStatusBarColor || ggRefreshGoodGames. The empty Parallel Actions node
//    at the start of On Load (no branches, no effect) is dropped.
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';

final class ParallelRefresh extends FlutterFlowAITask {
  @override
  String get name => 'gg-parallel-refresh';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  bool isCustom(FFActionNode n, String name) =>
      n.hasAction() && n.action.hasCustomAction() &&
      n.action.customAction.customActionIdentifier.name == name;
  bool isRefresh(FFActionNode n) =>
      n.hasAction() && n.action.hasExecuteActionComponent() &&
      n.action.executeActionComponent.actionComponentIdentifier.name == 'ggRefreshGoodGames';

  @override
  void run(TaskContext ctx) {
    final w = ctx.project.widgetClasses.values.firstWhere((w) => w.name == 'GoodGamesPage');

    // 1. Action block.
    final block = w.classModel.actionComponentsConfig.actionComponents
        .firstWhere((c) => c.identifier.name == 'ggRefreshGoodGames');
    final ranking = block.actions.rootAction;
    if (!isCustom(ranking, 'ggV2Rankings')) throw StateError('Block already restructured?');
    final rankingSet = ranking.followUpAction;
    final personal = rankingSet.followUpAction; // conditional: signed in
    rankingSet.clearFollowUpAction();
    final stats = personal.conditionActions.trueActions.first.trueAction;
    if (!isCustom(stats, 'ggV2ProfileStats')) throw StateError('Unexpected personal branch');
    final statsSet = stats.followUpAction;
    final history = statsSet.followUpAction;
    if (!isCustom(history, 'ggV2Games')) throw StateError('Unexpected history node');
    statsSet.clearFollowUpAction();
    personal.conditionActions.trueActions.first.trueAction = Actions.parallel([stats, history]);
    block.actions.rootAction = Actions.parallel([ranking, personal]);

    // 2. On Load chain.
    final trigger = w.node.triggerActions
        .firstWhere((t) => t.trigger.triggerType == FFActionTriggerType.ON_INIT_STATE);
    final chain = <FFActionNode>[];
    for (FFActionNode? n = trigger.rootAction; n != null;
        n = n.hasFollowUpAction() ? n.followUpAction : null) {
      chain.add(n);
    }
    for (final n in chain) n.clearFollowUpAction();
    bool isEmptyNode(FFActionNode n) =>
        !n.hasAction() && !n.hasConditionActions() && !n.hasParallelActions() && !n.hasFollowUpAction();
    final emptyParallel = chain
        .where((n) => n.hasParallelActions() && n.parallelActions.actions.every(isEmptyNode))
        .toList();
    final disabled = chain.where((n) => n.hasAction() && n.action.hasDisableAction()).toList();
    final tab = chain.where((n) => n.hasConditionActions()).toList();
    final custom = chain.where((n) => n.hasAction() && n.action.hasCustomAction()).toList();
    final updates = chain.where((n) => n.hasAction() && n.action.hasLocalStateUpdate()).toList();
    final refresh = chain.where(isRefresh).toList();
    final known = {...emptyParallel, ...disabled, ...tab, ...custom, ...updates, ...refresh};
    final unknown = chain.where((n) => !known.contains(n)).toList();
    if (refresh.length != 1 || tab.length != 1 || unknown.isNotEmpty) {
      throw StateError('On Load not as expected: refresh=${refresh.length} tab=${tab.length} unknown=${unknown.length}');
    }
    // Branch 3: period states first (the block reads them), then the RPC block.
    final loadChain = [...updates, refresh.single];
    for (var i = 0; i < loadChain.length - 1; i++) {
      loadChain[i].followUpAction = loadChain[i + 1];
    }
    final branches = <FFActionNode>[tab.single, ...custom, loadChain.first];
    final ordered = [...disabled, Actions.parallel(branches)];
    for (var i = 0; i < ordered.length - 1; i++) {
      ordered[i].followUpAction = ordered[i + 1];
    }
    trigger.rootAction = ordered.first;
    final rest = updates;
    stdout.writeln('Block: ranking || (stats || history). On Load: parallel[tab | '
        '${custom.length} custom | ${rest.length} state updates -> refresh]; '
        'dropped ${emptyParallel.length} empty parallel node(s), kept ${disabled.length} disabled.');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [ParallelRefresh()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games: parallel RPC loading and On Load',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
