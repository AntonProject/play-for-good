// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Requires the FF Supabase schema refreshed (Settings -> Supabase -> Get Schema)
// so games.test / invites.test are known.
// Every widget Backend Query on games/invites gets `test == Environment.test`;
// Supabase streams allow a single filter in FF, so streaming queries become
// one-time queries (refreshed on page load via their request manager key).
// Game inserts write `test = Environment.test`.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class TestEnvQueries extends FlutterFlowAITask {
  @override
  String get name => 'gg-test-env-queries';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final env = {
      'source': 'DEV_ENVIRONMENT',
      'baseVariable': {
        'environmentValue': {
          'identifier': findEnvironmentValue(p, 'test')!.parameter.identifier.toProto3Json(),
        }
      },
    };
    final report = <String>[];
    for (final entry in p.widgetClasses.entries.toList()) {
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json()));
      var changed = 0;
      void walk(dynamic x, String node) {
        if (x is Map) {
          if (x['key'] is String && x['type'] is String && x.containsKey('props')) node = x['key'] as String;
          final dr = x['databaseRequest'];
          if (dr is Map && dr['postgres'] is Map) {
            final table = dr['returnParameter']?['dataType']?['subType']?['tableIdentifier']?['name'];
            if (table == 'games' || table == 'invites') {
              final pg = dr['postgres'] as Map;
              final where = (pg['where'] ??= {'filters': [], 'isOr': false}) as Map;
              final filters = (where['filters'] ??= []) as List;
              if (where['isOr'] == true) throw StateError('${entry.value.name}/$node uses OR filters');
              final has = filters.any((f) => f['baseFilter']?['fieldIdentifier']?['name'] == 'test');
              if (!has) {
                filters.add({
                  'baseFilter': {
                    'fieldIdentifier': {'name': 'test'},
                    'relation': 'EQUAL_TO',
                    'value': {'variable': env},
                  }
                });
                final wasStream = pg['isStreamingSupabaseQuery'] == true;
                if (wasStream) pg.remove('isStreamingSupabaseQuery');
                report.add('${entry.value.name}/$node $table${wasStream ? ' (stream -> once)' : ''}');
                changed++;
              }
            }
          }
          final pa = x['postgresAction'];
          if (pa is Map && pa.containsKey('insert') && pa['tableIdentifier']?['name'] == 'games') {
            final updates = ((pa['data'] ??= {})['updates'] ??= []) as List;
            if (!updates.any((u) => u['fieldIdentifier']?['name'] == 'test')) {
              updates.add({'fieldIdentifier': {'name': 'test'}, 'value': {'variable': env}});
              report.add('${entry.value.name}/$node insert games.test');
              changed++;
            }
          }
          for (final v in x.values) walk(v, node);
        } else if (x is List) {
          for (final v in x) walk(v, node);
        }
      }
      walk(w, entry.value.name);
      if (changed == 0) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }
    stdout.writeln('Environment test applied (${report.length}):\n${report.join('\n')}');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [TestEnvQueries()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Games/invites: Environment.test filter on reads, test on game inserts',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
