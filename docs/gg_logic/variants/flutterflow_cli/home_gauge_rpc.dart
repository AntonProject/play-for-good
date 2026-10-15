// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// homePageScore: the gauge and the numbers come from the ranking RPC already
// loaded into ggHomeRank, with the SAME formulas as the legacy functions
// (see ggHomeGauge). Replaced inside the existing expressions, so formats,
// defaults and conditions around them stay:
//  * totalSumMAX(userId: null)        -> ggHomeGauge(ggHomeRank, 'max')
//  * totalSumMAX(userId: me|'guest')  -> ggHomeGauge(ggHomeRank, 'mine')
//  * totalSumAVG(userId: null)        -> ggHomeGauge(ggHomeRank, 'max')
//    (the legacy AVG returns the maximum when no user is given)
//  * totalSumAVG(userId: me|'guest')  -> ggHomeGauge(ggHomeRank, 'avg')
//  * totalSumPeriod (code: totalSumPeriodLichtwatt, my games) -> ggHomeGauge(ggHomeRank, 'mine')
//  * ratingUser (place fallback while loading) -> ggPlace(ggHomeRank)
// The "all users" query (only its count was used) is removed. Games/invites
// counts below the gauge still read the component parameters.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'homePageScore';

final class HomeGaugeRpc extends FlutterFlowAITask {
  @override
  String get name => 'gg-home-gauge-rpc';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final root = (w['node'] as Map)['key'];
    Map<String, dynamic> fnIdent(String n) =>
        findCustomFunction(p, name: n)!.identifier.toProto3Json() as Map<String, dynamic>;
    final rank = {
      'source': 'LOCAL_STATE',
      'baseVariable': {
        'localState': {
          'fieldIdentifier': ((w['classModel'] as Map)['stateFields'] as List)
              .firstWhere((f) => f['parameter']['identifier']['name'] == 'ggHomeRank')['parameter']['identifier'],
          'stateVariableType': 'WIDGET_CLASS_STATE',
        }
      },
      'nodeKeyRef': {'key': root},
    };
    Map<String, dynamic> gauge(String part) => {
          'customFunction': fnIdent('ggHomeGauge'),
          'values': [
            {'variable': rank},
            {'inputValue': {'serializedValue': part}},
          ],
        };
    final counts = <String, int>{};
    void count(String k) => counts[k] = (counts[k] ?? 0) + 1;
    String userArg(Map fc) {
      final v = (fc['values'] as List)[2] as Map;
      final s = jsonEncode(v);
      if (s.contains('SUPABASE_AUTH_USER')) return 'user';
      if (s.contains('"NULL"')) return 'null';
      throw StateError('Unexpected userId argument: $s');
    }
    void rewrite(dynamic x) {
      if (x is Map<String, dynamic>) {
        final fc = x['functionCall'];
        final name = fc is Map ? (fc['customFunction']?['name']) : null;
        Map<String, dynamic>? next;
        switch (name) {
          case 'totalSumMAX':
            next = gauge(userArg(fc as Map) == 'user' ? 'mine' : 'max');
          case 'totalSumAVG':
            next = gauge(userArg(fc as Map) == 'user' ? 'avg' : 'max');
          case 'totalSumPeriodLichtwatt' || 'totalSumPeriod':
            next = gauge('mine');
          case 'ratingUserLichtwatt' || 'ratingUser':
            next = {'customFunction': fnIdent('ggPlace'), 'values': [{'variable': rank}]};
        }
        if (next != null) {
          final from = name == 'totalSumMAX' || name == 'totalSumAVG' ? '$name(${userArg(fc as Map)})' : '$name';
          x['functionCall'] = next;
          count('$from -> ${next['values'].length == 2 ? next['values'][1]['inputValue']['serializedValue'] : 'ggPlace'}');
          return;
        }
        x.values.forEach(rewrite);
      } else if (x is List) {
        x.forEach(rewrite);
      }
    }
    rewrite(w['node']);
    rewrite(w['classModel']);

    // The all-users query: only its count fed the legacy functions.
    String? usersQuery;
    void q(Map<String, dynamic> n) {
      final dr = n['databaseRequest'];
      if (dr != null && jsonEncode(dr['returnParameter']).contains('"name":"users"') &&
          dr['postgres']?['isSingleRow'] != true) {
        if (usersQuery != null) throw StateError('Two users queries');
        usersQuery = n['key'] as String;
        n.remove('databaseRequest');
      }
      for (final c in (n['children'] as List? ?? [])) q(c as Map<String, dynamic>);
    }
    q(w['node']);
    if (usersQuery == null) throw StateError('users query not found');
    final left = <String>[];
    var at = '';
    void scan(dynamic x) {
      if (x is Map) {
        if (x['key'] is String && x['type'] is String) at = x['key'] as String;
        if (x['source'] == 'POSTGRES_QUERY' && x['nodeKeyRef']?['key'] == usersQuery) left.add('ref@$at ${jsonEncode(x)}');
        final n = x['functionCall'] is Map ? (x['functionCall']['customFunction']?['name']) : null;
        if (const ['totalSumMAX', 'totalSumAVG', 'totalSumPeriodLichtwatt', 'totalSumPeriod', 'ratingUserLichtwatt', 'ratingUser'].contains(n)) {
          left.add('$n');
        }
        x.values.forEach(scan);
      } else if (x is List) {
        x.forEach(scan);
      }
    }
    scan(w);
    if (left.isNotEmpty) throw StateError('Left: $left');
    final total = counts.values.fold(0, (a, b) => a + b);
    if (total != 7) throw StateError('Expected 7 replacements, got $counts');

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('homePageScore: $counts; removed all-users query $usersQuery');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [HomeGaugeRpc()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Home gauge from the ranking RPC (same formulas), no all-users query',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
