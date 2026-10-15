// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Avatars blink on every page change:
//  * the Image component (and other cached network images) fade in over 500 ms
//    each time the widget is created, even when the picture is cached;
//  * the header (apbarBG) waits for a "users" query just for the photo, with an
//    empty loader in the meantime.
// Fix:
//  1. App State ggMyPhotoUrl (Image Path = String in Dart, persisted) - written by ggMe (custom code)
//     every time the profile row loads;
//  2. cached network images in app screens: fade-in 500 -> 1 ms;
//  3. apbarBG: the query is removed; the avatar reads ggMyPhotoUrl (same default
//     image), so it is there on the first frame.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class AvatarNoBlink extends FlutterFlowAITask {
  @override
  String get name => 'gg-avatar-no-blink';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    ensureAppStateField(p,
        name: 'ggMyPhotoUrl',
        type: FFDataTypeV2(scalarType: FFBaseDataType.ImagePath),
        description: 'Signed-in user photo_url (set by ggMe), read by the header avatar.',
        persisted: true,
        defaultValue: '');
    final field = p.appState.fields.firstWhere((f) => f.parameter.identifier.name == 'ggMyPhotoUrl').parameter.identifier;

    var fades = 0;
    for (final entry in p.widgetClasses.entries.toList()) {
      final name = entry.value.name;
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      var changed = false;
      if (!name.toLowerCase().contains('admin')) {
        void walk(dynamic x) {
          if (x is Map) {
            if (x['cached'] == true && x['cacheFadeDuration'] is num && x['cacheFadeDuration'] > 1) {
              x['cacheFadeDuration'] = 1;
              fades++;
              changed = true;
            }
            x.values.forEach(walk);
          } else if (x is List) {
            x.forEach(walk);
          }
        }
        walk(w['node']);
      }
      if (name == 'apbarBG') {
        String? queryKey;
        void q(Map<String, dynamic> n) {
          final dr = n['databaseRequest'];
          if (dr != null && jsonEncode(dr).contains('"name":"users"')) {
            queryKey = n['key'] as String;
            n.remove('databaseRequest');
          }
          for (final c in (n['children'] as List? ?? [])) q(c as Map<String, dynamic>);
        }
        q(w['node']);
        if (queryKey == null) throw StateError('apbarBG: users query not found');
        final counts = <String, int>{};
        void rewrite(dynamic x) {
          if (x is Map<String, dynamic>) {
            if (x['source'] == 'POSTGRES_QUERY' && x['nodeKeyRef']?['key'] == queryKey) {
              final f = x['operations']?[0]?['accessPostgresRowField']?['fieldIdentifier']?['name'];
              if (f != 'photo_url') throw StateError('apbarBG: unexpected field $f');
              final keep = {for (final k in ['defaultValue', 'uiBuilderValue']) if (x[k] != null) k: x[k]};
              x
                ..clear()
                ..addAll({
                  'source': 'LOCAL_STATE',
                  'baseVariable': {'localState': {'fieldIdentifier': field.toProto3Json(), 'stateVariableType': 'APP_STATE'}},
                })
                ..addAll(keep);
              counts[f] = (counts[f] ?? 0) + 1;
              return;
            }
            x.values.forEach(rewrite);
          } else if (x is List) {
            x.forEach(rewrite);
          }
        }
        rewrite(w);
        report.add('apbarBG: users query $queryKey removed, avatar reads App State ggMyPhotoUrl ($counts)');
        changed = true;
      }
      if (!changed) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }
    report.add('cached network images: fade-in -> 1 ms in $fades place(s)');
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [AvatarNoBlink()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Avatars without blink: no fade-in, header photo from App State',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
