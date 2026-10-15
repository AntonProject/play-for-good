// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Good News posts: page-wise loading instead of streaming the whole table.
//  * page state ggPosts (List<PostsRow>) drives the existing post cards;
//  * On Load: show posts kept in app memory, then load 10 (ggRefreshPosts);
//  * a 1px Visibilitydetector at the end of the page loads 10 more;
//  * GgStatsListener(tables: posts) re-reads the loaded window on changes.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const page = 'GoodNewsPage';
const postsColumn = 'Column_wpfp8w9t';
const scrollColumn = 'Column_aldie211';
String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.posts.$seed');

final class PostsPaging extends FlutterFlowAITask {
  @override
  String get name => 'gg-posts-paging';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final postsTable = findTable(p, name: 'posts')!.identifier;
    final postsList = FFDataTypeV2(
        listType: FFDataTypeV2(scalarType: FFBaseDataType.PostgresRow),
        subType: FFSubType(tableIdentifier: postsTable));
    ensureAppStateField(p,
        name: 'ggPostsCache', type: postsList.deepCopy(),
        description: 'Good News posts already loaded in this app session.', persisted: false);
    final cacheId = p.appState.fields
        .firstWhere((f) => f.parameter.identifier.name == 'ggPostsCache').parameter.identifier;

    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == page);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    if (jsonEncode(w).contains('ggPosts')) throw StateError('Posts paging already applied');
    final root = (w['node'] as Map)['key'];
    final fields = ((w['classModel'] as Map)['stateFields'] as List);
    Map<String, dynamic> addState(String name, Map<String, dynamic> type, [List<String>? def]) {
      final ident = {'name': name, 'key': key('state$name')};
      fields.add({
        'parameter': {'identifier': ident, 'dataType': type},
        if (def != null) 'serializedDefaultValue': def,
      });
      return ident;
    }
    addState('ggPosts', postsList.toProto3Json() as Map<String, dynamic>);
    addState('ggPostsHasMore', {'scalarType': 'Boolean', 'nonNullable': true}, ['true']);
    addState('ggPostsLoading', {'scalarType': 'Boolean', 'nonNullable': true}, ['false']);

    Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
      if (n['key'] == k) return n;
      for (final c in (n['children'] as List? ?? [])) {
        final r = find(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    // Posts column: generator over ggPosts instead of the streaming query.
    final column = find(w['node'], postsColumn)!;
    final ggPostsIdent = fields.firstWhere((f) => f['parameter']['identifier']['name'] == 'ggPosts')['parameter']['identifier'];
    column['generatorVariable'] = {
      'identifier': {'name': 'postItem', 'key': key('generator')},
      'variable': {
        'source': 'LOCAL_STATE',
        'baseVariable': {'localState': {'fieldIdentifier': ggPostsIdent, 'stateVariableType': 'WIDGET_CLASS_STATE'}},
        'nodeKeyRef': {'key': root},
      },
    };
    var swapped = 0;
    void toItem(dynamic x) {
      if (x is Map<String, dynamic>) {
        if (x['source'] == 'POSTGRES_QUERY' && x['nodeKeyRef']?['key'] == postsColumn) {
          final ops = x['operations'];
          x
            ..clear()
            ..addAll(<String, dynamic>{
              'source': 'GENERATOR_VARIABLE',
              'baseVariable': {'generatorVariable': {}},
              'nodeKeyRef': {'key': postsColumn},
              if (ops != null) 'operations': ops,
            });
          swapped++;
        }
        x.values.forEach(toItem);
      } else if (x is List) {
        x.forEach(toItem);
      }
    }
    toItem(w['node']);
    // Bottom detector + listener nodes (callbacks attached below via SDK).
    final detectorDef = findCustomWidget(p, name: 'Visibilitydetector')!;
    final listenerDef = findCustomWidget(p, name: 'GgStatsListener')!;
    Map<String, dynamic> pid(FFCustomWidget d, String n) =>
        d.parameters.firstWhere((x) => x.identifier.name == n).identifier.toProto3Json() as Map<String, dynamic>;
    Map<String, dynamic> dims(FFCustomWidget d) => {
          'paramIdentifier': pid(d, 'dimensions'),
          'widgetProperty': {
            'dimensions': {'width': {'pixelsValue': {'inputValue': 1}}, 'height': {'pixelsValue': {'inputValue': 1}}}
          },
        };
    final detectorKey = 'Container_${key('detector')}';
    final listenerKey = 'Container_${key('listener')}';
    final scroll = find(w['node'], scrollColumn)!;
    (scroll['children'] as List).add({
      'key': detectorKey, 'type': 'Container', 'props': {},
      'customWidgetIdentifier': detectorDef.identifier.toProto3Json(),
      'enforceCustomWidgetDimensions': true,
      'parameterValues': {
        'parameterPasses': {
          pid(detectorDef, 'dimensions')['key']: dims(detectorDef),
          pid(detectorDef, 'visibilityThreshold')['key']: {
            'paramIdentifier': pid(detectorDef, 'visibilityThreshold'),
            'inputValue': {'serializedValue': '0.01'},
          },
        },
        'customWidgetIdentifier': detectorDef.identifier.toProto3Json(),
      },
    });
    (scroll['children'] as List).insert(0, {
      'key': listenerKey, 'type': 'Container', 'props': {},
      'customWidgetIdentifier': listenerDef.identifier.toProto3Json(),
      'enforceCustomWidgetDimensions': true,
      'parameterValues': {
        'parameterPasses': {
          pid(listenerDef, 'dimensions')['key']: dims(listenerDef),
          pid(listenerDef, 'refreshKey')['key']: {
            'paramIdentifier': pid(listenerDef, 'refreshKey'), 'inputValue': {'serializedValue': page}},
          pid(listenerDef, 'tables')['key']: {
            'paramIdentifier': pid(listenerDef, 'tables'), 'inputValue': {'serializedValue': 'posts'}},
        },
        'customWidgetIdentifier': listenerDef.identifier.toProto3Json(),
      },
    });
    final postsManager = (column['databaseRequest']?['requestManagerSettings']?['managerIdentifier']?['key']) as String? ??
        (jsonEncode(entry.value.toProto3Json()).contains('"cckd0"') ? 'cckd0' : null);
    column.remove('databaseRequest');
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;

    // "Clear Query Cache" of the removed posts query (admin organisation
    // add/edit, app block "refresh"): the cache no longer exists; the posts
    // listener keeps the list fresh. Each such node is spliced out of its chain.
    var cleared = 0;
    FFActionNode fix(FFActionNode n) {
      if (n.hasAction() && n.action.hasClearQueryCache() &&
          n.action.clearQueryCache.cacheManagerIdentifier.key == postsManager) {
        cleared++;
        return n.hasFollowUpAction() ? fix(n.followUpAction) : FFActionNode(key: n.key);
      }
      if (n.hasFollowUpAction()) n.followUpAction = fix(n.followUpAction);
      if (n.hasConditionActions()) {
        for (final t in n.conditionActions.trueActions) t.trueAction = fix(t.trueAction);
        if (n.conditionActions.hasFalseAction()) n.conditionActions.falseAction = fix(n.conditionActions.falseAction);
      }
      if (n.hasParallelActions()) {
        final branches = n.parallelActions.actions.map(fix).toList();
        n.parallelActions.actions..clear()..addAll(branches);
      }
      if (n.hasLoopAction() && n.loopAction.hasAction()) n.loopAction.action = fix(n.loopAction.action);
      if (n.hasTryCatchAction()) {
        final t = n.tryCatchAction;
        if (t.hasTryAction()) t.tryAction = fix(t.tryAction);
        if (t.hasCatchAction()) t.catchAction = fix(t.catchAction);
        if (t.hasFinallyAction()) t.finallyAction = fix(t.finallyAction);
      }
      return n;
    }
    void fixBlocks(FFActionComponentsConfig c) {
      for (final b in c.actionComponents) {
        if (b.hasActions() && b.actions.hasRootAction()) b.actions.rootAction = fix(b.actions.rootAction);
      }
    }
    void fixTree(FFNode n) {
      for (final t in n.triggerActions) {
        if (t.hasRootAction()) t.rootAction = fix(t.rootAction);
      }
      for (final c in n.children) fixTree(c);
    }
    if (postsManager != null) {
      fixBlocks(p.appState.actionComponentsConfig);
      for (final wc in p.widgetClasses.values) {
        fixTree(wc.node);
        fixBlocks(wc.classModel.actionComponentsConfig);
      }
    }

    // ---- Action blocks (SDK builders on the materialized class).
    final wc = p.widgetClasses[entry.key]!;
    FFVariable v(Map<String, dynamic> j) => FFVariable()..mergeFromProto3Json(j);
    Map<String, dynamic> st(String n, [List? ops]) => {
          'source': 'LOCAL_STATE',
          'baseVariable': {
            'localState': {
              'fieldIdentifier': wc.classModel.stateFields
                  .firstWhere((f) => f.parameter.identifier.name == n).parameter.identifier.toProto3Json(),
              'stateVariableType': 'WIDGET_CLASS_STATE',
            }
          },
          'nodeKeyRef': {'key': root},
          if (ops != null) 'operations': ops,
        };
    final cache = {
      'source': 'LOCAL_STATE',
      'baseVariable': {'localState': {'fieldIdentifier': cacheId.toProto3Json(), 'stateVariableType': 'APP_STATE'}},
    };
    Map<String, dynamic> fn(String n, List<Map<String, dynamic>> values) => {
          'source': 'FUNCTION_CALL',
          'functionCall': {'customFunction': findCustomFunction(p, name: n)!.identifier.toProto3Json(), 'values': values},
        };
    Map<String, dynamic> lit(Object x) => {'inputValue': {'serializedValue': '$x'}};
    Map<String, dynamic> eq(Map<String, dynamic> a, Object b) => {
          'source': 'FUNCTION_CALL',
          'functionCall': {'condition': {'relation': 'EQUAL_TO'}, 'values': [{'variable': a}, lit(b)]},
        };
    final count = st('ggPosts', [{'listNumItems': {}}]);
    final action = findCustomAction(p, name: 'ggPostsPage')!;
    FFActionNode callPage(String seed, Map<String, dynamic> offset, Map<String, dynamic> limit, String out) {
      final values = FFFunctionCallValues();
      final args = {'offset': offset, 'limit': limit};
      for (final a in action.arguments) {
        values.arguments[a.identifier.key] =
            FFFunctionCallValues_FFArgument(value: FFValue()..mergeFromProto3Json(args[a.identifier.name]!));
      }
      return FFActionNode(
          key: key('$seed.node'),
          action: FFAction(
              key: key('$seed.action'),
              customAction: FFCustomActionCall(customActionIdentifier: action.identifier, argumentValues: values),
              outputVariableName: out));
    }
    FFActionNode chain(List<FFActionNode> nodes) {
      for (var i = 0; i < nodes.length - 1; i++) {
        var t = nodes[i];
        while (t.hasFollowUpAction()) t = t.followUpAction;
        t.followUpAction = nodes[i + 1];
      }
      return nodes.first;
    }
    FFActionNode node(String seed, FFAction a) => FFActionNode(key: key(seed), action: a);

    // ggRefreshPosts
    final refreshCall = callPage('refresh', {'inputValue': {'serializedValue': '0'}},
        {'variable': fn('ggPostsWindow', [{'variable': st('ggPosts')}])}, 'ggPostsOut');
    final refreshOut = varFromActionOutput(actionKey: refreshCall.action.key, outputName: 'ggPostsOut');
    final refreshRoot = chain([
      Actions.conditional(
          condition: v(eq(count, 0)),
          trueActions: node('fromCache', Actions.updatePageState(p, widgetClassName: page, updates: [
            StateFieldUpdate.setFromVariable('ggPosts', v(cache)),
          ]))),
      refreshCall,
      node('refreshSet', Actions.updatePageState(p, widgetClassName: page, updates: [
        StateFieldUpdate.setFromVariable('ggPostsHasMore', v(fn('ggPostsHasMore', [
          {'variable': refreshOut.toProto3Json()},
          {'variable': fn('ggPostsWindow', [{'variable': st('ggPosts')}])},
        ]))),
        StateFieldUpdate.setFromVariable('ggPosts', refreshOut),
      ])),
      node('refreshCache', Actions.updateAppState(p, updates: [
        StateFieldUpdate.setFromVariable('ggPostsCache', v(st('ggPosts'))),
      ])),
    ]);
    final refreshBlock = addActionBlock(p,
        name: 'ggRefreshPosts', rootAction: refreshRoot, widgetClass: wc,
        description: 'Good News: re-read the loaded posts window (min 10).',
        identifier: FFIdentifier(name: 'ggRefreshPosts', key: key('refreshBlock')));

    // ggMorePosts
    final moreCall = callPage('more', {'variable': count}, lit(10), 'ggMoreOut');
    final moreOut = varFromActionOutput(actionKey: moreCall.action.key, outputName: 'ggMoreOut');
    final moreRoot = Actions.conditional(
      condition: v({
        'source': 'FUNCTION_CALL',
        'functionCall': {
          'combineConditions': {'operator': 'AND_OP'},
          'values': [
            {'variable': eq(st('ggPostsHasMore'), true)},
            {'variable': eq(st('ggPostsLoading'), false)},
          ],
        },
      }),
      trueActions: chain([
        node('moreLoading', Actions.updatePageState(p, widgetClassName: page, updates: [
          StateFieldUpdate.set('ggPostsLoading', 'true'),
        ])),
        moreCall,
        node('moreSet', Actions.updatePageState(p, widgetClassName: page, updates: [
          StateFieldUpdate.setFromVariable('ggPostsHasMore', v(fn('ggPostsHasMore', [
            {'variable': moreOut.toProto3Json()},
            lit(10),
          ]))),
          StateFieldUpdate.setFromVariable('ggPosts', v(fn('ggPostsConcat', [
            {'variable': st('ggPosts')},
            {'variable': moreOut.toProto3Json()},
          ]))),
          StateFieldUpdate.set('ggPostsLoading', 'false'),
        ])),
        node('moreCache', Actions.updateAppState(p, updates: [
          StateFieldUpdate.setFromVariable('ggPostsCache', v(st('ggPosts'))),
        ])),
      ]),
    );
    final moreBlock = addActionBlock(p,
        name: 'ggMorePosts', rootAction: moreRoot, widgetClass: wc,
        description: 'Good News: append the next 10 posts.',
        identifier: FFIdentifier(name: 'ggMorePosts', key: key('moreBlock')));
    for (final b in wc.classModel.actionComponentsConfig.actionComponents) {
      if (b.identifier.name != 'ggRefreshPosts' && b.identifier.name != 'ggMorePosts') continue;
      void ref(dynamic x) {
        if (x is FFVariable && x.source == FFVariableSource.ACTION_OUTPUTS) {
          x.actionComponentKeyRef = FFActionComponentKeyReference(key: b.identifier.key);
        }
      }
      void walkNode(FFActionNode n) {
        final j = n.writeToJsonMap();
        if (j.isEmpty) return;
        if (n.hasAction() && n.action.hasLocalStateUpdate()) {
          for (final u in n.action.localStateUpdate.updates) {
            void visit(FFVariable var_) {
              ref(var_);
              if (var_.hasFunctionCall()) {
                for (final val in var_.functionCall.values) {
                  if (val.hasVariable()) visit(val.variable);
                }
              }
            }
            if (u.hasSetValue() && u.setValue.hasVariable()) visit(u.setValue.variable);
          }
        }
        if (n.hasConditionActions()) {
          for (final t in n.conditionActions.trueActions) walkNode(t.trueAction);
        }
        if (n.hasFollowUpAction()) walkNode(n.followUpAction);
      }
      walkNode(b.actions.rootAction);
    }
    FFActionNode exec(String seed, String block) {
      final n = FFActionNode(key: key(seed), action: Actions.executeActionBlock(p, actionBlockName: block, widgetClass: wc));
      n.action.executeActionComponent.shouldSetState = true;
      return n;
    }
    // On Load tail, detector, listener.
    final onLoad = wc.node.triggerActions.firstWhere((t) => t.trigger.triggerType == FFActionTriggerType.ON_INIT_STATE);
    // The chain ends with an empty node: the refresh call takes its place.
    bool empty(FFActionNode n) => !n.hasAction() && !n.hasConditionActions() &&
        !n.hasParallelActions() && !n.hasLoopAction() && !n.hasTryCatchAction() && !n.hasFollowUpAction();
    final call = exec('onLoadRefresh', refreshBlock.name);
    if (empty(onLoad.rootAction)) {
      onLoad.rootAction = call;
    } else {
      var tail = onLoad.rootAction;
      while (tail.hasFollowUpAction() && !empty(tail.followUpAction)) tail = tail.followUpAction;
      tail.followUpAction = call;
    }
    void attach(FFNode n) {
      if (n.key == detectorKey) {
        n.triggerActions.add(FFTriggerActions()
          ..mergeFromProto3Json({'trigger': {'triggerType': 'CALLBACK', 'parameterIdentifier': pid(detectorDef, 'action')}})
          ..rootAction = Actions.conditional(
              condition: v(eq({
                'source': 'ACTION_INPUTS',
                'baseVariable': {'actionInput': {'actionInput': 'ACTION_PARAMETER', 'parameterIdentifier': {'name': 'visible'}}},
                'nodeKeyRef': {'key': detectorKey},
              }, true)),
              trueActions: exec('detectorMore', moreBlock.name)));
      }
      if (n.key == listenerKey) {
        n.triggerActions.add(FFTriggerActions()
          ..mergeFromProto3Json({'trigger': {'triggerType': 'CALLBACK', 'parameterIdentifier': pid(listenerDef, 'onRefresh')}})
          ..rootAction = exec('listenerRefresh', refreshBlock.name));
      }
      for (final c in n.children) attach(c);
    }
    attach(wc.node);
    stdout.writeln('Posts paging: generator over ggPosts ($swapped item refs), '
        'blocks ggRefreshPosts/ggMorePosts, bottom detector, posts listener; '
        'removed $cleared Clear Query Cache of the old posts query ($postsManager).');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PostsPaging()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good News: page-wise posts (10 + load more), memory cache, live refresh',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
