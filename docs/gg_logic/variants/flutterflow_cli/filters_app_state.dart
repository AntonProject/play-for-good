// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 19.10.2026, tester reports:
//  1 Filters / sorting were page state: leaving Good Games (or Home, profile)
//    and coming back reset them to the defaults. They move to App State (not
//    persisted: kept while the app runs, defaults after a restart):
//      GoodGamesPage periodPageUser / valuePageUser / periodPageGame / valuePageGame
//      homePageScore periodState, userProfilePage infoStatsPeriod
//    Every read of the page field reads the App State field; every update of it
//    updates the App State field (split into its own App State update when the
//    same action also sets page fields). The page fields stay, unused.
//    GoodGamesPage On Load set the games filters from its parameters on every
//    open (navbar passes none -> defaults); now only explicit ones (Home link).
//  2 energyComp: "Diese Woche" / "Diesen Monat" showed Good Energy but the place
//    of Good Power next to it (legacy ratingUser(valuable)). The place is now
//    the Good Energy place, like the value and the all-time place.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

// (widget class, page state field, App State field)
const moves = [
  ('GoodGamesPage', 'periodPageUser', 'ggUiGgPeriodUsers'),
  ('GoodGamesPage', 'valuePageUser', 'ggUiGgCategoryUsers'),
  ('GoodGamesPage', 'periodPageGame', 'ggUiGgPeriodGames'),
  ('GoodGamesPage', 'valuePageGame', 'ggUiGgCategoryGames'),
  ('homePageScore', 'periodState', 'ggUiHomePeriod'),
  ('userProfilePage', 'infoStatsPeriod', 'ggUiProfilePeriod'),
];

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.uistate.$seed');

final class FiltersAppState extends FlutterFlowAITask {
  @override
  String get name => 'gg-filters-app-state';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    final byClass = <String, List<(String, String)>>{};
    for (final (cls, field, app) in moves) {
      (byClass[cls] ??= []).add((field, app));
    }

