// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Fix for posts_pages_layout.dart: the page column (outer) got a copy of the
// posts column props, so the padding (12, 140, 12, 0) was applied twice: posts
// started 140 px lower and every page of 25 began with an extra 140 px gap.
// The inner (per-page) column loses its padding; the outer one keeps it, and
// keeps the 24 px spacing between pages (same as between posts).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const inner = 'Column_wpfp8w9t';

final class PostsPagesPadding extends FlutterFlowAITask {
  @override
  String get name => 'gg-posts-pages-padding';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
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
    final outer = parentOf(w['node'], inner) ?? (throw StateError('$inner not found'));
    if (outer['generatorVariable'] == null || !jsonEncode(outer['generatorVariable']).contains('ggPostPages')) {
      throw StateError('$inner is not inside the page generator');
    }
    final col = (outer['children'] as List).single as Map<String, dynamic>;
    final props = col['props'] as Map<String, dynamic>;
    if (props['padding'] == null) {
      stdout.writeln('GoodNewsPage: inner posts column has no padding already');
      return;
    }
    if ((outer['props'] as Map)['padding'] == null) throw StateError('outer column has no padding');
    props.remove('padding');
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('GoodNewsPage: padding only on the page column (posts back at 140, no gap between pages)');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PostsPagesPadding()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good News: single posts padding (no extra gap between pages)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
