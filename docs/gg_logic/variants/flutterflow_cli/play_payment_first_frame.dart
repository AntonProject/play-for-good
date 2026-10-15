// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// PlayPaymentPage: red error screen for a moment on open.
// Cause: page state gamePage is assigned in On Load, which runs after the first
// frame and only after the awaited status bar action (setStatusBarColor /
// forceStatusBarWhite); meanwhile 7 expressions read
// `gamePage!.<field>` and throw. Fix:
//  * On Load: the state update (paymentType, gamePage) moves before
//    setStatusBarColor, so the data is there on the next frame;
//  * the page body (ConditionalBuilder under the Scaffold) is shown only when
//    gamePage exists, so the first frame is the plain background, not an error.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'PlayPaymentPage';

final class PlayPaymentFirstFrame extends FlutterFlowAITask {
  @override
  String get name => 'gg-play-payment-first-frame';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final root = w['node'] as Map<String, dynamic>;
    final field = ((w['classModel'] as Map)['stateFields'] as List)
        .firstWhere((f) => f['parameter']['identifier']['name'] == 'gamePage')['parameter']['identifier'];

    // 1. On Load order.
    final trigger = (root['triggerActions'] as List)
        .firstWhere((t) => t['trigger']['triggerType'] == 'ON_INIT_STATE') as Map<String, dynamic>;
    final chain = <Map<String, dynamic>>[];
    for (Map<String, dynamic>? n = trigger['rootAction']; n != null; n = n['followUpAction']) {
      chain.add(n);
    }
    bool isStatusBar(Map n) => const ['setStatusBarColor', 'forceStatusBarWhite']
        .contains(n['action']?['customAction']?['customActionIdentifier']?['name']);
    bool setsGame(Map n) => jsonEncode(n['action']?['localStateUpdate'] ?? {}).contains('"${field['key']}"');
    final bar = chain.indexWhere(isStatusBar);
    final update = chain.indexWhere(setsGame);
    if (bar < 0 || update < 0) throw StateError('On Load not as expected');
    if (update > bar) {
      final moved = chain.removeAt(update);
      chain.insert(bar, moved);
      for (final n in chain) {
        n.remove('followUpAction');
      }
      for (var i = 0; i < chain.length - 1; i++) {
        chain[i]['followUpAction'] = chain[i + 1];
      }
      trigger['rootAction'] = chain.first;
    }

    // 2. Body only when gamePage exists.
    final body = (root['children'] as List).single as Map<String, dynamic>;
    if (body['props']?['visibility'] != null) throw StateError('Body already has a visibility');
    (body['props'] ??= <String, dynamic>{})['visibility'] = {
      'visibleValue': {
        'variable': {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'condition': {'relation': 'EXISTS_AND_NON_EMPTY'},
            'values': [
              {
                'variable': {
                  'source': 'LOCAL_STATE',
                  'baseVariable': {'localState': {'fieldIdentifier': field, 'stateVariableType': 'WIDGET_CLASS_STATE'}},
                  'nodeKeyRef': {'key': root['key']},
                }
              }
            ],
          },
        }
      }
    };

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('PlayPaymentPage: gamePage update moved from #$update to #$bar in On Load; '
        'body ${body['key']} visible when gamePage exists');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PlayPaymentFirstFrame()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'PlayPaymentPage: no red screen before gamePage is set',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
