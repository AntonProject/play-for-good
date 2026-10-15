// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Follow-up to row_divider.dart: the divider crossed under the stripe and left
// a gap between the coloured stripes. New layout of gamesUserComp:
//   Row_za59pjqz [ stripe (116) | Container(116, expanded) -> Column [content (expanded), divider] ]
// so the stripe is continuous and the line starts at the stripe's right edge.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class DividerBesideStripe extends FlutterFlowAITask {
  @override
  String get name => 'gg-row-divider-beside-stripe';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'gamesUserComp');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    Map<String, dynamic>? find(Map<String, dynamic> n, String key) {
      if (n['key'] == key) return n;
      for (final c in (n['children'] as List? ?? [])) {
        final r = find(c as Map<String, dynamic>, key);
        if (r != null) return r;
      }
      return null;
    }
    final body = find(w['node'], 'Container_9xooiwg2')!;
    final col = (body['children'] as List).single as Map<String, dynamic>;
    if (col['type'] != 'Column') throw StateError('Unexpected layout: run row_divider.dart first');
    final row = (col['children'] as List)[0] as Map<String, dynamic>;
    final divider = (col['children'] as List)[1] as Map<String, dynamic>;
    final kids = row['children'] as List;
    final stripe = kids[0] as Map<String, dynamic>;
    final content = kids[1] as Map<String, dynamic>;
    if (stripe['key'] != 'Container_rzgvzjsq' || content['key'] != 'Row_bddabz8e') {
      throw StateError('Unexpected row children');
    }
    col['children'] = [content, divider];
    ((col['props'] as Map)['column'] as Map)['minSizeValue'] = {'inputValue': 'main_axis_max'};
    final wrapper = {
      'key': 'Container_${generateRandomAlphaNumericString(seedString: 'pfg.gg.rowdivider.wrapper')}',
      'type': 'Container',
      'props': {
        'container': {
          'dimensions': {'height': {'pixelsValue': {'inputValue': 116}}},
        },
        'expanded': {'expandedType': 'EXPANDED'},
      },
      'children': [col],
    };
    row['children'] = [stripe, wrapper];
    body['children'] = [row];
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('Divider now beside the stripe in gamesUserComp.');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [DividerBesideStripe()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games rows: continuous stripe, divider beside it',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
