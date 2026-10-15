// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Applies build_ui_overlay.py output for the chosen scopes and wires the real
// v2 actions (no fixtures). Replaces the earlier preview-based push_ui.dart.
//   dart run dsl/gg_push_bindings.dart --scopes GoodGamesPage,gamesUserComp,goodGamesPlayersFilters [--apply]
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const projectId = 'play-for-good-o0lpcq';
const overlayPath = '/private/tmp/pfg-ui-overlay.json';
// The seed must include the role (node/action/set...): equal seeds produced
// equal keys and FF codegen cut the chain after the first action.
FFIdentifier id(String name, String seed) => FFIdentifier(
    name: name,
    key: generateRandomAlphaNumericString(seedString: 'pfg.gg.bind.$name.$seed'));
FFValue literal(Object v) =>
    FFValue(inputValue: FFParameterValue(serializedValue: v.toString()));
FFVariable state(FFWidgetClass w, String name) => varFromPageState(w
    .classModel.stateFields
    .firstWhere((f) => f.parameter.identifier.name == name)
    .parameter
    .identifier)
  ..nodeKeyRef = FFNodeKeyReference(key: w.node.key);
FFVariable param(FFWidgetClass w, String name) => FFVariable(
    source: FFVariableSource.WIDGET_CLASS_PARAMETER,
    baseVariable: FFBaseVariable(
        widgetClass: FFWidgetClassVariable(
            paramIdentifier: w.params.values
                .firstWhere((p) => p.identifier.name == name)
                .identifier)),
    nodeKeyRef: FFNodeKeyReference(key: w.node.key));
FFVariable jsonPath(FFVariable v, String path, FFBaseDataType type) =>
    v.deepCopy()
      ..operations.add(FFVariableOperation(
          jsonPathOperation: FFJsonPathOperation(
              jsonPath: path,
              returnParameter: FFParameter(
                  dataType: FFDataTypeV2(scalarType: type)))));
FFVariable func(FFProject p, String name, List<FFValue> args) => FFVariable(
    source: FFVariableSource.FUNCTION_CALL,
    functionCall: FFFunctionCall(
        customFunction: findCustomFunction(p, name: name)!.identifier,
        values: args));

// Calls [block] after On Load (once, at the end) and after every update of the
// watched states outside On Load; each call rebuilds the page.
void attachRefresh(FFProject p, FFWidgetClass w, String block, List<String> watchedNames, String seed) {
  final watched = w.classModel.stateFields
      .where((f) => watchedNames.contains(f.parameter.identifier.name))
      .map((f) => f.parameter.identifier.key)
      .toSet();
  var i = 0;
  FFActionNode refresh() {
    final node = FFActionNode(
        key: id('refresh', '$seed${i++}').key,
        action: Actions.executeActionBlock(p, actionBlockName: block, widgetClass: w));
    node.action.executeActionComponent.shouldSetState = true;
    return node;
  }
  FFActionNode tail(FFActionNode n) {
    var t = n;
    while (t.hasFollowUpAction()) t = t.followUpAction;
    return t;
  }
  void inspect(FFActionNode node) {
    if (node.hasFollowUpAction()) inspect(node.followUpAction);
    if (node.hasConditionActions()) {
      for (final b in node.conditionActions.trueActions) inspect(b.trueAction);
      if (node.conditionActions.hasFalseAction()) inspect(node.conditionActions.falseAction);
    }
    if (node.hasAction() && node.action.hasLocalStateUpdate() &&
        node.action.localStateUpdate.updates.any((u) => watched.contains(u.fieldIdentifier.key))) {
      final next = node.hasFollowUpAction() ? node.followUpAction : null;
      node.followUpAction = refresh();
      if (next != null) node.followUpAction.followUpAction = next;
    }
    if (node.hasAction() && node.action.hasBottomSheet()) {
      for (final pass in node.action.bottomSheet.passedParameters.parameterPasses.values) {
        if (pass.hasAction()) inspect(pass.action.rootAction);
      }
    }
  }
  void walk(FFNode n, bool root) {
    for (final t in n.triggerActions) {
      if (root && t.trigger.triggerType == FFActionTriggerType.ON_INIT_STATE) {
        tail(t.rootAction).followUpAction = refresh();
      } else {
        inspect(t.rootAction);
      }
    }
    for (final pass in n.parameterValues.parameterPasses.values) {
      if (pass.hasAction()) inspect(pass.action.rootAction);
    }
    for (final c in n.children) walk(c, false);
  }
  walk(w.node, true);
  stdout.writeln('${w.name}: $block attached at $i points.');
}

