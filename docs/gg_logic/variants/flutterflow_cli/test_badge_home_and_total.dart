// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 21.10.2026, owner:
//  1 The TEST pill in the shared header (apbarBG, test_env_badge.dart) took
//    room in the header Row: the avatar moved differently on Home / Good News
//    / Energy. It is removed from apbarBG.
//  2 Instead: one TEST pill on Home only, as a layer of the root Stack, top
//    centre (48 px from the top, under the notch / island), not moving any
//    layout. Visible only when the environment value test is true.
//  3 Good Games header "LW / Total Good Power" showed the all-time total of all
//    players (totalGoodPowerAllTime) whatever the period filter; e.g. season
//    2026/27 with two players of 100 showed 13.000. Now the total of the
//    selected period (totalGoodPower, same response).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.testbadge.$seed');

final class TestBadgeHomeAndTotal extends FlutterFlowAITask {
  @override
  String get name => 'gg-test-badge-home-and-total';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    Map<String, dynamic> load(String cls) =>
        jsonDecode(jsonEncode(p.widgetClasses.values.firstWhere((e) => e.name == cls).toProto3Json()));
    void save(String cls, Map<String, dynamic> w) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }

    // 1. apbarBG: remove the pill added by test_env_badge.dart.
    final oldKey = 'Container_${key('container')}';
    Map? removed;
    {
      final w = load('apbarBG');
      bool drop(Map n) {
        final children = n['children'] as List?;
        if (children == null) return false;
        final i = children.indexWhere((c) => (c as Map)['key'] == oldKey);
        if (i >= 0) {
          removed = children.removeAt(i) as Map;
          return true;
        }
        return children.any((c) => drop(c as Map));
      }
      if (drop(w['node'] as Map)) {
        save('apbarBG', w);
        report.add('apbarBG: TEST pill removed from the header');
      } else {
        report.add('apbarBG: no TEST pill');
      }
    }

    // 2. HomePage: TEST pill as the last layer of the root Stack.
    {
      final w = load('HomePage');
      final stack = ((w['node'] as Map)['children'] as List).first as Map;
      if (stack['type'] != 'Stack') throw StateError('HomePage: root is not a Stack');
      final layerKey = 'Container_${key('home.layer')}';
      final children = stack['children'] as List;
      if (children.any((c) => (c as Map)['key'] == layerKey)) {
        report.add('HomePage: TEST pill already there');
      } else {
        final env = {
          'source': 'DEV_ENVIRONMENT',
          'baseVariable': {
            'environmentValue': {
              'identifier': (findEnvironmentValue(p, 'test') ?? (throw StateError('environment value test missing')))
                  .parameter
                  .identifier
                  .toProto3Json(),
            }
          },
        };
        Map<String, dynamic> pad(num l, num t, num r, num b) => {
              'type': 'FF_PADDING_ONLY',
              'leftValue': {'inputValue': l},
              'topValue': {'inputValue': t},
              'rightValue': {'inputValue': r},
              'bottomValue': {'inputValue': b},
            };
        children.add({
          'key': layerKey,
          'type': 'Container',
          'props': {
            'container': {},
            'alignment': {
              'xValue': {'inputValue': 0},
              'yValue': {'inputValue': -1},
            },
            'padding': pad(0, 48, 0, 0),
            'visibility': {
              'visibleValue': {'variable': env}
            },
          },
          'children': [
            {
              'key': 'Container_${key('home.pill')}',
              'type': 'Container',
              'props': {
                'container': {
                  'boxDecoration': {
                    'colorValue': {
                      'inputValue': {'themeColor': 'PRIMARY_BACKGROUND'}
                    },
                    'borderRadius': {
                      'topLeftValue': {'inputValue': 99},
                      'topRightValue': {'inputValue': 99},
                      'bottomLeftValue': {'inputValue': 99},
                      'bottomRightValue': {'inputValue': 99},
                    },
                  },
                },
              },
              'children': [
                {
                  'key': 'Text_${key('home.text')}',
                  'type': 'Text',
                  'props': {
                    'text': {
                      'themeStyle': 'BODY_SMALL',
                      'translationIdentifier': {'key': key('home.translation').substring(0, 8).toLowerCase()},
                      'selectable': false,
                      'textValue': {'inputValue': 'TEST'},
                      'colorValue': {
                        'inputValue': {'themeColor': 'PRIMARY'}
                      },
                      'fontSizeValue': {'inputValue': 10},
                      'fontWeightValue': {'inputValue': 'w700'},
                    },
                    'padding': pad(8, 2, 8, 2),
                  },
                }
              ],
            }
          ],
        });
        save('HomePage', w);
        report.add('HomePage: TEST pill on top of the screen (test environment only)');
      }
    }

    // 3. Good Games: Total Good Power of the selected period.
    {
      final s = findDataStruct(p, name: 'GgRanking') ?? (throw StateError('GgRanking missing'));
      final total = s.fields.firstWhere((f) => f.identifier.name == 'totalGoodPower').identifier;
      final w = load('GoodGamesPage');
      var n = 0;
      void fix(dynamic x) {
        if (x is Map) {
          final f = x['accessDataStructField']?['fieldIdentifier'];
          if (f is Map && f['name'] == 'totalGoodPowerAllTime') {
            x['accessDataStructField']['fieldIdentifier'] = {'name': total.name, 'key': total.key};
            n++;
          }
          x.values.forEach(fix);
        } else if (x is List) {
          x.forEach(fix);
        }
      }
      fix(w['node']);
      if (n > 0) {
        save('GoodGamesPage', w);
        report.add('GoodGamesPage: Total Good Power of the selected period ($n ref)');
      } else {
        report.add('GoodGamesPage: Total Good Power already follows the period');
      }
    }
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [TestBadgeHomeAndTotal()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'TEST pill only on Home (overlay); Good Games total of the selected period',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
