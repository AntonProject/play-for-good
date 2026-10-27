// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 26.10.2026, owner: a guest saw 300 in the Good Games list (guest 100 + two
// players with 100) and 200 as "LW / Total Good Power": the server total has
// no demo guest. GoodGamesPage Text_5m4bxljx now shows ggTotalPowerOf(ggRanking)
// = the server total + 100 for a guest viewer in periods that include today
// (where the guest stands in the list). Default "0" and number format kept.
// ONE commit (with the function transfer).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

final class GuestTotalPower extends FlutterFlowAITask {
  @override
  String get name => 'gg-guest-total-power';
  @override
  Set<String> get dependsOn => {'register-gg-rpc'};
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'GoodGamesPage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    Map? text;
    void s(dynamic x) {
      if (text != null) return;
      if (x is Map) {
        if (x['key'] == 'Text_5m4bxljx' && x['type'] == 'Text') {
          text = x;
          return;
        }
        x.values.forEach(s);
      } else if (x is List) {
        x.forEach(s);
      }
    }
    s(w['node']);
    final v = (text ?? (throw StateError('Text_5m4bxljx missing')))['props']['text']['textValue']['variable'] as Map;
    final fc = v['functionCall'] as Map;
    if (fc['customFunction']?['name'] == 'ggTotalPowerOf') {
      stdout.writeln('GoodGamesPage: total already ggTotalPowerOf');
      return;
    }
    final ops = (v['operations'] as List?) ?? const [];
    if (fc['customFunction']?['name'] != 'ggRankingOrEmpty' ||
        !jsonEncode(ops).contains('"totalGoodPower"')) {
      throw StateError('Text_5m4bxljx: unexpected binding');
    }
    final f = p.customCode.customFunctions.where((f) => f.identifier.name == 'ggTotalPowerOf').firstOrNull ??
        (throw StateError('ggTotalPowerOf missing (transfer first)'));
    fc['customFunction'] = {'name': f.identifier.name, 'key': f.identifier.key};
    v['operations'] = [
      for (final op in ops)
        if ((op as Map)['accessDataStructField'] == null) op
    ];
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('GoodGamesPage: "LW / Total Good Power" = ggTotalPowerOf(ggRanking)');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-total-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports), GuestTotalPower()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games total includes the demo guest for a guest viewer',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
