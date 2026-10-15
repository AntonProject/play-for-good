// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Empty states appear only after the first load finished, so they no longer
// flash while data is on its way:
//  * GoodNewsPage: the list's built-in empty image is switched off; the same
//    image (Post.png, same paddings and radius) sits next to the list and is
//    visible when ggPostsLoaded AND ggPosts is empty; ggPostsLoaded is set at the
//    end of ggRefreshPosts;
//  * HomePage ("Noch keine Games", "Keine Organisationen") and EnergyPage (empty
//    "Letzte Wirkung" image): the empty branch is visible after ggMyGamesLoaded,
//    set at the end of ggRefreshMyGames (also for guests, who have no games).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.emptyafterload.$seed');

const targets = {
  // page: [block, loaded state, empty-state node keys]
  'GoodNewsPage': ['ggRefreshPosts', 'ggPostsLoaded', <String>[]],
  'HomePage': ['ggRefreshMyGames', 'ggMyGamesLoaded', ['Container_lvsrwm25', 'Container_ish6skw9']],
  'EnergyPage': ['ggRefreshMyGames', 'ggMyGamesLoaded', ['Image_3ctcgtj4']],
};
const postsColumn = 'Column_wpfp8w9t';

final class EmptyStatesAfterLoad extends FlutterFlowAITask {
  @override
  String get name => 'gg-empty-states-after-load';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    for (final page in targets.keys) {
      final t = targets[page]!;
      final block = t[0] as String, loadedName = t[1] as String, empties = t[2] as List<String>;
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == page);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      if (jsonEncode(w).contains('"$loadedName"')) throw StateError('$page already has $loadedName');
      final root = (w['node'] as Map)['key'] as String;
      Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
        if (n['key'] == k) return n;
        for (final c in (n['children'] as List? ?? [])) {
          final r = find(c as Map<String, dynamic>, k);
          if (r != null) return r;
        }
        return null;
      }

      // State + "loaded" at the end of the block.
      final ident = {'name': loadedName, 'key': key('$page.state')};
      ((w['classModel'] as Map)['stateFields'] as List).add({
        'parameter': {'identifier': ident, 'dataType': {'scalarType': 'Boolean', 'nonNullable': true}},
        'serializedDefaultValue': ['false'],
      });
      Map<String, dynamic> st(Map id) => {
            'source': 'LOCAL_STATE',
            'baseVariable': {'localState': {'fieldIdentifier': id, 'stateVariableType': 'WIDGET_CLASS_STATE'}},
            'nodeKeyRef': {'key': root},
          };
      final blocks = ((w['classModel'] as Map)['actionComponentsConfig']['actionComponents'] as List);
      final b = blocks.firstWhere((x) => x['identifier']['name'] == block) as Map<String, dynamic>;
      Map<String, dynamic> tail = b['actions']['rootAction'] as Map<String, dynamic>;
      while (tail['followUpAction'] != null) {
        tail = tail['followUpAction'] as Map<String, dynamic>;
      }
      tail['followUpAction'] = {
        'key': key('$page.set.node'),
        'action': {
          'key': key('$page.set.action'),
          'localStateUpdate': {
            'updates': [
              {'fieldIdentifier': {'key': ident['key']}, 'setValue': {'inputValue': {'serializedValue': 'true'}}}
            ],
            'updateType': 'WIDGET',
            'stateVariableType': 'WIDGET_CLASS_STATE',
          },
        },
      };
      final loaded = {
        'source': 'FUNCTION_CALL',
        'functionCall': {
          'condition': {'relation': 'EQUAL_TO'},
          'values': [
            {'variable': st(ident)},
            {'inputValue': {'serializedValue': 'true'}},
          ],
        },
      };

      // Empty-state nodes visible after load.
      for (final k in empties) {
        final n = find(w['node'], k) ?? (throw StateError('$page/$k not found'));
        final props = (n['props'] ??= <String, dynamic>{}) as Map<String, dynamic>;
        if (props['visibility'] != null) throw StateError('$page/$k already has a visibility');
        props['visibility'] = {'visibleValue': {'variable': loaded}};
        report.add('$page/$k visible after $loadedName');
      }

      // Good News: own empty image next to the posts list.
      if (page == 'GoodNewsPage') {
        Map<String, dynamic>? parentOf(Map<String, dynamic> n, String k) {
          for (final c in (n['children'] as List? ?? [])) {
            if ((c as Map)['key'] == k) return n;
            final r = parentOf(c as Map<String, dynamic>, k);
            if (r != null) return r;
          }
          return null;
        }
        final column = find(w['node'], postsColumn)!;
        final emptyCfg = column['props']['emptyListWidget'] as Map<String, dynamic>;
        final image = jsonDecode(jsonEncode(emptyCfg['image'])) as Map<String, dynamic>;
        emptyCfg['show'] = false;
        image['dimensions'] = {'width': {'pixelsValue': {'inputValue': 'Infinity'}}};
        final postsState = ((w['classModel'] as Map)['stateFields'] as List)
            .firstWhere((f) => f['parameter']['identifier']['name'] == 'ggPosts')['parameter']['identifier'] as Map;
        final noPosts = {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'condition': {'relation': 'EQUAL_TO'},
            'values': [
              {'variable': {...st(postsState), 'operations': [{'listNumItems': {}}]}},
              {'inputValue': {'serializedValue': '0'}},
            ],
          },
        };
        final parent = parentOf(w['node'], postsColumn)!;
        final i = (parent['children'] as List).indexWhere((c) => c['key'] == postsColumn);
        (parent['children'] as List).insert(i + 1, {
          'key': 'Image_${key('empty')}',
          'type': 'Image',
          'props': {
            'image': image,
            'padding': column['props']['padding'],
            'visibility': {
              'visibleValue': {
                'variable': {
                  'source': 'FUNCTION_CALL',
                  'functionCall': {
                    'combineConditions': {'operator': 'AND_OP'},
                    'values': [
                      {'variable': loaded},
                      {'variable': noPosts},
                    ],
                  },
                }
              }
            },
          },
        });
        report.add('GoodNewsPage: list empty image off, own Post.png visible after load when no posts');
      }
      report.add('$page: $block ends with $loadedName = true');

      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [EmptyStatesAfterLoad()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Empty states only after the first load (Good News, Home, Energy)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
