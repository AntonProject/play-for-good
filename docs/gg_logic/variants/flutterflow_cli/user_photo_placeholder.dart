// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 21.10.2026, owner: every user photo without a picture shows the profile
// placeholder (Profilbild.png: white circle with the person icon), as the
// profile header does.
// The shared Image component falls back to Vector.png (it also shows
// organisation logos, so its own default stays). User photos passed to it:
//  * default Vector.png: GamePage, GoodGamesPage (current user), PlayPage,
//    PlayPaymentPage -> Profilbild.png;
//  * no default (an empty photo reached Image -> Vector.png): Good Games
//    ranking rows (gamesUserComp, player.photoUrl) and podium
//    (ggTopPlayerAt(...).photoUrl) -> default Profilbild.png.
// Only variables that read a photo field (photoUrl / photo_url) are touched;
// admin pages already use Profilbild.png and are left as they are.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const profilbild =
    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png';

final class UserPhotoPlaceholder extends FlutterFlowAITask {
  @override
  String get name => 'gg-user-photo-placeholder';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    bool readsPhoto(Map v) {
      final ops = (v['operations'] as List?) ?? const [];
      if (ops.isEmpty) return false;
      final last = ops.last as Map;
      final f = (last['accessDataStructField'] ?? last['accessPostgresRowField'])?['fieldIdentifier']?['name'];
      return f == 'photoUrl' || f == 'photo_url';
    }

    for (final entry in p.widgetClasses.entries.toList()) {
      final name = entry.value.name;
      if (name.endsWith('Admin') || name == 'profileEditDialog') continue;
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      var n = 0;
      // Variables inside a parameter passed to a component (parameterPasses).
      void fix(dynamic x) {
        if (x is Map) {
          if (x['source'] != null && jsonEncode(x).contains('hoto')) {
            final d = x['defaultValue']?['serializedValue'] as String?;
            if (d != null && d.endsWith('/Vector.png') && jsonEncode(x).contains(RegExp(r'"photo(Url|_url)"'))) {
              x['defaultValue'] = {'serializedValue': profilbild};
              n++;
            } else if (d == null && readsPhoto(x)) {
              x['defaultValue'] = {'serializedValue': profilbild};
              n++;
            }
          }
          x.values.forEach(fix);
        } else if (x is List) {
          x.forEach(fix);
        }
      }
      void walk(dynamic x) {
        if (x is Map) {
          final passes = x['parameterPasses'];
          if (passes is Map) {
            for (final pass in passes.values) {
              if (pass is Map && jsonEncode(pass).contains(RegExp(r'"photo(Url|_url)"'))) fix(pass);
            }
          }
          x.values.forEach(walk);
        } else if (x is List) {
          x.forEach(walk);
        }
      }
      walk(w['node']);
      if (n == 0) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      report.add('$name: $n photo value(s) -> Profilbild.png fallback');
    }
    stdout.writeln(report.isEmpty ? 'Every user photo already falls back to Profilbild.png' : report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [UserPhotoPlaceholder()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'User photos: profile placeholder (Profilbild.png) when there is no photo',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
