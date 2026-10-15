// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Season options come from the server calendar (gg_v2.seasons, returned by the
// RPCs as available_periods) instead of hardcoded 'Saison 2026/27' / '2025/26':
//  1. homePageScore period dropdown: options and labels from
//     ggPeriodOptions / ggPeriodOptionLabels(ggHomeRank, withWeek: true);
//     periodState starts at 'auto' (= the current season, labelled with its name).
//  2. goodGamesPlayersFilters: new parameter `ranking` (JSON); the two season
//     rows become one generated row per season (ggSeasonOptions(ranking)):
//     name ggPeriodName, selected ggPeriodSame, tap sets periodState to the key.
//     Fixed rows (Letzten Monat, Diesen Monat, All-Time) are unchanged.
//  3. GoodGamesPage: both filter sheets pass ranking = ggRanking.
// A season added to gg_v2.seasons (cron or admin) appears once it has started.
// Requires the functions above (transfer.dart, rpc variant).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.periods.$seed');

const dialogColumn = 'Column_lbur8gzt';
const seasonRow = 'Row_cuuikz4f';
const seasonRows = ['Row_cuuikz4f', 'Divider_xsuz9bc2', 'Row_s96d3eq2', 'Divider_49ewm4mr'];
const seasonText = 'Text_be4rwgqq';
const seasonSelected = 'PlaceholderWidget_393q9ckn';

