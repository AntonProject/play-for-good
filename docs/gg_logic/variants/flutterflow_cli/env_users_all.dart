// Run inside the FlutterFlow AI workspace. Dry-run by default.
// Home gauge average per environment (16.10.2026), ONE FlutterFlow commit:
//   1 GgRanking.envOtherUsersCount (Integer) = gg_v2_rankings env_other_users_count
//   2 transfer.dart (rpc): ggLoadRanking reads it, ggHomeGaugeOf divides by it
//     (users of this environment except the viewer; older server -> as before)
// SQL 02_rpc/iteration1/15_env_users.sql first.
// Copy into dsl/ as gg_env_users_all.dart next to gg_transfer.dart.
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'gg_transfer.dart' show RegisterGgCode;

final class EnvUsersSchema extends FlutterFlowAITask {
  @override
  String get name => 'gg-env-users-schema';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final ranking = findDataStruct(ctx.project, name: 'GgRanking') ?? (throw StateError('GgRanking missing'));
    if (ranking.fields.any((f) => f.identifier.name == 'envOtherUsersCount')) {
      stdout.writeln('GgRanking.envOtherUsersCount: exists, kept');
      return;
    }
    ranking.fields.add(structField('envOtherUsersCount', intType,
        description: 'Users of this environment except the requested user (Home gauge average).'));
    stdout.writeln('GgRanking.envOtherUsersCount: added');
  }
}

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
  final reports = Directory.systemTemp.createTempSync('pfg-gg-env-users-').path;
  final schema = Step(EnvUsersSchema());
  final code = Step(RegisterGgCode(root, 'rpc', reports), {schema.name});
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [schema, code],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Home gauge: average over the users of this environment',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
