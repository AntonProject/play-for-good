// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Restores the row divider visibility in gamesUserComp: shown when showDivider
// is true and the row is not the last one of the loaded ranking page.
// Only the divider's visibility changes; its look (indent etc.) is kept.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const dividerKey = 'Divider_7rjrbpl5';

final class DividerLastRow extends FlutterFlowAITask {
  @override
  String get name => 'gg-divider-last-row';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final isLast = findCustomFunction(p, name: 'ggIsLastPlayer')!.identifier.toProto3Json();
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'gamesUserComp');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final compKey = (w['node'] as Map)['key'];
    Map<String, dynamic> ident(String name) => ((w['params'] as Map).values
        .firstWhere((p) => p['identifier']['name'] == name) as Map)['identifier'] as Map<String, dynamic>;
    Map<String, dynamic> paramVar(String name) => {
          'source': 'WIDGET_CLASS_PARAMETER',
          'baseVariable': {'widgetClass': {'paramIdentifier': ident(name)}},
          'nodeKeyRef': {'key': compKey},
        };
    Map<String, dynamic> equals(Map<String, dynamic> v, String literal) => {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'condition': {'relation': 'EQUAL_TO'},
            'values': [
              {'variable': v},
              {'inputValue': {'serializedValue': literal}},
            ],
          },
        };
    var found = false;
    void walk(Map<String, dynamic> n) {
      if (n['key'] == dividerKey) {
        found = true;
        (n['props'] as Map<String, dynamic>)['visibility'] = {
          'visibleValue': {
            'variable': {
              'source': 'FUNCTION_CALL',
              'functionCall': {
                'combineConditions': {'operator': 'AND_OP'},
                'values': [
                  {'variable': equals(paramVar('showDivider')..['defaultValue'] = {'serializedValue': 'true'}, 'true')},
                  {'variable': equals({
                    'source': 'FUNCTION_CALL',
                    'functionCall': {
                      'customFunction': isLast,
                      'values': [
                        {'variable': paramVar('rankingJson')},
                        {'variable': paramVar('playerJson')},
                      ],
                    },
                  }, 'false')},
                ],
              },
            },
          },
        };
      }
      for (final c in (n['children'] as List? ?? [])) walk(c as Map<String, dynamic>);
    }
    walk(w['node']);
    if (!found) throw StateError('$dividerKey not found');
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('Divider visibility: showDivider && !ggIsLastPlayer.');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [DividerLastRow()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games rows: no divider under the last row',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
