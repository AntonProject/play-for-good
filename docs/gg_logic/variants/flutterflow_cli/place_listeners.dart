// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Places a 1x1 GgStatsListener on the screens that show RPC data. On a DB
// change (filtered by table), on return to the page and on app resume it
// runs the screen's refresh action block. Inserted as the first child of the
// screen's main scroll column(s); ConditionalBuilder branches get one each
// (only one branch is built at a time).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const statsTables = 'games,invites,users,point_awards,seasons';
const targets = {
  // scope: [refresh block, tables]
  'GoodGamesPage': ['ggRefreshGoodGames', statsTables],
  'userProfilePage': ['ggRefreshProfile', statsTables],
  'userProfile': ['ggRefreshProfile', statsTables],
  'homePageScore': ['ggRefreshHomeRank', 'games,invites,point_awards'],
};

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.listener.$seed');

final class PlaceListeners extends FlutterFlowAITask {
  @override
  String get name => 'gg-place-listeners';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final def = findCustomWidget(p, name: 'GgStatsListener')!;
    final defJson = def.identifier.toProto3Json();
    Map<String, dynamic> param(String n) =>
        def.parameters.firstWhere((x) => x.identifier.name == n).identifier.toProto3Json() as Map<String, dynamic>;
    final report = <String>[];
    for (final scope in targets.keys) {
      final blockName = targets[scope]![0];
      final tables = targets[scope]![1];
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      if (jsonEncode(w).contains('"name":"GgStatsListener"')) throw StateError('$scope already has a listener');
      // Hosts: outermost vertical scroll columns; fallback the first Column.
      final hosts = <Map<String, dynamic>>[];
      void scroll(Map<String, dynamic> n, bool inside) {
        final isScroll = n['type'] == 'Column' && (n['props']?['column']?['scrollable'] == true);
        if (isScroll && !inside) hosts.add(n);
        for (final c in (n['children'] as List? ?? [])) scroll(c as Map<String, dynamic>, inside || isScroll);
      }
      scroll(w['node'], false);
      if (hosts.isEmpty) {
        final queue = <Map<String, dynamic>>[w['node']];
        while (queue.isNotEmpty) {
          final n = queue.removeAt(0);
          if (n['type'] == 'Column') {
            hosts.add(n);
            break;
          }
          queue.addAll((n['children'] as List? ?? []).cast<Map<String, dynamic>>());
        }
      }
      if (hosts.isEmpty) throw StateError('$scope: no host column');
      var i = 0;
      for (final host in hosts) {
        final nodeKey = 'Container_${key('$scope${i++}')}';
        (host['children'] as List).insert(0, {
          'key': nodeKey,
          'type': 'Container',
          'props': {},
          'customWidgetIdentifier': defJson,
          'enforceCustomWidgetDimensions': true,
          'parameterValues': {
            'parameterPasses': {
              param('dimensions')['key']: {
                'paramIdentifier': param('dimensions'),
                'widgetProperty': {
                  'dimensions': {
                    'width': {'pixelsValue': {'inputValue': 1}},
                    'height': {'pixelsValue': {'inputValue': 1}},
                  }
                },
              },
              param('refreshKey')['key']: {
                'paramIdentifier': param('refreshKey'),
                'inputValue': {'serializedValue': scope},
              },
              param('tables')['key']: {
                'paramIdentifier': param('tables'),
                'inputValue': {'serializedValue': tables},
              },
            },
            'customWidgetIdentifier': defJson,
          },
          '__refresh__': blockName,
        });
        report.add('$scope -> ${host['key']} ($blockName)');
      }
      // Materialize, then attach the onRefresh callback with SDK builders.
      final pending = <String>[];
      void strip(Map<String, dynamic> n) {
        if (n.remove('__refresh__') != null) pending.add(n['key'] as String);
        for (final c in (n['children'] as List? ?? [])) strip(c as Map<String, dynamic>);
      }
      strip(w['node']);
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      void attach(FFNode n) {
        if (pending.contains(n.key)) {
          final call = FFActionNode(
              key: key('${n.key}call'),
              action: Actions.executeActionBlock(p, actionBlockName: blockName, widgetClass: next));
          call.action.executeActionComponent.shouldSetState = true;
          n.triggerActions.add(FFTriggerActions()
            ..mergeFromProto3Json({
              'trigger': {'triggerType': 'CALLBACK', 'parameterIdentifier': param('onRefresh')}
            })
            ..rootAction = call);
        }
        for (final c in n.children) attach(c);
      }
      attach(next.node);
    }
    stdout.writeln('Listeners placed:\n${report.join('\n')}');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PlaceListeners()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Live refresh: GgStatsListener on Good Games, profile and Home',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