final class BindGoodGames extends FlutterFlowAITask {
  BindGoodGames(this.scopes, {this.replaceOwn = false});
  final List<String> scopes;
  // Only after checking that the live revision is our own previous push.
  final bool replaceOwn;
  @override
  String get name => 'bind-good-games-rpc';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final overlay = jsonDecode(File(overlayPath).readAsStringSync()) as Map;
    final before = overlay['before'] as Map;
    final after = overlay['after'] as Map;
    final untouched = {
      for (final e in p.widgetClasses.entries)
        if (!scopes.contains(e.value.name))
          e.key: base64Encode(e.value.writeToBuffer())
    };
    for (final scope in scopes) {
      final old = p.widgetClasses.values.firstWhere((w) => w.name == scope);
      if (jsonEncode(old.toProto3Json()) != jsonEncode(before[scope]) && !replaceOwn) {
        throw StateError('$scope changed in FF since the snapshot; rebuild the overlay.');
      }
      final next = FFWidgetClass()..mergeFromProto3Json(after[scope]);
      restoreUnknownFields(old, next);
      p.widgetClasses[old.node.key] = next;
    }
    final test = varFromEnvironmentSecret('test')
      ..baseVariable.environmentValue.identifier =
          findEnvironmentValue(p, 'test')!.parameter.identifier;
    final uid = varFromSupabaseAuthUser(FFAuthVariable_AuthProperty.USER_ID);

    FFActionNode call(FFWidgetClass w, String action, String seed,
        Map<String, FFValue> args, List<StateFieldUpdate> Function(FFVariable) updates) {
      final a = findCustomAction(p, name: action)!;
      final key = id('action', '${w.name}$seed').key;
      final out = 'gg${seed}Out';
      final values = FFFunctionCallValues();
      for (final arg in a.arguments) {
        values.arguments[arg.identifier.key] =
            FFFunctionCallValues_FFArgument(value: args[arg.identifier.name]!);
      }
      final root = FFActionNode(
          key: id('node', '${w.name}$seed').key,
          action: FFAction(
              key: key,
              customAction: FFCustomActionCall(
                  customActionIdentifier: a.identifier, argumentValues: values),
              outputVariableName: out));
      root.followUpAction = FFActionNode(
          key: id('set', '${w.name}$seed').key,
          action: Actions.updatePageState(p,
              widgetClassName: w.name,
              updates: updates(varFromActionOutput(actionKey: key, outputName: out))));
      return root;
    }

    FFActionNode tail(FFActionNode n) {
      var t = n;
      while (t.hasFollowUpAction()) t = t.followUpAction;
      return t;
    }

    if (scopes.contains('GoodGamesPage')) {
      final w = p.widgetClasses.values.firstWhere((w) => w.name == 'GoodGamesPage');
      FFValue st(String n, [Object? fallback]) {
        final v = state(w, n);
        if (fallback != null) v.defaultValue = FFParameterValue(serializedValue: '$fallback');
        return FFValue(variable: v);
      }
      final ranking = call(w, 'ggV2Rankings', 'Ranking', {
        'period': FFValue(variable: func(p, 'ggPeriodKey', [st('periodPageUser')])),
        'category': st('valuePageUser', 'valuable'),
        'page': st('pageNumberUsers', 1),
        'pageSize': literal(10),
        'userId': FFValue(variable: uid),
        'test': FFValue(variable: test),
      }, (out) => [
            StateFieldUpdate.setFromVariable('ggRanking', out),
            StateFieldUpdate.setFromVariable(
                'periodPageUser', jsonPath(out, r'$.period.key', FFBaseDataType.String)),
          ]);
      final stats = call(w, 'ggV2ProfileStats', 'MyStats', {
        'userId': FFValue(variable: uid),
        'period': FFValue(variable: func(p, 'ggPeriodKey', [st('periodPageGame')])),
        'test': FFValue(variable: test),
      }, (out) => [
            StateFieldUpdate.setFromVariable('ggMyStats', out),
            StateFieldUpdate.setFromVariable(
                'periodPageGame', jsonPath(out, r'$.period.key', FFBaseDataType.String)),
          ]);
      tail(stats).followUpAction = call(w, 'ggV2Games', 'History', {
        'userId': FFValue(variable: uid),
        'period': FFValue(variable: func(p, 'ggPeriodKey', [st('periodPageGame')])),
        'category': st('valuePageGame', 'valuable'),
        'page': st('pageNumberGames', 1),
        'pageSize': literal(10),
        'test': FFValue(variable: test),
      }, (out) => [StateFieldUpdate.setFromVariable('ggHistory', out)]);
      // Personal Meine Games data only for a signed-in user; guests keep demo UI.
      tail(ranking).followUpAction = Actions.conditional(
          condition: varFromGlobalProp(
              FFGlobalPropertiesVariable_GlobalProperty.IS_USER_LOGGED_IN),
          trueActions: stats);
      final block = addActionBlock(p,
          name: 'ggRefreshGoodGames',
          rootAction: ranking,
          widgetClass: w,
          description: 'Good Games v2: ranking + Meine Games via RPC (Environment.test).',
          identifier: id('ggRefreshGoodGames', 'GoodGamesPage.block'));
      FFActionNode refresh(String seed) => FFActionNode(
          key: id('refresh', 'GoodGamesPage$seed').key,
          action: Actions.executeActionBlock(p,
              actionBlockName: block.name, widgetClass: w));
      // Refresh after On Load and after every filter/page/tab state update.
      final watched = w.classModel.stateFields
          .where((f) => [
                'periodPageUser', 'periodPageGame', 'valuePageUser', 'valuePageGame',
                'pageNumberUsers', 'pageNumberGames', 'tab',
              ].contains(f.parameter.identifier.name))
          .map((f) => f.parameter.identifier.key)
          .toSet();
      var hooks = 0;
      void inspect(FFActionNode node) {
        if (node.hasFollowUpAction()) inspect(node.followUpAction);
        if (node.hasConditionActions()) {
          for (final b in node.conditionActions.trueActions) inspect(b.trueAction);
          if (node.conditionActions.hasFalseAction()) inspect(node.conditionActions.falseAction);
        }
        if (node.hasAction() &&
            node.action.hasLocalStateUpdate() &&
            node.action.localStateUpdate.updates
                .any((u) => watched.contains(u.fieldIdentifier.key))) {
          tail(node).followUpAction = refresh('update${node.key}');
          hooks++;
        }
        if (node.hasAction() && node.action.hasBottomSheet()) {
          for (final pass in node.action.bottomSheet.passedParameters.parameterPasses.values) {
            if (pass.hasAction()) inspect(pass.action.rootAction);
          }
        }
      }
      void walk(FFNode n) {
        for (final t in n.triggerActions) {
          inspect(t.rootAction);
          if (n.key == w.node.key && t.trigger.triggerType == FFActionTriggerType.ON_INIT_STATE) {
            tail(t.rootAction).followUpAction = refresh('onLoad');
            hooks++;
          }
        }
        for (final pass in n.parameterValues.parameterPasses.values) {
          if (pass.hasAction()) inspect(pass.action.rootAction);
        }
        for (final c in n.children) walk(c);
      }
      walk(w.node);
      stdout.writeln('GoodGamesPage: refresh block attached at $hooks points.');
    }

