// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Good Games + profile (page/dialog) are computed by the v2 RPCs, so the old
// global Backend Queries (all users / all invites / all games) are removed:
// the screens no longer wait for them and nothing global is downloaded.
// Every remaining reference is switched to RPC data first:
//  * "ggHasData(json) ? new : old" -> new
//  * "<my games/invites>.length > 0" -> ggHasGames / ggHasActivity(ggMyStats)
//  * legacy rank/score calls -> ggMetricRank / ggMetricValue / ggPlace
//  * guest "@playerforgood<N>" -> registered users count from ggGuest
// Per-object queries (profile user, own games for organisations, posts,
// followers, avatars) stay. Fails if any reference to a removed query is left.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const removed = {
  'GoodGamesPage': ['Container_n9xqchnl', 'Container_puvoacps', 'Container_9l1w54fh', 'Container_tuzi6e31'],
  'userProfilePage': ['Container_ggt9txkv', 'Container_s4gf3oc1', 'Container_usgqgitn', 'Container_3tzmxyks'],
  'userProfile': ['Container_asnsev56', 'Container_cbks9vjw', 'Container_bngxnriw', 'Container_hdu38d61', 'Container_1i7egj4q'],
};
const invitesQueries = {'Container_puvoacps', 'Container_usgqgitn', 'Container_bngxnriw'};

final class RemoveLegacyQueries extends FlutterFlowAITask {
  @override
  String get name => 'gg-remove-legacy-queries';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String, int>{};
    void count(String k) => report[k] = (report[k] ?? 0) + 1;
    Map<String, dynamic> fnIdent(String n) =>
        findCustomFunction(p, name: n)!.identifier.toProto3Json() as Map<String, dynamic>;

