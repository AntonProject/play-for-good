// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// PlayPage: one layout for signed-in users and guests.
// The signed-in copy was wrapped in a live "my profile" query (users, Hide On
// Empty); the guest copy was the same 106 widgets with constants. Full diff:
//   avatars (4)             photo_url              | default images
//   "Game #N" + new game    games_count + 1 (with !) | 1
//   profile passed to sheet my row                 | not passed (null)
//   3 labels font size      theme Title Small (18) | 18 (same on phones)
//   start button actions (chosen_org, id, emails, row; mostly disabled): the
//   same in both copies (the guest one pointed at its own query-less Stack).
// Steps: page state ggMe (users row) from ggMe() in the block ggRefreshMe
// (On Load + GgStatsListener on users); every use of the query reads ggMe with
// the same operations; games_count gets default 0 (guest -> "Game #1"), photos
// keep/get the guest default images; the ConditionalBuilder is replaced by the
// signed-in copy. JSON backup first.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'PlayPage';
const builderKey = 'ConditionalBuilder_tp204gcw';
const profileImage =
    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png';
String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.playmerge.$seed');

final class MergeGuestPlay extends FlutterFlowAITask {
  @override
  String get name => 'gg-merge-guest-play';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    File('${Platform.environment['HOME']}/.config/pfg-gg-backups/'
            'PlayPage_before_guest_merge_${DateTime.now().millisecondsSinceEpoch}.json')
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
    if (branches.length != 2 || !jsonEncode(branches[0]['props']['visibility']).contains('IS_USER_LOGGED_IN')) {
      throw StateError('Unexpected branches');
    }
    final kept = (branches[0]['children'] as List).single as Map<String, dynamic>;
    final queryKey = kept['key'] as String;
    final dr = kept['databaseRequest'] as Map<String, dynamic>?;
    if (dr == null || !jsonEncode(dr).contains('"name":"users"') || dr['postgres']?['isSingleRow'] != true ||
        !jsonEncode(dr).contains('SUPABASE_AUTH_USER')) {
      throw StateError('Kept wrapper is not the my-profile query');
    }
    final manager = dr['requestManagerSettings']?['managerIdentifier']?['key'] as String?;
    var otherQueries = 0;
    void q(Map<String, dynamic> n) {
      if (n != kept && n['databaseRequest'] != null) otherQueries++;
      for (final c in (n['children'] as List? ?? [])) q(c as Map<String, dynamic>);
    }
    q(kept);

    final fields = ((w['classModel'] ??= <String, dynamic>{})['stateFields'] ??= []) as List;
    final stateIdent = {'name': 'ggMe', 'key': key('state')};
    fields.add({
      'parameter': {
        'identifier': stateIdent,
        'dataType': {'scalarType': 'PostgresRow', 'subType': {'tableIdentifier': {'name': 'users'}}},
      }
    });
    final state = {
      'source': 'LOCAL_STATE',
      'baseVariable': {'localState': {'fieldIdentifier': stateIdent, 'stateVariableType': 'WIDGET_CLASS_STATE'}},
      'nodeKeyRef': {'key': root},
    };
    final counts = <String, int>{};
    void rewrite(dynamic x) {
      if (x is Map<String, dynamic>) {
        if (x['source'] == 'POSTGRES_QUERY' && x['nodeKeyRef']?['key'] == queryKey) {
          final field = x['operations']?[0]?['accessPostgresRowField']?['fieldIdentifier']?['name'] as String?;
          final keep = {for (final k in ['operations', 'defaultValue', 'uiBuilderValue']) if (x[k] != null) k: x[k]};
          if (field == 'games_count' && keep['defaultValue'] == null) {
            keep['defaultValue'] = {'serializedValue': '0'};
          }
          if (field == 'photo_url' && keep['defaultValue'] == null) {
            keep['defaultValue'] = {'serializedValue': profileImage};
          }
          x
            ..clear()
            ..addAll(jsonDecode(jsonEncode(state)) as Map<String, dynamic>)
            ..addAll(keep);
          final k = field ?? 'row';
          counts[k] = (counts[k] ?? 0) + 1;
          return;
        }
        x.values.forEach(rewrite);
      } else if (x is List) {
        x.forEach(rewrite);
      }
    }
    rewrite(kept);
    kept.remove('databaseRequest');
    final unexpected = counts.keys.where((k) => !const ['photo_url', 'games_count', 'row', 'chosen_org', 'id', 'emails'].contains(k)).toList();
    if (unexpected.isNotEmpty || (counts['photo_url'] ?? 0) == 0 || (counts['games_count'] ?? 0) == 0) {
      throw StateError('Unexpected uses: $counts');
    }

