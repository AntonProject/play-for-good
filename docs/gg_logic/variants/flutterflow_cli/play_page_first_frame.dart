// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// PlayPage: red error screen on open (null check on `_model.game!`).
// After the guest merge (merge_guest_play.dart) the page body is no longer
// behind the profile StreamBuilder that used to show a loader until On Load had
// set `game`; and ggRefreshMe was put first in On Load and awaited, delaying
// `game` until a network call returned. Fix:
//  * On Load: ggRefreshMe moves to the end (game is set at once);
//  * the page body (Stack under the Scaffold) is built only when game exists,
//    via a ConditionalBuilder (a Visibility still evaluated `game!`).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'PlayPage';

final class PlayPageFirstFrame extends FlutterFlowAITask {
  @override
  String get name => 'gg-play-page-first-frame';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final root = w['node'] as Map<String, dynamic>;
    final field = ((w['classModel'] as Map)['stateFields'] as List)
        .firstWhere((f) => f['parameter']['identifier']['name'] == 'game')['parameter']['identifier'];

    // 1. ggRefreshMe to the end of On Load.
    final trigger = (root['triggerActions'] as List)
        .firstWhere((t) => t['trigger']['triggerType'] == 'ON_INIT_STATE') as Map<String, dynamic>;
    final chain = <Map<String, dynamic>>[];
    for (Map<String, dynamic>? n = trigger['rootAction']; n != null; n = n['followUpAction']) {
      chain.add(n);
    }
    final me = chain.indexWhere((n) =>
        n['action']?['executeActionComponent']?['actionComponentIdentifier']?['name'] == 'ggRefreshMe');
    if (me < 0) throw StateError('ggRefreshMe not in On Load');
    // (already last after the first run: moving it again changes nothing)
    final moved = chain.removeAt(me);
    chain.add(moved);
    for (final n in chain) {
      n.remove('followUpAction');
    }
    for (var i = 0; i < chain.length - 1; i++) {
      chain[i]['followUpAction'] = chain[i + 1];
    }
    trigger['rootAction'] = chain.first;

    // 2. Body only when game exists, through a ConditionalBuilder: a Visibility
    // would still construct the Stack and evaluate `_model.game!` eagerly.
    final body = (root['children'] as List).single as Map<String, dynamic>;
    (body['props'] as Map?)?.remove('visibility'); // first attempt (eager)
    final gameExists = {
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
    };
    String k(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.playframe.$seed');
    final wrapper = {
      'key': 'ConditionalBuilder_${k('builder')}',
      'type': 'ConditionalBuilder',
      'props': {'conditionalBuilder': {}},
      'children': [
        {
          'key': 'PlaceholderWidget_${k('if')}',
          'type': 'PlaceholderWidget',
          'props': {'placeholderWidget': {}, 'visibility': {'visibleValue': gameExists}},
          'children': [body],
        },
        {
          'key': 'PlaceholderWidget_${k('else')}',
          'type': 'PlaceholderWidget',
          'props': {'placeholderWidget': {}, 'visibility': {'visibleValue': {'mostRecentInputValue': false}}},
          'children': [
            {'key': 'Container_${k('empty')}', 'type': 'Container', 'props': {'container': {}}}
          ],
        },
      ],
    };
    root['children'] = [wrapper];
    final slots = (root['childPropertyMap']?['body']?['keyRefs'] as List?) ?? [];
    for (final r in slots) {
      if (r['key'] == body['key']) r['key'] = wrapper['key'];
    }
    if (slots.every((r) => r['key'] != wrapper['key'])) throw StateError('Scaffold body slot not repointed');

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('PlayPage: ggRefreshMe at #$me of On Load (end); body ${body['key']} '
        'inside ${wrapper['key']} (built only when game exists)');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PlayPageFirstFrame()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'PlayPage: no red screen before game is set',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
