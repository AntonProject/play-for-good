// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 21.10.2026, owner: one place logic everywhere (Home, profile, Good Games,
// Energy) for users and the guest. Before: the guest saw #0 on Energy and in
// the Meine Games header, the Good Power place elsewhere, ...
// Rule: a user - own place in the category / period, without points the place
// after all players with points; the guest - the place of the demo guest
// (100 Good Power, nothing else) = guest_places of gg_v2_rankings.
//  1 transfer.dart (rpc): ggLoadProfileStats returns the demo guest stats
//    (guest_places of the same period) for userId '' / 'guest'.
//  2 energyComp.ggRefreshEnergy: the "signed in" gate is removed, the guest
//    gets these stats too (week / month / all time).
//  3 GoodGamesPage.ggRefreshGoodGames: ggLoadProfileStats moves out of the
//    "signed in" gate (Meine Games header for the guest); the games history
//    stays signed-in only.
//  4 GoodGamesPage, Meine Games header: "Good Power per Game" showed the
//    place of "Energy per Game" (goodEnergyPerGame.rank); now its own
//    goodPowerPerGame.rank.
// ONE commit.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

final class GuestStatsPlaces extends FlutterFlowAITask {
  @override
  String get name => 'gg-guest-stats-places';
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

    Map block(Map w, String name) =>
        ((w['classModel'] as Map)['actionComponentsConfig']['actionComponents'] as List)
            .firstWhere((b) => b['identifier']['name'] == name) as Map;
    bool isLoggedInGate(Map node) {
      final ca = node['conditionActions'];
      if (ca is! Map) return false;
      final t = (ca['trueActions'] as List?) ?? [];
      return t.length == 1 && jsonEncode(t.single['condition']).contains('IS_USER_LOGGED_IN');
    }

    // 2. Energy: root = IF signed in { parallel } -> parallel.
    {
      final w = load('energyComp');
      final b = block(w, 'ggRefreshEnergy');
      final root = b['actions']['rootAction'] as Map;
      if (isLoggedInGate(root)) {
        if (root['followUpAction'] != null) throw StateError('energyComp: gate has a follow-up');
        final inner = ((root['conditionActions']['trueActions'] as List).single as Map)['trueAction'] as Map;
        if (inner['parallelActions'] == null) throw StateError('energyComp: unexpected gate body');
        b['actions']['rootAction'] = inner;
        save('energyComp', w);
        report.add('energyComp: ggRefreshEnergy also for the guest');
      } else {
        report.add('energyComp: ggRefreshEnergy has no signed-in gate');
      }
    }

    final w = load('GoodGamesPage');
    var changed = false;
    // 3. Good Games: stats out of the gate, history stays inside.
    {
      final b = block(w, 'ggRefreshGoodGames');
      final branches = (b['actions']['rootAction']['parallelActions']['actions'] as List);
      final gate = branches.whereType<Map>().where(isLoggedInGate).firstOrNull;
      if (gate == null) {
        report.add('GoodGamesPage: stats already outside the signed-in gate');
      } else {
        final t = (gate['conditionActions']['trueActions'] as List).single as Map;
        final body = t['trueAction'] as Map;
        final inner = (body['parallelActions']?['actions'] as List?) ?? [];
        final stats = inner.whereType<Map>().where((n) => jsonEncode(n).contains('"ggLoadProfileStats"')).toList();
        final history = inner.whereType<Map>().where((n) => jsonEncode(n).contains('"ggLoadGames"')).toList();
        if (stats.length != 1 || history.length != 1 || inner.length != 2) {
          throw StateError('GoodGamesPage: unexpected signed-in gate body');
        }
        t['trueAction'] = history.single;
        branches.insert(branches.indexOf(gate), stats.single);
        changed = true;
        report.add('GoodGamesPage: profile stats loaded for the guest too; history stays signed-in only');
      }
    }
    // 4. "Good Power per Game" badge: its own place.
    {
      final s = findDataStruct(p, name: 'GgProfileStats') ?? (throw StateError('GgProfileStats missing'));
      final gpg = s.fields.firstWhere((f) => f.identifier.name == 'goodPowerPerGame').identifier;
      Map? smallest;
      void find(dynamic x) {
        if (x is Map) {
          final e = jsonEncode(x);
          if (x['type'] != null &&
              e.contains('Good Power per Game') &&
              e.contains('"goodEnergyPerGame"') &&
              !e.contains('nergy per Game')) {
            smallest = x;
          }
          x.values.forEach(find);
        } else if (x is List) {
          x.forEach(find);
        }
      }
      find(w['node']);
      if (smallest == null) {
        report.add('GoodGamesPage: Good Power per Game badge already uses its own place');
      } else {
        var n = 0;
        void fix(dynamic x) {
          if (x is Map) {
            final f = x['accessDataStructField']?['fieldIdentifier'];
            if (f is Map && f['name'] == 'goodEnergyPerGame') {
              x['accessDataStructField']['fieldIdentifier'] = {'name': gpg.name, 'key': gpg.key};
              n++;
            }
            x.values.forEach(fix);
          } else if (x is List) {
            x.forEach(fix);
          }
        }
        fix(smallest);
        changed = true;
        report.add('GoodGamesPage: Good Power per Game badge -> goodPowerPerGame.rank ($n ref)');
      }
    }
    if (changed) save('GoodGamesPage', w);
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-guestplaces-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports), GuestStatsPlaces()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'One place logic: guest stats on Energy / Meine Games; Good Power per Game place',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
