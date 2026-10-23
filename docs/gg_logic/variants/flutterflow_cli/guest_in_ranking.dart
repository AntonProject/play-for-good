// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 22.10.2026, customer feedback 5 / 10: one place everywhere.
//  5.1 The demo guest stands in the Good Power list at its place, like the own
//      row of a signed-in user (it was only under the list: a second #1 / #8);
//      the players from that place on move one place down, on the podium too.
//      Functions ggListIdsOf (new), ggPlayerOf, ggTopPlayerAt, ggShowMeRowOf,
//      ggIsLastPlayerOf, ggRowStyleOf; ggLoadProfileStats shifts the Good Power
//      places of other players for a guest viewer the same way.
//  5.2 The guest has its 100 only in periods that include today: in a closed
//      season or last month it has 0 and no row in Good Games (ggRankingPlace,
//      ggHomeGaugeOf, ggLoadProfileStats).
//  5.3 Profile header (page and dialog): Good Power and place of the period
//      chosen in Stats, not All-Time (#14 above, #3 in Stats).
//  10  Energy: the places under €nergy are Good Power places of the week /
//      month / All-Time (#12 by €nergy, #14 in the profile).
// FF changes:
//   GoodGamesPage   list rows = ggListIdsOf(ggRanking); list frame shown when
//                   it is not empty; row under the list = ggShowMeRowOf only
//                   (the "or not signed in" part removed)
//   gamesUserComp   name / place / points in red also for the guest row
//   userProfilePage header value / place: ggProfile.goodPower.value / .rank
//   userProfile     same (dialog)
//   energyComp      three place badges: goodPower.rank instead of goodEnergy.rank
// ONE commit.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

