// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Step 2.2 of the typed Good Games data: GoodGamesPage, the ranking row
// component (GamesUserComp) and the filter sheet (goodGamesPlayersFilters)
// move from JSON to Data Types.
//   GoodGamesPage state ggRanking / ggMyStats / ggHistory
//     -> GgRanking / GgProfileStats / GgGamesEntry
//   GamesUserComp params playerJson / rankingJson -> GgPlayer / GgRanking
//   goodGamesPlayersFilters param ranking -> GgRanking
//   ggV2Rankings / ggV2ProfileStats / ggV2Games -> ggLoadRanking /
//     ggLoadProfileStats / ggLoadGames; JSON caches -> typed App State caches
//   JSON helper functions -> fields or their typed versions (...Of)
// The task fails (nothing is written) if a JSON use of these values remains.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

// class -> {state field / parameter name -> Data Type}
const typedState = {
  'GoodGamesPage': {'ggRanking': 'GgRanking', 'ggMyStats': 'GgProfileStats', 'ggHistory': 'GgGamesEntry'},
};
const typedParams = {
  'gamesUserComp': {'playerJson': 'GgPlayer', 'rankingJson': 'GgRanking'},
  'goodGamesPlayersFilters': {'ranking': 'GgRanking'},
};
const typedOutputs = {
  'ggRankingOut': 'GgRanking',
  'ggMyStatsOut': 'GgProfileStats',
  'ggHistoryOut': 'GgGamesEntry',
};
const metricFields = {
  'good_power': 'goodPower',
  'games': 'games',
  'good_energy': 'goodEnergy',
  'sponsored_games': 'sponsoredGames',
  'good_power_per_game': 'goodPowerPerGame',
  'good_energy_per_game': 'goodEnergyPerGame',
};
// JSON paths -> fields, per Data Type
const jsonPaths = {
  'GgPlayer': {
    r'$.display_name': ['GgPlayer.displayName'],
    r'$.photo_url': ['GgPlayer.photoUrl'],
    r'$.user_id': ['GgPlayer.userId'],
  },
  'GgRanking': {r'$.period.key': ['GgRanking.period', 'GgPeriod.key']},
  'GgProfileStats': {r'$.period.key': ['GgProfileStats.period', 'GgPeriod.key']},
  'GgGamesEntry': {r'$.period.key': ['GgGamesEntry.meta', 'GgGamesPage.period', 'GgPeriod.key']},
};
const oldFunctions = {
  'ggHasData', 'ggMetricValue', 'ggMetricRank', 'ggPlayerRow', 'ggRankingPlayerIds', 'ggTopPlayerIds',
  'ggShowMeRow', 'ggShowFinalPlace', 'ggShowCurrentPlace', 'ggIsFinalSeason', 'ggHasGames', 'ggHasMore',
  'ggTopPlayerPhoto', 'ggMyPhoto', 'ggPlace', 'ggTotalPower', 'ggGamesRows', 'ggHasAward', 'ggIsLastPlayer',
  'ggRowStyle', 'ggSeasonOptions', 'ggPeriodName', 'ggPeriodSame', 'ggCacheGet', 'ggCachePut',
};

final class TypedGoodGames extends FlutterFlowAITask {
  TypedGoodGames({this.after = const {}});
  final Set<String> after;
  @override
  Set<String> get dependsOn => after;
  @override
  String get name => 'gg-typed-good-games';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    Map<String, dynamic> id(FFIdentifier i) => {'name': i.name, 'key': i.key};
    Map<String, dynamic> fn(String name) => id(
        (p.customCode.customFunctions.where((f) => f.identifier.name == name).firstOrNull ??
                (throw StateError('$name function missing')))
            .identifier);
    FFDataStruct struct(String name) =>
        findDataStruct(p, name: name) ?? (throw StateError('$name Data Type missing'));
    Map<String, dynamic> field(String path) {
      final parts = path.split('.');
      return {
        'accessDataStructField': {
          'fieldIdentifier': id(struct(parts[0])
              .fields
              .firstWhere((f) => f.identifier.name == parts[1], orElse: () => throw StateError('$path missing'))
              .identifier)
        }
      };
    }
    Map<String, dynamic> appState(String name) => id(p.appState.fields
        .firstWhere((f) => f.parameter.identifier.name == name, orElse: () => throw StateError('App State $name missing'))
        .parameter
        .identifier);
    FFCustomAction action(String name) =>
        findCustomAction(p, name: name) ?? (throw StateError('$name action missing'));
    Map<String, dynamic> structType(String name, {bool list = false}) {
      final single = {
        'scalarType': 'DataStruct',
        'subType': {'dataStructIdentifier': id(struct(name).identifier)},
        'nonNullable': false,
      };
      return single;
    }

