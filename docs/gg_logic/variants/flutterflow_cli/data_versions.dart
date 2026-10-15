// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Step 2 of the query cache: data versions in App State (not persisted).
// GgStatsListener sets them on Realtime events of the table; cached FF queries
// end their cache key with the version, so a change loads them once again.
//   ggVerGames, ggVerOrganization, ggVerUsers: String, default '0'
// Existing fields with the same name are kept (re-run safe).
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';

const fields = {
  'ggVerGames': 'Version of the games data (changes on a games event).',
  'ggVerOrganization': 'Version of the organization data (changes on an organization event).',
  'ggVerUsers': 'Version of the users data (changes on a users event).',
};

final class DataVersions extends FlutterFlowAITask {
  @override
  String get name => 'gg-data-versions';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    for (final MapEntry(key: name, value: description) in fields.entries) {
      if (p.appState.fields.any((f) => f.parameter.identifier.name == name)) {
        stdout.writeln('app state $name: exists, kept');
        continue;
      }
      addAppStateField(p, name: name, type: stringType, description: description, defaultValue: '0');
      stdout.writeln('app state $name: String, default 0, not persisted');
    }
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [DataVersions()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Data versions in App State for cached queries',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
