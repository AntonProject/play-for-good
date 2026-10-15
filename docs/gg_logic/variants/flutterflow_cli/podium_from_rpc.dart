// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Good Games podium (both layouts, places 1..3): the per-place "users" single
// row queries are removed. The ranking RPC already returns the podium players:
//  * id        -> ggTopPlayerIds(ggRanking)[i] (the query's own filter value)
//  * photo_url -> ggTopPlayerPhoto(ggRanking, i), same default image
// Their cache key was the signed-in user's id, not the podium player's, so a
// filter change could keep an old avatar; reading the RPC fixes that as well.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'GoodGamesPage';

final class PodiumFromRpc extends FlutterFlowAITask {
  @override
  String get name => 'gg-podium-from-rpc';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final photoFn = findCustomFunction(p, name: 'ggTopPlayerPhoto')!.identifier.toProto3Json();
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    // Podium queries: users single row filtered by ggTopPlayerIds(..)[i].
    final ids = <String, Map<String, dynamic>>{}; // node -> id variable
    final podiumManagers = <String>{};
    final rankings = <String, dynamic>{};
    final indexes = <String, String>{};
    void collect(Map<String, dynamic> n) {
      final dr = n['databaseRequest'];
      if (dr is Map && jsonEncode(dr).contains('"ggTopPlayerIds"') &&
          dr['postgres']?['isSingleRow'] == true) {
        final value = dr['postgres']['where']['filters'][0]['baseFilter']['value']['variable'] as Map<String, dynamic>;
        ids[n['key'] as String] = value;
        podiumManagers.add(dr['requestManagerSettings']['managerIdentifier']['key'] as String);
        rankings[n['key'] as String] = value['functionCall']['values'][0];
        indexes[n['key'] as String] =
            value['operations'][0]['listItemAtIndex']['index']['inputValue']['serializedValue'] as String;
      }
      for (final c in (n['children'] as List? ?? [])) collect(c as Map<String, dynamic>);
    }
    collect(w['node']);
    if (ids.length != 6) throw StateError('Expected 6 podium queries, found ${ids.length}');
    final counts = <String, int>{};
    void rewrite(dynamic x) {
      if (x is Map<String, dynamic>) {
        final ref = x['nodeKeyRef']?['key'];
        if (x['source'] == 'POSTGRES_QUERY' && ids.containsKey(ref)) {
          final field = x['operations']?[0]?['accessPostgresRowField']?['fieldIdentifier']?['name'];
          final keep = {
            for (final k in ['defaultValue', 'uiBuilderValue']) if (x[k] != null) k: x[k],
          };
          final Map<String, dynamic> next;
          if (field == 'id') {
            next = jsonDecode(jsonEncode(ids[ref])) as Map<String, dynamic>;
          } else if (field == 'photo_url') {
            next = {
              'source': 'FUNCTION_CALL',
              'functionCall': {
                'customFunction': photoFn,
                'values': [
                  rankings[ref],
                  {'inputValue': {'serializedValue': indexes[ref]}},
                ],
              },
            };
          } else {
            throw StateError('$ref: unexpected field $field');
          }
          x
            ..clear()
            ..addAll(next)
            ..addAll(keep);
          counts['$field'] = (counts['$field'] ?? 0) + 1;
          return;
        }
        x.values.forEach(rewrite);
      } else if (x is List) {
        x.forEach(rewrite);
      }
    }
    rewrite(w['node']);
    rewrite(w['classModel']);
    void drop(Map<String, dynamic> n) {
      if (ids.containsKey(n['key'])) n.remove('databaseRequest');
      for (final c in (n['children'] as List? ?? [])) drop(c as Map<String, dynamic>);
    }
    drop(w['node']);
    final left = ids.keys.where((k) => jsonEncode(w).contains('"nodeKeyRef":{"key":"$k"}') &&
        jsonEncode(w).contains('"POSTGRES_QUERY"')).toList();
    if (left.isNotEmpty) {
      // Exact check: any POSTGRES_QUERY ref to these nodes left.
      final s = <String>[];
      void scan(dynamic x) {
        if (x is Map) {
          if (x['source'] == 'POSTGRES_QUERY' && ids.containsKey(x['nodeKeyRef']?['key'])) s.add('${x['nodeKeyRef']['key']}');
          x.values.forEach(scan);
        } else if (x is List) {
          x.forEach(scan);
        }
      }
      scan(w);
      if (s.isNotEmpty) throw StateError('References left: $s');
    }
    // "Clear Query Cache" of these queries (also inside callbacks passed to
    // the filter bottom sheet): each such action node is spliced out.
    var cleared = 0;
    bool isClear(dynamic v) =>
        v is Map && podiumManagers.contains(v['action']?['clearQueryCache']?['cacheManagerIdentifier']?['key']);
    dynamic splice(dynamic v) {
      while (isClear(v)) {
        cleared++;
        v = v['followUpAction'] ?? {'key': v['key']};
      }
      return v;
    }
    void unclear(dynamic x) {
      if (x is Map) {
        for (final k in x.keys.toList()) {
          x[k] = splice(x[k]);
          unclear(x[k]);
        }
      } else if (x is List) {
        for (var i = 0; i < x.length; i++) {
          x[i] = splice(x[i]);
          unclear(x[i]);
        }
      }
    }
    unclear(w);
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('Podium: removed ${ids.length} users queries (${ids.keys.join(', ')}), '
        'rewired $counts (indexes ${indexes.values.join(',')}), '
        'removed $cleared Clear Query Cache of $podiumManagers.');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PodiumFromRpc()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games podium: avatars and ids from the ranking RPC',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