    for (final scope in removed.keys) {
      final keys = removed[scope]!.toSet();
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      final page = (w['node'] as Map)['key'];
      Map<String, dynamic> stateVar(String name, [String? path, String type = 'JSON']) {
        final f = ((w['classModel'] as Map)['stateFields'] as List)
            .firstWhere((f) => f['parameter']['identifier']['name'] == name);
        return {
          'source': 'LOCAL_STATE',
          'baseVariable': {
            'localState': {'fieldIdentifier': f['parameter']['identifier'], 'stateVariableType': 'WIDGET_CLASS_STATE'}
          },
          'nodeKeyRef': {'key': page},
          if (path != null)
            'operations': [
              {'jsonPathOperation': {'jsonPath': path, 'returnParameter': {'dataType': {'scalarType': type}}}}
            ],
        };
      }
      Map<String, dynamic> fnVar(String n, List<Map<String, dynamic>> values) =>
          {'source': 'FUNCTION_CALL', 'functionCall': {'customFunction': fnIdent(n), 'values': values}};
      Map<String, dynamic> lit(Object v) => {'inputValue': {'serializedValue': '$v'}};
      bool refs(dynamic x) {
        final s = jsonEncode(x);
        return s.contains('"POSTGRES_QUERY"') && keys.any((k) => s.contains('"key":"$k"'));
      }
      String? queryOf(dynamic v) =>
          v is Map && v['source'] == 'POSTGRES_QUERY' && keys.contains(v['nodeKeyRef']?['key'])
              ? v['nodeKeyRef']['key'] as String
              : null;
      final stats = scope == 'GoodGamesPage' ? 'ggMyStats' : 'ggProfile';

      void rewrite(dynamic x, String node) {
        if (x is Map) {
          if (x['key'] is String && x['type'] is String && x.containsKey('props')) node = x['key'] as String;
          // A variable dict: try the replacements, then descend.
          final fc = x['functionCall'];
          if (fc is Map) {
            final cv = fc['conditionalValue'];
            if (cv is Map) {
              final ifs = (cv['ifConditionalValues'] as List?) ?? [];
              if (ifs.length == 1 &&
                  jsonEncode(ifs.first['condition']).contains('ggHasData') &&
                  refs(cv['elseValue']) && !refs(ifs.first['value']) &&
                  (ifs.first['value'] as Map).containsKey('variable')) {
                final nv = jsonDecode(jsonEncode(ifs.first['value']['variable'])) as Map;
                x..clear()..addAll(nv.cast<String, dynamic>());
                count('$scope collapse ready?new:old');
                rewrite(x, node);
                return;
              }
            }
            final rel = (fc['condition'] as Map?)?['relation'];
            final vals = fc['values'] as List?;
            if (rel == 'GREATER_THAN' && vals != null && vals.isNotEmpty) {
              final q = queryOf((vals.first as Map)['variable']);
              if (q != null) {
                final nv = fnVar(invitesQueries.contains(q) ? 'ggHasActivity' : 'ggHasGames',
                    [{'variable': stateVar(stats)}]);
                x..clear()..addAll(nv);
                count('$scope list>0 -> ${invitesQueries.contains(q) ? 'ggHasActivity' : 'ggHasGames'}');
                return;
              }
            }
            final fname = (fc['customFunction'] as Map?)?['name'];
            Map<String, dynamic>? swap;
            if (fname == 'ratingUserGamesByAverage') {
              swap = fnVar('ggMetricRank', [{'variable': stateVar('ggMyStats')}, lit('good_energy_per_game'), lit(false)]);
            } else if (fname == 'ratingUsersPerUser' && refs(fc)) {
              swap = fnVar('ggMetricRank', [{'variable': stateVar(stats)}, lit('good_power'), lit(true)]);
            } else if (fname == 'getUserRatingScore' && refs(fc)) {
              swap = fnVar('ggMetricValue', [{'variable': stateVar(stats)}, lit('good_power'), lit(true)]);
            }
            if (swap != null) {
              x['functionCall'] = swap['functionCall'];
              count('$scope $fname -> RPC');
              return;
            }
          }
          // Guest number/place from the removed "all users" list.
          final q = queryOf(x);
          if (q != null && jsonEncode(x['operations']).contains('listNumItems') &&
              !invitesQueries.contains(q)) {
            final parentHash = node; // decided by the caller context below
            x
              ..clear()
              ..addAll(stateVar('ggGuest', r'$.legacy_bonus_users_count', 'Integer'));
            count('$scope users.length -> registered count ($parentHash)');
            return;
          }
          for (final e in x.entries.toList()) {
            if (e.key == 'children') {
              for (final c in e.value as List) rewrite(c, node);
            } else {
              rewrite(e.value, node);
            }
          }
        } else if (x is List) {
          for (final v in x) rewrite(v, node);
        }
      }
      rewrite(w['node'], scope);
      // Class-level action blocks may also read the removed queries.
      rewrite(w['classModel'], scope);

      // Specific nodes.
      Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
        if (n['key'] == k) return n;
        for (final c in (n['children'] as List? ?? [])) {
          final r = find(c as Map<String, dynamic>, k);
          if (r != null) return r;
        }
        return null;
      }
      if (scope == 'GoodGamesPage') {
        for (final k in ['Container_spkska2u', 'Divider_erkrx0uk']) {
          (find(w['node'], k)!['props'] as Map)['visibility'] = {'visibleValue': {'inputValue': true}};
          count('$scope guest pinned row visible');
        }
        // gamesUserComp legacy list params: harmless non-global values.
        for (final k in ['Container_x6xywqe6', 'Container_pm65r2z0', 'Container_hsks3evp', 'Container_spkska2u']) {
          final passes = find(w['node'], k)!['parameterValues']['parameterPasses'] as Map;
          for (final pass in passes.values) {
            final n = pass['paramIdentifier']['name'];
            if (n == 'games' && refs(pass)) {
              pass['variable'] = fnVar('ggGamesRows', [{'variable': stateVar('ggHistory')}]);
              count('$scope games param');
            } else if (n == 'invites' && refs(pass)) {
              pass['variable'] = fnVar('getEmptyInvitesList', []);
              count('$scope invites param');
            }
          }
        }
      }
      // Guest place "#<N>": the guest_rank, same as Home.
      for (final k in ['Text_ps6amarn', 'Text_8a8sdmoz']) {
        final t = find(w['node'], k);
        if (t == null) continue;
        final tv = ((t['props'] as Map)['text'] as Map)['textValue'] as Map;
        final values = tv['variable']?['functionCall']?['values'] as List?;
        if (values != null && values.length == 2) {
          values[1] = {'variable': fnVar('ggPlace', [{'variable': stateVar('ggGuest')}])};
          count('$scope guest #place -> ggPlace');
        }
      }

      // Remove the global queries themselves.
      for (final k in keys) {
        final n = find(w['node'], k) ?? (throw StateError('$scope/$k missing'));
        n.remove('databaseRequest');
        count('$scope removed query');
      }
      {
        final left = <String>[];
        void scan(dynamic x, String node) {
          if (x is Map) {
            if (x['key'] is String && x['type'] is String && x.containsKey('props')) node = x['key'] as String;
            if (queryOf(x) != null) left.add('$node->${x['nodeKeyRef']['key']}');
            x.forEach((k, v) => scan(v, node));
          } else if (x is List) {
            for (final v in x) scan(v, node);
          }
        }
        scan(w, scope);
        if (left.isNotEmpty) throw StateError('$scope still references removed queries: $left');
      }
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }
    final keys = report.keys.toList()..sort();
    stdout.writeln(keys.map((k) => '$k: ${report[k]}').join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RemoveLegacyQueries()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games + profile: remove global legacy queries (RPC only)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
