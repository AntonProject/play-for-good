// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 21.10.2026, owner: Good News -> a post with organisation + user (the 64 px
// author avatar in that block) -> the profile opens without data, points and
// posts, and shows the "Mein Profil" tab for a guest.
// Customer's bug (same in store 1.1.18): that navigation passed userId = ''
// (empty input value). With '' the profile loads nothing, and for a guest
// ('' == currentUserUid) it looks like the own profile.
// The other navigation of postComp (40 px avatar on top) passes the author id
// from the users query (Container_8tzgfgfs); the empty one gets the same value.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class PostAuthorNav extends FlutterFlowAITask {
  @override
  String get name => 'gg-post-author-nav';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final profileKey = p.widgetClasses.values.firstWhere((w) => w.name == 'userProfilePage').node.key;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'postComp');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final passes = <Map>[];
    void walk(dynamic x) {
      if (x is Map) {
        final nav = x['navigate'];
        if (nav is Map && nav['pageNodeKeyRef']?['key'] == profileKey) {
          for (final pass in ((nav['passedParameters']?['parameterPasses'] as Map?) ?? {}).values) {
            if ((pass as Map)['paramIdentifier']?['name'] == 'userId') passes.add(pass);
          }
        }
        x.values.forEach(walk);
      } else if (x is List) {
        x.forEach(walk);
      }
    }
    walk(w);
    final good = passes.where((p) => p['variable'] != null).toList();
    final empty = passes.where((p) => p['variable'] == null).toList();
    if (empty.isEmpty) {
      stdout.writeln('postComp: every navigation to the profile passes the author id');
      return;
    }
    if (good.length != 1) throw StateError('postComp: expected one navigation with the author id, found ${good.length}');
    final source = jsonEncode(good.single['variable']);
    if (!source.contains('Container_8tzgfgfs') || !source.contains('"id"')) {
      throw StateError('postComp: unexpected author id source: $source');
    }
    for (final e in empty) {
      e.remove('inputValue');
      e['variable'] = jsonDecode(source);
    }
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('postComp: ${empty.length} navigation(s) to the profile now pass the author id');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PostAuthorNav()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Post card: organisation block opens the author profile (userId was empty)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
