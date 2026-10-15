// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Ranking rows: the divider moves inside gamesUserComp (bottom of the row,
// full width), the row's stripe/background cover the whole row height.
// Row height is unchanged: stripe 84 + outer padding 16+16 -> stripe 116.
// Only the listed nodes change; old generator dividers are hidden, not deleted.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) =>
    generateRandomAlphaNumericString(seedString: 'pfg.gg.rowdivider.$seed');

Map<String, dynamic> nodesOf(Map<String, dynamic> root) {
  final out = <String, dynamic>{};
  void walk(Map<String, dynamic> n) {
    out[n['key'] as String] = n;
    for (final c in (n['children'] as List? ?? [])) walk(c as Map<String, dynamic>);
  }
  walk(root);
  return out;
}

void replaceClass(FFProject p, String name, void Function(Map<String, dynamic>) edit) {
  final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == name);
  final json = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
  edit(json);
  final next = FFWidgetClass()..mergeFromProto3Json(json);
  restoreUnknownFields(entry.value, next);
  p.widgetClasses[entry.key] = next;
}

final class RowDivider extends FlutterFlowAITask {
  @override
  String get name => 'gg-row-divider';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final isLast = findCustomFunction(p, name: 'ggIsLastPlayer')!.identifier.toProto3Json();
    late Map<String, dynamic> showParam;

    replaceClass(p, 'gamesUserComp', (w) {
      final n = nodesOf(w['node'] as Map<String, dynamic>);
      final compKey = (w['node'] as Map)['key'];
      final params = w.putIfAbsent('params', () => <String, dynamic>{}) as Map<String, dynamic>;
      Map<String, dynamic> paramIdent(String name) => (params.values
          .firstWhere((p) => p['identifier']['name'] == name) as Map)['identifier'] as Map<String, dynamic>;
      if (!params.values.any((p) => p['identifier']['name'] == 'showDivider')) {
        final ident = {'name': 'showDivider', 'key': key('param')};
        params[ident['key']!] = {
          'identifier': ident,
          'dataType': {'scalarType': 'Boolean', 'nonNullable': false},
          'defaultValue': {'serializedValue': 'true'},
        };
      }
      showParam = paramIdent('showDivider');
      Map<String, dynamic> paramVar(String name) => {
            'source': 'WIDGET_CLASS_PARAMETER',
            'baseVariable': {'widgetClass': {'paramIdentifier': paramIdent(name)}},
            'nodeKeyRef': {'key': compKey},
          };
      // Stripe covers the full row height that the outer padding used to add.
      final stripe = n['Container_rzgvzjsq']['props']['container']['dimensions']['height'];
      stripe['pixelsValue'] = {'inputValue': 116};
      final body = n['Container_9xooiwg2'] as Map<String, dynamic>;
      final row = (body['children'] as List).single as Map<String, dynamic>;
      if (row['type'] == 'Column') throw StateError('Divider already moved into gamesUserComp');
      final divider = {
        'key': 'Divider_${key('divider')}',
        'type': 'Divider',
        'props': {
          'divider': {
            'heightValue': {'inputValue': 1},
            'thicknessValue': {'inputValue': 1},
            'colorValue': {'inputValue': {'value': '4291743169', 'paletteColorName': 'divider'}},
            'indentValue': {'inputValue': 0},
            'endIndentValue': {'inputValue': 0},
          },
          'visibility': {
            'visibleValue': {
              'variable': {
                'source': 'FUNCTION_CALL',
                'functionCall': {
                  'combineConditions': {'operator': 'AND_OP'},
                  'values': [
                    {'variable': {
                      'source': 'FUNCTION_CALL',
                      'functionCall': {
                        'condition': {'relation': 'EQUAL_TO'},
                        'values': [
                          {'variable': paramVar('showDivider')..['defaultValue'] = {'serializedValue': 'true'}},
                          {'inputValue': {'serializedValue': 'true'}},
                        ],
                      },
                    }},
                    {'variable': {
                      'source': 'FUNCTION_CALL',
                      'functionCall': {
                        'condition': {'relation': 'EQUAL_TO'},
                        'values': [
                          {'variable': {
                            'source': 'FUNCTION_CALL',
                            'functionCall': {
                              'customFunction': isLast,
                              'values': [
                                {'variable': paramVar('rankingJson')},
                                {'variable': paramVar('playerJson')},
                              ],
                            },
                          }},
                          {'inputValue': {'serializedValue': 'false'}},
                        ],
                      },
                    }},
                  ],
                },
              },
            },
          },
        },
      };
      body['children'] = [
        {
          'key': 'Column_${key('column')}',
          'type': 'Column',
          'props': {'column': {'minSizeValue': {'inputValue': 'main_axis_min'}}},
          'children': [row, divider],
        }
      ];
    });

    replaceClass(p, 'GoodGamesPage', (w) {
      final n = nodesOf(w['node'] as Map<String, dynamic>);
      for (final d in ['Divider_p0etyffr', 'Divider_kly9xj62']) {
        (n[d]['props'] as Map)['visibility'] = {'visibleValue': {'inputValue': false}};
      }
      for (final c in ['Container_x6xywqe6', 'Container_pm65r2z0', 'Container_hsks3evp', 'Container_spkska2u']) {
        final pad = n[c]['props']['padding'] as Map;
        pad['topValue'] = {'inputValue': 0};
        pad['bottomValue'] = {'inputValue': 0};
      }
      // Pinned "me" rows keep their dotted separator above; no line below.
      for (final c in ['Container_hsks3evp', 'Container_spkska2u']) {
        final passes = n[c]['parameterValues']['parameterPasses'] as Map;
        passes[showParam['key']] = {
          'paramIdentifier': showParam,
          'inputValue': {'serializedValue': 'false'},
        };
      }
    });
    stdout.writeln('Row divider moved into gamesUserComp; 4 instances updated.');
  }
}

Future<void> main(List<String> args) async {
  final key = Platform.environment['FF_API_KEY']!;
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: key,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RowDivider()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games rows: divider inside row, full-height stripe/background',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
