// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// GoodGamesPage fixes after remove_legacy_queries.dart:
//  * that script mapped every "<legacy list>.length > 0" to the user's own
//    stats (ggHasGames/ggHasActivity). Five of those lists were GLOBAL (all
//    completed games / used invites of the environment), i.e. effectively
//    always true, so guests and players without games lost the filters and
//    Meisterschaft rows. The owner removed the Meisterschaft filter condition;
//    here: Meine Games filter opens unconditionally, Meisterschaft rows have no
//    visibility condition, the logo padding is its "has data" value (0).
//    Personal conditions (ggHasGames || ggGamesRows(history)) stay.
//  * "per Game" numbers: #,##0.0 -> #,##0.# (0 instead of 0,0, as in profile).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'GoodGamesPage';
const filterTap = 'Container_mhscf3iu';
const rows = ['Row_7t3fadr7', 'Row_rd1b1xr0'];
const logo = 'Image_97isam37';

final class GoodGamesGlobalConditions extends FlutterFlowAITask {
  @override
  String get name => 'gg-goodgames-global-conditions';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    Map<String, dynamic> find(Map<String, dynamic> n, String k) {
      if (n['key'] == k) return n;
      for (final c in (n['children'] as List? ?? [])) {
        try {
          return find(c as Map<String, dynamic>, k);
        } on StateError {
          continue;
        }
      }
      throw StateError('$k not found');
    }
    bool ownStatsOnly(dynamic v) {
      final s = jsonEncode(v);
      return s.contains('"ggHasGames"') && s.contains('"ggMyStats"') && !s.contains('ggGamesRows');
    }
    final done = <String>[];

    // 1. Meine Games filter: open the bottom sheet without the condition.
    final tap = find(w['node'], filterTap);
    final trigger = (tap['triggerActions'] as List).single as Map<String, dynamic>;
    final root = trigger['rootAction'] as Map<String, dynamic>;
    final branch = (root['conditionActions']?['trueActions'] as List?)?.single as Map?;
    if (branch == null || !ownStatsOnly(branch['condition']) || root['conditionActions']['falseAction'] != null ||
        root['followUpAction'] != null || branch['trueAction']?['action']?['bottomSheet'] == null) {
      throw StateError('$filterTap: unexpected tap flow');
    }
    trigger['rootAction'] = branch['trueAction'];
    done.add('filter');

    // 2. Meisterschaft rows: no visibility condition.
    for (final k in rows) {
      final n = find(w['node'], k);
      final vis = n['props']?['visibility'];
      if (vis == null || !ownStatsOnly(vis) || !jsonEncode(vis).contains('ggHasActivity')) {
        throw StateError('$k: unexpected visibility');
      }
      (n['props'] as Map).remove('visibility');
      done.add(k);
    }

    // 3. Logo bottom padding: the value used when there is data.
    final bottom = find(w['node'], logo)['props']['padding']['bottomValue'] as Map<String, dynamic>;
    final cv = bottom['variable']?['functionCall']?['conditionalValue'];
    final ifs = cv?['ifConditionalValues'] as List?;
    if (ifs == null || ifs.length != 1 || !ownStatsOnly(ifs.first['condition'])) {
      throw StateError('$logo: unexpected padding');
    }
    // Conditional values are serialized strings; a plain padding is a number.
    final value = ifs.first['value'] as Map<String, dynamic>;
    final number = double.parse('${value['inputValue']?['serializedValue'] ?? value['inputValue']}');
    bottom
      ..clear()
      ..addAll({'inputValue': number});
    done.add('logo=${jsonEncode(value)}');

    // 4. Number formats with a forced decimal.
    var formats = 0;
    void fmt(dynamic x) {
      if (x is Map) {
        final nf = x['numberFormat'];
        if (nf is Map && nf['customFormat'] == '#,##0.0') {
          nf['customFormat'] = '#,##0.#';
          formats++;
        }
        x.values.forEach(fmt);
      } else if (x is List) {
        x.forEach(fmt);
      }
    }
    fmt(w);
    if (formats != 2) throw StateError('Expected 2 #,##0.0 formats, found $formats');

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('GoodGamesPage: ${done.join(', ')}; formats $formats -> #,##0.#');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [GoodGamesGlobalConditions()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'GoodGamesPage: global conditions back to always-on, 0 instead of 0,0',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
