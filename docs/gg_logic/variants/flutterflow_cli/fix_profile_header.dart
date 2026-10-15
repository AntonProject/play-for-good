// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// userProfilePage header fix: the profile overlay bound Text_nfa5jrbd (the
// @handle) to Good Power by mistake and dropped the " LW" suffix of
// Text_wn608uvw. Restores the handle exactly from the pre-push snapshot and
// rebuilds the Good Power text as before ("<value> LW"), with only the value
// switched to the RPC (old value as fallback until ggProfile is loaded).
//   dart run dsl/gg_fix_profile_header.dart <before_profile_page.json> [--apply]
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

Map<String, dynamic>? find(Map<String, dynamic> n, String key) {
  if (n['key'] == key) return n;
  for (final c in (n['children'] as List? ?? [])) {
    final r = find(c as Map<String, dynamic>, key);
    if (r != null) return r;
  }
  return null;
}

final class FixProfileHeader extends FlutterFlowAITask {
  FixProfileHeader(this.before);
  final Map<String, dynamic> before;
  @override
  String get name => 'gg-fix-profile-header';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'userProfilePage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final page = (w['node'] as Map)['key'];
    Map<String, dynamic> textValue(Map<String, dynamic> root, String key) =>
        ((find(root, key)!['props'] as Map)['text'] as Map)['textValue'] as Map<String, dynamic>;

    // 1. @handle exactly as before the bindings push.
    final handle = textValue(w['node'], 'Text_nfa5jrbd');
    handle
      ..clear()
      ..addAll(jsonDecode(jsonEncode(textValue(before['node'], 'Text_nfa5jrbd'))));

    // 2. Good Power: original "<value> LW" with the value from the RPC.
    final field = ((w['classModel'] as Map)['stateFields'] as List)
        .firstWhere((f) => f['parameter']['identifier']['name'] == 'ggProfile');
    final profile = {
      'source': 'LOCAL_STATE',
      'baseVariable': {
        'localState': {'fieldIdentifier': field['parameter']['identifier'], 'stateVariableType': 'WIDGET_CLASS_STATE'}
      },
      'nodeKeyRef': {'key': page},
    };
    Map<String, dynamic> fn(String name, List<Map<String, dynamic>> values, [List? ops]) => {
          'source': 'FUNCTION_CALL',
          if (ops != null) 'operations': ops,
          'functionCall': {
            'customFunction': findCustomFunction(p, name: name)!.identifier.toProto3Json(),
            'values': values,
          },
        };
    final original = jsonDecode(jsonEncode(textValue(before['node'], 'Text_wn608uvw'))) as Map<String, dynamic>;
    final values = original['variable']['functionCall']['values'] as List;
    final oldValue = values.first as Map<String, dynamic>;
    values[0] = {
      'variable': {
        'source': 'FUNCTION_CALL',
        'functionCall': {
          'conditionalValue': {
            'ifConditionalValues': [
              {
                'condition': fn('ggHasData', [{'variable': profile}]),
                'value': {
                  'variable': fn('ggMetricValue', [
                    {'variable': profile},
                    {'inputValue': {'serializedValue': 'good_power'}},
                    {'inputValue': {'serializedValue': 'true'}},
                  ], [
                    {'numberFormat': {'formatType': 'CUSTOM', 'customFormat': '#,##0', 'customLocale': 'de_DE'}}
                  ]),
                },
              }
            ],
            'elseValue': oldValue,
            'returnParameter': {'dataType': {'scalarType': 'String', 'nonNullable': true}},
          },
        },
      },
    };
    final gp = textValue(w['node'], 'Text_wn608uvw');
    gp
      ..clear()
      ..addAll(original);

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('Profile header: handle restored, Good Power "<value> LW" from RPC.');
  }
}

Future<void> main(List<String> args) async {
  final before = (jsonDecode(File(args.first).readAsStringSync()) as Map<String, dynamic>);
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [FixProfileHeader(before)],
    source: PipelineSource.paths([Platform.script.toFilePath(), args.first]),
    commitMessage: 'Profile header: restore @handle, Good Power with LW',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
