// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// HomePage score (16.10.2026, owner request): one ConditionalBuilder instead of
// two components switched by visibility.
//   before: homePageScore (visible: signed in OR hasGuestGetLichtwatt),
//           homePageScoreEmpty (visible: NOT signed in AND NOT hasGuestGetLichtwatt),
//           ConditionalBuilder_2a6ntjlt hidden by a constant FALSE (old customer
//           block on a removed games query, generated as `if (false)`)
//   after:  ConditionalBuilder_2a6ntjlt (visible): If signed in OR
//           hasGuestGetLichtwatt -> homePageScore, Else -> homePageScoreEmpty
// The two components keep their keys, parameters and models; only their
// visibility moves to the builder. The old hidden branch contents (one
// homePageScore and one homePageScoreEmpty that were never built) are removed.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const page = 'HomePage';
const column = 'Column_rlcuqik3';
const builderKey = 'ConditionalBuilder_2a6ntjlt';
const scoreKey = 'Container_v0mw7kco';
const emptyKey = 'Container_av6wqdm3';

final class HomeScoreBuilder extends FlutterFlowAITask {
  @override
  String get name => 'gg-home-score-builder';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == page);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    Map<String, dynamic>? find(dynamic x, String k) {
      if (x is Map) {
        if (x['key'] == k && x.containsKey('type')) return x as Map<String, dynamic>;
        for (final v in x.values) {
          final r = find(v, k);
          if (r != null) return r;
        }
      } else if (x is List) {
        for (final v in x) {
          final r = find(v, k);
          if (r != null) return r;
        }
      }
      return null;
    }

    final col = find(w['node'], column) ?? (throw StateError('$column not found'));
    final children = col['children'] as List;
    final builder = find(col, builderKey) ?? (throw StateError('$builderKey not found'));
    if (children.any((c) => c['key'] == scoreKey)) {
      final score = children.firstWhere((c) => c['key'] == scoreKey) as Map<String, dynamic>;
      final empty = children.firstWhere((c) => c['key'] == emptyKey,
          orElse: () => throw StateError('$emptyKey not next to the score')) as Map<String, dynamic>;
      final showScore = score['props']?['visibility']?['visibleValue']?['variable'];
      final hideScore = jsonEncode(empty['props']?['visibility']);
      if (showScore == null || !jsonEncode(showScore).contains('IS_USER_LOGGED_IN') ||
          !hideScore.contains('IS_USER_LOGGED_IN')) {
        throw StateError('$page: score visibility changed, check before rewriting');
      }
      final builderVis = jsonEncode(builder['props']?['visibility']);
      if (!builderVis.contains('"FALSE"') && !builderVis.contains('false')) {
        throw StateError('$builderKey is not the hidden block any more');
      }
      final branches = builder['children'] as List;
      if (branches.length != 2) throw StateError('$builderKey: expected If / Else');

      // Components: visibility moves to the builder.
      (score['props'] as Map).remove('visibility');
      (empty['props'] as Map).remove('visibility');
      final ifBranch = branches[0] as Map<String, dynamic>;
      final elseBranch = branches[1] as Map<String, dynamic>;
      ifBranch['props'] = {
        ...((ifBranch['props'] as Map?) ?? {}),
        'visibility': {'visibleValue': {'variable': showScore}},
      };
      ifBranch['children'] = [score];
      elseBranch['children'] = [empty];
      (builder['props'] as Map).remove('visibility');

      // Column: the builder takes the place of the two components.
      children.removeWhere((c) => c['key'] == scoreKey || c['key'] == emptyKey);
      final at = children.indexWhere((c) => c['key'] == builderKey);
      final b = children.removeAt(at);
      children.insert(0, b);
    } else if (find(builder, scoreKey) != null) {
      stdout.writeln('$page: score already in $builderKey');
      return;
    } else {
      throw StateError('$page: $scoreKey not found');
    }

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('$page: $builderKey visible, If -> homePageScore ($scoreKey), '
        'Else -> homePageScoreEmpty ($emptyKey); old hidden branch contents removed');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [HomeScoreBuilder()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'HomePage: score / empty score in one ConditionalBuilder',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
