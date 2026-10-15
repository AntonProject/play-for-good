// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// In the userProfile dialog infoStatsPeriod is an Integer tab (1 = current
// season, 2 = All-Time), unlike the page (String key). Fixes the bindings:
// default back to 1, RPC period 1->'auto' / 2->'all_time', no write-back of the
// period key into the int state, period label taken from the response.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class FixDialogPeriod extends FlutterFlowAITask {
  @override
  String get name => 'gg-fix-profile-dialog-period';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'userProfile');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final field = ((w['classModel'] as Map)['stateFields'] as List)
        .firstWhere((f) => f['parameter']['identifier']['name'] == 'infoStatsPeriod') as Map;
    field['serializedDefaultValue'] = ['1'];
    final periodIdent = field['parameter']['identifier'];
    final report = <String, int>{};
    void count(String k) => report[k] = (report[k] ?? 0) + 1;
    bool usesPeriod(dynamic x) => jsonEncode(x).contains('"name":"infoStatsPeriod"');
    void walk(dynamic x) {
      if (x is Map) {
        final f = x['functionCall'];
        if (f is Map) {
          final name = (f['customFunction'] as Map?)?['name'];
          final values = f['values'] as List?;
          if (name == 'ggPeriodKey' && values != null && usesPeriod(values)) {
            final stateVar = (values.first as Map)['variable'];
            x['functionCall'] = {
              'conditionalValue': {
                'ifConditionalValues': [
                  {
                    'condition': {
                      'source': 'FUNCTION_CALL',
                      'functionCall': {
                        'condition': {'relation': 'EQUAL_TO'},
                        'values': [
                          {'variable': stateVar},
                          {'inputValue': {'serializedValue': '2'}},
                        ],
                      },
                    },
                    'value': {'inputValue': {'serializedValue': 'all_time'}},
                  }
                ],
                'elseValue': {'inputValue': {'serializedValue': 'auto'}},
                'returnParameter': {'dataType': {'scalarType': 'String', 'nonNullable': true}},
              },
            };
            count('ggPeriodKey(int)->conditional');
          } else if (name == 'ggPeriodLabel' && values != null && values.isNotEmpty && usesPeriod(values.first)) {
            values[0] = {'inputValue': {'serializedValue': 'auto'}};
            count('ggPeriodLabel->response label');
          }
        }
        final upd = x['localStateUpdate'];
        if (upd is Map && upd['updates'] is List) {
          final before = (upd['updates'] as List).length;
          (upd['updates'] as List).removeWhere((u) =>
              (u as Map)['fieldIdentifier']?['key'] == periodIdent['key'] &&
              jsonEncode(u).contains('ACTION_OUTPUTS'));
          if ((upd['updates'] as List).length != before) count('removed period write-back');
        }
        x.values.forEach(walk);
      } else if (x is List) {
        x.forEach(walk);
      }
    }
    walk(w);
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('userProfile period fixes: $report');
    if (!report.containsKey('ggPeriodKey(int)->conditional')) throw StateError('RPC period not found');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [FixDialogPeriod()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Profile dialog: integer Stats period mapped to RPC period',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
