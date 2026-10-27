// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 26.10.2026, customer answers:
//  1 Good Games header logo of the 2026 season: with the season 2025/26
//    selected (period season_year 2026) the old design logo
//    Logo_Good_Games_2026.png; otherwise the current Good Heart Games logo.
//    GoodGamesPage: Image_97isam37 gets "season_year != 2026", a copy of it
//    with Logo_Good_Games_2026.png and "season_year == 2026" goes next to it.
//  2 Profile awards of the 2026/27 season (1st/2nd/3rd_Place27.png,
//    Most_Active_Player27.png), shown after that season is closed. The award
//    images were shown by awardFlags (all seasons together), so a 2026/27 gold
//    would also light the "2026" picture. Now each picture checks its season:
//    ggHasAwardOf(ggProfile.awards, category, place, season):
//      2026 pictures  season_2025_26 (Image_yv3tfxhl / spkgfsmx / ph402coe / zib6wzsg)
//      2027 pictures  season_2026_27 (new copies, placed before the 2026 ones)
//    Cannot be checked on a device before the 2026/27 season is closed.
// ONE commit.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const assets = 'projects/play-for-good-o0lpcq/assets';
const logoNow = '$assets/b6sedz229et5/Good_Games_Logo_-_Standard_7_1.webp';
const logo2026 = '$assets/rndg9mihhghm/Logo_Good_Games_2026.png';
// image key -> [category, place, 2027 image]
const awards = {
  'Image_yv3tfxhl': ['valuable', '1', '$assets/fqosytan5wwo/1st_Place27.png'],
  'Image_spkgfsmx': ['valuable', '2', '$assets/ke8aghe1ciea/2nd_Place27.png'],
  'Image_ph402coe': ['valuable', '3', '$assets/tpyfdgp9euab/3rd_Place27.png'],
  'Image_zib6wzsg': ['active', '1', '$assets/g3m16mpwxwmo/Most_Active_Player27.png'],
};

String newKey(String seed) => 'Image_${generateRandomAlphaNumericString(seedString: 'pfg.gg.season.$seed').toLowerCase().substring(0, 8)}';

