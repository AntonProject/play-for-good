// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Good News empty state (16.10.2026): the image Post.png is visible when
// ggPostsLoaded AND no posts (empty_states_after_load.dart).
// The flag update at the end of ggRefreshPosts had the state key without its
// name and sat behind an empty step, and the exported code had no
// `ggPostsLoaded = true`, so an empty feed showed nothing. The update gets the
// name, empty steps of the block are removed (adds the update if missing).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.postsloaded.$seed');

final class PostsLoadedFlag extends FlutterFlowAITask {
  @override
  String get name => 'gg-posts-loaded-flag';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'GoodNewsPage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final state = ((w['classModel'] as Map)['stateFields'] as List)
        .firstWhere((f) => f['parameter']['identifier']['name'] == 'ggPostsLoaded',
            orElse: () => throw StateError('GoodNewsPage: state ggPostsLoaded missing'));
    final stateKey = state['parameter']['identifier']['key'] as String;
    final blocks = (w['classModel'] as Map)['actionComponentsConfig']['actionComponents'] as List;
    final b = blocks.firstWhere((x) => x['identifier']['name'] == 'ggRefreshPosts') as Map<String, dynamic>;
    final notes = <String>[];
    // Chain of the block: drop empty steps (no action, no condition).
    var node = b['actions']['rootAction'] as Map<String, dynamic>;
    while (node['followUpAction'] != null) {
      final next = node['followUpAction'] as Map<String, dynamic>;
      if (next['action'] == null && next['conditionActions'] == null) {
        notes.add('empty step ${next['key']} removed');
        if (next['followUpAction'] != null) {
          node['followUpAction'] = next['followUpAction'];
        } else {
          node.remove('followUpAction');
        }
        continue;
      }
      node = next;
    }
    // Existing flag update: the field identifier gets its name (it had the key only).
    var named = false;
    void fix(dynamic x) {
      if (x is Map) {
        final f = x['fieldIdentifier'];
        if (f is Map && f['key'] == stateKey) {
          if (f['name'] != 'ggPostsLoaded') {
            f['name'] = 'ggPostsLoaded';
            notes.add('flag update named');
          }
          named = true;
        }
        x.values.forEach(fix);
      } else if (x is List) {
        x.forEach(fix);
      }
    }
    fix(b);
    if (!named) {
      node['followUpAction'] = _setFlag(stateKey);
      notes.add('ggPostsLoaded = true added at the end');
    }
    if (notes.isEmpty) {
      stdout.writeln('GoodNewsPage: ggRefreshPosts already sets ggPostsLoaded');
      return;
    }
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('GoodNewsPage ggRefreshPosts: ${notes.join(', ')}');
  }
}

Map<String, dynamic> _setFlag(String stateKey) => {
      'key': key('node'),
      'action': {
        'key': key('action'),
        'localStateUpdate': {
          'updates': [
            {
              'fieldIdentifier': {'name': 'ggPostsLoaded', 'key': stateKey},
              'setValue': {'inputValue': {'serializedValue': 'true'}},
            }
          ],
          'updateType': 'WIDGET',
          'stateVariableType': 'WIDGET_CLASS_STATE',
        },
      },
    };

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PostsLoadedFlag()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good News: empty state after loading (ggPostsLoaded)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