    // Profile page + profile dialog: own/other profile via ggV2ProfileStats,
    // guest (userId 'guest') via the ranking RPC for its place (ggGuest).
    for (final scope in ['userProfilePage', 'userProfile']) {
      if (!scopes.contains(scope)) continue;
      final w = p.widgetClasses.values.firstWhere((w) => w.name == scope);
      final userId = param(w, 'userId');
      final period = state(w, 'infoStatsPeriod');
      final stats = call(w, 'ggV2ProfileStats', 'Profile', {
        'userId': FFValue(variable: userId),
        'period': FFValue(variable: func(p, 'ggPeriodKey', [FFValue(variable: period)])),
        'test': FFValue(variable: test),
      }, (out) => [
            StateFieldUpdate.setFromVariable('ggProfile', out),
            StateFieldUpdate.setFromVariable(
                'infoStatsPeriod', jsonPath(out, r'$.period.key', FFBaseDataType.String)),
          ]);
      final guest = call(w, 'ggV2Rankings', 'Guest', {
        'period': literal('all_time'),
        'category': literal('valuable'),
        'page': literal(1),
        'pageSize': literal(1),
        'userId': literal('guest'),
        'test': FFValue(variable: test),
      }, (out) => [StateFieldUpdate.setFromVariable('ggGuest', out)]);
      final notGuest = FFVariable(
          source: FFVariableSource.FUNCTION_CALL,
          functionCall: FFFunctionCall(
              condition: FFCondition(relation: FFCondition_Relation.NOT_EQUAL_TO),
              values: [FFValue(variable: userId), literal('guest')]));
      final root = Actions.conditional(
          condition: notGuest, trueActions: stats, falseActions: guest);
      final block = addActionBlock(p,
          name: 'ggRefreshProfile',
          rootAction: root,
          widgetClass: w,
          description: 'Profile v2: stats via RPC; guest place via ranking RPC.',
          identifier: id('ggRefreshProfile', '$scope.block'));
      attachRefresh(p, w, block.name, ['infoStatsPeriod'], 'profile$scope');
    }

    for (final e in untouched.entries) {
      if (base64Encode(p.widgetClasses[e.key]!.writeToBuffer()) != e.value) {
        throw StateError('Unexpected edit outside requested scopes');
      }
    }
    stdout.writeln('Bindings prepared for: $scopes');
  }
}

Future<void> main(List<String> args) async {
  String? option(String k) {
    final i = args.indexOf(k);
    return i < 0 || i + 1 >= args.length ? null : args[i + 1];
  }
  final scopes = (option('--scopes') ?? 'GoodGamesPage,gamesUserComp,goodGamesPlayersFilters').split(',');
  final apply = args.contains('--apply');
  final key = Platform.environment['FF_API_KEY'] ?? Platform.environment['FLUTTERFLOW_API_KEY'];
  if (key == null || key.isEmpty) throw StateError('FlutterFlow key missing');
  final result = await FlutterFlowAIPipeline(
    apiKey: key,
    project: PipelineProject.existing(projectId),
    tasks: [BindGoodGames(scopes, replaceOwn: args.contains('--replace-own-push'))],
    source: PipelineSource.paths([Platform.script.toFilePath(), overlayPath]),
    commitMessage: 'Good Games v2 native bindings via RPC: $scopes',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
