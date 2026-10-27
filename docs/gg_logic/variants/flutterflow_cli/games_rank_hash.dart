// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 26.10.2026, owner: Meine Games header - the place under "Games" showed "1",
// the other two places "#1". GoodGamesPage Text_234kysby becomes "#" + place,
// built like Text_jmkc3tqq (Good Power per Game): default "0" on the place and
// on the whole text.
// Same commit, owner: 0 in a metric = place 0 ("0 games, 0 points, place 1"
// made no sense; before: the place after all players with points). Transfer of
// ggLoadProfileStats, ggLoadRanking (guest places in games / €nergy = 0),
// ggRankingPlace, ggPlayerOf, ggPlaceLabelOf (0 -> "#0"). Applies to profile
// Stats and header, Meine Games header, Energy, Home and the own / guest row.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

final class GamesRankHash extends FlutterFlowAITask {
  @override
  String get name => 'gg-games-rank-hash';
  @override
  Set<String> get dependsOn => {'register-gg-rpc'};
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'GoodGamesPage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    Map? text;
    void s(dynamic x) {
      if (text != null) return;
      if (x is Map) {
        if (x['key'] == 'Text_234kysby' && x['type'] == 'Text') {
          text = x;
          return;
        }
        x.values.forEach(s);
      } else if (x is List) {
        x.forEach(s);
      }
    }
    s(w['node']);
    final tv = (text ?? (throw StateError('Text_234kysby missing')))['props']['text']['textValue'] as Map;
    final v = tv['variable'] as Map;
    if (v['functionCall']?['stringInterpolation'] != null) {
      stdout.writeln('GoodGamesPage: Games place already with "#"');
      return;
    }
    final e = jsonEncode(v);
    if (!e.contains('"games"') || !e.contains('"rank"')) throw StateError('Text_234kysby: not the Games place');
    final place = jsonDecode(e) as Map
      ..['defaultValue'] = {'serializedValue': '0'}
      ..remove('uiBuilderValue');
    tv['variable'] = {
      'source': 'FUNCTION_CALL',
      'defaultValue': {'serializedValue': '#0'},
      'functionCall': {
        'stringInterpolation': {},
        'values': [
          {
            'inputValue': {'serializedValue': '#'}
          },
          {'variable': place}
        ],
      },
      'uiBuilderValue': {'serializedValue': '#1'},
    };
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('GoodGamesPage: Games place "#" + place');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-zero-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports), GamesRankHash()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Place 0 for 0 in a metric; Meine Games header: Games place with "#"',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
