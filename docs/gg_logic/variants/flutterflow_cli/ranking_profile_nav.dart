// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 21.10.2026, owner: Good Games -> tap a player -> sometimes another profile.
//  1 gamesUserComp (ranking rows): the profile got the id of the users row the
//    row had loaded (rowUsersRow.id). Rows are keyed by position, so after a
//    period / category / page change a row shows a new player while its users
//    query still returns the previous one -> the previous profile opened.
//    Now the row's own parameter userId (the player shown in the ranking).
//  2 GoodGamesPage podium: ggPlayerIdsOf(topPlayers)[i] skips players without
//    an id, so its index could differ from the photo / name shown
//    (ggTopPlayerAt(ranking, i)). Now ggTopPlayerAt(ranking, i).userId, the
//    same source as the photo.
//  3 Guest row under the list (demo feedback 6, 7, 10): userId is empty for a
//    guest, so the row showed "unnamed", 0 and the Good Power place in every
//    category and opened other users. transfer.dart (rpc) brings
//    ggPlayerOf (demo guest row: playerforgood_N, 100 Good Power, place of
//    the category), ggRankingPlace (guest place of the category, also Home /
//    profile) and ggRowStyleOf (no podium look for the guest); the row's
//    profile navigation gets the default 'guest' (empty id -> guest profile).
// ONE commit: transfer.dart (rpc) + this change.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

final class RankingProfileNav extends FlutterFlowAITask {
  @override
  String get name => 'gg-ranking-profile-nav';
  @override
  Set<String> get dependsOn => {'register-gg-rpc'};
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final profileKey = p.widgetClasses.values.firstWhere((w) => w.name == 'userProfilePage').node.key;
    final player = findDataStruct(p, name: 'GgPlayer') ?? (throw StateError('GgPlayer Data Type missing'));
    final userIdField = player.fields.firstWhere((f) => f.identifier.name == 'userId').identifier;
    final report = <String>[];

    Map<String, dynamic> load(String cls) =>
        jsonDecode(jsonEncode(p.widgetClasses.values.firstWhere((e) => e.name == cls).toProto3Json()));
    void save(String cls, Map<String, dynamic> w) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }

    List<Map> userIdPasses(Map w) {
      final out = <Map>[];
      void walk(dynamic x) {
        if (x is Map) {
          final nav = x['navigate'];
          if (nav is Map && nav['pageNodeKeyRef']?['key'] == profileKey) {
            for (final pass in ((nav['passedParameters']?['parameterPasses'] as Map?) ?? {}).values) {
              if ((pass as Map)['paramIdentifier']?['name'] == 'userId') out.add(pass);
            }
          }
          x.values.forEach(walk);
        } else if (x is List) {
          x.forEach(walk);
        }
      }
      walk(w);
      return out;
    }

    // 1. gamesUserComp: the row's parameter userId.
    {
      final w = load('gamesUserComp');
      Map? param;
      void find(dynamic x) {
        if (param != null) return;
        if (x is Map) {
          if (x['source'] == 'WIDGET_CLASS_PARAMETER' &&
              x['baseVariable']?['widgetClass']?['paramIdentifier']?['name'] == 'userId') {
            param = x;
            return;
          }
          x.values.forEach(find);
        } else if (x is List) {
          x.forEach(find);
        }
      }
      find(w['node']);
      final passes = userIdPasses(w);
      if (passes.length != 1) throw StateError('gamesUserComp: ${passes.length} navigations to the profile');
      final pass = passes.single;
      final guest = {'serializedValue': 'guest'};
      if (jsonEncode(pass['variable']).contains('WIDGET_CLASS_PARAMETER')) {
        if (jsonEncode((pass['variable'] as Map)['defaultValue']) == jsonEncode(guest)) {
          report.add('gamesUserComp: already passes the row parameter userId (default guest)');
        } else {
          (pass['variable'] as Map)['defaultValue'] = guest;
          save('gamesUserComp', w);
          report.add('gamesUserComp: row parameter userId gets the default guest');
        }
      } else {
        if (!jsonEncode(pass['variable']).contains('POSTGRES_QUERY')) {
          throw StateError('gamesUserComp: unexpected userId source ${jsonEncode(pass['variable'])}');
        }
        pass.remove('inputValue');
        pass['variable'] = jsonDecode(jsonEncode(param ?? (throw StateError('gamesUserComp: userId parameter ref not found'))))
          ..['defaultValue'] = guest;
        save('gamesUserComp', w);
        report.add('gamesUserComp: profile gets the row parameter userId (empty -> guest)');
      }
    }

    // 2. GoodGamesPage podium: ggTopPlayerAt(ranking, i).userId.
    {
      final w = load('GoodGamesPage');
      Map? photo;
      void find(dynamic x) {
        if (photo != null) return;
        if (x is Map) {
          final s = jsonEncode(x);
          if (x['source'] == 'FUNCTION_CALL' &&
              x['functionCall']?['customFunction']?['name'] == 'ggTopPlayerAt' &&
              s.contains('"photoUrl"')) {
            photo = x;
            return;
          }
          x.values.forEach(find);
        } else if (x is List) {
          x.forEach(find);
        }
      }
      find(w['node']);
      if (photo == null) throw StateError('GoodGamesPage: ggTopPlayerAt(...).photoUrl not found');
      var n = 0;
      for (final pass in userIdPasses(w)) {
        final v = pass['variable'] as Map?;
        final s = jsonEncode(v);
        if (v == null || !s.contains('"ggPlayerIdsOf"')) continue;
        final op = ((v['operations'] as List?) ?? []).cast<Map>();
        int index;
        if (op.isNotEmpty && op.first['listItemAtIndex'] != null) {
          final li = op.first['listItemAtIndex'] as Map;
          index = li['type'] == 'SPECIFIED'
              ? int.parse('${li['index']?['inputValue']?['serializedValue'] ?? 0}')
              : li['type'] == 'FIRST'
                  ? 0
                  : (throw StateError('GoodGamesPage: list item type ${li['type']}'));
        } else {
          throw StateError('GoodGamesPage: unexpected podium userId $s');
        }
        final next = jsonDecode(jsonEncode(photo)) as Map<String, dynamic>;
        (next['functionCall']['values'] as List)[1] = {
          'inputValue': {'serializedValue': '$index'}
        };
        next['operations'] = [
          {
            'accessDataStructField': {'fieldIdentifier': {'name': userIdField.name, 'key': userIdField.key}}
          }
        ];
        next.remove('defaultValue');
        pass['variable'] = next;
        n++;
      }
      if (n > 0) {
        save('GoodGamesPage', w);
        report.add('GoodGamesPage: $n podium navigation(s) -> ggTopPlayerAt(ranking, i).userId');
      } else {
        report.add('GoodGamesPage: podium already uses ggTopPlayerAt');
      }
    }
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-ranknav-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports), RankingProfileNav()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games: rows and podium open the shown player; guest row with its demo values and place',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
