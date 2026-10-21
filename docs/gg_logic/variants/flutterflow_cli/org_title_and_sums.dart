// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 16.10.2026, customer's original code:
//  1 OrganisationPage "Über uns" title (Text_f5yhctfd, organization.title):
//    Ellipsis without Max Lines -> Flutter cut it to ONE line ("Blau-Gelbes
//    Kreuz Deutsch-Ukrainischer ..."). The customer asked not to cut
//    organisation names: the ellipsis is removed, the title wraps in full.
//    (All other organisation names already have Max Lines 3-4.)
//  2 Numeric code expressions (e.g. userMoney+teamMoney+siegMoney) had
//    non-nullable arguments, generated as `widget!.game!.userMoney!`: a missing
//    value -> red screen. Arguments become nullable and every argument in the
//    expression is read as (x ?? 0). FinishPage got the same fix before.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const titleText = ('OrganisationPage', 'Text_f5yhctfd');
const numeric = {'Double', 'Integer'};

final class OrgTitleAndSums extends FlutterFlowAITask {
  @override
  String get name => 'gg-org-title-and-sums';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    for (final entry in p.widgetClasses.entries.toList()) {
      final cls = entry.value.name;
      if (cls.toLowerCase().contains('admin')) continue;
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      final notes = <String>[];
      var exprs = 0;
      void walk(dynamic x) {
        if (x is Map) {
          // 1
          if (cls == titleText.$1 && x['key'] == titleText.$2 && x['type'] == 'Text') {
            final t = (x['props'] as Map)['text'] as Map;
            if (t['overflowReplacement'] == 'ELLIPSIS' && t['maxLinesValue'] == null) {
              t.remove('overflowReplacement');
              notes.add('${titleText.$2}: full organisation name, no ellipsis');
            }
          }
          // 2
          final ce = x['codeExpression'];
          if (ce is Map && ce['arguments'] is List && (ce['arguments'] as List).isNotEmpty) {
            final args = (ce['arguments'] as List).cast<Map>();
            final allNumeric = args.every((a) => numeric.contains(a['dataType']?['scalarType']));
            final strict = args.any((a) => a['dataType']?['nonNullable'] == true);
            if (allNumeric && strict) {
              var e = ce['expression'] as String;
              for (final a in args) {
                final n = a['identifier']['name'] as String;
                e = e.replaceAllMapped(RegExp('(?<![A-Za-z0-9_])${RegExp.escape(n)}(?![A-Za-z0-9_])'), (_) => '($n ?? 0)');
                (a['dataType'] as Map)['nonNullable'] = false;
              }
              ce['expression'] = e;
              exprs++;
            }
          }
          x.values.forEach(walk);
        } else if (x is List) {
          x.forEach(walk);
        }
      }
      walk(w);
      if (exprs > 0) notes.add('numeric expressions null-safe x$exprs');
      if (notes.isEmpty) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      report.add('$cls: ${notes.join(', ')}');
    }
    stdout.writeln(report.isEmpty ? 'nothing to change' : report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [OrgTitleAndSums()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Organisation title not cut; game sums without null errors',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
