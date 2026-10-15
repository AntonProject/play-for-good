// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Step 3 of the typed Good Games data: remove what the migration left unused
// (owner decision 15.10.2026): the JSON RPC actions, JSON helper functions,
// ggSortAwards (profile awards are fixed images since profile_awards_flags),
// JSON caches in App State, old totals and the unused GgScrollBoundary widget.
// Before removing, every item is checked: its identifier key must not be
// referenced anywhere else in the project, and its name must not appear in
// another item's custom code. One reference stops the task (nothing removed).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';

const actions = ['ggV2Rankings', 'ggV2ProfileStats', 'ggV2Games', 'ggClaimSignupBonus'];
const functions = [
  'ggHasData', 'ggMetricValue', 'ggMetricRank', 'ggPlace', 'ggPlayerRow', 'ggRankingPlayerIds',
  'ggTopPlayerIds', 'ggTopPlayerPhoto', 'ggMyPhoto', 'ggTotalPower', 'ggShowMeRow', 'ggShowFinalPlace',
  'ggShowCurrentPlace', 'ggIsFinalSeason', 'ggIsLastPlayer', 'ggRowStyle', 'ggHasAward', 'ggAwards',
  'ggHasGames', 'ggHasMore', 'ggGamesRows', 'ggHomeGauge', 'ggPeriodLabel', 'ggPeriodOptions',
  'ggPeriodOptionLabels', 'ggSeasonOptions', 'ggPeriodName', 'ggPeriodSame', 'ggCacheGet', 'ggCachePut',
  'ggPlaceLabel', 'ggHasActivity', 'totalSumMAX', 'totalSumAVG', 'ggSortAwards',
];
const widgets = ['GgScrollBoundary'];
const appState = ['ggCacheRanking', 'ggCacheStats', 'ggCacheHistory', 'ggCacheProfile', 'ggCacheGuest', 'ggCacheHome'];

final class TypedCleanup extends FlutterFlowAITask {
  TypedCleanup({this.after = const {}});
  final Set<String> after;
  @override
  Set<String> get dependsOn => after;
  @override
  String get name => 'gg-typed-cleanup';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final cc = p.customCode;
    final items = <String, (String kind, String key, String code)>{};
    for (final n in functions) {
      final f = cc.customFunctions.where((x) => x.identifier.name == n).firstOrNull;
      if (f != null) items[n] = ('function', f.identifier.key, f.code);
    }
    for (final n in actions) {
      final a = findCustomAction(p, name: n);
      if (a != null) items[n] = ('action', a.identifier.key, a.code);
    }
    for (final n in widgets) {
      final w = cc.customWidgets.where((x) => x.identifier.name == n).firstOrNull;
      if (w != null) items[n] = ('widget', w.identifier.key, w.code);
    }
    for (final n in appState) {
      final f = p.appState.fields.where((x) => x.parameter.identifier.name == n).firstOrNull;
      if (f != null) items[n] = ('app state', f.parameter.identifier.key, '');
    }

    final all = jsonEncode(p.toProto3Json());
    // Code of the items that stay, without // comments (mentions there are notes).
    String noComments(String c) => c.replaceAll(RegExp(r'//[^\n]*'), '');
    final codes = <String>[
      for (final f in cc.customFunctions)
        if (!items.containsKey(f.identifier.name)) noComments(f.code),
      for (final a in cc.customActions)
        if (!items.containsKey(a.identifier.name)) noComments(a.code),
      for (final w in cc.customWidgets)
        if (!items.containsKey(w.identifier.name)) noComments(w.code),
    ];
    final problems = <String>[];
    for (final MapEntry(key: n, value: (kind, key, _)) in items.entries) {
      final refs = RegExp('"key":"${RegExp.escape(key)}"').allMatches(all).length - 1;
      if (refs > 0) problems.add('$kind $n: $refs reference(s) to its key');
      final inCode = codes.where((c) => RegExp('\\b${RegExp.escape(n)}\\b').hasMatch(c)).length;
      if (inCode > 0) problems.add('$kind $n: named in $inCode other custom code item(s)');
    }
    if (problems.isNotEmpty) throw StateError('Still used:\n${problems.join('\n')}');

    for (final MapEntry(key: n, value: (kind, _, _)) in items.entries) {
      switch (kind) {
        case 'function':
          removeCustomFunction(p, name: n);
        case 'action':
          removeCustomAction(p, name: n);
        case 'widget':
          removeCustomWidget(p, name: n);
        case 'app state':
          removeAppStateField(p, name: n);
      }
    }
    final missing = [...actions, ...functions, ...widgets, ...appState].where((n) => !items.containsKey(n));
    stdout.writeln('removed ${items.length}: '
        '${items.values.where((v) => v.$1 == 'action').length} actions, '
        '${items.values.where((v) => v.$1 == 'function').length} functions, '
        '${items.values.where((v) => v.$1 == 'widget').length} widget, '
        '${items.values.where((v) => v.$1 == 'app state').length} App State fields'
        '${missing.isEmpty ? '' : '; not found (already removed): ${missing.join(', ')}'}');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [TypedCleanup()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games: remove JSON actions, helpers and caches (unused after Data Types)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
