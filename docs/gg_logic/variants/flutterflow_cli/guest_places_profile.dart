// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Guest profile places (16.10.2026), step 3 of 3 (after guest_places_schema.dart
// and transfer.dart): userProfilePage, guest layout.
//   ggRefreshProfile, guest branch:
//     ggLoadRanking period 'all_time' -> ggPeriodKey(infoStatsPeriod) (the Stats
//     filter, as for registered users); cache key 'g|test' -> 'g|period|test';
//     after loading infoStatsPeriod = ggGuestOut.period.key ('auto' becomes
//     season_2026_27: the filter button and dialog show the real season)
//   guest Stats rows: number = ggPlaceLabelOf(ggGuest.guestPlaces.<metric>)
//     (was the rank of the empty profile stats -> "#0"); Supporters value 0
//   guest header place: ggPlaceLabelOf(ggGuest.guestPlaces.allTimeGoodPower)
//     (All-Time as for registered users; the same response)
//   guest filter button: ggPeriodLabelOf with the guest ranking periods
//   registered Supporters value: sponsoredGames.value (was the fixed "1")
// All struct reads go through ggRankingOrEmpty / ggStatsOrEmpty (first frame).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const page = 'userProfilePage';
// Stats rows (userProfileInfoStatsRow instances): node key -> metric field.
const guestRows = {
  'Container_b205ys9w': ('Total Good Power', 'goodPower'),
  'Container_3tygbpzj': ('Punkte per Game', 'goodEnergy'), // as the registered row
  'Container_ezj4hmea': ('Good Games', 'games'),
  'Container_hno7gqe7': ('Supporters', 'sponsoredGames'),
};
const registeredSupporters = 'Container_cxima6vo';
const registeredGames = 'Container_5ydb6fe7';
const guestHeaderPlace = 'Text_ps6amarn';

