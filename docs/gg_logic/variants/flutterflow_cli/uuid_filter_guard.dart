// Run inside the FlutterFlow AI workspace. Dry-run by default.
// uuid filters (16.10.2026): queries and updates filtered a uuid column
// (id, *_id) by a value that can be '' (currentUserUid of a guest, empty page
// parameters such as guestChosenOrgId) or 'guest' (profile of a guest);
// Postgres answered 22P02 "invalid input syntax for type uuid" (seen in the
// simulator log). Such filter values are wrapped in ggUuidOrNone: null stays
// null (FF skips the filter, as before), a uuid passes, anything else becomes
// the nil uuid, so the query finds nothing instead of failing.
// Wrapped sources: the signed-in user id and page / component parameters
// without field access. Values read from database rows are uuid or null and
// stay as they are. Admin pages are not touched.
// Runs with transfer.dart (registers ggUuidOrNone) in one commit.
// Copy into dsl/ as gg_uuid_filter_guard.dart next to gg_transfer.dart.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

final class UuidFilterGuard extends FlutterFlowAITask {
  @override
  String get name => 'gg-uuid-filter-guard';
  @override
  Set<String> get dependsOn => {'register-gg-rpc'};
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final f = p.customCode.customFunctions.where((x) => x.identifier.name == 'ggUuidOrNone').firstOrNull ??
        (throw StateError('ggUuidOrNone missing (transfer first)'));
    final fn = {'name': f.identifier.name, 'key': f.identifier.key};
    final report = <String>[];
    var total = 0;
    for (final entry in p.widgetClasses.entries.toList()) {
      final cls = entry.value.name;
      if (cls.toLowerCase().contains('admin')) continue;
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json()));
      var n = 0;
      void walk(dynamic x) {
        if (x is Map) {
          final bf = x['baseFilter'];
          if (bf is Map) {
            final field = bf['fieldIdentifier']?['name'] as String? ?? '';
            final value = bf['value'];
            final v = value is Map ? value['variable'] : null;
            if ((field == 'id' || field.endsWith('_id')) && v is Map) {
              final src = v['source'];
              final ops = (v['operations'] as List?) ?? const [];
              final userId = src == 'SUPABASE_AUTH_USER' && v['baseVariable']?['auth']?['property'] == 'USER_ID';
              final param = src == 'WIDGET_CLASS_PARAMETER' && ops.isEmpty;
              if (userId || param) {
                value['variable'] = {
                  'source': 'FUNCTION_CALL',
                  'functionCall': {
                    'values': [
                      {'variable': v}
                    ],
                    'customFunction': fn,
                  },
                };
                n++;
              }
            }
          }
          x.values.forEach(walk);
        } else if (x is List) {
          x.forEach(walk);
        }
      }
      walk(w);
      if (n == 0) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(w as Map<String, dynamic>);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      report.add('$cls: $n');
      total += n;
    }
    stdout.writeln('uuid filters wrapped in ggUuidOrNone: $total (${report.join(', ')})');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-uuid-guard-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports), UuidFilterGuard()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'uuid filters: no 22P02 for empty / guest ids (ggUuidOrNone)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
