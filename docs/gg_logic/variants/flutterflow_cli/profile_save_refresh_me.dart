// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// profileEditDialog: after saving the profile (update of `users`) the avatar in
// the page headers kept the old photo: it reads App State ggMyPhotoUrl, which
// only ggMe (Home / PlayPage On Load) refreshes. The save chain now calls ggMe
// right after the database update. The rest of the chain is unchanged
// (refreshDate, cache clear, close sheet, close keyboard).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.profilesave.$seed');

final class ProfileSaveRefreshMe extends FlutterFlowAITask {
  @override
  String get name => 'gg-profile-save-refresh-me';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final ggMe = findCustomAction(p, name: 'ggMe') ?? (throw StateError('ggMe action is missing'));
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'profileEditDialog');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    var changed = 0;
    void walk(Object? n) {
      if (n is Map) {
        final action = n['action'];
        // The users UPDATE of the save button: the database action whose
        // follow-up sets App State refreshDate.
        if (action is Map && action['database'] is Map &&
            jsonEncode(action['database']).contains('haus_nr')) {
          final next = n['followUpAction'];
          if (next is Map && jsonEncode(next).contains('"ggMe"')) return; // already there
          n['followUpAction'] = {
            'key': key('node'),
            'action': {
              'customAction': {
                'customActionIdentifier': {
                  'name': ggMe.identifier.name,
                  'key': ggMe.identifier.key,
                },
                'argumentValues': {},
              },
              'key': key('action'),
            },
            if (next != null) 'followUpAction': next,
          };
          changed++;
          return;
        }
        n.values.forEach(walk);
      } else if (n is List) {
        n.forEach(walk);
      }
    }
    walk(w['node']);
    if (changed != 1) throw StateError('expected 1 profile save update, found $changed');
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('profileEditDialog: ggMe after the users update (header avatar refresh)');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [ProfileSaveRefreshMe()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Profile edit: refresh my photo after saving',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