final class GuestPlacesProfile extends FlutterFlowAITask {
  @override
  String get name => 'gg-guest-places-profile';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    Map<String, dynamic> id(FFIdentifier i) => {'name': i.name, 'key': i.key};
    Map<String, dynamic> fn(String name) => id(
        (p.customCode.customFunctions.where((f) => f.identifier.name == name).firstOrNull ??
                (throw StateError('$name function missing (run transfer.dart first)')))
            .identifier);
    Map<String, dynamic> field(String struct, String name) {
      final s = findDataStruct(p, name: struct) ??
          (throw StateError('$struct Data Type missing (run guest_places_schema.dart first)'));
      final f = s.fields.where((f) => f.identifier.name == name).firstOrNull ??
          (throw StateError('$struct.$name missing (run guest_places_schema.dart first)'));
      return {'accessDataStructField': {'fieldIdentifier': id(f.identifier)}};
    }
    Map<String, dynamic> copy(Object? x) => jsonDecode(jsonEncode(x)) as Map<String, dynamic>;

    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == page);
    final w = copy(entry.value.toProto3Json());
    final log = <String>[];

    Map<String, dynamic>? byKey(dynamic x, String key, {bool widget = false}) {
      if (x is Map) {
        if (x['key'] == key && (!widget || x.containsKey('props') || x.containsKey('type'))) {
          return x as Map<String, dynamic>;
        }
        for (final v in x.values) {
          final r = byKey(v, key, widget: widget);
          if (r != null) return r;
        }
      } else if (x is List) {
        for (final v in x) {
          final r = byKey(v, key, widget: widget);
          if (r != null) return r;
        }
      }
      return null;
    }
    Map<String, dynamic> need(dynamic x, String key, {bool widget = false}) =>
        byKey(x, key, widget: widget) ?? (throw StateError('$page: $key not found'));

    // ---- ggRefreshProfile, guest branch
    final refresh = ((w['classModel']['actionComponentsConfig']['actionComponents'] as List)
        .firstWhere((a) => a['identifier']['name'] == 'ggRefreshProfile'))['actions'];
    Map<String, dynamic> action(String nodeKey) => need(refresh, nodeKey)['action'] as Map<String, dynamic>;

    final profileLoad = action('mbxvl31v');
    final guestLoad = action('t2jdussy');
    if (profileLoad['customAction']?['customActionIdentifier']?['name'] != 'ggLoadProfileStats' ||
        guestLoad['customAction']?['customActionIdentifier']?['name'] != 'ggLoadRanking' ||
        guestLoad['outputVariableName'] != 'ggGuestOut') {
      throw StateError('$page: ggRefreshProfile changed, check the action keys');
    }
    final profileArgs = profileLoad['customAction']['argumentValues']['arguments'] as Map;
    final guestArgs = guestLoad['customAction']['argumentValues']['arguments'] as Map;
    final periodArg = profileArgs['icz444ur']['value'];
    if (jsonEncode(periodArg).contains('infoStatsPeriod') != true) throw StateError('$page: profile period argument changed');
    if (guestArgs['m28c01xd']['value']?['inputValue']?['serializedValue'] == 'all_time') {
      guestArgs['m28c01xd']['value'] = copy(periodArg);
      log.add('guest ggLoadRanking: period = ggPeriodKey(infoStatsPeriod)');
    } else if (jsonEncode(guestArgs['m28c01xd']).contains('infoStatsPeriod')) {
      log.add('guest ggLoadRanking: period already set');
    } else {
      throw StateError('$page: guest ggLoadRanking period argument changed');
    }

    // cache keys 'g|' + test -> 'g|' + infoStatsPeriod + '|' + test
    final profileKeyParts = ((action('5us68ho3')['localStateUpdate']['updates'][0]['setValue']['variable']
        ['functionCall']['values'] as List)[1]['variable']['functionCall']['values'] as List);
    final periodVar = profileKeyParts[3];
    if (!jsonEncode(periodVar).contains('"infoStatsPeriod"')) throw StateError('$page: profile cache key changed');
    for (final k in ['i4il6yt0', 'el6hu9u0']) {
      final call = action(k)['localStateUpdate']['updates'][0]['setValue']['variable']['functionCall'];
      final parts = ((call['values'] as List)[1]['variable']['functionCall']['values'] as List);
      if (parts.first['inputValue']?['serializedValue'] != 'g|') throw StateError('$page: guest cache key changed ($k)');
      if (jsonEncode(parts).contains('"infoStatsPeriod"')) {
        log.add('guest cache key $k: already has the period');
        continue;
      }
      parts.insertAll(1, [copy(periodVar), {'inputValue': {'serializedValue': '|'}}]);
      log.add('guest cache key ${call['customFunction']['name']}: g|period|test');
    }

    // infoStatsPeriod = ggGuestOut.period.key after loading
    final guestSet = action('m25z61xd')['localStateUpdate']['updates'] as List;
    if (!guestSet.any((u) => u['fieldIdentifier']['name'] == 'infoStatsPeriod')) {
      final profileSet = (action('8kvr8lvl')['localStateUpdate']['updates'] as List)
          .firstWhere((u) => u['fieldIdentifier']['name'] == 'infoStatsPeriod');
      final u = copy(profileSet);
      final v = u['setValue']['variable'];
      v['baseVariable']['actionOutput'] = copy(
          guestSet.first['setValue']['variable']['baseVariable']['actionOutput']); // ggGuestOut
      final ops = v['operations'] as List;
      ops[0] = field('GgRanking', 'period');
      guestSet.add(u);
      log.add('guest: infoStatsPeriod = ggGuestOut.period.key');
    } else {
      log.add('guest: infoStatsPeriod update exists');
    }

    // ---- bindings
    if (!jsonEncode(need(w['node'], guestHeaderPlace, widget: true)['props']['text']).contains('"ggGuest"')) {
      throw StateError('$page: guest header binding changed');
    }
    // The page state ggGuest as the page binds it (nodeKeyRef included).
    Map<String, dynamic> guestState() {
      final found = <Map<String, dynamic>>[];
      void walk(dynamic x) {
        if (x is Map) {
          if (x['source'] == 'LOCAL_STATE' && x['baseVariable']?['localState']?['fieldIdentifier']?['name'] == 'ggGuest') {
            found.add(copy(x)..remove('operations'));
          }
          x.values.forEach(walk);
        } else if (x is List) {
          x.forEach(walk);
        }
      }
      walk(w['node']);
      if (found.isEmpty) throw StateError('$page: no ggGuest binding found');
      return found.first;
    }
    Map<String, dynamic> guestOrEmpty(List<Map<String, dynamic>> ops) => {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'values': [
              {'variable': guestState()}
            ],
            'customFunction': fn('ggRankingOrEmpty'),
          },
          'operations': ops,
        };
    Map<String, dynamic> placeLabel(String placeField) => {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'values': [
              {'variable': guestOrEmpty([field('GgRanking', 'guestPlaces'), field('GgGuestPlaces', placeField)])}
            ],
            'customFunction': fn('ggPlaceLabelOf'),
          },
        };
    Map pass(String nodeKey, String param) {
      final node = need(w['node'], nodeKey, widget: true);
      final passes = node['parameterValues']['parameterPasses'] as Map;
      return passes.values.firstWhere((x) => x['paramIdentifier']['name'] == param);
    }
    String title(String nodeKey) => pass(nodeKey, 'title')['inputValue']['serializedValue'] as String;

    guestRows.forEach((nodeKey, spec) {
      final (expected, metric) = spec;
      if (title(nodeKey) != expected) throw StateError('$page: $nodeKey is "${title(nodeKey)}", expected "$expected"');
      final number = pass(nodeKey, 'number');
      number
        ..remove('inputValue')
        ..['variable'] = placeLabel(metric);
      log.add('guest row $expected: number = ggPlaceLabelOf(guestPlaces.$metric)');
    });
    final guestSupporters = pass('Container_hno7gqe7', 'value');
    guestSupporters
      ..remove('variable')
      ..['inputValue'] = {'serializedValue': '0'};
    log.add('guest row Supporters: value 0');

    // header (All-Time place)
    final header = need(w['node'], guestHeaderPlace, widget: true)['props']['text']['textValue'];
    header
      ..remove('inputValue')
      ..['variable'] = placeLabel('allTimeGoodPower');
    log.add('guest header: ggPlaceLabelOf(guestPlaces.allTimeGoodPower)');

    // registered Supporters value = sponsoredGames.value, formatted like Good Games
    if (title(registeredSupporters) != 'Supporters' || title(registeredGames) != 'Good Games') {
      throw StateError('$page: registered Stats rows changed');
    }
    final gamesValue = copy(pass(registeredGames, 'value'));
    final gamesField = field('GgProfileStats', 'games')['accessDataStructField']['fieldIdentifier'];
    final sponsoredField = field('GgProfileStats', 'sponsoredGames')['accessDataStructField']['fieldIdentifier'];
    var swapped = 0;
    void swap(dynamic x) {
      if (x is Map) {
        final a = x['accessDataStructField'];
        if (a is Map && a['fieldIdentifier']?['key'] == gamesField['key']) {
          a['fieldIdentifier'] = sponsoredField;
          swapped++;
        }
        x.values.forEach(swap);
      } else if (x is List) {
        x.forEach(swap);
      }
    }
    swap(gamesValue);
    if (swapped != 1) throw StateError('$page: Good Games value binding has $swapped games reads');
    // Same component, same parameter "value": the whole pass is reused.
    pass(registeredSupporters, 'value')
      ..clear()
      ..addAll(gamesValue);
    log.add('registered row Supporters: value = sponsoredGames.value');

    // guest filter button label: periods of the guest ranking
    final guestRoot = need(w['node'], 'Container_b205ys9w', widget: true);
    final registeredRoot = need(w['node'], 'Container_1bmqscxh', widget: true);
    bool contains(dynamic x, Map target) {
      if (identical(x, target)) return true;
      if (x is Map) return x.values.any((v) => contains(v, target));
      if (x is List) return x.any((v) => contains(v, target));
      return false;
    }
    final labels = <(Map, List<Map>)>[];
    void findLabels(dynamic x, List<Map> chain) {
      if (x is Map) {
        final next = x.containsKey('type') && x.containsKey('key') ? [...chain, x] : chain;
        if (x['source'] == 'FUNCTION_CALL' && x['functionCall']?['customFunction']?['name'] == 'ggPeriodLabelOf') {
          labels.add((x, next));
        }
        x.values.forEach((v) => findLabels(v, next));
      } else if (x is List) {
        x.forEach((v) => findLabels(v, chain));
      }
    }
    findLabels(w['node'], []);
    var guestLabels = 0;
    for (final (call, chain) in labels) {
      String? side;
      for (final a in chain.reversed) {
        final g = contains(a, guestRoot), r = contains(a, registeredRoot);
        if (g && !r) side = 'guest';
        if (r && !g) side = 'registered';
        if (g || r) break;
      }
      if (side != 'guest') continue;
      final values = call['functionCall']['values'] as List;
      values[1] = {'variable': guestOrEmpty([field('GgRanking', 'period')])};
      values[2] = {'variable': guestOrEmpty([field('GgRanking', 'availablePeriods')])};
      guestLabels++;
    }
    if (guestLabels != 1) throw StateError('$page: expected 1 guest period label, found $guestLabels');
    log.add('guest filter button: ggPeriodLabelOf(infoStatsPeriod, guest period, guest periods)');

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('$page:\n  ${log.join('\n  ')}');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [GuestPlacesProfile()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Profile guest: places per period, real season in the filter, Supporters value',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