final class GuestInRanking extends FlutterFlowAITask {
  @override
  String get name => 'gg-guest-in-ranking';
  @override
  Set<String> get dependsOn => {'register-gg-rpc'};
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    Map<String, dynamic> load(String cls) =>
        jsonDecode(jsonEncode(p.widgetClasses.values.firstWhere((e) => e.name == cls).toProto3Json()));
    void save(String cls, Map<String, dynamic> w) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }

    Map node(Map w, String key) {
      Map? r;
      void s(dynamic x) {
        if (r != null) return;
        if (x is Map) {
          if (x['key'] == key && x['type'] != null) {
            r = x;
            return;
          }
          x.values.forEach(s);
        } else if (x is List) {
          x.forEach(s);
        }
      }
      s(w['node']);
      return r ?? (throw StateError('node $key missing'));
    }

    Map<String, dynamic> fn(String name) {
      final f = p.customCode.customFunctions.where((f) => f.identifier.name == name).firstOrNull ??
          (throw StateError('$name function missing (transfer first)'));
      return {'name': f.identifier.name, 'key': f.identifier.key};
    }

    Map<String, dynamic> field(String struct, String name) {
      final s = findDataStruct(p, name: struct) ?? (throw StateError('$struct missing'));
      final f = s.fields.firstWhere((f) => f.identifier.name == name).identifier;
      return {'name': f.name, 'key': f.key};
    }

    Map access(Map<String, dynamic> f) => {
          'accessDataStructField': {'fieldIdentifier': f}
        };

    // Replaces, in `ops` lists under `root`, the struct field `from` by `to`
    // (a list of operations). Returns the number of replacements.
    int replaceOps(dynamic root, String from, List<Map> to, {String? nextName}) {
      var n = 0;
      void s(dynamic x) {
        if (x is Map) {
          final ops = x['operations'];
          if (ops is List) {
            for (var i = 0; i < ops.length; i++) {
              final f = (ops[i] as Map)['accessDataStructField']?['fieldIdentifier'];
              if (f is! Map || f['name'] != from) continue;
              if (nextName != null) {
                final next = i + 1 < ops.length ? ((ops[i + 1] as Map)['accessDataStructField']?['fieldIdentifier']) : null;
                if (next is! Map || next['name'] != nextName) continue;
              }
              ops.replaceRange(i, i + 1, jsonDecode(jsonEncode(to)) as List);
              n++;
            }
          }
          x.values.forEach(s);
        } else if (x is List) {
          x.forEach(s);
        }
      }
      s(root);
      return n;
    }

    // 1. GoodGamesPage.
    {
      final w = load('GoodGamesPage');
      var changed = 0;
      final list = node(w, 'ListView_f2ogaegd');
      final gen = list['props']?['generator']?['generatorVariable'] ??
          _find(list, 'generatorVariable') ??
          (throw StateError('GoodGamesPage: list generator missing'));
      final genVar = gen['variable'] as Map;
      if (jsonEncode(genVar).contains('"ggListIdsOf"')) {
        report.add('GoodGamesPage: list already uses ggListIdsOf');
      } else {
        // The ggRanking page state variable as the generator already reads it.
        final rankingVar = _find(genVar, 'baseVariable', where: (m) => m['source'] == 'LOCAL_STATE', parent: true) ??
            (throw StateError('GoodGamesPage: ggRanking variable missing'));
        final call = {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'values': [
              {'variable': jsonDecode(jsonEncode(rankingVar))}
            ],
            'customFunction': fn('ggListIdsOf'),
          },
        };
        gen['variable'] = call;
        // The list frame: shown when there are rows (the guest alone too).
        final frame = node(w, 'PlaceholderWidget_o7qo5wzq');
        final cond = frame['props']['visibility']['visibleValue']['variable']['functionCall']['values'][0]['variable'] as Map;
        if (cond['functionCall']?['customFunction']?['name'] != 'ggPlayerIdsOf') {
          throw StateError('GoodGamesPage: unexpected list frame condition');
        }
        cond['functionCall'] = jsonDecode(jsonEncode(call['functionCall']));
        changed++;
        report.add('GoodGamesPage: list rows and frame -> ggListIdsOf(ggRanking)');
      }
      for (final key in ['Divider_5m77xyn5', 'Container_hsks3evp']) {
        final vv = node(w, key)['props']['visibility']['visibleValue'] as Map;
        final v = vv['variable'] as Map;
        final values = (v['functionCall']?['values'] as List?) ?? const [];
        if (v['functionCall']?['combineConditions']?['operator'] == 'OR_OP' &&
            values.length == 2 &&
            jsonEncode(values[0]).contains('"ggShowMeRowOf"') &&
            jsonEncode(values[1]).contains('IS_USER_LOGGED_IN')) {
          vv['variable'] = (values[0] as Map)['variable'];
          changed++;
          report.add('GoodGamesPage: $key visible = ggShowMeRowOf only');
        } else if (v['functionCall']?['customFunction']?['name'] == 'ggShowMeRowOf') {
          report.add('GoodGamesPage: $key already ggShowMeRowOf only');
        } else {
          throw StateError('GoodGamesPage: unexpected $key visibility');
        }
      }
      if (changed > 0) save('GoodGamesPage', w);
    }

    // 2. gamesUserComp: the guest row in red like the own row.
    {
      final w = load('gamesUserComp');
      var n = 0;
      final userId = field('GgPlayer', 'userId');
      for (final key in ['Text_yttsso1d', 'Text_tnfcf2yg', 'Text_l3frcpxh']) {
        final cv = node(w, key)['props']['text']['colorValue']['variable'] as Map;
        final branch = (cv['functionCall']['conditionalValue']['ifConditionalValues'] as List).first as Map;
        final cond = branch['condition'] as Map;
        if (jsonEncode(cond).contains('"guest"')) continue;
        final values = (cond['functionCall']?['values'] as List?) ?? const [];
        if (cond['functionCall']?['condition']?['relation'] != 'EQUAL_TO' ||
            values.length != 2 ||
            !jsonEncode(values[1]).contains('USER_ID')) {
          throw StateError('gamesUserComp: unexpected own-row condition in $key');
        }
        branch['condition'] = {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'values': [
              {'variable': cond},
              {
                'variable': {
                  'source': 'FUNCTION_CALL',
                  'functionCall': {
                    'values': [
                      {
                        'variable': {
                          'source': 'WIDGET_CLASS_PARAMETER',
                          'baseVariable': {
                            'widgetClass': {
                              'paramIdentifier': {'name': 'player', 'key': 'gg6b92438ce7'}
                            }
                          },
                          'operations': [access(userId)],
                          'nodeKeyRef': {'key': 'Container_f1ihd94m'},
                        }
                      },
                      {
                        'inputValue': {'serializedValue': 'guest'}
                      }
                    ],
                    'condition': {'relation': 'EQUAL_TO'},
                  },
                }
              }
            ],
            'combineConditions': {'operator': 'OR_OP'},
          },
        };
        n++;
      }
      if (n > 0) {
        save('gamesUserComp', w);
        report.add('gamesUserComp: guest row in red ($n texts)');
      } else {
        report.add('gamesUserComp: guest row already in red');
      }
    }

    final goodPower = field('GgProfileStats', 'goodPower');
    final value = field('GgMetric', 'value');
    final rank = field('GgMetric', 'rank');

    // 3. Profile header (page and dialog): Good Power of the Stats period.
    for (final cls in ['userProfilePage', 'userProfile']) {
      final w = load(cls);
      final keys = cls == 'userProfilePage'
          ? {'value': 'Text_wn608uvw', 'rank': 'Text_gsiwo116'}
          : {'value': 'Text_wlmhu8bi', 'rank': 'Text_hxquiapz'};
      var n = replaceOps(node(w, keys['value']!), 'allTimeGoodPower', [access(goodPower), access(value)]);
      n += replaceOps(node(w, keys['rank']!), 'allTimeRank', [access(goodPower), access(rank)]);
      if (cls == 'userProfilePage') {
        // Guest badge: the same place from the guest stats (ggProfile).
        final t = node(w, 'Text_ps6amarn')['props']['text']['textValue']['variable'] as Map;
        final arg = (t['functionCall']['values'] as List).first as Map;
        if (jsonEncode(arg).contains('"guestPlaces"')) {
          final statsVar = _find(node(w, 'Text_gsiwo116')['props']['text']['textValue'], 'functionCall',
                  where: (m) => m['functionCall']?['customFunction']?['name'] == 'ggStatsOrEmpty', parent: true) ??
              (throw StateError('userProfilePage: ggProfile variable missing'));
          final v = jsonDecode(jsonEncode(statsVar)) as Map;
          v['operations'] = [access(goodPower), access(rank)];
          arg['variable'] = v;
          n++;
        }
      }
      if (n > 0) {
        save(cls, w);
        report.add('$cls: header Good Power / place of the Stats period ($n refs)');
      } else {
        report.add('$cls: header already follows the Stats period');
      }
    }

    // 4. Energy: Good Power places of the week / month / All-Time.
    {
      final w = load('energyComp');
      var n = 0;
      for (final key in ['Text_5z51rir0', 'Text_ba7t9wu1', 'Text_iv394fu7']) {
        n += replaceOps(node(w, key), 'goodEnergy', [access(goodPower)], nextName: 'rank');
      }
      if (n > 0) {
        save('energyComp', w);
        report.add('energyComp: places by Good Power ($n badges)');
      } else {
        report.add('energyComp: places already by Good Power');
      }
    }
    stdout.writeln(report.join('\n'));
  }
}

// First map under `x` that has `key` (and passes `where` on its value); with
// `parent` the map holding the key, otherwise the value.
Map? _find(dynamic x, String key, {bool Function(Map)? where, bool parent = false}) {
  Map? r;
  void s(dynamic y) {
    if (r != null) return;
    if (y is Map) {
      final v = y[key];
      if (v is Map && (where == null || where(parent ? y : v))) {
        r = parent ? y : v;
        return;
      }
      y.values.forEach(s);
    } else if (y is List) {
      y.forEach(s);
    }
  }
  s(x);
  return r;
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-guestlist-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports), GuestInRanking()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Guest inside the Good Games list, only in current periods; one Good Power place in profile header and Energy',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
