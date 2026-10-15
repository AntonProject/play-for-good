// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// userProfilePage badges: the Row generates one item per award
// (ggAwards(ggProfile, '')), but FlutterFlow repeats only the FIRST child of a
// generator, so every item was the "1st place MVP" image and only MVP-1 awards
// showed. The six badge images (each visible for its award type) now sit in one
// Stack - the single repeated child - so each award shows its own badge.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const rowKey = 'Row_l459ypck';

final class ProfileBadgesStack extends FlutterFlowAITask {
  @override
  String get name => 'gg-profile-badges-stack';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'userProfilePage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
      if (n['key'] == k) return n;
      for (final c in (n['children'] as List? ?? [])) {
        final r = find(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    final row = find(w['node'], rowKey) ?? (throw StateError('$rowKey not found'));
    if (row['generatorVariable'] == null) throw StateError('$rowKey is not a generator');
    final kids = row['children'] as List;
    if (kids.length != 6 || kids.any((c) => c['type'] != 'Image')) throw StateError('Unexpected badge row children');
    row['children'] = [
      {
        'key': 'Stack_${generateRandomAlphaNumericString(seedString: 'pfg.gg.badgestack')}',
        'type': 'Stack',
        'props': {'stack': {}},
        'children': kids,
      }
    ];
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('userProfilePage: 6 badge images in one Stack (generator child)');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [ProfileBadgesStack()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Profile: every award shows its own badge',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
