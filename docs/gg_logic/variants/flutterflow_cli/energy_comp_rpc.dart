// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// energyComp (Good Energy header): values and places from gg_v2_profile_stats
// instead of downloading all completed games + my invites.
//  * states ggEnergyWeek / ggEnergyMonth / ggEnergyAll (JSON), filled by the
//    block ggRefreshEnergy: signed in -> 3 RPC calls in parallel
//    (this_week, this_month, all_time); guest -> nothing, so the texts show
//    0 / #0 exactly like energyCompGuest;
//  * on init + GgStatsListener (games, invites, point_awards) run the block;
//  * texts (wrappers/formats kept):
//      totalSumPeriodGoodEnergy(games, P)          -> ggMetricValue(P, 'good_energy')
//      ratingUser(games, me, P, valuable, invites) -> ggMetricRank(P, 'good_power')
//      ratingUserGamesByGoodEnergy(games, me, P)   -> ggMetricRank(P, 'good_energy')
//    Good Energy = user+team+sieg money + additional donation, same as legacy.
//    Places follow the server rule used everywhere (ties: recent activity first).
//  * both queries are removed.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'energyComp';
const hostColumn = 'Column_x34s55ga';
const periods = {'woche': ['ggEnergyWeek', 'this_week'], 'monat': ['ggEnergyMonth', 'this_month'], 'gesamt': ['ggEnergyAll', 'all_time']};
String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.energycomp.$seed');

final class EnergyCompRpc extends FlutterFlowAITask {
  @override
  String get name => 'gg-energy-comp-rpc';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    if (jsonEncode(w).contains('ggEnergyWeek')) throw StateError('Already applied');
    final root = (w['node'] as Map)['key'] as String;
    final model = (w['classModel'] ??= <String, dynamic>{}) as Map<String, dynamic>;
    final fields = (model['stateFields'] ??= []) as List;
    final ident = <String, Map<String, dynamic>>{};
    for (final s in periods.values) {
      ident[s[0]] = {'name': s[0], 'key': key('state.${s[0]}')};
      fields.add({
        'parameter': {'identifier': ident[s[0]], 'dataType': {'scalarType': 'JSON'}}
      });
    }
    Map<String, dynamic> st(String n) => {
          'source': 'LOCAL_STATE',
          'baseVariable': {'localState': {'fieldIdentifier': ident[n], 'stateVariableType': 'WIDGET_CLASS_STATE'}},
          'nodeKeyRef': {'key': root},
        };
    Map<String, dynamic> fnIdent(String n) =>
        findCustomFunction(p, name: n)!.identifier.toProto3Json() as Map<String, dynamic>;

    // Texts.
    final counts = <String, int>{};
    String periodOf(Map fc, int i) {
      final v = (fc['values'] as List)[i]['variable'];
      final e = v?['baseVariable']?['enumVariable']?['enumElementIdentifier']?['name'];
      if (!periods.containsKey(e)) throw StateError('Unexpected period $e');
      return e as String;
    }
    void rewrite(dynamic x) {
      if (x is Map<String, dynamic>) {
        final fc = x['functionCall'];
        final name = fc is Map ? (fc['customFunction']?['name']) : null;
        Map<String, dynamic>? next;
        if (name == 'totalSumPeriodGoodEnergy' || name == 'totalSumPeriodGoodPower') {
          final per = periodOf(fc as Map, 1);
          next = {
            'customFunction': fnIdent('ggMetricValue'),
            'values': [
              {'variable': st(periods[per]![0])},
              {'inputValue': {'serializedValue': 'good_energy'}},
              {'inputValue': {'serializedValue': 'false'}},
            ],
          };
          counts['value.$per'] = (counts['value.$per'] ?? 0) + 1;
        } else if (name == 'ratingUser' || name == 'ratingUserLichtwatt') {
          final per = periodOf(fc as Map, 2);
          if (!jsonEncode((fc['values'] as List)[3]).contains('"valuable"')) throw StateError('ratingUser not valuable');
          next = {
            'customFunction': fnIdent('ggMetricRank'),
            'values': [
              {'variable': st(periods[per]![0])},
              {'inputValue': {'serializedValue': 'good_power'}},
              {'inputValue': {'serializedValue': 'false'}},
            ],
          };
          counts['powerRank.$per'] = (counts['powerRank.$per'] ?? 0) + 1;
        } else if (name == 'ratingUserGamesByGoodEnergy') {
          final per = periodOf(fc as Map, 2);
          next = {
            'customFunction': fnIdent('ggMetricRank'),
            'values': [
              {'variable': st(periods[per]![0])},
              {'inputValue': {'serializedValue': 'good_energy'}},
              {'inputValue': {'serializedValue': 'false'}},
            ],
          };
          counts['energyRank.$per'] = (counts['energyRank.$per'] ?? 0) + 1;
        }
        if (next != null) {
          x['functionCall'] = next;
          return;
        }
        x.values.forEach(rewrite);
      } else if (x is List) {
        x.forEach(rewrite);
      }
    }
    rewrite(w['node']);
    if (counts.values.fold(0, (a, b) => a + b) != 6) throw StateError('Expected 6 texts, got $counts');

