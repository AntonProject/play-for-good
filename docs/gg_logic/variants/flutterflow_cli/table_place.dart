// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 27.10.2026, customer: a new user, MVP, last month / last season (0 points)
// - the Good Games list read "1 tiprop, 0 rolf_neuman". Owner: the rating may
// be 0, a table may not ("1-2-3-0"). The rating stays 0 (ggRankingPlace: Home,
// profile, headers); the table row number is the place right after all players
// with points (ggPlayerOf: own row, guest row in the other categories;
// ggRowStyleOf: no podium look for such a row).
// GoodGamesPage, row under the divider (Container_hsks3evp): rating was
// ggRankingPlace(ggRanking), now ggPlayerOf(ggRanking, auth user id).rank like
// the rows of the list. ONE commit (with the function transfer).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

final class TablePlace extends FlutterFlowAITask {
  @override
  String get name => 'gg-table-place';
  @override
  Set<String> get dependsOn => {'register-gg-rpc'};
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'GoodGamesPage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    Map? row;
    void s(dynamic x) {
      if (row != null) return;
      if (x is Map) {
        if (x['key'] == 'Container_hsks3evp' && x['parameterValues'] != null) {
          row = x;
          return;
        }
        x.values.forEach(s);
      } else if (x is List) {
        x.forEach(s);
      }
    }
    s(w['node']);
    final passes = (row ?? (throw StateError('Container_hsks3evp missing')))['parameterValues']['parameterPasses'] as Map;
    final rating = passes['phsgpm'] as Map? ?? (throw StateError('rating pass missing'));
    final player = passes['gg6b92438ce7'] as Map? ?? (throw StateError('player pass missing'));
    final now = jsonEncode(rating['variable']);
    if (now.contains('"ggPlayerOf"')) {
      stdout.writeln('GoodGamesPage: row under the divider already ggPlayerOf(...).rank');
      return;
    }
    if (!now.contains('"ggRankingPlace"')) throw StateError('rating: unexpected binding');
    final pv = player['variable'] as Map;
    if (!jsonEncode(pv).contains('"ggPlayerOf"') || !jsonEncode(pv).contains('SUPABASE_AUTH_USER')) {
      throw StateError('player: unexpected binding');
    }
    final rankKey = findDataStruct(p, name: 'GgPlayer')!
        .fields
        .firstWhere((f) => f.identifier.name == 'rank')
        .identifier;
    rating['variable'] = (jsonDecode(jsonEncode(pv)) as Map)
      ..['defaultValue'] = {'serializedValue': '0'}
      ..['operations'] = [
        {
          'accessDataStructField': {
            'fieldIdentifier': {'name': rankKey.name, 'key': rankKey.key}
          }
        }
      ]
      ..['uiBuilderValue'] = {'serializedValue': '0'};
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('GoodGamesPage: row under the divider = ggPlayerOf(ggRanking, user).rank');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-table-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports), TablePlace()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games list: rows without points get the table place after all players with points',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
