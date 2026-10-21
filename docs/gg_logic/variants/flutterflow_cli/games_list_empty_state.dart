// Run inside the FlutterFlow AI workspace. Dry-run by default.
// 20.10.2026, tester (iPhone): Good Games -> Meine Games, filter "Saison
// 2025/26": an empty grey box under "# Details P€ Good Power".
// The list frame (ConditionalBuilder_16b5kuom, first branch) was visible when
// ggHasGamesOf(ggMyStats) (any completed game EVER) OR the loaded page has
// games. A period without games of the user therefore showed the empty frame
// instead of the "no games" picture (second branch).
// Now: ggShowGamesListOf(ggMyStats, ggHistory): a loaded page decides by its
// games; before the first page arrives a user with games keeps the frame (no
// flash of the picture).
// Same commit, through transfer.dart (rpc): sendSignInOtp checks the password
// with a separate auth client. It signed the whole app in and out for a
// moment; the router then rebuilt the guest profile page and the open sign-in
// dialog vanished (tester, iPhone + Android: first attempt no code screen, the
// second attempt worked, two codes by email). Reproduced in the simulator.
// ONE commit: transfer.dart (rpc: registers ggShowGamesListOf, sendSignInOtp)
// + this change.
// Copy into dsl/ as gg_games_list_empty_state.dart next to gg_transfer.dart.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

final class GamesListEmptyState extends FlutterFlowAITask {
  @override
  String get name => 'gg-games-list-empty-state';
  @override
  Set<String> get dependsOn => {'register-gg-rpc'};
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    Map<String, dynamic> fn(String name) {
      final f = p.customCode.customFunctions.where((f) => f.identifier.name == name).firstOrNull ??
          (throw StateError('$name function missing (transfer first)'));
      return {'name': f.identifier.name, 'key': f.identifier.key};
    }

    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'GoodGamesPage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;

    // Visibility conditions (not disabled actions) that call ggHasGamesOf.
    final hits = <Map>[];
    var already = 0;
    void find(dynamic x) {
      if (x is Map) {
        final vv = x['visibility']?['visibleValue'];
        if (vv is Map && vv['variable'] is Map) {
          final s = jsonEncode(vv['variable']);
          if (s.contains('"ggHasGamesOf"')) hits.add(vv);
          if (s.contains('"ggShowGamesListOf"')) already++;
        }
        x.values.forEach(find);
      } else if (x is List) {
        x.forEach(find);
      }
    }
    find(w['node']);
    if (hits.isEmpty) {
      if (already > 0) {
        stdout.writeln('GoodGamesPage: Meine Games already uses ggShowGamesListOf');
        return;
      }
      throw StateError('GoodGamesPage: Meine Games condition not found');
    }
    if (hits.length != 1) throw StateError('GoodGamesPage: ${hits.length} conditions with ggHasGamesOf');

    final cond = hits.single['variable'] as Map<String, dynamic>;
    // The two state variables of the old OR: ggMyStats and ggHistory.
    Map? stateVar(String name) {
      Map? r;
      void s(dynamic x) {
        if (r != null) return;
        if (x is Map) {
          if (x['source'] == 'LOCAL_STATE' &&
              x['baseVariable']?['localState']?['fieldIdentifier']?['name'] == name) {
            r = x;
            return;
          }
          x.values.forEach(s);
        } else if (x is List) {
          x.forEach(s);
        }
      }
      s(cond);
      return r;
    }

    final stats = stateVar('ggMyStats') ?? (throw StateError('ggMyStats not in the condition'));
    final history = stateVar('ggHistory') ?? (throw StateError('ggHistory not in the condition'));
    hits.single['variable'] = {
      'source': 'FUNCTION_CALL',
      'functionCall': {
        'values': [
          {'variable': stats},
          {'variable': history},
        ],
        'customFunction': fn('ggShowGamesListOf'),
      },
    };

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('GoodGamesPage: Meine Games frame -> ggShowGamesListOf(ggMyStats, ggHistory)');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-gameslist-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports), GamesListEmptyState()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Sign-in: password check no longer flips the app session; '
        'Meine Games: "no games" picture for a period without games',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
