// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Step 2.1 of the typed Good Games data: profile page (userProfilePage) and the
// profile sheet (userProfile) move from JSON to Data Types.
//   state ggProfile: JSON -> GgProfileStats, ggGuest: JSON -> GgRanking
//   ggV2ProfileStats / ggV2Rankings -> ggLoadProfileStats / ggLoadRanking
//   App State ggCacheProfile / ggCacheGuest -> ggStatsCache / ggRankingCache
//   ggMetricValue(p, 'good_power', false) -> p.goodPower.value (all metrics,
//     all-time -> p.allTimeGoodPower / p.allTimeRank), formatting kept
//   ggHasData -> ggStatsLoaded / ggRankingLoaded, ggPlace -> ggRankingPlace,
//   ggAwards -> ggSortAwards(p.awards), ggPeriodLabel -> ggPeriodLabelOf,
//   ggHasAward(award, 'valuable', 1) -> award.badge == GgBadge.mvp_gold
//   JSON paths $.period.key / $.legacy_bonus_users_count -> fields
// The task fails (nothing is written) if a JSON use of these values remains.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const classes = ['userProfilePage', 'userProfile'];
const metricFields = {
  'good_power': 'goodPower',
  'games': 'games',
  'good_energy': 'goodEnergy',
  'sponsored_games': 'sponsoredGames',
  'good_power_per_game': 'goodPowerPerGame',
  'good_energy_per_game': 'goodEnergyPerGame',
};
const awardBadges = {
  'valuable:1': 'mvp_gold',
  'valuable:2': 'mvp_silver',
  'valuable:3': 'mvp_bronze',
  'active:1': 'active_fire',
  'active:2': 'map_silver',
  'active:3': 'map_bronze',
};

final class TypedProfile extends FlutterFlowAITask {
  TypedProfile({this.after = const {}});
  final Set<String> after;
  @override
  Set<String> get dependsOn => after;
  @override
  String get name => 'gg-typed-profile';
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
    Map<String, dynamic> field(String structName, String fieldName) => {
          'accessDataStructField': {
            'fieldIdentifier': id(struct(structName)
                .fields
                .firstWhere((f) => f.identifier.name == fieldName,
                    orElse: () => throw StateError('$structName.$fieldName missing'))
                .identifier)
          }
        };
    Map<String, dynamic> appState(String name) => id(p.appState.fields
        .firstWhere((f) => f.parameter.identifier.name == name,
            orElse: () => throw StateError('App State $name missing'))
        .parameter
        .identifier);
    FFCustomAction action(String name) =>
        findCustomAction(p, name: name) ?? (throw StateError('$name action missing'));
    final badgeEnum = p.backend.dataSchemaConfig.enums.firstWhere((e) => e.identifier.name == 'GgBadge');
    Map<String, dynamic> badge(String value) => {
          'source': 'ENUMS',
          'baseVariable': {
            'enumVariable': {
              'enumIdentifier': id(badgeEnum.identifier),
              'enumElementIdentifier':
                  id(badgeEnum.elements.firstWhere((e) => e.identifier.name == value).identifier),
            }
          },
        };
    final cacheSwap = {
      appState('ggCacheProfile')['key']: appState('ggStatsCache'),
      appState('ggCacheGuest')['key']: appState('ggRankingCache'),
    };
    final actionSwap = {
      action('ggV2ProfileStats').identifier.key: action('ggLoadProfileStats'),
      action('ggV2Rankings').identifier.key: action('ggLoadRanking'),
    };
    final oldArgs = {
      for (final a in [action('ggV2ProfileStats'), action('ggV2Rankings')])
        a.identifier.key: {for (final x in a.arguments) x.identifier.key: x.identifier.name}
    };

    final counts = <String, int>{};
    void count(String rule) => counts[rule] = (counts[rule] ?? 0) + 1;

    for (final cls in classes) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      final stateFields = (w['classModel'] as Map)['stateFields'] as List;
      String stateKey(String name) => (stateFields.firstWhere(
          (f) => f['parameter']['identifier']['name'] == name)['parameter']['identifier']['key']) as String;
      final profileKey = stateKey('ggProfile');
      final guestKey = stateKey('ggGuest');

