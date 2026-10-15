// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Good News still jumped to the top after loading more posts: FF keys a
// component inside a generator as 'Key<id>_<index>_of_<length>', so when the
// list grew every card got a new key, was rebuilt and, while its user /
// organization queries reloaded, collapsed to ~0 px (scroll position clamped).
// Now the list is rendered page by page (25 posts, as loaded):
//   outer Column generator over ggPostPages(ggPosts)            (page numbers)
//     inner Column (the existing Column_wpfp8w9t) over ggPostsSlice(ggPosts, page)
//       post card (unchanged)
// A loaded page keeps its length, so its cards keep their keys and state when
// the next page is appended. Requires ggPostPages / ggPostsSlice (transfer.dart).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const inner = 'Column_wpfp8w9t';
String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.postpages.$seed');

final class PostsPagesLayout extends FlutterFlowAITask {
  PostsPagesLayout({this.after = const {}});
  final Set<String> after;
  @override
  Set<String> get dependsOn => after;
  @override
  String get name => 'gg-posts-pages-layout';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    FFIdentifier fn(String name) =>
        (p.customCode.customFunctions.where((f) => f.identifier.name == name).firstOrNull ??
                (throw StateError('$name custom function is missing')))
            .identifier;
    final pages = fn('ggPostPages');
    final slice = fn('ggPostsSlice');

    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'GoodNewsPage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    Map<String, dynamic>? parentOf(Map<String, dynamic> n, String k) {
      for (final c in (n['children'] as List? ?? [])) {
        if ((c as Map)['key'] == k) return n;
        final r = parentOf(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    final parent = parentOf(w['node'], inner) ?? (throw StateError('$inner not found'));
    final kids = parent['children'] as List;
    final i = kids.indexWhere((c) => c['key'] == inner);
    final col = kids[i] as Map<String, dynamic>;
    final gen = col['generatorVariable'] as Map<String, dynamic>;
    final postsVar = gen['variable'] as Map<String, dynamic>;
    if (postsVar['source'] != 'LOCAL_STATE' || !jsonEncode(postsVar).contains('ggPosts')) {
      throw StateError('$inner is not the ggPosts generator (already paged?)');
    }
    final outerKey = 'Column_${key('outer')}';
    // inner: posts of the current page
    gen['variable'] = {
      'source': 'FUNCTION_CALL',
      'functionCall': {
        'values': [
          {'variable': jsonDecode(jsonEncode(postsVar))},
          {
            'variable': {
              'source': 'GENERATOR_VARIABLE',
              'baseVariable': {'generatorVariable': {}},
              'nodeKeyRef': {'key': outerKey},
            }
          },
        ],
        'customFunction': {'name': slice.name, 'key': slice.key},
      },
    };
    // outer: page numbers, same layout as the inner column (spacing 24)
    final outer = {
      'key': outerKey,
      'type': 'Column',
      'props': jsonDecode(jsonEncode(col['props'])),
      'generatorVariable': {
        'identifier': {'name': 'postPage', 'key': key('outer.var')},
        'variable': {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'values': [
              {'variable': jsonDecode(jsonEncode(postsVar))},
            ],
            'customFunction': {'name': pages.name, 'key': pages.key},
          },
        },
      },
      'children': [col],
    };
    kids[i] = outer;
    for (final r in (parent['childPropertyMap'] as Map? ?? {}).values) {
      for (final ref in ((r as Map)['keyRefs'] as List? ?? [])) {
        if (ref['key'] == inner) ref['key'] = outerKey;
      }
    }
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('GoodNewsPage: posts rendered page by page (ggPostPages / ggPostsSlice)');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PostsPagesLayout()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good News: posts page by page, cards keep keys (no jump)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
