// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 21.10.2026, owner: the profile header showed an empty line under the nick
// for users without first name / surname (the text "first surname" was a single
// space, valueOrDefault keeps it, the line kept its height). The guest line
// "Gastnutzer" stays.
// userProfilePage and the userProfile dialog: the Text with first name +
// surname / "Gastnutzer" gets the visibility ggShowNameLineOf(userId,
// first_name, surname) - true for the guest or when a name is set. The
// arguments are taken from the same Text (its userId parameter and the users
// query row fields).
// ONE commit: transfer.dart (rpc: registers ggShowNameLineOf) + this change.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

final class ProfileNameLine extends FlutterFlowAITask {
  @override
  String get name => 'gg-profile-name-line';
  @override
  Set<String> get dependsOn => {'register-gg-rpc'};
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final fn = p.customCode.customFunctions.where((f) => f.identifier.name == 'ggShowNameLineOf').firstOrNull ??
        (throw StateError('ggShowNameLineOf missing (transfer first)'));
    final report = <String>[];
    for (final cls in ['userProfilePage', 'userProfile']) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      final texts = <Map>[];
      void walk(dynamic x) {
        if (x is Map) {
          if (x['type'] == 'Text' && jsonEncode(x).contains('Gastnutzer') && jsonEncode(x).contains('"surname"')) {
            texts.add(x);
          }
          x.values.forEach(walk);
        } else if (x is List) {
          x.forEach(walk);
        }
      }
      walk(w['node']);
      if (texts.isEmpty) throw StateError('$cls: name line not found');
      var n = 0;
      for (final t in texts) {
        final props = t['props'] as Map;
        if (jsonEncode(props['visibility'] ?? {}).contains('"ggShowNameLineOf"')) continue;
        if (props['visibility'] != null) throw StateError('$cls/${t['key']}: already has a visibility');
        Map? find(bool Function(Map) test) {
          Map? r;
          void s(dynamic x) {
            if (r != null) return;
            if (x is Map) {
              if (x['source'] != null && test(x)) {
                r = x;
                return;
              }
              x.values.forEach(s);
            } else if (x is List) {
              x.forEach(s);
            }
          }
          s(props['text']);
          return r;
        }
        bool field(Map v, String name) =>
            v['source'] == 'POSTGRES_QUERY' &&
            ((v['operations'] as List?) ?? []).any((o) => o['accessPostgresRowField']?['fieldIdentifier']?['name'] == name);
        final userId = find((v) => v['source'] == 'WIDGET_CLASS_PARAMETER' &&
                v['baseVariable']?['widgetClass']?['paramIdentifier']?['name'] == 'userId') ??
            (throw StateError('$cls: userId parameter not in the name line'));
        final first = find((v) => field(v, 'first_name')) ?? (throw StateError('$cls: first_name not found'));
        final sur = find((v) => field(v, 'surname')) ?? (throw StateError('$cls: surname not found'));
        Map clean(Map v) => (jsonDecode(jsonEncode(v)) as Map)..remove('defaultValue');
        props['visibility'] = {
          'visibleValue': {
            'variable': {
              'source': 'FUNCTION_CALL',
              'functionCall': {
                'values': [
                  {'variable': clean(userId)},
                  {'variable': clean(first)},
                  {'variable': clean(sur)},
                ],
                'customFunction': {'name': fn.identifier.name, 'key': fn.identifier.key},
              },
            }
          }
        };
        n++;
      }
      if (n == 0) {
        report.add('$cls: name line already hidden without a name');
        continue;
      }
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      report.add('$cls: $n name line(s) hidden when there is no name');
    }
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-nameline-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports), ProfileNameLine()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Profile header: no empty line under the nick without a name',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