    // Queries out.
    final removed = <String>[];
    void q(Map<String, dynamic> n) {
      if (n.remove('databaseRequest') != null) removed.add(n['key'] as String);
      for (final c in (n['children'] as List? ?? [])) q(c as Map<String, dynamic>);
    }
    q(w['node']);
    final left = <String>[];
    void scan(dynamic x) {
      if (x is Map) {
        if (x['source'] == 'POSTGRES_QUERY' && removed.contains(x['nodeKeyRef']?['key'])) left.add('${x['nodeKeyRef']['key']}');
        x.values.forEach(scan);
      } else if (x is List) {
        x.forEach(scan);
      }
    }
    scan(w);
    if (removed.length != 2 || left.isNotEmpty) throw StateError('Queries: removed $removed, refs left $left');

    // Listener node (callback attached below).
    final def = findCustomWidget(p, name: 'GgStatsListener')!;
    Map<String, dynamic> pid(String n) =>
        def.parameters.firstWhere((x) => x.identifier.name == n).identifier.toProto3Json() as Map<String, dynamic>;
    final listenerKey = 'Container_${key('listener')}';
    Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
      if (n['key'] == k) return n;
      for (final c in (n['children'] as List? ?? [])) {
        final r = find(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    (find(w['node'], hostColumn)!['children'] as List).insert(0, {
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
          pid('tables')['key']: {'paramIdentifier': pid('tables'), 'inputValue': {'serializedValue': 'games,invites,point_awards'}},
        },
        'customWidgetIdentifier': def.identifier.toProto3Json(),
      },
    });

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    final wc = p.widgetClasses[entry.key]!;

    // Block: signed in -> 3 calls in parallel, each sets its state.
    final action = findCustomAction(p, name: 'ggV2ProfileStats')!;
    final env = findEnvironmentValue(p, 'test')!.parameter.identifier.toProto3Json();
    FFActionNode call(String per) {
      final s = periods[per]!;
      final args = {
        'userId': {'variable': {'source': 'SUPABASE_AUTH_USER', 'baseVariable': {'auth': {'property': 'USER_ID'}}}},
        'period': {'inputValue': {'serializedValue': s[1]}},
        'test': {'variable': {'source': 'DEV_ENVIRONMENT', 'baseVariable': {'environmentValue': {'identifier': env}}}},
      };
      final values = FFFunctionCallValues();
      for (final a in action.arguments) {
        values.arguments[a.identifier.key] =
            FFFunctionCallValues_FFArgument(value: FFValue()..mergeFromProto3Json(args[a.identifier.name]!));
      }
      final out = '${s[0]}Out';
      final n = FFActionNode(
          key: key('$per.call.node'),
          action: FFAction(
              key: key('$per.call.action'),
              customAction: FFCustomActionCall(customActionIdentifier: action.identifier, argumentValues: values),
              outputVariableName: out));
      final outVar = varFromActionOutput(actionKey: n.action.key, outputName: out)
        ..actionComponentKeyRef = FFActionComponentKeyReference(key: key('block'));
      n.followUpAction = FFActionNode(
          key: key('$per.set'),
          action: Actions.updatePageState(p, widgetClassName: scope, updates: [
            StateFieldUpdate.setFromVariable(s[0], outVar),
          ]));
      return n;
    }
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
    final rootAction = Actions.conditional(
        condition: signedIn, trueActions: Actions.parallel([for (final per in periods.keys) call(per)]));
    final block = addActionBlock(p,
        name: 'ggRefreshEnergy', rootAction: rootAction, widgetClass: wc,
        description: 'Good Energy header: my week / month / all-time stats (signed in only).',
        identifier: FFIdentifier(name: 'ggRefreshEnergy', key: key('block')));
    FFActionNode exec(String seed) {
      final n = FFActionNode(key: key(seed), action: Actions.executeActionBlock(p, actionBlockName: block.name, widgetClass: wc));
      n.action.executeActionComponent.shouldSetState = true;
      return n;
    }
    wc.node.triggerActions.add(FFTriggerActions()
      ..mergeFromProto3Json({'trigger': {'triggerType': 'ON_INIT_STATE'}})
      ..rootAction = exec('init'));
    void attach(FFNode n) {
      if (n.key == listenerKey) {
        n.triggerActions.add(FFTriggerActions()
          ..mergeFromProto3Json({'trigger': {'triggerType': 'CALLBACK', 'parameterIdentifier': pid('onRefresh')}})
          ..rootAction = exec('listener'));
      }
      for (final c in n.children) attach(c);
    }
    attach(wc.node);
    stdout.writeln('energyComp: texts $counts; removed queries $removed; block ggRefreshEnergy on init + listener');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [EnergyCompRpc()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'energyComp: Good Energy and places from gg_v2_profile_stats',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
