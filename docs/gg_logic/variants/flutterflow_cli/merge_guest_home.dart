// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// HomePage: one layout for signed-in users and guests.
// Signed-in copy: "my used invites" query wrapping homePageScore + Play/Invite.
// Guest copy (component homePageGuestContent): homePageScore if the guest has
// demo points (hasGuestGetLichtwatt), otherwise homePageScoreEmpty, and the same
// Play/Invite row where Invite opens the registration dialog.
// Kept differences in the shared layout:
//  * homePageScore: signed in OR hasGuestGetLichtwatt; else homePageScoreEmpty;
//  * Invite: signed in -> inviteEmail sheet (as before); guest -> the guest
//    chain copied as is (authDialog, its disabled steps untouched).
// Data: page state ggMyInvites (List<InvitesRow>) from ggMyInvites(test) in the
// block ggRefreshMyInvites (On Load + GgStatsListener on invites); guest -> [].
// The query and its Clear Query Cache calls are removed. JSON backup first.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'HomePage';
const builderKey = 'ConditionalBuilder_uuoyhssk';
const scoreKey = 'Container_v0mw7kco';
const inviteKey = 'IconButton_od733wan';
const hostColumn = 'Column_rlcuqik3';
const guestScope = 'homePageGuestContent';
const guestInvite = 'IconButton_vs9y4ahf';
const guestEmpty = 'Container_f55u9kj8';
String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.homemerge.$seed');

final class MergeGuestHome extends FlutterFlowAITask {
  @override
  String get name => 'gg-merge-guest-home';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final g = jsonDecode(jsonEncode(p.widgetClasses.values.firstWhere((x) => x.name == guestScope).toProto3Json()))
        as Map<String, dynamic>;
    File('${Platform.environment['HOME']}/.config/pfg-gg-backups/'
            'HomePage_before_guest_merge_${DateTime.now().millisecondsSinceEpoch}.json')
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
    if (branches.length != 2 || !jsonEncode(branches[0]['props']['visibility']).contains('IS_USER_LOGGED_IN') ||
        !jsonEncode(branches[1]).contains('"key":"${g['node']['key']}"')) {
      throw StateError('Unexpected branches');
    }
    final kept = (branches[0]['children'] as List).single as Map<String, dynamic>;
    final queryKey = kept['key'] as String;
    final dr = kept['databaseRequest'] as Map<String, dynamic>;
    if (!jsonEncode(dr).contains('"name":"invites"') || !jsonEncode(dr).contains('inviter_user_id')) {
      throw StateError('Kept wrapper is not the my-invites query');
    }
    final manager = dr['requestManagerSettings']?['managerIdentifier']?['key'] as String?;

