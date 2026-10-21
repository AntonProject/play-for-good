// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 21.10.2026, owner re-uploaded the award images as PNG and deleted the old
// ones first, so 12 references pointed to deleted assets. Re-points every
// reference (all widget classes) by the conditions they are shown under:
//   MVP (valuable) badges 1/2/3: mvp_gold/silver/bronze -> firstGold/first/third
//   Most Active badges 1/2/3: Group_1675/1676/1677 -> fireGold/fireSecond/fireThird
//   podium 1st place: Trophy_1st_4x_3 (valuable) -> champ, map_fire_gold (active) -> fireMap
//   profile awards: 1st/2nd/3rd_Place, Most_Active_Player .webp -> .png
// Fails if an old asset still exists or a new one is missing.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const projectId = 'play-for-good-o0lpcq';
const repoint = {
  'mvp_gold.webp': 'firstGold.png',
  'mvp_silver.webp': 'first.png',
  'mvp_bronze.webp': 'third.png',
  'Group_1675.webp': 'fireGold.png',
  'Group_1676.webp': 'fireSecond.png',
  'Group_1677.webp': 'fireThird.png',
  'Trophy_1st_4x_3.webp': 'champ.png',
  'map_fire_gold.webp': 'fireMap.png',
  '1st_Place.webp': '1st_Place.png',
  '2nd_Place.webp': '2nd_Place.png',
  '3rd_Place.webp': '3rd_Place.png',
  'Most_Active_Player.webp': 'Most_Active_Player.png',
};

final class RepointAwardAssets extends FlutterFlowAITask {
  RepointAwardAssets(this.targets, this.existing);
  final Map<String, String> targets; // old filename -> new storage path
  final Set<String> existing;
  @override
  String get name => 'repoint-award-assets';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final re = RegExp(r'projects/play-for-good-o0lpcq/assets/[A-Za-z0-9]+/([^"\\/]+)');
    final counts = <String, int>{};
    final missingLeft = <String>{};
    for (final entry in p.widgetClasses.entries.toList()) {
      final old = entry.value;
      final s = jsonEncode(old.toProto3Json());
      var n = 0;
      final out = s.replaceAllMapped(re, (m) {
        final path = m.group(0)!;
        if (existing.contains(path)) return path;
        final to = targets[m.group(1)!];
        if (to == null) {
          missingLeft.add(path);
          return path;
        }
        n++;
        return to;
      });
      if (n == 0) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(jsonDecode(out));
      restoreUnknownFields(old, next);
      p.widgetClasses[entry.key] = next;
      counts[old.name] = n;
    }
    stdout.writeln('Re-pointed references: $counts');
    if (missingLeft.isNotEmpty) stdout.writeln('Still missing (no mapping): $missingLeft');
    if (counts.isEmpty) stdout.writeln('Nothing to re-point');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final key = Platform.environment['FF_API_KEY']!;
  final assets = await FlutterFlowAI(apiKey: key).assets.list(projectId);
  final targets = <String, String>{};
  repoint.forEach((from, to) {
    if (assets.any((a) => a.filename == from)) throw StateError('$from still exists; not re-pointing it');
    final t = assets.where((a) => a.filename == to).toList();
    if (t.length != 1) throw StateError('$to: ${t.length} assets with this name');
    targets[from] = t.single.storagePath;
  });
  final result = await FlutterFlowAIPipeline(
    apiKey: key,
    project: PipelineProject.existing(projectId),
    tasks: [RepointAwardAssets(targets, {for (final a in assets) a.storagePath})],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Award images: references to the re-uploaded PNG assets',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
