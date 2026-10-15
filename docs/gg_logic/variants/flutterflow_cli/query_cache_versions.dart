// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Step 3 of the query cache: queries of games / organization / users that ran
// again on every rebuild (no cache: `future: XTable().queryRows(...)` in build)
// get an APP-scoped FF query cache. The cache key is
//   '<query node>|' + every variable of the query filter + '|' + data version
// (App State ggVerGames / ggVerOrganization / ggVerUsers, set by GgStatsListener
// on Realtime events). So a rebuild or a reopened page reads the cache (no
// loader), and a change of the table loads the query once again.
// Admin pages (and the admin receipt dialog), streams and queries that already
// use a cache are not touched.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const versions = {'games': 'ggVerGames', 'organization': 'ggVerOrganization', 'users': 'ggVerUsers'};

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.qcache.$seed').substring(0, 5);
String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

final class QueryCacheVersions extends FlutterFlowAITask {
  @override
  String get name => 'gg-query-cache-versions';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final appStateJson = jsonDecode(jsonEncode(p.appState.toProto3Json())) as Map<String, dynamic>;
    final managers = (appStateJson['databaseRequestManagers'] as List? ?? []).cast<Map<String, dynamic>>();
    final usedNames = {for (final m in managers) m['identifier']['name']};
    Map<String, dynamic> appVar(String name) {
      final f = p.appState.fields.firstWhere((x) => x.parameter.identifier.name == name,
          orElse: () => throw StateError('App State $name missing'));
      return {
        'source': 'LOCAL_STATE',
        'baseVariable': {
          'localState': {
            'fieldIdentifier': {'name': name, 'key': f.parameter.identifier.key},
            'stateVariableType': 'APP_STATE',
          }
        },
      };
    }

    final report = <String>[];
    for (final entry in p.widgetClasses.entries.toList()) {
      final cls = entry.value.name;
      // Admin tools (incl. the receipt dialog of the admin) keep their behaviour.
      if (cls.toLowerCase().contains('admin') || cls == 'CreateReceiptDialog') continue;
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      var changed = 0;
      void walk(Object? n) {
        if (n is Map) {
          final dr = n['databaseRequest'];
          if (dr is Map && n['key'] is String) {
            final table = dr['returnParameter']?['dataType']?['subType']?['tableIdentifier']?['name'] as String?;
            final postgres = dr['postgres'] as Map?;
            final rm = dr['requestManagerSettings'] as Map?;
            final cached = rm != null && rm['useRequestManager'] == true;
            final stream = postgres?['isStreamingSupabaseQuery'] == true;
            if (table != null && versions.containsKey(table) && postgres != null && !cached && !stream) {
              // every variable used by the filter is part of the key
              final vars = <Map>[];
              void collect(Object? x) {
                if (x is Map) {
                  if (x['variable'] is Map) vars.add(x['variable'] as Map);
                  x.values.forEach(collect);
                } else if (x is List) {
                  x.forEach(collect);
                }
              }
              collect(postgres['where']);
              var name = 'gg${cap(cls)}${cap(table)}';
              for (var i = 2; usedNames.contains(name); i++) {
                name = 'gg${cap(cls)}${cap(table)}$i';
              }
              usedNames.add(name);
              final id = key('$cls.${n['key']}');
              managers.add({
                'identifier': {'name': name, 'key': id},
                'originalNodeKeyRef': {'key': n['key']},
              });
              dr['requestManagerSettings'] = {
                'useRequestManager': true,
                'scope': 'APP',
                'managerIdentifier': {'key': id},
                'uniqueQueryKey': {
                  'source': 'FUNCTION_CALL',
                  'functionCall': {
                    'stringInterpolation': {},
                    'values': [
                      {'inputValue': {'serializedValue': '${n['key']}|'}},
                      for (final v in vars) ...[
                        {'variable': jsonDecode(jsonEncode(v))},
                        {'inputValue': {'serializedValue': '|'}},
                      ],
                      {'variable': appVar(versions[table]!)},
                    ],
                  },
                },
                'overrideCache': {},
              };
              changed++;
              report.add('$cls ${n['key']} $table -> FFAppState().$name (${vars.length} filter value(s) + ${versions[table]})');
            }
          }
          n.values.forEach(walk);
        } else if (n is List) {
          n.forEach(walk);
        }
      }
      walk(w['node']);
      if (changed == 0) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }
    appStateJson['databaseRequestManagers'] = managers;
    final nextState = FFAppState()..mergeFromProto3Json(appStateJson);
    restoreUnknownFields(p.appState, nextState);
    p.appState = nextState;
    stdout.writeln(report.join('\n'));
    stdout.writeln('${report.length} queries cached');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [QueryCacheVersions()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Query cache with data versions (games, organization, users)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