    // Query -> page state.
    final fields = ((w['classModel'] ??= <String, dynamic>{})['stateFields'] ??= []) as List;
    final stateIdent = {'name': 'ggMyInvites', 'key': key('state')};
    fields.add({
      'parameter': {
        'identifier': stateIdent,
        'dataType': {
          'listType': {'scalarType': 'PostgresRow'},
          'subType': {'tableIdentifier': {'name': 'invites'}},
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
    kept.remove('databaseRequest');
    if (refs != 3) throw StateError('Expected 3 uses of the invites query, got $refs');

    // Score: signed in OR guest with demo points; else the empty variant.
    final signedIn = {'source': 'GLOBAL_PROPERTIES', 'baseVariable': {'globalProperties': {'property': 'IS_USER_LOGGED_IN'}}};
    final guestPoints = jsonDecode(jsonEncode(find(g['node'], 'PlaceholderWidget_04d3pb49')!['props']['visibility']['visibleValue']['variable']))
        as Map<String, dynamic>;
    if (!jsonEncode(guestPoints).contains('hasGuestGetLichtwatt')) throw StateError('Guest condition changed');
    Map<String, dynamic> eq(Map<String, dynamic> v, String value) => {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'condition': {'relation': 'EQUAL_TO'},
            'values': [
              {'variable': v},
              {'inputValue': {'serializedValue': value}},
            ],
          },
        };
    final showScore = {
      'source': 'FUNCTION_CALL',
      'functionCall': {
        'combineConditions': {'operator': 'OR_OP'},
        'values': [
          {'variable': signedIn},
          {'variable': guestPoints},
        ],
      },
    };
    final hideScore = {
      'source': 'FUNCTION_CALL',
      'functionCall': {
        'combineConditions': {'operator': 'AND_OP'},
        'values': [
          {'variable': eq(signedIn, 'false')},
          {'variable': eq(guestPoints['functionCall']['values'][0]['variable'] as Map<String, dynamic>, 'false')},
        ],
      },
    };
    final column = parentOf(kept, scoreKey) ?? (throw StateError('$scoreKey not found'));
    final score = find(kept, scoreKey)!;
    (score['props'] ??= <String, dynamic>{})['visibility'] = {'visibleValue': {'variable': showScore}};
    final empty = jsonDecode(jsonEncode(find(g['node'], guestEmpty) ?? (throw StateError('$guestEmpty not found'))))
        as Map<String, dynamic>;
    empty['key'] = 'Container_${key('empty')}';
    (empty['props'] ??= <String, dynamic>{})['visibility'] = {'visibleValue': {'variable': hideScore}};
    final children = column['children'] as List;
    children.insert(children.indexWhere((c) => c['key'] == scoreKey) + 1, empty);

    // Invite: signed in -> as before; guest -> the guest chain (re-keyed).
    final invite = find(kept, inviteKey) ?? (throw StateError('$inviteKey not found'));
    final tap = (invite['triggerActions'] as List).single as Map<String, dynamic>;
    final signedInRoot = tap['rootAction'];
    if (!jsonEncode(signedInRoot).contains('bottomSheet')) throw StateError('Unexpected signed-in Invite');
    final guestTap = ((find(g['node'], guestInvite) ?? (throw StateError('$guestInvite not found')))['triggerActions'] as List)
        .single as Map<String, dynamic>;
    var chain = jsonEncode(guestTap['rootAction']);
    final actionKeys = <String>{};
    void collect(dynamic x) {
      if (x is Map) {
        final isAction = x.containsKey('action') || x.containsKey('conditionActions') ||
            x.keys.any((k) => const ['bottomSheet', 'alertDialog', 'localStateUpdate', 'disableAction', 'navigate'].contains(k));
        if (isAction && x['key'] is String) actionKeys.add(x['key'] as String);
        x.values.forEach(collect);
      } else if (x is List) {
        x.forEach(collect);
      }
    }
    collect(guestTap['rootAction']);
    for (final k in actionKeys) {
      chain = chain.replaceAll('"$k"', '"${key('a.$k')}"');
    }
    chain = chain.replaceAll('"$guestInvite"', '"$inviteKey"');
    tap['rootAction'] = {
      'key': key('invite.if'),
      'conditionActions': {
        'trueActions': [
          {'condition': {'variable': signedIn}, 'trueAction': signedInRoot}
        ],
        'falseAction': jsonDecode(chain),
      },
    };

    // Listener for my invites (callback attached below).
    final def = findCustomWidget(p, name: 'GgStatsListener')!;
    Map<String, dynamic> pid(String n) =>
        def.parameters.firstWhere((x) => x.identifier.name == n).identifier.toProto3Json() as Map<String, dynamic>;
    final listenerKey = 'Container_${key('listener')}';
    (find(kept, hostColumn)!['children'] as List).insert(0, {
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
          pid('tables')['key']: {'paramIdentifier': pid('tables'), 'inputValue': {'serializedValue': 'invites'}},
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

    // Block: signed in -> ggMyInvites(test) -> state; On Load + listener.
    final action = findCustomAction(p, name: 'ggMyInvites')!;
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
            outputVariableName: 'ggMyInvitesOut'));
    final out = varFromActionOutput(actionKey: call.action.key, outputName: 'ggMyInvitesOut')
      ..actionComponentKeyRef = FFActionComponentKeyReference(key: key('block'));
    call.followUpAction = FFActionNode(
        key: key('set'),
        action: Actions.updatePageState(p, widgetClassName: scope, updates: [
          StateFieldUpdate.setFromVariable('ggMyInvites', out),
        ]));
    final block = addActionBlock(p,
        name: 'ggRefreshMyInvites',
        rootAction: Actions.conditional(condition: FFVariable()..mergeFromProto3Json(eq(signedIn, 'true')), trueActions: call),
        widgetClass: wc,
        description: 'Home: my used invites of the environment (signed in only).',
        identifier: FFIdentifier(name: 'ggRefreshMyInvites', key: key('block')));
    FFActionNode exec(String seed) {
      final n = FFActionNode(key: key(seed), action: Actions.executeActionBlock(p, actionBlockName: block.name, widgetClass: wc));
      n.action.executeActionComponent.shouldSetState = true;
      return n;
    }
    final onLoad = wc.node.triggerActions.where((t) => t.trigger.triggerType == FFActionTriggerType.ON_INIT_STATE);
    if (onLoad.isEmpty) {
      wc.node.triggerActions.add(FFTriggerActions()
        ..mergeFromProto3Json({'trigger': {'triggerType': 'ON_INIT_STATE'}})
        ..rootAction = exec('onload'));
    } else {
      var tail = onLoad.first.rootAction;
      while (tail.hasFollowUpAction()) tail = tail.followUpAction;
      tail.followUpAction = exec('onload');
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
    stdout.writeln('HomePage merged: query -> state ($refs uses), score/empty by sign-in or guest points, '
        'Invite signed-in/guest kept (${actionKeys.length} guest actions re-keyed), '
        'removed $cleared Clear Query Cache ($manager)');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [MergeGuestHome()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'HomePage: one layout for signed-in users and guests',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
