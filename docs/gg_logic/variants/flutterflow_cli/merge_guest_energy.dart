// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// EnergyPage: one layout for signed-in users and guests.
// The signed-in copy was wrapped in a "my games" query (creator = auth user);
// for a guest that query fails, so the guest copy repeated the page with
// constants. Compared block by block:
//   header energyComp / energyCompGuest  -> energyComp (guest shows 0 / #0 too)
//   Community / Persönliche €nergy        -> same texts; guest has no games -> 0
//   Letzte Wirkung (my games or empty)    -> same; guest -> empty image
//   Transformation method (my profile)    -> signed in only (kept difference)
//   empty image bottom padding safe+48    -> guest only (it is the last block)
// Steps: page state ggMyGames (List<GamesRow>) filled by ggMyGames(test) in the
// block ggRefreshMyGames (On Load + GgStatsListener on games); the 6 uses of the
// query read the state with the same list operations; the query is removed;
// the ConditionalBuilder is replaced by the signed-in copy. JSON backup first.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'EnergyPage';
const builderKey = 'ConditionalBuilder_1gg86jw7';
const transformation = 'Column_vcmzne5q';
const emptyImage = 'Image_3ctcgtj4';
const listenerHost = 'Column_x8d68wtt';
String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.energypage.$seed');

