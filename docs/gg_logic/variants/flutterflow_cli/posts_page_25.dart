// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Good News: the list jumped back to the top when the next page was appended.
// Each post card's key was 'Keyc5u_<index>_of_<length>' (FF default for a
// generator child): when 10 more posts arrived the length changed, so every card
// was rebuilt from scratch, briefly without its author (smaller height), and the
// scroll position collapsed. Now:
//  * the post card's key is the post id (valueKey), cards survive appends;
//  * pages are 25 posts: ggPostsWindow (first page / refresh) and ggMorePosts.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const generator = 'Column_wpfp8w9t';
const card = 'Container_c5uyqrvs';
const pageSize = '25';
final windowSource = '${Platform.environment['GG_VARIANTS_ROOT'] ?? '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants'}'
    '/02_rpc/flutterflow/functions/gg_posts_window.dart';

final class PostsPage25 extends FlutterFlowAITask {
  @override
  String get name => 'gg-posts-page-25';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    // 1. ggPostsWindow body from the source file (FF stores the body only).
    final src = File(windowSource).readAsStringSync();
    final body = src.substring(src.indexOf('{', src.indexOf('ggPostsWindow(')) + 1, src.lastIndexOf('}'));
    if (!body.contains('25')) throw StateError('ggPostsWindow source is not the 25 version');
    updateCustomFunction(p, name: 'ggPostsWindow', code: body);

    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'GoodNewsPage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    // 2. ggMorePosts: limit and hasMore page size 10 -> 25.
    final blocks = ((w['classModel'] as Map)['actionComponentsConfig'] as Map)['actionComponents'] as List;
    final more = blocks.cast<Map>().where((b) => jsonEncode(b).contains('ggPostsConcat')).single;
    var tens = 0;
    void walk(Object? n) {
      if (n is Map) {
        if (n['serializedValue'] == '10') {
          n['serializedValue'] = pageSize;
          tens++;
        }
        n.values.forEach(walk);
      } else if (n is List) {
        n.forEach(walk);
      }
    }
    walk(more);
    if (tens != 2 && !jsonEncode(more).contains('"serializedValue":"$pageSize"')) {
      throw StateError('ggMorePosts: expected 2 page sizes, found $tens');
    }
    // 3. Stable card key = post id.
    Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
      if (n['key'] == k) return n;
      for (final c in (n['children'] as List? ?? [])) {
        final r = find(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    final c = find(w['node'], card) ?? (throw StateError('$card not found'));
    c['valueKey'] = {
      'variable': {
        'source': 'GENERATOR_VARIABLE',
        'baseVariable': {'generatorVariable': {}},
        'nodeKeyRef': {'key': generator},
        'operations': [
          {
            'accessPostgresRowField': {
              'fieldIdentifier': {'name': 'id'}
            }
          }
        ],
      }
    };
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('ggPostsWindow: first page 25; ggMorePosts: $tens page size(s) -> 25; '
        'post card key = post id');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PostsPage25()],
    source: PipelineSource.paths([Platform.script.toFilePath(), windowSource]),
    commitMessage: 'Good News: 25 posts per page, stable post keys (no jump)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
