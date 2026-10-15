// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// HomePage: the query of ALL completed games of the environment is replaced by
// the signed-in user's completed games (ggMyCompletedGames), loaded into page
// state ggMyCompletedGames by the block ggRefreshMyGames (On Load, in parallel
// with ggRefreshMyInvites; GgStatsListener on games). Every Home use already
// filtered the list to creator = me (directly or inside orgCompHome /
// homePageScore), so the numbers stay; the sponsor block date (last sponsored
// game) now comes from my games, like its sum. Guest -> empty list, as before.
// The query and its Clear Query Cache calls are removed.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'HomePage';
const queryKey = 'Container_3uvdavog';
String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.homegames.$seed');

final class HomeMyGames extends FlutterFlowAITask {
  @override
  String get name => 'gg-home-my-games';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    File('${Platform.environment['HOME']}/.config/pfg-gg-backups/'
            'HomePage_before_my_games_${DateTime.now().millisecondsSinceEpoch}.json')
        .writeAsStringSync(jsonEncode(w));
    final root = (w['node'] as Map)['key'] as String;
    Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
      if (n['key'] == k) return n;
      for (final c in (n['children'] as List? ?? [])) {
        final r = find(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    final host = find(w['node'], queryKey) ?? (throw StateError('$queryKey not found'));
    final dr = host['databaseRequest'] as Map<String, dynamic>;
    final drs = jsonEncode(dr);
    if (!drs.contains('"name":"games"') || !drs.contains('"completed"') || drs.contains('creator_user_id')) {
      throw StateError('Not the all-completed-games query');
    }
    final manager = dr['requestManagerSettings']?['managerIdentifier']?['key'] as String?;
    final fields = ((w['classModel'] ??= <String, dynamic>{})['stateFields'] ??= []) as List;
    final stateIdent = {'name': 'ggMyCompletedGames', 'key': key('state')};
    fields.add({
      'parameter': {
        'identifier': stateIdent,
        'dataType': {
          'listType': {'scalarType': 'PostgresRow'},
          'subType': {'tableIdentifier': {'name': 'games'}},
        },
      }
    });
    final state = {
      'source': 'LOCAL_STATE',
      'baseVariable': {'localState': {'fieldIdentifier': stateIdent, 'stateVariableType': 'WIDGET_CLASS_STATE'}},
      'nodeKeyRef': {'key': root},
    };
    var refs = 0;
    void rewrite(dynamic x) {
      if (x is Map<String, dynamic>) {
        if (x['source'] == 'POSTGRES_QUERY' && x['nodeKeyRef']?['key'] == queryKey) {
          final keep = {for (final k in ['operations', 'defaultValue', 'uiBuilderValue']) if (x[k] != null) k: x[k]};
          x
            ..clear()
            ..addAll(jsonDecode(jsonEncode(state)) as Map<String, dynamic>)
            ..addAll(keep);
          refs++;
          return;
        }
        x.values.forEach(rewrite);
      } else if (x is List) {
        x.forEach(rewrite);
      }
    }
    rewrite(w);
    host.remove('databaseRequest');
    if (refs < 10) throw StateError('Too few uses rewritten: $refs');

    // Listener for my games, next to the invites listener.
    final def = findCustomWidget(p, name: 'GgStatsListener')!;
    Map<String, dynamic> pid(String n) =>
        def.parameters.firstWhere((x) => x.identifier.name == n).identifier.toProto3Json() as Map<String, dynamic>;
    String? invitesListenerParent;
    void locate(Map<String, dynamic> n) {
      for (final c in (n['children'] as List? ?? [])) {
        final s = jsonEncode((c as Map)['parameterValues'] ?? {});
        if (c['customWidgetIdentifier'] != null && s.contains('"serializedValue":"invites"')) invitesListenerParent = n['key'] as String;
        locate(c as Map<String, dynamic>);
      }
    }
    locate(w['node']);
    if (invitesListenerParent == null) throw StateError('invites listener not found (run merge_guest_home first)');
    final listenerKey = 'Container_${key('listener')}';
    (find(w['node'], invitesListenerParent!)!['children'] as List).insert(0, {
      'key': listenerKey,
      'type': 'Container',
      'props': {},
      'customWidgetIdentifier': def.identifier.toProto3Json(),
      'enforceCustomWidgetDimensions': true,
      'parameterValues': {
        'parameterPasses': {
          pid('dimensions')['key']: {
            'paramIdentifier': pid('dimensions'),
            'widgetProperty': {
              'dimensions': {'width': {'pixelsValue': {'inputValue': 1}}, 'height': {'pixelsValue': {'inputValue': 1}}}
            },
          },
          pid('refreshKey')['key']: {'paramIdentifier': pid('refreshKey'), 'inputValue': {'serializedValue': '${scope}Games'}},
          pid('tables')['key']: {'paramIdentifier': pid('tables'), 'inputValue': {'serializedValue': 'games'}},
        },
        'customWidgetIdentifier': def.identifier.toProto3Json(),
      },
    });

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    final wc = p.widgetClasses[entry.key]!;

    // Clear Query Cache of the removed query: spliced out everywhere.
    var cleared = 0;
    FFActionNode fix(FFActionNode n) {
      if (n.hasAction() && n.action.hasClearQueryCache() &&
          n.action.clearQueryCache.cacheManagerIdentifier.key == manager) {
        cleared++;
        return n.hasFollowUpAction() ? fix(n.followUpAction) : FFActionNode(key: n.key);
      }
      if (n.hasFollowUpAction()) n.followUpAction = fix(n.followUpAction);
      if (n.hasConditionActions()) {
        for (final t in n.conditionActions.trueActions) t.trueAction = fix(t.trueAction);
        if (n.conditionActions.hasFalseAction()) n.conditionActions.falseAction = fix(n.conditionActions.falseAction);
      }
      if (n.hasParallelActions()) {
        final b = n.parallelActions.actions.map(fix).toList();
        n.parallelActions.actions..clear()..addAll(b);
      }
      if (n.hasAction() && n.action.hasDisableAction() && n.action.disableAction.hasActionNode()) {
        n.action.disableAction.actionNode = fix(n.action.disableAction.actionNode);
      }
      return n;
    }
    void fixTree(FFNode n) {
      for (final t in n.triggerActions) {
        if (t.hasRootAction()) t.rootAction = fix(t.rootAction);
      }
      for (final c in n.children) fixTree(c);
    }
    if (manager != null) {
      for (final b in p.appState.actionComponentsConfig.actionComponents) {
        if (b.hasActions() && b.actions.hasRootAction()) b.actions.rootAction = fix(b.actions.rootAction);
      }
      for (final c in p.widgetClasses.values) {
        fixTree(c.node);
        for (final b in c.classModel.actionComponentsConfig.actionComponents) {
          if (b.hasActions() && b.actions.hasRootAction()) b.actions.rootAction = fix(b.actions.rootAction);
        }
      }
    }

    // Block + On Load (parallel with the invites block) + listener.
    final action = findCustomAction(p, name: 'ggMyCompletedGames')!;
    final env = findEnvironmentValue(p, 'test')!.parameter.identifier.toProto3Json();
    final values = FFFunctionCallValues();
    for (final a in action.arguments) {
      values.arguments[a.identifier.key] = FFFunctionCallValues_FFArgument(
          value: FFValue()
            ..mergeFromProto3Json({
              'variable': {'source': 'DEV_ENVIRONMENT', 'baseVariable': {'environmentValue': {'identifier': env}}}
            }));
    }
    final call = FFActionNode(
        key: key('call.node'),
        action: FFAction(
            key: key('call.action'),
            customAction: FFCustomActionCall(customActionIdentifier: action.identifier, argumentValues: values),
            outputVariableName: 'ggMyCompletedGamesOut'));
    final out = varFromActionOutput(actionKey: call.action.key, outputName: 'ggMyCompletedGamesOut')
      ..actionComponentKeyRef = FFActionComponentKeyReference(key: key('block'));
    call.followUpAction = FFActionNode(
        key: key('set'),
        action: Actions.updatePageState(p, widgetClassName: scope, updates: [
          StateFieldUpdate.setFromVariable('ggMyCompletedGames', out),
        ]));
    final signedIn = FFVariable()
      ..mergeFromProto3Json({
        'source': 'FUNCTION_CALL',
        'functionCall': {
          'condition': {'relation': 'EQUAL_TO'},
          'values': [
            {'variable': {'source': 'GLOBAL_PROPERTIES', 'baseVariable': {'globalProperties': {'property': 'IS_USER_LOGGED_IN'}}}},
            {'inputValue': {'serializedValue': 'true'}},
          ],
        },
      });
    final block = addActionBlock(p,
        name: 'ggRefreshMyGames',
        rootAction: Actions.conditional(condition: signedIn, trueActions: call),
        widgetClass: wc,
        description: 'Home: my completed games of the environment (signed in only).',
        identifier: FFIdentifier(name: 'ggRefreshMyGames', key: key('block')));
    FFActionNode exec(String seed) {
      final n = FFActionNode(key: key(seed), action: Actions.executeActionBlock(p, actionBlockName: block.name, widgetClass: wc));
      n.action.executeActionComponent.shouldSetState = true;
      return n;
    }
    final onLoad = wc.node.triggerActions.firstWhere((t) => t.trigger.triggerType == FFActionTriggerType.ON_INIT_STATE);
    bool isInvites(FFActionNode n) =>
        n.hasAction() && n.action.hasExecuteActionComponent() &&
        n.action.executeActionComponent.actionComponentIdentifier.name == 'ggRefreshMyInvites';
    FFActionNode? prev;
    var cur = onLoad.rootAction;
    while (!isInvites(cur)) {
      if (!cur.hasFollowUpAction()) throw StateError('ggRefreshMyInvites not in On Load');
      prev = cur;
      cur = cur.followUpAction;
    }
    final invitesCall = cur;
    final rest = invitesCall.hasFollowUpAction() ? invitesCall.followUpAction : null;
    invitesCall.clearFollowUpAction();
    final both = Actions.parallel([invitesCall, exec('onload')]);
    if (rest != null) both.followUpAction = rest;
    if (prev == null) {
      onLoad.rootAction = both;
    } else {
      prev.followUpAction = both;
    }
    void attach(FFNode n) {
      if (n.key == listenerKey) {
        n.triggerActions.add(FFTriggerActions()
          ..mergeFromProto3Json({'trigger': {'triggerType': 'CALLBACK', 'parameterIdentifier': pid('onRefresh')}})
          ..rootAction = exec('listener'));
      }
      for (final c in n.children) attach(c);
    }
    attach(wc.node);
    stdout.writeln('HomePage: all-games query -> my completed games ($refs uses), On Load parallel, '
        'games listener; removed $cleared Clear Query Cache ($manager)');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [HomeMyGames()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'HomePage: only my completed games instead of all games',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