final class MergeGuestEnergy extends FlutterFlowAITask {
  @override
  String get name => 'gg-merge-guest-energy';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final backup = File('${Platform.environment['HOME']}/.config/pfg-gg-backups/'
        'EnergyPage_before_guest_merge_${DateTime.now().millisecondsSinceEpoch}.json');
    backup.writeAsStringSync(jsonEncode(w));
    final root = (w['node'] as Map)['key'] as String;
    Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
      if (n['key'] == k) return n;
      for (final c in (n['children'] as List? ?? [])) {
        final r = find(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    Map<String, dynamic>? parentOf(Map<String, dynamic> n, String k) {
      for (final c in (n['children'] as List? ?? [])) {
        if ((c as Map)['key'] == k) return n;
        final r = parentOf(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    final parent = parentOf(w['node'], builderKey) ?? (throw StateError('$builderKey not found'));
    final builder = find(w['node'], builderKey)!;
    final branches = builder['children'] as List;
    if (branches.length != 2 || !jsonEncode(branches[0]['props']['visibility']).contains('IS_USER_LOGGED_IN')) {
      throw StateError('Unexpected branches');
    }
    final kept = (branches[0]['children'] as List).single as Map<String, dynamic>;
    final queryKey = kept['key'] as String;
    final dr = jsonEncode(kept['databaseRequest']);
    if (!dr.contains('"name":"games"') || !dr.contains('creator_user_id') || !dr.contains('SUPABASE_AUTH_USER')) {
      throw StateError('Kept wrapper is not the my-games query');
    }

    // Page state with the same type as the query result.
    final fields = ((w['classModel'] ??= <String, dynamic>{})['stateFields'] ??= []) as List;
    final stateIdent = {'name': 'ggMyGames', 'key': key('state')};
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
    rewrite(kept);
    final manager = kept['databaseRequest']['requestManagerSettings']?['managerIdentifier']?['key'] as String?;
    kept.remove('databaseRequest');
    if (refs != 6) throw StateError('Expected 6 uses of the games query, got $refs');

    // Kept differences.
    final notSignedIn = {
      'source': 'FUNCTION_CALL',
      'functionCall': {
        'condition': {'relation': 'EQUAL_TO'},
        'values': [
          {'variable': {'source': 'GLOBAL_PROPERTIES', 'baseVariable': {'globalProperties': {'property': 'IS_USER_LOGGED_IN'}}}},
          {'inputValue': {'serializedValue': 'false'}},
        ],
      },
    };
    final trans = find(kept, transformation) ?? (throw StateError('$transformation not found'));
    (trans['props'] as Map)['visibility'] = {
      'visibleValue': {
        'variable': {'source': 'GLOBAL_PROPERTIES', 'baseVariable': {'globalProperties': {'property': 'IS_USER_LOGGED_IN'}}}
      }
    };
    final guestImage = find(branches[1] as Map<String, dynamic>, 'Image_jugmuqr3');
    final guestBottom = guestImage?['props']?['padding']?['bottomValue'];
    if (guestBottom == null) throw StateError('Guest image padding not found');
    final image = find(kept, emptyImage) ?? (throw StateError('$emptyImage not found'));
    final padding = ((image['props'] as Map)['padding'] ??= <String, dynamic>{}) as Map;
    padding['bottomValue'] = {
      'variable': {
        'source': 'FUNCTION_CALL',
        'functionCall': {
          'conditionalValue': {
            'ifConditionalValues': [
              {'condition': notSignedIn, 'value': {'variable': guestBottom['variable']}},
            ],
            'elseValue': {'inputValue': {'serializedValue': '0'}},
            'returnParameter': {'dataType': {'scalarType': 'Double'}},
          }
        },
      }
    };

    // Listener node (callback attached after materializing).
    final def = findCustomWidget(p, name: 'GgStatsListener')!;
    Map<String, dynamic> pid(String n) =>
        def.parameters.firstWhere((x) => x.identifier.name == n).identifier.toProto3Json() as Map<String, dynamic>;
    final listenerKey = 'Container_${key('listener')}';
    (find(kept, listenerHost)!['children'] as List).insert(0, {
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
          pid('refreshKey')['key']: {'paramIdentifier': pid('refreshKey'), 'inputValue': {'serializedValue': scope}},
          pid('tables')['key']: {'paramIdentifier': pid('tables'), 'inputValue': {'serializedValue': 'games'}},
        },
        'customWidgetIdentifier': def.identifier.toProto3Json(),
      },
    });

    // One layout.
    final i = (parent['children'] as List).indexWhere((c) => c['key'] == builderKey);
    (parent['children'] as List)[i] = kept;

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    final wc = p.widgetClasses[entry.key]!;

    // "Clear Query Cache" of the removed query (app block "refresh"): spliced out;
    // the games listener keeps the page fresh.
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

    // Block: signed in -> ggMyGames(test) -> state.
    final action = findCustomAction(p, name: 'ggMyGames')!;
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
            outputVariableName: 'ggMyGamesOut'));
    final out = varFromActionOutput(actionKey: call.action.key, outputName: 'ggMyGamesOut')
      ..actionComponentKeyRef = FFActionComponentKeyReference(key: key('block'));
    call.followUpAction = FFActionNode(
        key: key('set'),
        action: Actions.updatePageState(p, widgetClassName: scope, updates: [
          StateFieldUpdate.setFromVariable('ggMyGames', out),
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
        description: 'Good Energy: my games of the environment (signed in only).',
        identifier: FFIdentifier(name: 'ggRefreshMyGames', key: key('block')));
    FFActionNode exec(String seed) {
      final n = FFActionNode(key: key(seed), action: Actions.executeActionBlock(p, actionBlockName: block.name, widgetClass: wc));
      n.action.executeActionComponent.shouldSetState = true;
      return n;
    }
    final onLoad = wc.node.triggerActions.firstWhere((t) => t.trigger.triggerType == FFActionTriggerType.ON_INIT_STATE);
    var tail = onLoad.rootAction;
    while (tail.hasFollowUpAction()) tail = tail.followUpAction;
    tail.followUpAction = exec('onload');
    void attach(FFNode n) {
      if (n.key == listenerKey) {
        n.triggerActions.add(FFTriggerActions()
          ..mergeFromProto3Json({'trigger': {'triggerType': 'CALLBACK', 'parameterIdentifier': pid('onRefresh')}})
          ..rootAction = exec('listener'));
      }
      for (final c in n.children) attach(c);
    }
    attach(wc.node);
    stdout.writeln('EnergyPage merged: kept $queryKey (query -> state, $refs uses), Transformation signed-in only, '
        'guest image padding kept; block ggRefreshMyGames on load + listener; '
        'removed $cleared Clear Query Cache ($manager); backup ${backup.path}');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [MergeGuestEnergy()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'EnergyPage: one layout for signed-in users and guests',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