    final caches = {
      appState('ggCacheRanking')['key']: ['ggRankingCache', 'ggRankingFromCache', 'ggRankingToCache'],
      appState('ggCacheStats')['key']: ['ggStatsCache', 'ggStatsFromCache', 'ggStatsToCache'],
      appState('ggCacheHistory')['key']: ['ggGamesCache', 'ggGamesFromCache', 'ggGamesToCache'],
    };
    final actionSwap = {
      action('ggV2Rankings').identifier.key: action('ggLoadRanking'),
      action('ggV2ProfileStats').identifier.key: action('ggLoadProfileStats'),
      action('ggV2Games').identifier.key: action('ggLoadGames'),
    };
    final oldArgs = {
      for (final a in [action('ggV2Rankings'), action('ggV2ProfileStats'), action('ggV2Games')])
        a.identifier.key: {for (final x in a.arguments) x.identifier.key: x.identifier.name}
    };

    final edits = <String, Map<String, dynamic>>{};
    Map<String, dynamic> load(String cls) => edits[cls] ??= jsonDecode(jsonEncode(
        p.widgetClasses.values.firstWhere((x) => x.name == cls).toProto3Json())) as Map<String, dynamic>;
    for (final cls in ['GoodGamesPage', 'gamesUserComp', 'goodGamesPlayersFilters']) {
      load(cls);
    }

