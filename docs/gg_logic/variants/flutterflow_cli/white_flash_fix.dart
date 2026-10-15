// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// White flash when a page with a red header opens.
//  1. Splash On Load starts ggPrecacheHeaders (not awaited): the big header
//     backgrounds are decoded before any page needs them (a red underlay is not
//     possible: the images have a transparent curved bottom).
//  2. HomePage: the whole page waited for a "users" query (transparent loader =
//     white screen) used for one value, chosen_org. The query is removed; the
//     value reads page state ggMe, loaded by ggRefreshMe (signed in only), run
//     in parallel with the other On Load blocks. The shared current-user cache
//     (and its Clear Query Cache calls) stays.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.whiteflash.$seed');
const homeQuery = 'Column_ab3b63xw';

final class WhiteFlashFix extends FlutterFlowAITask {
  @override
  String get name => 'gg-white-flash-fix';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];

    // 1. Splash: precache, not awaited, first in On Load.
    final splash = p.widgetClasses.values.firstWhere((w) => w.name == 'splash');
    final onLoad = splash.node.triggerActions.firstWhere((t) => t.trigger.triggerType == FFActionTriggerType.ON_INIT_STATE);
    if (jsonEncode(onLoad.toProto3Json()).contains('ggPrecacheHeaders')) throw StateError('Splash already precaches');
    final pre = findCustomAction(p, name: 'ggPrecacheHeaders')!;
    final call = FFActionNode(
        key: key('splash.node'),
        action: FFAction(
            key: key('splash.action'),
            customAction: FFCustomActionCall(customActionIdentifier: pre.identifier, argumentValues: FFFunctionCallValues()),
            nonBlocking: true));
    call.followUpAction = onLoad.rootAction;
    onLoad.rootAction = call;
    report.add('Splash: ggPrecacheHeaders first in On Load (not awaited)');

    // 2. Home: query -> ggMe.
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'HomePage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final root = (w['node'] as Map)['key'] as String;
    Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
      if (n['key'] == k) return n;
      for (final c in (n['children'] as List? ?? [])) {
        final r = find(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    final host = find(w['node'], homeQuery) ?? (throw StateError('$homeQuery not found'));
    final dr = jsonEncode(host['databaseRequest']);
    if (!dr.contains('"name":"users"') || !dr.contains('SUPABASE_AUTH_USER')) throw StateError('Not the my-profile query');
    final stateIdent = {'name': 'ggMe', 'key': key('home.state')};
    ((w['classModel'] as Map)['stateFields'] as List).add({
      'parameter': {
        'identifier': stateIdent,
        'dataType': {'scalarType': 'PostgresRow', 'subType': {'tableIdentifier': {'name': 'users'}}},
      }
    });
    var refs = 0;
    void rewrite(dynamic x) {
      if (x is Map<String, dynamic>) {
        if (x['source'] == 'POSTGRES_QUERY' && x['nodeKeyRef']?['key'] == homeQuery) {
          final keep = {for (final k in ['operations', 'defaultValue', 'uiBuilderValue']) if (x[k] != null) k: x[k]};
          x
            ..clear()
            ..addAll({
              'source': 'LOCAL_STATE',
              'baseVariable': {'localState': {'fieldIdentifier': stateIdent, 'stateVariableType': 'WIDGET_CLASS_STATE'}},
              'nodeKeyRef': {'key': root},
            })
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
    if (refs == 0) throw StateError('No uses of the Home profile query');
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    final wc = p.widgetClasses[entry.key]!;

    final me = findCustomAction(p, name: 'ggMe')!;
    final meCall = FFActionNode(
        key: key('home.call.node'),
        action: FFAction(
            key: key('home.call.action'),
            customAction: FFCustomActionCall(customActionIdentifier: me.identifier, argumentValues: FFFunctionCallValues()),
            outputVariableName: 'ggMeOut'));
    final out = varFromActionOutput(actionKey: meCall.action.key, outputName: 'ggMeOut')
      ..actionComponentKeyRef = FFActionComponentKeyReference(key: key('home.block'));
    meCall.followUpAction = FFActionNode(
        key: key('home.set'),
        action: Actions.updatePageState(p, widgetClassName: 'HomePage', updates: [
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
        rootAction: Actions.conditional(condition: signedIn, trueActions: meCall),
        widgetClass: wc,
        description: 'Home: my profile row (signed in only).',
        identifier: FFIdentifier(name: 'ggRefreshMe', key: key('home.block')));
    final exec = FFActionNode(
        key: key('home.exec'),
        action: Actions.executeActionBlock(p, actionBlockName: block.name, widgetClass: wc));
    exec.action.executeActionComponent.shouldSetState = true;
    final homeLoad = wc.node.triggerActions.firstWhere((t) => t.trigger.triggerType == FFActionTriggerType.ON_INIT_STATE);
    FFActionNode? parallel;
    for (FFActionNode? n = homeLoad.rootAction; n != null; n = n.hasFollowUpAction() ? n.followUpAction : null) {
      if (n.hasParallelActions() &&
          jsonEncode(n.toProto3Json()).contains('"ggRefreshMyInvites"')) {
        parallel = n;
      }
    }
    if (parallel == null) throw StateError('Home On Load: parallel invites/games node not found');
    parallel.parallelActions.actions.add(exec);
    report.add('HomePage: profile query removed ($refs uses -> ggMe), ggRefreshMe in the On Load parallel');
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [WhiteFlashFix()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'No white flash: precache header images; Home without the profile query wrapper',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
