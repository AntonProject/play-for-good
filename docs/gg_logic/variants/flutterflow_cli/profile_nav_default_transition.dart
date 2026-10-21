// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 20.10.2026, tester (iPhone + Android): guest -> Mein Profil -> Profil
// editieren -> sign in: the first attempt closed the dialog and left the guest
// profile, the second attempt worked (two codes by email). Not in the store
// version (1.1.18).
// Cause: first_frame_headers.dart (part 1) gave every navigation to
// userProfilePage the INSTANT transition. FF passes it as
// `extra: {'__transition_info__': TransitionInfo}`; go_router cannot keep that
// object in the stored route state, so on the first router refresh (any
// sign-in / sign-out) the extra is lost and the profile page is rebuilt as a
// different page type: a new page State, and the dialog open on it is removed.
// Checked in the simulator: pushed with the extra -> the page State changes on
// the first auth change and the extra becomes null; pushed without it (store
// version) -> the State stays.
// The store version had no transition on any navigation to the profile. This
// removes the INSTANT transition from them again (default transition, as in
// the store). Parts 2 and 3 of first_frame_headers (header image while loading)
// stay.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class ProfileNavDefaultTransition extends FlutterFlowAITask {
  @override
  String get name => 'gg-profile-nav-default-transition';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final profileKey = p.widgetClasses.values.firstWhere((w) => w.name == 'userProfilePage').node.key;
    final report = <String>[];
    for (final entry in p.widgetClasses.entries.toList()) {
      if (!jsonEncode(entry.value.toProto3Json()).contains('"$profileKey"')) continue;
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      var n = 0;
      void walk(dynamic x) {
        if (x is Map) {
          final nav = x['navigate'];
          if (nav is Map &&
              nav['pageNodeKeyRef']?['key'] == profileKey &&
              nav['transition'] is Map &&
              nav['transition']['transitionType'] == 'INSTANT') {
            nav.remove('transition');
            n++;
          }
          x.values.forEach(walk);
        } else if (x is List) {
          x.forEach(walk);
        }
      }
      walk(w);
      if (n == 0) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      report.add('${entry.value.name}: $n navigation(s) to the profile -> default transition');
    }
    stdout.writeln(report.isEmpty ? 'No INSTANT navigation to the profile left' : report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [ProfileNavDefaultTransition()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Profile navigations without the INSTANT transition (sign-in dialog survives auth changes)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