final class SeasonImages extends FlutterFlowAITask {
  @override
  String get name => 'gg-season-images';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    Map<String, dynamic> load(String cls) =>
        jsonDecode(jsonEncode(p.widgetClasses.values.firstWhere((e) => e.name == cls).toProto3Json()));
    void save(String cls, Map<String, dynamic> w) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }

    // Parent children list holding the node with this key.
    List? siblingsOf(Map w, String key) {
      List? r;
      void s(dynamic x) {
        if (r != null) return;
        if (x is Map) {
          final c = x['children'];
          if (c is List && c.any((n) => (n as Map)['key'] == key)) {
            r = c;
            return;
          }
          x.values.forEach(s);
        } else if (x is List) {
          x.forEach(s);
        }
      }
      s(w['node']);
      return r;
    }

    Map<String, dynamic> fn(String name) {
      final f = p.customCode.customFunctions.firstWhere((f) => f.identifier.name == name).identifier;
      return {'name': f.name, 'key': f.key};
    }

    Map<String, dynamic> field(String struct, String name) {
      final s = findDataStruct(p, name: struct) ?? (throw StateError('$struct missing'));
      final f = s.fields.firstWhere((f) => f.identifier.name == name).identifier;
      return {'name': f.name, 'key': f.key};
    }

    Map access(Map<String, dynamic> f) => {
          'accessDataStructField': {'fieldIdentifier': f}
        };
    Map localState(String name, String key, String scaffold) => {
          'source': 'LOCAL_STATE',
          'baseVariable': {
            'localState': {
              'fieldIdentifier': {'name': name, 'key': key},
              'stateVariableType': 'WIDGET_CLASS_STATE'
            }
          },
          'nodeKeyRef': {'key': scaffold},
        };

    // 1. Good Games header logo.
    {
      final w = load('GoodGamesPage');
      final list = siblingsOf(w, 'Image_97isam37') ?? (throw StateError('Image_97isam37 missing'));
      final copyKey = newKey('logo2026');
      if (list.any((n) => (n as Map)['key'] == copyKey)) {
        stdout.writeln('GoodGamesPage: 2026 logo already there');
      } else {
        final img = list.firstWhere((n) => (n as Map)['key'] == 'Image_97isam37') as Map;
        if (!jsonEncode(img).contains(logoNow)) throw StateError('Image_97isam37: not the current logo');
        if (img['props']?['visibility']?['visibleValue']?['variable'] != null) {
          throw StateError('Image_97isam37 already has a visibility condition');
        }
        Map year(String relation) => {
              'visibleValue': {
                'variable': {
                  'source': 'FUNCTION_CALL',
                  'functionCall': {
                    'values': [
                      {
                        'variable': {
                          'source': 'FUNCTION_CALL',
                          'operations': [access(field('GgRanking', 'period')), access(field('GgPeriod', 'seasonYear'))],
                          'functionCall': {
                            'values': [
                              {'variable': localState('ggRanking', 'gg7aa7e4e351', 'Scaffold_caqt7zc6')}
                            ],
                            'customFunction': fn('ggRankingOrEmpty'),
                          },
                        }
                      },
                      {
                        'inputValue': {'serializedValue': '2026'}
                      }
                    ],
                    'condition': {'relation': relation},
                  },
                },
              },
            };
        final copy = jsonDecode(jsonEncode(img).replaceAll(logoNow, logo2026)) as Map
          ..['key'] = copyKey;
        (copy['props'] as Map)['visibility'] = year('EQUAL_TO');
        (img['props'] as Map)['visibility'] = year('NOT_EQUAL_TO');
        list.insert(list.indexOf(img) + 1, copy);
        save('GoodGamesPage', w);
        stdout.writeln('GoodGamesPage: header logo 2026 for season 2025/26 ($copyKey)');
      }
    }

    // 2. Profile awards per season.
    {
      final w = load('userProfilePage');
      final awardsVar = {
        'source': 'FUNCTION_CALL',
        'operations': [access(field('GgProfileStats', 'awards'))],
        'functionCall': {
          'values': [
            {'variable': localState('ggProfile', 'gg3c006f0ea8', 'Scaffold_kvtv6adx')}
          ],
          'customFunction': fn('ggStatsOrEmpty'),
        },
      };
      Map has(String category, String place, String season) => {
            'visibleValue': {
              'variable': {
                'source': 'FUNCTION_CALL',
                'functionCall': {
                  'values': [
                    {'variable': jsonDecode(jsonEncode(awardsVar))},
                    {
                      'inputValue': {'serializedValue': category}
                    },
                    {
                      'inputValue': {'serializedValue': place}
                    },
                    {
                      'inputValue': {'serializedValue': season}
                    }
                  ],
                  'customFunction': fn('ggHasAwardOf'),
                },
              },
            },
          };
      var n = 0;
      final firstKey = awards.keys.first;
      final list = siblingsOf(w, firstKey) ?? (throw StateError('$firstKey missing'));
      var insertAt = list.indexWhere((x) => (x as Map)['key'] == firstKey);
      awards.forEach((key, a) {
        final img = list.firstWhere((x) => (x as Map)['key'] == key, orElse: () => throw StateError('$key not in the awards row')) as Map;
        final props = img['props'] as Map;
        if (!jsonEncode(props['visibility'] ?? {}).contains('"ggHasAwardOf"')) {
          props['visibility'] = has(a[0], a[1], 'season_2025_26');
          n++;
        }
        final copyKey = newKey('award27.$key');
        if (list.any((x) => (x as Map)['key'] == copyKey)) return;
        final path = (props['image']['pathValue']['inputValue']) as String;
        final copy = jsonDecode(jsonEncode(img).replaceAll(path, a[2])) as Map..['key'] = copyKey;
        (copy['props'] as Map)['visibility'] = has(a[0], a[1], 'season_2026_27');
        list.insert(insertAt++, copy);
        n++;
      });
      if (n > 0) {
        save('userProfilePage', w);
        stdout.writeln('userProfilePage: awards per season, 2027 pictures added ($n changes)');
      } else {
        stdout.writeln('userProfilePage: awards already per season');
      }
    }
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [SeasonImages()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Season images: 2026 logo for season 2025/26; profile awards per season with 2027 pictures',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
