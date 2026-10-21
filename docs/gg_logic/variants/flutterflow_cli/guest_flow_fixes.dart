// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Guest flow fixes (16.10.2026, found on the simulator in the prod guest mode;
// customer's original code):
//  1 PlayPaymentPage, guest: white screen. Text_65r7zhhh ("Nach der
//    Registrierung kannst du ... Spendenbescheinigung aktivieren.") was Expanded
//    inside a Column in the scroll view (unbounded height): the layout threw and
//    no frame was painted. The Text is no longer Expanded (only such case in the
//    project, checked by a scan).
//  2 Conditions on the result of a bottom sheet / dialog (the auth dialog:
//    success, successAuth, wasSuccessAuth) were generated as `_model.x!`;
//    closing the dialog returns null -> "Null check operator used on a null
//    value". They become `x == true` (closed = not signed in).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const expandedText = ('PlayPaymentPage', 'Text_65r7zhhh');

final class GuestFlowFixes extends FlutterFlowAITask {
  @override
  String get name => 'gg-guest-flow-fixes';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    for (final entry in p.widgetClasses.entries.toList()) {
      final cls = entry.value.name;
      if (cls.toLowerCase().contains('admin')) continue;
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      final notes = <String>[];

      // 1 Expanded Text in an unbounded Column
      if (cls == expandedText.$1) {
        Map? find(dynamic x) {
          if (x is Map) {
            if (x['key'] == expandedText.$2 && x.containsKey('type')) return x;
            for (final v in x.values) {
              final r = find(v);
              if (r != null) return r;
            }
          } else if (x is List) {
            for (final v in x) {
              final r = find(v);
              if (r != null) return r;
            }
          }
          return null;
        }
        final t = find(w['node']) ?? (throw StateError('$cls: ${expandedText.$2} not found'));
        final ex = (t['props'] as Map)['expanded'] as Map?;
        if (ex?['expandedType'] == 'EXPANDED') {
          ex!['expandedType'] = 'UNEXPANDED';
          notes.add('${expandedText.$2} not Expanded');
        }
      }

      // 2 dialog results: keys of bottom sheet / dialog actions with an output
      final dialogActions = <String>{};
      void collect(dynamic x) {
        if (x is Map) {
          final a = x['action'];
          if (a is Map && a['outputVariableName'] != null &&
              (a['bottomSheet'] != null || a['alertDialog'] != null)) {
            dialogActions.add(a['key'] as String);
          }
          x.values.forEach(collect);
        } else if (x is List) {
          x.forEach(collect);
        }
      }
      collect(w);
      var wrapped = 0;
      void fix(dynamic x) {
        if (x is Map) {
          final ca = x['conditionActions'];
          if (ca is Map) {
            for (final t in (ca['trueActions'] as List? ?? [])) {
              final cond = t['condition'] as Map?;
              final v = cond?['variable'];
              if (v is Map && v['source'] == 'ACTION_OUTPUTS' &&
                  ((v['operations'] as List?) ?? const []).isEmpty &&
                  dialogActions.contains(v['baseVariable']?['actionOutput']?['actionKeyRef']?['key'])) {
                cond!['variable'] = {
                  'source': 'FUNCTION_CALL',
                  'functionCall': {
                    'values': [
                      {'variable': v},
                      {'inputValue': {'serializedValue': 'true'}},
                    ],
                    'condition': {'relation': 'EQUAL_TO'},
                  },
                };
                wrapped++;
              }
            }
          }
          x.values.forEach(fix);
        } else if (x is List) {
          x.forEach(fix);
        }
      }
      fix(w);
      if (wrapped > 0) notes.add('dialog result conditions == true x$wrapped');

      if (notes.isEmpty) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      report.add('$cls: ${notes.join(', ')}');
    }
    stdout.writeln(report.isEmpty ? 'nothing to change' : report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [GuestFlowFixes()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Guest flow: payment page layout, closed auth dialog without null errors',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
