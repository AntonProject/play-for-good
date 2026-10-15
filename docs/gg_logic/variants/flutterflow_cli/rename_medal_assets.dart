// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// FF code export strips emoji from asset names, so 🥇_1/🥈_1/🥉_1/🔥_1.webp all
// became one `_1.webp` in every build. Uploads byte-identical copies under ASCII
// names and re-points every reference. Old assets are kept (not deleted).
//   dart run dsl/gg_rename_medal_assets.dart <dir-with-ascii-files> [--apply]
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const projectId = 'play-for-good-o0lpcq';
const renames = {
  '🥇_1.webp': 'mvp_gold.webp',
  '🥈_1.webp': 'mvp_silver.webp',
  '🥉_1.webp': 'mvp_bronze.webp',
  '🔥_1.webp': 'map_fire_gold.webp',
};

final class RepointAssets extends FlutterFlowAITask {
  RepointAssets(this.paths);
  final Map<String, String> paths; // old storage path -> new storage path
  @override
  String get name => 'repoint-medal-assets';
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final counts = <String, int>{};
    for (final entry in p.widgetClasses.entries.toList()) {
      final old = entry.value;
      var s = jsonEncode(old.toProto3Json());
      var n = 0;
      paths.forEach((from, to) {
        final c = from.allMatches(s).length;
        if (c > 0) {
          s = s.replaceAll(from, to);
          n += c;
        }
      });
      if (n == 0) continue;
      final next = FFWidgetClass()..mergeFromProto3Json(jsonDecode(s));
      restoreUnknownFields(old, next);
      p.widgetClasses[entry.key] = next;
      counts[old.name] = n;
    }
    stdout.writeln('Re-pointed references: $counts');
    if (counts.isEmpty) throw StateError('No references found');
  }
}

Future<void> main(List<String> args) async {
  final dir = args.first;
  final apply = args.contains('--apply');
  final key = Platform.environment['FF_API_KEY']!;
  final client = FlutterFlowAI(apiKey: key);
  final assets = await client.assets.list(projectId);
  final paths = <String, String>{};
  for (final e in renames.entries) {
    final old = assets.firstWhere((a) => a.filename == e.key);
    final file = File('$dir/${e.value}');
    if (file.lengthSync() != old.fileSizeBytes) {
      throw StateError('${e.value} differs from ${e.key} (${file.lengthSync()} vs ${old.fileSizeBytes})');
    }
    var target = assets.where((a) => a.filename == e.value).firstOrNull?.storagePath;
    if (target == null && apply) {
      target = (await client.assets.upload(projectId,
              filename: e.value, bytes: file.readAsBytesSync()))
          .storagePath;
    }
    // Dry-run: use a placeholder path only to count references.
    paths[old.storagePath] = target ??
        old.storagePath.replaceFirst(e.key, e.value);
    stdout.writeln('${e.key} -> ${e.value}${target == null ? ' (upload on --apply)' : ''}');
  }
  final result = await FlutterFlowAIPipeline(
    apiKey: key,
    project: PipelineProject.existing(projectId),
    tasks: [RepointAssets(paths)],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Medal assets: ASCII names (emoji names collide in code export)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