    // Listener on users (callback attached below), first in the kept Stack's column.
    final def = findCustomWidget(p, name: 'GgStatsListener')!;
    Map<String, dynamic> pid(String n) =>
        def.parameters.firstWhere((x) => x.identifier.name == n).identifier.toProto3Json() as Map<String, dynamic>;
    final listenerKey = 'Container_${key('listener')}';
    Map<String, dynamic>? host;
    void firstColumn(Map<String, dynamic> n) {
      if (host != null) return;
      if (n['type'] == 'Column') {
        host = n;
        return;
      }
      for (final c in (n['children'] as List? ?? [])) firstColumn(c as Map<String, dynamic>);
    }
    firstColumn(kept);
    (host!['children'] as List).insert(0, {
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
          pid('tables')['key']: {'paramIdentifier': pid('tables'), 'inputValue': {'serializedValue': 'users'}},
        },
        'customWidgetIdentifier': def.identifier.toProto3Json(),
      },
    });

    final i = (parent['children'] as List).indexWhere((c) => c['key'] == builderKey);
    (parent['children'] as List)[i] = kept;
    // The Scaffold names its body by key (childPropertyMap.body.keyRefs): point
    // it at the kept copy, otherwise FF generates an empty page body.
    var slots = 0;
    void repoint(dynamic x) {
      if (x is Map) {
        if (x['key'] == builderKey && !x.containsKey('type')) {
          x['key'] = queryKey;
          slots++;
        }
        x.values.forEach(repoint);
      } else if (x is List) {
        x.forEach(repoint);
      }
    }
    repoint(parent['childPropertyMap']);
    if (jsonEncode(w).contains('"$builderKey"')) throw StateError('$builderKey still referenced');

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    final wc = p.widgetClasses[entry.key]!;

    // Clear Query Cache calls are spliced out only when no other query uses the
    // same cache manager (0a5jj is the shared current-user cache: kept).
    var shared = 0;
    void countUses(dynamic x) {
      if (x is Map) {
        final m = x['databaseRequest']?['requestManagerSettings']?['managerIdentifier']?['key'];
        if (m != null && m == manager) shared++;
        x.values.forEach(countUses);
      } else if (x is List) {
        x.forEach(countUses);
      }
    }
    for (final c in p.widgetClasses.values) {
      countUses(c.node.toProto3Json());
    }
    final exclusive = manager != null && shared == 0;
    var cleared = 0;
    FFActionNode fix(FFActionNode n) {
      if (exclusive && n.hasAction() && n.action.hasClearQueryCache() &&
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
    if (exclusive) {
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

    // Block: signed in -> ggMe() -> state.
    final action = findCustomAction(p, name: 'ggMe')!;
    final call = FFActionNode(
        key: key('call.node'),
        action: FFAction(
            key: key('call.action'),
            customAction: FFCustomActionCall(customActionIdentifier: action.identifier, argumentValues: FFFunctionCallValues()),
            outputVariableName: 'ggMeOut'));
    final out = varFromActionOutput(actionKey: call.action.key, outputName: 'ggMeOut')
      ..actionComponentKeyRef = FFActionComponentKeyReference(key: key('block'));
    call.followUpAction = FFActionNode(
        key: key('set'),
        action: Actions.updatePageState(p, widgetClassName: scope, updates: [
          StateFieldUpdate.setFromVariable('ggMe', out),
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
        name: 'ggRefreshMe',
        rootAction: Actions.conditional(condition: signedIn, trueActions: call),
        widgetClass: wc,
        description: 'Play: my profile row (signed in only).',
        identifier: FFIdentifier(name: 'ggRefreshMe', key: key('block')));
    FFActionNode exec(String seed) {
      final n = FFActionNode(key: key(seed), action: Actions.executeActionBlock(p, actionBlockName: block.name, widgetClass: wc));
      n.action.executeActionComponent.shouldSetState = true;
      return n;
    }
    final onLoads = wc.node.triggerActions.where((t) => t.trigger.triggerType == FFActionTriggerType.ON_INIT_STATE);
    if (onLoads.isEmpty) {
      wc.node.triggerActions.add(FFTriggerActions()
        ..mergeFromProto3Json({'trigger': {'triggerType': 'ON_INIT_STATE'}})
        ..rootAction = exec('onload'));
    } else {
      // First, so the profile is there as early as possible; the rest follows.
      final first = exec('onload');
      first.followUpAction = onLoads.first.rootAction;
      onLoads.first.rootAction = first;
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
    stdout.writeln('PlayPage merged: body slots repointed $slots, uses $counts, other queries in kept copy $otherQueries, '
        'Clear Query Cache of $manager: ${exclusive ? 'removed $cleared' : 'kept (shared by $shared queries)'}, block ggRefreshMe on load + users listener');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [MergeGuestPlay()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'PlayPage: one layout for signed-in users and guests',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
