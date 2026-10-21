// Run inside the FlutterFlow AI workspace. Dry-run by default.
// Posts test / prod + guest Home gauge (16.10.2026) in ONE FlutterFlow commit:
//   1 transfer.dart (rpc)      ggPostsPage: only posts of this environment;
//                              ggHomeGaugeOf: guest = the demo 100
//   2 posts_test_queries.dart  posts lists of profile / organisation / sheet
// Order: SQL 02_rpc/iteration1/13_posts_test.sql in Supabase, then the FF
// Supabase schema refresh (Settings -> Supabase -> Get Schema), then this.
// Copy into dsl/ with the gg_ prefix (gg_posts_test_all.dart, gg_transfer.dart,
// gg_posts_test_queries.dart).
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'gg_transfer.dart' show RegisterGgCode;
import 'gg_posts_test_queries.dart' show PostsTestQueries;

/// Runs [inner] after [after] (the pipeline orders tasks by dependsOn only).
final class Step extends FlutterFlowAITask {
  Step(this.inner, [this.after = const {}]);
  final FlutterFlowAITask inner;
  final Set<String> after;
  @override
  String get name => inner.name;
  @override
  Set<String> get dependsOn => after;
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) => inner.run(ctx);
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-posts-test-').path;
  final code = Step(RegisterGgCode(root, 'rpc', reports));
  final queries = Step(PostsTestQueries(), {code.name});
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [code, queries],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Posts: test / prod environment; Home gauge for guests',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