    for (final cls in byClass.keys) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls,
          orElse: () => throw StateError('$cls not found'));
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      final stateFields = (w['classModel']['stateFields'] as List).cast<Map>();
      var changed = 0;
      // Page-state key -> App State identifier, for all fields of this class.
      final targets = <String, Map<String, String>>{};
      final names = <String, String>{};
      for (final (field, app) in byClass[cls]!) {
        final sf = stateFields.firstWhere((f) => f['parameter']['identifier']['name'] == field,
            orElse: () => throw StateError('$cls.$field not found'));
        final stateKey = sf['parameter']['identifier']['key'] as String;
        var appField = p.appState.fields.where((f) => f.parameter.identifier.name == app).firstOrNull;
        if (appField == null) {
          appField = FFAppStateField()
            ..mergeFromProto3Json({
              'parameter': {
                'identifier': {'name': app, 'key': key(app)},
                'dataType': {'scalarType': sf['parameter']['dataType']['scalarType']},
                'description': 'UI filter of $cls ($field), kept while the app runs.',
              },
              'persisted': false,
              if (sf['serializedDefaultValue'] != null) 'serializedDefaultValue': sf['serializedDefaultValue'],
            });
          p.appState.fields.add(appField);
        }
        targets[stateKey] = {'name': app, 'key': appField.parameter.identifier.key};
        names[stateKey] = '$field -> $app';
      }

      final reads = <String, int>{}, writes = <String, int>{};
      void walk(dynamic x) {
        if (x is Map) {
          // reads
          final ls = x['baseVariable']?['localState'];
          String? rk;
          if (ls is Map) rk = (ls['fieldIdentifier'] as Map?)?['key'] as String?;
          if (x['source'] == 'LOCAL_STATE' && ls is Map && targets.containsKey(rk) &&
              ls['stateVariableType'] == 'WIDGET_CLASS_STATE') {
            ls['fieldIdentifier'] = Map.of(targets[rk]!);
            ls['stateVariableType'] = 'APP_STATE';
            x.remove('nodeKeyRef');
            reads[rk!] = (reads[rk] ?? 0) + 1;
          }
          // writes: one page-state update block -> one App State block
          final a = x['action'];
          final lsu = a is Map ? a['localStateUpdate'] : null;
          if (lsu is Map && lsu['stateVariableType'] == 'WIDGET_CLASS_STATE') {
            final ups = (lsu['updates'] as List).cast<Map>();
            final mine = ups.where((u) => targets.containsKey(u['fieldIdentifier']?['key'])).toList();
            if (mine.isNotEmpty) {
              for (final u in mine) {
                final k = u['fieldIdentifier']['key'] as String;
                writes[k] = (writes[k] ?? 0) + 1;
                u['fieldIdentifier'] = Map.of(targets[k]!);
              }
              if (mine.length == ups.length) {
                lsu['stateVariableType'] = 'APP_STATE';
                lsu['updateType'] = 'APPLICATION';
              } else {
                ups.removeWhere(mine.contains);
                final follow = x['followUpAction'];
                final n = '${x['key']}.${cls}';
                x['followUpAction'] = {
                  'key': key('node.$n'),
                  'action': {
                    'key': key('action.$n'),
                    'localStateUpdate': {
                      'updates': mine,
                      'updateType': 'APPLICATION',
                      'stateVariableType': 'APP_STATE',
                    },
                  },
                  if (follow != null) 'followUpAction': follow,
                };
              }
            }
          }
          x.values.toList().forEach(walk);
        } else if (x is List) {
          x.toList().forEach(walk);
        }
      }
      walk(w);
      final json = jsonEncode(w);
      for (final k in targets.keys) {
        final rest = RegExp('"key":\\s*"$k"').allMatches(json).length;
        if (rest != 1) throw StateError('$cls ${names[k]}: $rest references left (expected only its declaration)');
        report.add('$cls.${names[k]} (reads ${reads[k] ?? 0}, updates ${writes[k] ?? 0})');
        changed += (reads[k] ?? 0) + (writes[k] ?? 0);
      }

      if (changed > 0) {
        final next = FFWidgetClass()..mergeFromProto3Json(w);
        restoreUnknownFields(entry.value, next);
        p.widgetClasses[entry.key] = next;
      }
    }

    // 1b GoodGamesPage On Load set the games filters from the page parameters
    //    every time (navbar: defaults auto / valuable, so the kept filters were
    //    reset). Only explicit parameters set them now (Home "all games" passes
    //    gesamt / recent): periodGames != 'auto' OR valueGames != 'valuable'.
    {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'GoodGamesPage');
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      final load = ((w['node']['triggerActions'] as List)
          .firstWhere((t) => t['trigger']['triggerType'] == 'ON_INIT_STATE'))['rootAction'] as Map;
      var gated = 0;
      Map<String, dynamic> notDefault(Map v, String def) => {
            'source': 'FUNCTION_CALL',
            'functionCall': {
              'values': [
                {'variable': Map.of(v)..remove('defaultValue')},
                {'inputValue': {'serializedValue': def}},
              ],
              'condition': {'relation': 'NOT_EQUAL_TO'},
            },
          };
      dynamic gate(dynamic x) {
        if (x is Map) {
          for (final k in x.keys.toList()) {
            x[k] = gate(x[k]);
          }
          final ups = x['action']?['localStateUpdate']?['updates'];
          if (ups is List && x['conditionActions'] == null) {
            Map? param(String app, String paramName) {
              for (final u in ups) {
                final v = u['setValue']?['variable'];
                if (u['fieldIdentifier']?['name'] == app && v is Map &&
                    v['source'] == 'WIDGET_CLASS_PARAMETER' &&
                    v['baseVariable']?['widgetClass']?['paramIdentifier']?['name'] == paramName) {
                  return v;
                }
              }
              return null;
            }
            final period = param('ggUiGgPeriodGames', 'periodGames');
            final value = param('ggUiGgCategoryGames', 'valueGames');
            if (period != null && value != null) {
              gated++;
              final node = x as Map<String, dynamic>;
              final follow = node.remove('followUpAction');
              return {
                'key': key('gate.${node['key']}'),
                'conditionActions': {
                  'key': key('gatecond.${node['key']}'),
                  'trueActions': [
                    {
                      'condition': {
                        'variable': {
                          'source': 'FUNCTION_CALL',
                          'functionCall': {
                            'combineConditions': {'operator': 'OR_OP'},
                            'values': [
                              {'variable': notDefault(period, 'auto')},
                              {'variable': notDefault(value, 'valuable')},
                            ],
                          },
                        }
                      },
                      'trueAction': node,
                    }
                  ],
                },
                if (follow != null) 'followUpAction': follow,
              };
            }
          }
          return x;
        }
        if (x is List) {
          for (var i = 0; i < x.length; i++) {
            x[i] = gate(x[i]);
          }
        }
        return x;
      }
      gate(load);
      if (gated == 0 && !jsonEncode(load).contains('"OR_OP"')) {
        throw StateError('GoodGamesPage: On Load games filter update not found');
      }
      if (gated > 0) {
        final next = FFWidgetClass()..mergeFromProto3Json(w);
        restoreUnknownFields(entry.value, next);
        p.widgetClasses[entry.key] = next;
        report.add('GoodGamesPage On Load: games filters from parameters only when passed explicitly');
      }
    }

    // 2 energyComp week / month place: goodPower.rank -> goodEnergy.rank
    final stats = findDataStruct(p, name: 'GgProfileStats') ?? (throw StateError('GgProfileStats missing'));
    Map fieldId(String n) {
      final f = stats.fields.firstWhere((f) => f.identifier.name == n);
      return {'name': f.identifier.name, 'key': f.identifier.key};
    }
    final gp = fieldId('goodPower'), ge = fieldId('goodEnergy');
    final eEntry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'energyComp');
    final ew = jsonDecode(jsonEncode(eEntry.value.toProto3Json())) as Map<String, dynamic>;
    var fixed = 0;
    void energy(dynamic x) {
      if (x is Map) {
        final ops = x['operations'];
        final s = jsonEncode(x['functionCall'] ?? const {});
        if (x['source'] == 'FUNCTION_CALL' && ops is List && ops.length >= 2 &&
            (s.contains('"ggEnergyWeek"') || s.contains('"ggEnergyMonth"')) &&
            ops[0]['accessDataStructField']?['fieldIdentifier']?['key'] == gp['key'] &&
            ops[1]['accessDataStructField']?['fieldIdentifier']?['name'] == 'rank') {
          ops[0]['accessDataStructField']['fieldIdentifier'] = Map.of(ge);
          fixed++;
        }
        x.values.forEach(energy);
      } else if (x is List) {
        x.forEach(energy);
      }
    }
    energy(ew);
    if (fixed > 0) {
      final next = FFWidgetClass()..mergeFromProto3Json(ew);
      restoreUnknownFields(eEntry.value, next);
      p.widgetClasses[eEntry.key] = next;
      report.add('energyComp: week / month place = Good Energy place x$fixed');
    }
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [FiltersAppState()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Filters kept while the app runs (App State); Energy places by Good Energy',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
