// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Posts split into test / prod (16.10.2026), after SQL 13_posts_test.sql and
// the FF Supabase schema refresh (Settings -> Supabase -> Get Schema), so
// posts.test is known.
// Every widget Backend Query on posts (profile, organisation page, profile
// sheet; admin pages are not touched) gets `test == Environment.test`.
// Supabase streams allow a single filter in FF, so the streams become one-time
// queries with the APP cache they already have; the cache key gets
// '|' + ggVerGames: a post appears only when a game is completed, and that
// game event bumps ggVerGames (GgStatsListener), so the list loads again.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class PostsTestQueries extends FlutterFlowAITask {
  @override
  String get name => 'gg-posts-test-queries';
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
    final ver = p.appState.fields.firstWhere((x) => x.parameter.identifier.name == 'ggVerGames',
        orElse: () => throw StateError('App State ggVerGames missing'));
    final verVar = {
      'source': 'LOCAL_STATE',
      'baseVariable': {
        'localState': {
          'fieldIdentifier': {'name': 'ggVerGames', 'key': ver.parameter.identifier.key},
          'stateVariableType': 'APP_STATE',
        }
      },
    };
    final report = <String>[];
    for (final entry in p.widgetClasses.entries.toList()) {
      final cls = entry.value.name;
      if (cls.toLowerCase().contains('admin')) continue;
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json()));
      var changed = 0;
      void walk(dynamic x, String node) {
        if (x is Map) {
          if (x['key'] is String && x['type'] is String && x.containsKey('props')) node = x['key'] as String;
          final dr = x['databaseRequest'];
          if (dr is Map && dr['postgres'] is Map &&
              dr['returnParameter']?['dataType']?['subType']?['tableIdentifier']?['name'] == 'posts') {
            final pg = dr['postgres'] as Map;
            final where = (pg['where'] ??= {'filters': [], 'isOr': false}) as Map;
            final filters = (where['filters'] ??= []) as List;
            if (where['isOr'] == true) throw StateError('$cls/$node uses OR filters');
            final notes = <String>[];
            if (!filters.any((f) => f['baseFilter']?['fieldIdentifier']?['name'] == 'test')) {
              filters.add({
                'baseFilter': {
                  'fieldIdentifier': {'name': 'test'},
                  'relation': 'EQUAL_TO',
                  'value': {'variable': env},
                }
              });
              notes.add('test filter');
            }
            if (pg.remove('isStreamingSupabaseQuery') == true) notes.add('stream -> once');
            final rm = dr['requestManagerSettings'] as Map?;
            if (rm == null || rm['useRequestManager'] != true) {
              throw StateError('$cls/$node: posts query without a query cache');
            }
            final keyValues = rm['uniqueQueryKey']?['functionCall']?['values'] as List?;
            if (keyValues == null) throw StateError('$cls/$node: cache key is not a text');
            if (!jsonEncode(keyValues).contains('"ggVerGames"')) {
              keyValues.addAll([
                {'inputValue': {'serializedValue': '|'}},
                {'variable': verVar},
              ]);
              notes.add('cache key + ggVerGames');
            }
            if (notes.isNotEmpty) {
              report.add('$cls/$node posts: ${notes.join(', ')}');
              changed++;
            }
          }
          for (final v in x.values) walk(v, node);
        } else if (x is List) {
          for (final v in x) walk(v, node);
        }
      }
      walk(w, '');
      if (changed == 0) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(w as Map<String, dynamic>);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }
    if (report.isEmpty) report.add('posts queries: already filtered');
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PostsTestQueries()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Posts lists: test / prod environment',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