final class DynamicPeriods extends FlutterFlowAITask {
  DynamicPeriods({this.after = const {}});
  final Set<String> after;
  @override
  Set<String> get dependsOn => after;
  @override
  String get name => 'gg-dynamic-periods';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
    if (n['key'] == k) return n;
    for (final c in (n['children'] as List? ?? [])) {
      final r = find(c as Map<String, dynamic>, k);
      if (r != null) return r;
    }
    return null;
  }

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    Map<String, dynamic> fnRef(String name) {
      final f = p.customCode.customFunctions.where((f) => f.identifier.name == name).firstOrNull ??
          (throw StateError('$name custom function is missing'));
      return {'name': f.identifier.name, 'key': f.identifier.key};
    }
    Map<String, dynamic> call(String fn, List<Map<String, dynamic>> values) => {
          'source': 'FUNCTION_CALL',
          'functionCall': {'values': values, 'customFunction': fnRef(fn)},
        };
    Map<String, dynamic> v(Map<String, dynamic> variable) => {'variable': variable};
    Map<String, dynamic> stateVar(Map<String, dynamic> w, String field) {
      final f = ((w['classModel'] as Map)['stateFields'] as List)
          .firstWhere((f) => f['parameter']['identifier']['name'] == field);
      return {
        'source': 'LOCAL_STATE',
        'baseVariable': {
          'localState': {'fieldIdentifier': f['parameter']['identifier'], 'stateVariableType': 'WIDGET_CLASS_STATE'}
        },
        'nodeKeyRef': {'key': w['node']['key']},
      };
    }
    void edit(String cls, void Function(Map<String, dynamic>) f) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      f(w);
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }

    // 1. Home dropdown.
    edit('homePageScore', (w) {
      Map<String, dynamic>? dd;
      void walk(Object? n) {
        if (n is Map) {
          if (n['props'] is Map && (n['props'] as Map)['dropDown'] is Map) dd = (n['props'] as Map)['dropDown'];
          n.values.forEach(walk);
        } else if (n is List) {
          n.forEach(walk);
        }
      }
      walk(w['node']);
      final d = dd ?? (throw StateError('home dropdown not found'));
      final rank = stateVar(w, 'ggHomeRank');
      final week = {'inputValue': {'serializedValue': 'true'}};
      d['optionsValues'] = {'variable': call('ggPeriodOptions', [v(rank), week])};
      d['optionsLabels'] = {'variable': call('ggPeriodOptionLabels', [v(rank), week])};
      (d['hintText'] as Map)['textValue'] = {'inputValue': 'Saison'};
      final field = ((w['classModel'] as Map)['stateFields'] as List)
          .firstWhere((f) => f['parameter']['identifier']['name'] == 'periodState') as Map;
      field['serializedDefaultValue'] = ['auto'];
    });

    // 2. Filter dialog.
    late Map<String, dynamic> rankingParam;
    edit('goodGamesPlayersFilters', (w) {
      final params = (w['params'] as Map<String, dynamic>);
      var existing = params.values.cast<Map>().where((x) => x['identifier']['name'] == 'ranking').firstOrNull;
      if (existing == null) {
        final k = key('param.ranking').substring(0, 6);
        existing = {
          'identifier': {'name': 'ranking', 'key': k},
          'dataType': {'scalarType': 'JSON', 'nonNullable': false},
        };
        params[k] = existing;
      }
      rankingParam = Map<String, dynamic>.from(existing['identifier'] as Map);
      final root = w['node'] as Map<String, dynamic>;
      final col = find(root, dialogColumn) ?? (throw StateError('$dialogColumn not found'));
      final kids = col['children'] as List;
      final idx = seasonRows.map((k) => kids.indexWhere((c) => c['key'] == k)).toList();
      if (idx.contains(-1)) throw StateError('season rows not found (already dynamic?)');
      if (idx.toString() != [for (var i = 0; i < 4; i++) idx.first + i].toString()) {
        throw StateError('season rows are not consecutive: $idx');
      }
      final row = kids[idx[0]] as Map<String, dynamic>;
      final divider = kids[idx[1]] as Map<String, dynamic>;
      final genKey = 'Column_${key('dialog.gen')}';
      final item = {
        'source': 'GENERATOR_VARIABLE',
        'baseVariable': {'generatorVariable': {}},
        'nodeKeyRef': {'key': genKey},
      };
      final ranking = {
        'source': 'WIDGET_CLASS_PARAMETER',
        'baseVariable': {
          'widgetClass': {'paramIdentifier': rankingParam}
        },
        'nodeKeyRef': {'key': root['key']},
      };
      final periodState = stateVar(w, 'periodState');
      // name
      final text = find(row, seasonText) ?? (throw StateError('$seasonText not found'));
      final t = (text['props'] as Map)['text'] as Map;
      t.remove('translationIdentifier');
      t['textValue'] = {'variable': call('ggPeriodName', [v(item), v(ranking)])};
      // selected mark
      final mark = find(row, seasonSelected) ?? (throw StateError('$seasonSelected not found'));
      (mark['props'] as Map)['visibility'] = {
        'visibleValue': {
          'variable': call('ggPeriodSame', [v(periodState), v(item), v(ranking)]),
          'mostRecentInputValue': true,
        }
      };
      // tap: periodState = season key
      final updates = (((row['triggerActions'] as List).single as Map)['rootAction']['action']['localStateUpdate']
          as Map)['updates'] as List;
      if (updates.length != 1) throw StateError('season row tap: unexpected updates');
      (updates.single as Map)['setValue'] = {'variable': item};
      final gen = {
        'key': genKey,
        'type': 'Column',
        'props': {
          'column': {'minSizeValue': {'inputValue': 'main_axis_min'}}
        },
        'generatorVariable': {
          'identifier': {'name': 'seasonItem', 'key': key('dialog.gen.var')},
          'variable': call('ggSeasonOptions', [v(ranking)]),
        },
        'children': [
          {
            'key': 'Column_${key('dialog.item')}',
            'type': 'Column',
            'props': {
              'column': {'minSizeValue': {'inputValue': 'main_axis_min'}}
            },
            'children': [row, divider],
          }
        ],
      };
      kids.replaceRange(idx.first, idx.last + 1, [gen]);
      for (final r in (col['childPropertyMap'] as Map? ?? {}).values) {
        final refs = (r as Map)['keyRefs'] as List? ?? [];
        refs.removeWhere((x) => seasonRows.skip(1).contains(x['key']));
        for (final x in refs) {
          if (x['key'] == seasonRows.first) x['key'] = genKey;
        }
      }
    });

    // 3. GoodGamesPage passes its ranking to both filter sheets.
    var passes = 0;
    edit('GoodGamesPage', (w) {
      final rank = stateVar(w, 'ggRanking');
      void walk(Object? n) {
        if (n is Map) {
          final pp = (n['passedParameters'] as Map?)?['parameterPasses'] as Map?;
          final period = pp?['6d3bf7'] as Map?;
          if (pp != null && period != null && period['paramIdentifier']?['name'] == 'period' && pp.containsKey('zc8lp0')) {
            pp[rankingParam['key']] = {
              'paramIdentifier': rankingParam,
              'variable': {...rank, 'nodeKeyRef': (period['variable'] as Map?)?['nodeKeyRef'] ?? rank['nodeKeyRef']},
            };
            passes++;
          }
          n.values.forEach(walk);
        } else if (n is List) {
          n.forEach(walk);
        }
      }
      walk(w['node']);
    });
    if (passes < 2) throw StateError('expected the filter sheets on GoodGamesPage, found $passes');
    stdout.writeln('homePageScore: dropdown options from ggPeriodOptions (default auto)\n'
        'goodGamesPlayersFilters: season rows from ggSeasonOptions(ranking)\n'
        'GoodGamesPage: ranking passed to $passes filter sheets');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [DynamicPeriods()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Period filters: seasons from gg_v2.seasons',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