      bool isState(dynamic v, String key) =>
          v is Map && v['source'] == 'LOCAL_STATE' && v['baseVariable']?['localState']?['fieldIdentifier']?['key'] == key;
      bool isOutput(dynamic v, String name) =>
          v is Map && v['source'] == 'ACTION_OUTPUTS' && v['baseVariable']?['actionOutput']?['outputVariableIdentifier']?['name'] == name;
      String? fnName(Map v) => (v['functionCall'] as Map?)?['customFunction']?['name'] as String?;
      List args(Map v) => ((v['functionCall'] as Map)['values'] as List);
      dynamic argVar(Map v, int i) => (args(v)[i] as Map)['variable'];
      String? argInput(Map v, int i) => (args(v)[i] as Map)['inputValue']?['serializedValue'] as String?;
      Map<String, dynamic> withOps(Map base, List<Map<String, dynamic>> ops, Map from) {
        final r = jsonDecode(jsonEncode(base)) as Map<String, dynamic>;
        r['operations'] = [...((r['operations'] as List?) ?? []), ...ops, ...((from['operations'] as List?) ?? [])];
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

      Map rewriteVar(Map v) {
        final name = v['source'] == 'FUNCTION_CALL' ? fnName(v) : null;
        // metrics
        if ((name == 'ggMetricValue' || name == 'ggMetricRank') && isState(argVar(v, 0), profileKey)) {
          final metric = argInput(v, 1)!;
          final allTime = argInput(v, 2) == 'true';
          final rank = name == 'ggMetricRank';
          count(name!);
          if (allTime) {
            if (metric != 'good_power') throw StateError('$cls: all-time $metric not mapped');
            return withOps(argVar(v, 0), [field('GgProfileStats', rank ? 'allTimeRank' : 'allTimeGoodPower')], v);
          }
          final f = metricFields[metric] ?? (throw StateError('$cls: metric $metric not mapped'));
          return withOps(argVar(v, 0), [field('GgProfileStats', f), field('GgMetric', rank ? 'rank' : 'value')], v);
        }
        if (name == 'ggHasData' && isState(argVar(v, 0), profileKey)) {
          count('ggHasData profile');
          return call('ggStatsLoaded', [args(v)[0]], v);
        }
        if (name == 'ggHasData' && isState(argVar(v, 0), guestKey)) {
          count('ggHasData guest');
          return call('ggRankingLoaded', [args(v)[0]], v);
        }
        if (name == 'ggPlace' && isState(argVar(v, 0), guestKey)) {
          count('ggPlace');
          return call('ggRankingPlace', [args(v)[0]], v);
        }
        if (name == 'ggAwards' && isState(argVar(v, 0), profileKey)) {
          count('ggAwards');
          return call('ggSortAwards', [
            {'variable': withOps(argVar(v, 0), [field('GgProfileStats', 'awards')], {})},
            args(v)[1],
          ], v);
        }
        if (name == 'ggPeriodLabel' && isState(argVar(v, 1), profileKey)) {
          count('ggPeriodLabel');
          return call('ggPeriodLabelOf', [
            args(v)[0],
            {'variable': withOps(argVar(v, 1), [field('GgProfileStats', 'period')], {})},
            {'variable': withOps(argVar(v, 1), [field('GgProfileStats', 'availablePeriods')], {})},
          ], v);
        }
        if (name == 'ggHasAward' && (argVar(v, 0) as Map?)?['source'] == 'GENERATOR_VARIABLE') {
          // award item of the awards generator
          final category = argInput(v, 1);
          final place = argInput(v, 2);
          final season = argInput(v, 3) ?? '';
          if (season.isNotEmpty) throw StateError('$cls: ggHasAward with a season not mapped');
          final b = awardBadges['$category:$place'] ?? (throw StateError('$cls: award $category $place not mapped'));
          count('ggHasAward');
          return {
            'source': 'FUNCTION_CALL',
            'functionCall': {
              'values': [
                {'variable': withOps(argVar(v, 0), [field('GgAward', 'badge')], {})},
                {'variable': badge(b)},
              ],
              'condition': {'relation': 'EQUAL_TO'},
            },
          };
        }
        if (name == 'ggCacheGet' || name == 'ggCachePut') {
          final cache = argVar(v, 0) as Map?;
          final key = cache?['baseVariable']?['localState']?['fieldIdentifier']?['key'];
          final next = cacheSwap[key];
          if (next != null) {
            final stats = next['name'] == 'ggStatsCache';
            final newName = name == 'ggCacheGet'
                ? (stats ? 'ggStatsFromCache' : 'ggRankingFromCache')
                : (stats ? 'ggStatsToCache' : 'ggRankingToCache');
            final newCache = jsonDecode(jsonEncode(cache)) as Map<String, dynamic>;
            newCache['baseVariable']['localState']['fieldIdentifier'] = next;
            count(newName);
            return call(newName, [
              {'variable': newCache},
              ...args(v).skip(1),
            ], v);
          }
        }
        // JSON paths on typed values
        final ops = v['operations'] as List?;
        if (ops != null && ops.isNotEmpty && (ops.first as Map).containsKey('jsonPathOperation')) {
          final path = ops.first['jsonPathOperation']['jsonPath'];
          if (isState(v, guestKey) && path == r'$.legacy_bonus_users_count') {
            count('json legacy_bonus_users_count');
            return {...v, 'operations': [field('GgRanking', 'legacyBonusUsersCount'), ...ops.skip(1)]};
          }
          if (isOutput(v, 'ggProfileOut') && path == r'$.period.key') {
            count('json period.key');
            return {...v, 'operations': [field('GgProfileStats', 'period'), field('GgPeriod', 'key'), ...ops.skip(1)]};
          }
        }
        return v;
      }

      dynamic rewrite(dynamic n) {
        if (n is Map) {
          for (final k in n.keys.toList()) {
            n[k] = rewrite(n[k]);
          }
          // custom actions
          final ca = n['customAction'];
          if (ca is Map) {
            final oldKey = ca['customActionIdentifier']?['key'];
            final next = actionSwap[oldKey];
            if (next != null) {
              final names = oldArgs[oldKey]!;
              final byName = {for (final a in next.arguments) a.identifier.name: a.identifier.key};
              final argsMap = (ca['argumentValues']?['arguments'] as Map?) ?? {};
              final remapped = <String, dynamic>{};
              argsMap.forEach((k, value) {
                final argName = names[k] ?? (throw StateError('$cls: unknown argument $k'));
                remapped[byName[argName] ?? (throw StateError('$cls: ${next.identifier.name} has no $argName'))] = value;
              });
              ca['customActionIdentifier'] = id(next.identifier);
              ca['argumentValues'] = {...?(ca['argumentValues'] as Map?), 'arguments': remapped};
              count(next.identifier.name);
            }
          }
          // App State updates of the old caches
          final lsu = n['localStateUpdate'];
          if (lsu is Map && lsu['stateVariableType'] == 'APP_STATE') {
            for (final u in (lsu['updates'] as List? ?? [])) {
              final next = cacheSwap[u['fieldIdentifier']?['key']];
              if (next != null) {
                u['fieldIdentifier'] = next;
                count('app state update ${next['name']}');
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
          return n;
        }
        return n;
      }

      rewrite(w);

      // state field types
      for (final f in stateFields) {
        final ident = f['parameter']['identifier'];
        final target = {'ggProfile': 'GgProfileStats', 'ggGuest': 'GgRanking'}[ident['name']];
        if (target == null) continue;
        f['parameter']['dataType'] = {
          'scalarType': 'DataStruct',
          'subType': {'dataStructIdentifier': id(struct(target).identifier)},
          'nonNullable': false,
        };
        (f['parameter'] as Map).remove('defaultValue');
        (f as Map).remove('serializedDefaultValue');
        count('state $target');
      }

      // nothing JSON-shaped may remain on these values
      final rest = <String>[];
      void check(dynamic n) {
        if (n is Map) {
          if (n['source'] is String) {
            final name = n['source'] == 'FUNCTION_CALL' ? fnName(n) : null;
            const old = {'ggMetricValue', 'ggMetricRank', 'ggHasData', 'ggPlace', 'ggAwards', 'ggPeriodLabel', 'ggHasAward', 'ggCacheGet', 'ggCachePut'};
            if (name != null && old.contains(name) && jsonEncode(n['functionCall']['values']).contains(RegExp('"($profileKey|$guestKey)"'))) {
              rest.add('$name(${profileKey}/${guestKey})');
            }
            final ops = n['operations'] as List?;
            if ((isState(n, profileKey) || isState(n, guestKey) || isOutput(n, 'ggProfileOut') || isOutput(n, 'ggGuestOut')) &&
                ops != null && ops.any((o) => (o as Map).containsKey('jsonPathOperation'))) {
              rest.add('jsonPath on ${n['baseVariable']}');
            }
          }
          if (jsonEncode(n).length < 4000) {
            final s = jsonEncode(n);
            if (cacheSwap.keys.any((k) => s.contains('"$k"')) && n['source'] != null) rest.add('old cache ${s.substring(0, 120)}');
          }
          n.values.forEach(check);
        } else if (n is List) {
          n.forEach(check);
        }
      }
      check(w);
      if (rest.isNotEmpty) throw StateError('$cls: JSON uses remain:\n${rest.toSet().join('\n')}');

      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      stdout.writeln('$cls: ${counts.entries.map((e) => '${e.key} x${e.value}').join(', ')}');
      counts.clear();
    }
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [TypedProfile()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Profile: Data Types instead of JSON (state, cache, bindings)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
