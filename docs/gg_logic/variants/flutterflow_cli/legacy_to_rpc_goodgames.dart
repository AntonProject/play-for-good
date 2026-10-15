// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// GoodGamesPage: switches the remaining legacy client calculations to the v2
// RPC page states (ggRanking / ggMyStats / ggHistory). Only the listed nodes
// change; wrappers/operations around a replaced call are kept.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class LegacyToRpc extends FlutterFlowAITask {
  @override
  String get name => 'gg-goodgames-legacy-to-rpc';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'GoodGamesPage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final page = (w['node'] as Map)['key'];
    final nodes = <String, Map<String, dynamic>>{};
    void index(Map<String, dynamic> n) {
      nodes[n['key'] as String] = n;
      for (final c in (n['children'] as List? ?? [])) index(c as Map<String, dynamic>);
    }
    index(w['node']);
    Map<String, dynamic> fnIdent(String name) =>
        findCustomFunction(p, name: name)!.identifier.toProto3Json() as Map<String, dynamic>;
    Map<String, dynamic> stateVar(String name) {
      final f = ((w['classModel'] as Map)['stateFields'] as List)
          .firstWhere((f) => f['parameter']['identifier']['name'] == name);
      return {
        'source': 'LOCAL_STATE',
        'baseVariable': {
          'localState': {
            'fieldIdentifier': f['parameter']['identifier'],
            'stateVariableType': 'WIDGET_CLASS_STATE',
          }
        },
        'nodeKeyRef': {'key': page},
      };
    }
    Map<String, dynamic> lit(Object v) => {'inputValue': {'serializedValue': '$v'}};
    Map<String, dynamic> call(String fn, List<Map<String, dynamic>> values) =>
        {'customFunction': fnIdent(fn), 'values': values};
    Map<String, dynamic> callVar(String fn, List<Map<String, dynamic>> values) =>
        {'source': 'FUNCTION_CALL', 'functionCall': call(fn, values)};
    final report = <String, int>{};

    // Replace every call of [old] inside a node (not its children) by [next].
    void swap(String key, String old, Map<String, dynamic> next) {
      final node = nodes[key] ?? (throw StateError('$key missing'));
      var n = 0;
      void walk(dynamic x) {
        if (x is Map) {
          final f = x['functionCall'];
          if (f is Map && (f['customFunction'] as Map?)?['name'] == old) {
            x['functionCall'] = jsonDecode(jsonEncode(next));
            n++;
          }
          for (final e in x.entries) {
            if (e.key != 'children') walk(e.value);
          }
        } else if (x is List) {
          x.forEach(walk);
        }
      }
      walk(node);
      if (n == 0) throw StateError('$old not found in $key');
      report['$key:$old'] = n;
    }
    void visible(String key, Map<String, dynamic> variable) {
      final props = nodes[key]!['props'] as Map<String, dynamic>;
      props['visibility'] = {'visibleValue': {'variable': variable}};
      report['$key:visibility'] = 1;
    }

    final ranking = {'variable': stateVar('ggRanking')};
    final history = {'variable': stateVar('ggHistory')};
    // Podium players: top_players, not the current list page.
    for (final k in ['Stack_lspkrsgh', 'Stack_d8ch3pyr', 'Stack_y8g2r7sq',
        'Stack_ff59uepl', 'Stack_9s3qgozx', 'Stack_ymvf9ztj']) {
      swap(k, 'ratingUsersIds', call('ggTopPlayerIds', [ranking]));
    }
    // List generators (fallback branch) and "list not empty" placeholders.
    for (final k in ['ListView_f2ogaegd', 'Column_vukwnj3x',
        'PlaceholderWidget_o7qo5wzq', 'PlaceholderWidget_p5jb2kzp']) {
      swap(k, 'ratingUsersIds', call('ggRankingPlayerIds', [ranking]));
    }
    // Pinned "me" row (signed-in branch): only when I am not on this page.
    for (final k in ['Container_hsks3evp', 'Divider_5m77xyn5']) {
      visible(k, callVar('ggShowMeRow', [ranking]));
    }
    // Guest pinned demo row: the same place as Home/profile (guest_rank).
    final guestPasses = nodes['Container_spkska2u']!['parameterValues']['parameterPasses'] as Map;
    (guestPasses['phsgpm'] as Map)['variable'] = callVar('ggPlace', [ranking]);
    report['Container_spkska2u:rating'] = 1;
    // Meine Games list + empty states.
    for (final k in ['Column_h1seev6d', 'Column_ogpjzbyv', 'Row_fuk7zgol',
        'PlaceholderWidget_vlukxtqx', 'Row_aek85h6y', 'PlaceholderWidget_30dg7q6w']) {
      swap(k, 'filterAllGames', call('ggGamesRows', [history]));
    }
    // Meine Games pagination: next page exists, or we are past page 1.
    final pastFirst = {
      'source': 'FUNCTION_CALL',
      'functionCall': {
        'condition': {'relation': 'GREATER_THAN'},
        'values': [
          {'variable': stateVar('pageNumberGames')..['defaultValue'] = {'serializedValue': '1'}},
          lit(1),
        ],
      },
    };
    for (final k in ['Container_stxosst7', 'Column_y4p13zno', 'Container_uf5h5mk1', 'Column_e38xpd0i']) {
      final s = jsonEncode(nodes[k]!['props']['visibility']);
      // The block-level condition asks for page 1; the "next" button for the current page.
      final blockLevel = s.contains('"pageNumberGames"') == false;
      visible(k, blockLevel
          ? {
              'source': 'FUNCTION_CALL',
              'functionCall': {
                'combineConditions': {'operator': 'OR_OP'},
                'values': [
                  {'variable': callVar('ggHasMore', [history])},
                  {'variable': pastFirst},
                ],
              },
            }
          : callVar('ggHasMore', [history]));
    }
    // Meine Games: €nergy per game place from the profile stats RPC.
    swap('Text_jmkc3tqq', 'ratingUserGamesByGoodEnergyPerGame', call('ggMetricRank', [
      {'variable': stateVar('ggMyStats')},
      lit('good_energy_per_game'),
      lit(false),
    ]));

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('Replaced: ${report.length} bindings\n${report.keys.join('\n')}');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [LegacyToRpc()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games: podium, list, Meine Games and pagination from RPC',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
