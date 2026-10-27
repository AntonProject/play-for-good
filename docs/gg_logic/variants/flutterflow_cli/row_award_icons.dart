// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 26.10.2026, design (Figma comment): in the Good Games rows the 1st place
// badges are the cup and the red emoji-like fire, as on the podium and in the
// profile awards. gamesUserComp:
//   Image_0vehu90a  MVP 1st place   firstGold.png (gold medal) -> champ.png (cup)
//   Image_xxzxnlnx  MAP 1st place   fireGold.png (gold fire)   -> fireMap.png (red fire)
// --revert puts the old images back. Places 2/3 stay as they are.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const assets = 'projects/play-for-good-o0lpcq/assets';
const icons = {
  'Image_0vehu90a': ['$assets/67gus2t8019a/firstGold.png', '$assets/cd9i8er7kqk7/champ.png'],
  'Image_xxzxnlnx': ['$assets/4w3u9he5bdg7/fireGold.png', '$assets/r18sf3dbkn7o/fireMap.png'],
};

final class RowAwardIcons extends FlutterFlowAITask {
  RowAwardIcons(this.revert);
  final bool revert;
  @override
  String get name => 'gg-row-award-icons';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'gamesUserComp');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    var n = 0;
    icons.forEach((key, pair) {
      final from = revert ? pair[1] : pair[0];
      final to = revert ? pair[0] : pair[1];
      Map? node;
      void s(dynamic x) {
        if (node != null) return;
        if (x is Map) {
          if (x['key'] == key && x['type'] == 'Image') {
            node = x;
            return;
          }
          x.values.forEach(s);
        } else if (x is List) {
          x.forEach(s);
        }
      }
      s(w['node']);
      if (node == null) throw StateError('$key missing');
      final before = jsonEncode(node);
      if (before.contains(to) && !before.contains(from)) {
        stdout.writeln('$key: already ${to.split('/').last}');
        return;
      }
      if (!before.contains(from)) throw StateError('$key: ${from.split('/').last} not found');
      final after = jsonDecode(before.replaceAll(from, to)) as Map;
      node!
        ..clear()
        ..addAll(after);
      n++;
      stdout.writeln('$key: ${from.split('/').last} -> ${to.split('/').last}');
    });
    if (n == 0) return;
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final revert = args.contains('--revert');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RowAwardIcons(revert)],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: revert
        ? 'Good Games rows: 1st place badges back to gold medal / gold fire'
        : 'Good Games rows: 1st place badges cup / red fire as in the design',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
