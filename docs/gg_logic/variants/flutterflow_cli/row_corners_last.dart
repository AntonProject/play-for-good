// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Ranking row corners: the last row of the loaded list gets the bottom radius
// (stripe bottom-left, background bottom-left/right = 16), mirroring the
// existing top radius of place 1. Only these radius values change.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class RowCornersLast extends FlutterFlowAITask {
  @override
  String get name => 'gg-row-corners-last';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final isLast = findCustomFunction(p, name: 'ggIsLastPlayer')!.identifier.toProto3Json();
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'gamesUserComp');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final compKey = (w['node'] as Map)['key'];
    Map<String, dynamic> param(String name) => {
          'source': 'WIDGET_CLASS_PARAMETER',
          'baseVariable': {
            'widgetClass': {
              'paramIdentifier': ((w['params'] as Map).values
                  .firstWhere((p) => p['identifier']['name'] == name) as Map)['identifier']
            }
          },
          'nodeKeyRef': {'key': compKey},
        };
    Map<String, dynamic> radius() => {
          'variable': {
            'source': 'FUNCTION_CALL',
            'defaultValue': {'serializedValue': '0'},
            'functionCall': {
              'conditionalValue': {
                'ifConditionalValues': [
                  {
                    'condition': {
                      'source': 'FUNCTION_CALL',
                      'functionCall': {
                        'customFunction': isLast,
                        'values': [
                          {'variable': param('rankingJson')},
                          {'variable': param('playerJson')},
                        ],
                      },
                    },
                    'value': {'inputValue': {'serializedValue': '16'}},
                  }
                ],
                'elseValue': {'inputValue': {'serializedValue': '0'}},
                'returnParameter': {'dataType': {'scalarType': 'Double', 'nonNullable': true}},
              },
            },
          },
        };
    var n = 0;
    void walk(Map<String, dynamic> node) {
      final corners = {
        'Container_9xooiwg2': ['bottomLeftValue', 'bottomRightValue'],
        'Container_rzgvzjsq': ['bottomLeftValue'],
      }[node['key']];
      if (corners != null) {
        final deco = ((node['props'] as Map)['container'] as Map)
            .putIfAbsent('boxDecoration', () => <String, dynamic>{}) as Map;
        final br = deco.putIfAbsent('borderRadius', () => <String, dynamic>{}) as Map;
        for (final c in corners) {
          br[c] = radius();
          n++;
        }
      }
      for (final c in (node['children'] as List? ?? [])) walk(c as Map<String, dynamic>);
    }
    walk(w['node']);
    if (n != 3) throw StateError('Expected 3 corners, set $n');
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('Bottom corners of the last row: $n values.');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RowCornersLast()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games rows: rounded bottom corners on the last row',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