    final counts = <String, Map<String, int>>{};
    for (final cls in edits.keys) {
      final w = edits[cls]!;
      final c = counts[cls] = <String, int>{};
      void count(String rule) => c[rule] = (c[rule] ?? 0) + 1;

      final stateKeys = <String, String>{}; // key -> struct
      for (final f in ((w['classModel'] as Map?)?['stateFields'] as List? ?? [])) {
        final t = typedState[cls]?[f['parameter']['identifier']['name']];
        if (t != null) stateKeys[f['parameter']['identifier']['key']] = t;
      }
      final paramKeys = <String, String>{}; // key -> struct
      for (final e in ((w['params'] as Map?) ?? {}).values) {
        final t = typedParams[cls]?[e['identifier']['name']];
        if (t != null) paramKeys[e['identifier']['key']] = t;
      }

      String? typeOf(dynamic v) {
        if (v is! Map) return null;
        String? t;
        switch (v['source']) {
          case 'LOCAL_STATE':
            t = stateKeys[v['baseVariable']?['localState']?['fieldIdentifier']?['key']];
          case 'WIDGET_CLASS_PARAMETER':
            t = paramKeys[v['baseVariable']?['widgetClass']?['paramIdentifier']?['key']];
          case 'ACTION_OUTPUTS':
            t = typedOutputs[v['baseVariable']?['actionOutput']?['outputVariableIdentifier']?['name']];
          case 'FUNCTION_CALL':
            final name = (v['functionCall'] as Map?)?['customFunction']?['name'];
            if (name == 'ggPlayerOf' || name == 'ggTopPlayerAt') t = 'GgPlayer';
        }
        if (t != null && (v['operations'] as List? ?? []).isNotEmpty) return null; // a field of it
        return t;
      }
      String? fnName(Map v) => (v['functionCall'] as Map?)?['customFunction']?['name'] as String?;
      List args(Map v) => ((v['functionCall'] as Map)['values'] as List);
      dynamic argVar(Map v, int i) => (args(v)[i] as Map)['variable'];
      String? argInput(Map v, int i) => (args(v)[i] as Map)['inputValue']?['serializedValue'] as String?;
      Map<String, dynamic> copy(dynamic x) => jsonDecode(jsonEncode(x)) as Map<String, dynamic>;
      Map<String, dynamic> withOps(Map base, List<String> fields, Map from) {
        final r = copy(base);
        r['operations'] = [...((r['operations'] as List?) ?? []), for (final f in fields) field(f), ...((from['operations'] as List?) ?? [])];
        for (final k in ['defaultValue', 'uiBuilderValue']) {
          if (from[k] != null) r[k] = from[k];
        }
        return r;
      }
      Map<String, dynamic> call(String name, List values, Map from) => {
            'source': 'FUNCTION_CALL',
            if (from['defaultValue'] != null) 'defaultValue': from['defaultValue'],
            'functionCall': {'values': values, 'customFunction': fn(name)},
            if (from['operations'] != null) 'operations': from['operations'],
            if (from['uiBuilderValue'] != null) 'uiBuilderValue': from['uiBuilderValue'],
          };
      Map<String, dynamic> varArg(Map v) => {'variable': v};

      Map rewriteVar(Map v) {
        // JSON paths on typed values -> fields / top player
        final ops = v['operations'] as List?;
        if (ops != null && ops.isNotEmpty && (ops.first as Map).containsKey('jsonPathOperation')) {
          final base = copy(v)..remove('operations');
          final t = typeOf(base);
          if (t != null) {
            final path = ops.first['jsonPathOperation']['jsonPath'] as String;
            final top = RegExp(r'^\$\.top_players\[(\d)\]$').firstMatch(path);
            Map<String, dynamic> next;
            if (t == 'GgRanking' && top != null) {
              count('top_players[i] -> ggTopPlayerAt');
              next = {
                'source': 'FUNCTION_CALL',
                'functionCall': {
                  'values': [varArg(base), {'inputValue': {'serializedValue': top.group(1)}}],
                  'customFunction': fn('ggTopPlayerAt'),
                },
              };
            } else {
              final fields = jsonPaths[t]?[path] ?? (throw StateError('$cls: JSON path $path on $t not mapped'));
              count('json $path');
              next = withOps(base, fields, {});
            }
            final rest = ops.skip(1).toList();
            for (final k in ['defaultValue', 'uiBuilderValue']) {
              if (v[k] != null) next[k] = v[k];
            }
            if (rest.isEmpty) return next;
            next['operations'] = [...?(next['operations'] as List?), ...rest];
            return rewriteVar(next); // e.g. a second JSON path on the top player
          }
        }
        if (v['source'] != 'FUNCTION_CALL') return v;
        final name = fnName(v);
        if (name == null || !oldFunctions.contains(name)) return v;
        final t0 = args(v).isNotEmpty ? typeOf(argVar(v, 0)) : null;
        switch (name) {
          case 'ggHasData':
            final f = {'GgRanking': 'ggRankingLoaded', 'GgProfileStats': 'ggStatsLoaded', 'GgGamesEntry': 'ggGamesLoaded', 'GgPlayer': 'ggPlayerLoaded'}[t0];
            if (f == null) return v;
            count('ggHasData -> $f');
            return call(f, [args(v)[0]], v);
          case 'ggMetricValue':
          case 'ggMetricRank':
            final metric = argInput(v, 1) ?? '';
            final allTime = argInput(v, 2) == 'true';
            final rank = name == 'ggMetricRank';
            if (t0 == 'GgProfileStats') {
              count(name);
              if (allTime) {
                if (metric != 'good_power') throw StateError('$cls: all-time $metric not mapped');
                return withOps(argVar(v, 0), ['GgProfileStats.${rank ? 'allTimeRank' : 'allTimeGoodPower'}'], v);
              }
              final f = metricFields[metric] ?? (throw StateError('$cls: metric $metric not mapped'));
              return withOps(argVar(v, 0), ['GgProfileStats.$f', 'GgMetric.${rank ? 'rank' : 'value'}'], v);
            }
            if (t0 == 'GgPlayer' && metric == 'score' && !allTime) {
              count('$name player');
              return withOps(argVar(v, 0), ['GgPlayer.${rank ? 'rank' : 'score'}'], v);
            }
            return v;
          case 'ggPlayerRow':
            if (t0 != 'GgRanking') return v;
            count('ggPlayerRow -> ggPlayerOf');
            return call('ggPlayerOf', args(v), v);
          case 'ggRankingPlayerIds':
          case 'ggTopPlayerIds':
            if (t0 != 'GgRanking') return v;
            count(name);
            return call('ggPlayerIdsOf', [
              varArg(withOps(argVar(v, 0), ['GgRanking.${name == 'ggTopPlayerIds' ? 'topPlayers' : 'players'}'], {}))
            ], v);
          case 'ggShowMeRow':
          case 'ggShowFinalPlace':
          case 'ggShowCurrentPlace':
          case 'ggIsFinalSeason':
          case 'ggPlace':
          case 'ggIsLastPlayer':
          case 'ggRowStyle':
            if (t0 != 'GgRanking') return v;
            final f = {
              'ggShowMeRow': 'ggShowMeRowOf',
              'ggShowFinalPlace': 'ggShowFinalPlaceOf',
              'ggShowCurrentPlace': 'ggShowCurrentPlaceOf',
              'ggIsFinalSeason': 'ggIsFinalOf',
              'ggPlace': 'ggRankingPlace',
              'ggIsLastPlayer': 'ggIsLastPlayerOf',
              'ggRowStyle': 'ggRowStyleOf',
            }[name]!;
            if (args(v).length > 1 && typeOf(argVar(v, 1)) != 'GgPlayer') {
              throw StateError('$cls: $name with an untyped player');
            }
            count('$name -> $f');
            return call(f, args(v), v);
          case 'ggHasGames':
            if (t0 != 'GgProfileStats') return v;
            count('ggHasGames');
            return call('ggHasGamesOf', args(v), v);
          case 'ggHasMore':
            if (t0 != 'GgGamesEntry') return v;
            count('ggHasMore');
            return withOps(argVar(v, 0), ['GgGamesEntry.meta', 'GgGamesPage.hasMore'], v);
          case 'ggTopPlayerPhoto':
            if (t0 != 'GgRanking') return v;
            count('ggTopPlayerPhoto');
            return withOps({
              'source': 'FUNCTION_CALL',
              'functionCall': {'values': args(v), 'customFunction': fn('ggTopPlayerAt')},
            }, ['GgPlayer.photoUrl'], v);
          case 'ggMyPhoto':
            if (t0 != 'GgRanking') return v;
            count('ggMyPhoto');
            return withOps(argVar(v, 0), ['GgRanking.currentUser', 'GgPlayer.photoUrl'], v);
          case 'ggTotalPower':
            if (t0 != 'GgRanking') return v;
            count('ggTotalPower');
            return withOps(argVar(v, 0), ['GgRanking.totalGoodPowerAllTime'], v);
          case 'ggGamesRows':
            if (t0 != 'GgGamesEntry') return v;
            count('ggGamesRows');
            return call('ggGamesOf', args(v), v);
          case 'ggHasAward':
            if (t0 != 'GgPlayer') return v;
            count('ggHasAward');
            return call('ggHasAwardOf', [
              varArg(withOps(argVar(v, 0), ['GgPlayer.awards'], {})),
              ...args(v).skip(1),
            ], v);
          case 'ggSeasonOptions':
            if (t0 != 'GgRanking') return v;
            count('ggSeasonOptions');
            return call('ggSeasonOptionsOf', [varArg(withOps(argVar(v, 0), ['GgRanking.availablePeriods'], {}))], v);
          case 'ggPeriodName':
          case 'ggPeriodSame':
            final ri = name == 'ggPeriodName' ? 1 : 2;
            if (typeOf(argVar(v, ri)) != 'GgRanking') return v;
            count(name);
            return call('${name}Of', [
              ...args(v).take(ri),
              varArg(withOps(argVar(v, ri), ['GgRanking.availablePeriods'], {})),
            ], v);
          case 'ggCacheGet':
          case 'ggCachePut':
            final cache = argVar(v, 0) as Map?;
            final swap = caches[cache?['baseVariable']?['localState']?['fieldIdentifier']?['key']];
            if (swap == null) return v;
            final newCache = copy(cache);
            newCache['baseVariable']['localState']['fieldIdentifier'] = appState(swap[0]);
            final f = name == 'ggCacheGet' ? swap[1] : swap[2];
            count(f);
            return call(f, [varArg(newCache), ...args(v).skip(1)], v);
        }
        return v;
      }

      dynamic rewrite(dynamic n) {
        if (n is Map) {
          for (final k in n.keys.toList()) {
            n[k] = rewrite(n[k]);
          }
          final ca = n['customAction'];
          if (ca is Map) {
            final oldKey = ca['customActionIdentifier']?['key'];
            final next = actionSwap[oldKey];
            if (next != null) {
              final names = oldArgs[oldKey]!;
              final byName = {for (final a in next.arguments) a.identifier.name: a.identifier.key};
              final remapped = <String, dynamic>{};
              ((ca['argumentValues']?['arguments'] as Map?) ?? {}).forEach((k, value) {
                final argName = names[k] ?? (throw StateError('$cls: unknown argument $k'));
                remapped[byName[argName] ?? (throw StateError('$cls: ${next.identifier.name} has no $argName'))] = value;
              });
              ca['customActionIdentifier'] = id(next.identifier);
              ca['argumentValues'] = {...?(ca['argumentValues'] as Map?), 'arguments': remapped};
              count(next.identifier.name);
            }
          }
          final lsu = n['localStateUpdate'];
          if (lsu is Map && lsu['stateVariableType'] == 'APP_STATE') {
            for (final u in (lsu['updates'] as List? ?? [])) {
              final swap = caches[u['fieldIdentifier']?['key']];
              if (swap != null) {
                u['fieldIdentifier'] = appState(swap[0]);
                count('app state update ${swap[0]}');
              }
            }
          }
          if (n['source'] is String) return rewriteVar(n);
          return n;
        }
        if (n is List) {
          for (var i = 0; i < n.length; i++) {
            n[i] = rewrite(n[i]);
          }
        }
        return n;
      }

      rewrite(w);

      for (final f in ((w['classModel'] as Map?)?['stateFields'] as List? ?? [])) {
        final t = typedState[cls]?[f['parameter']['identifier']['name']];
        if (t == null) continue;
        f['parameter']['dataType'] = structType(t);
        (f['parameter'] as Map).remove('defaultValue');
        (f as Map).remove('serializedDefaultValue');
        count('state $t');
      }
      for (final e in ((w['params'] as Map?) ?? {}).values) {
        final t = typedParams[cls]?[e['identifier']['name']];
        if (t == null) continue;
        e['dataType'] = structType(t);
        (e as Map).remove('defaultValue');
        count('param $t');
      }

      // nothing JSON-shaped may remain on these values
      final rest = <String>{};
      void check(dynamic n) {
        if (n is Map) {
          if (n['source'] is String) {
            final name = n['source'] == 'FUNCTION_CALL' ? fnName(n) : null;
            if (name != null && oldFunctions.contains(name)) {
              final s = jsonEncode(n['functionCall']['values']);
              final typedKeys = [...stateKeys.keys, ...paramKeys.keys, ...typedOutputs.keys, ...caches.keys];
              if (typedKeys.any((k) => s.contains('"$k"'))) rest.add('$name on a typed value');
            }
            final ops = n['operations'] as List?;
            if (ops != null && ops.any((o) => (o as Map).containsKey('jsonPathOperation'))) {
              final base = copy(n)..remove('operations');
              if (typeOf(base) != null) rest.add('JSON path on ${typeOf(base)}');
            }
          }
          n.values.forEach(check);
        } else if (n is List) {
          n.forEach(check);
        }
      }
      check(w);
      if (rest.isNotEmpty) throw StateError('$cls: JSON uses remain: ${rest.join(', ')}');
    }

    // GoodGamesPage passes typed values to the component / sheet: nothing else to change.
    for (final cls in edits.keys) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final next = FFWidgetClass()..mergeFromProto3Json(edits[cls]!);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      stdout.writeln('$cls: ${counts[cls]!.entries.map((e) => '${e.key} x${e.value}').join(', ')}');
    }
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [TypedGoodGames()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games: Data Types instead of JSON (page, ranking row, filters)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
