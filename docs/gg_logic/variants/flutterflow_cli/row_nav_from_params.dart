// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 21.10.2026, owner: check every navigation to a user / organisation.
// Audit (dsl/gg_scan_navs.dart): every navigation passes a value; the ones
// below took the id from the row's own query result, although the row already
// has it in its parameter `game`. Rows are reused for another game on a page /
// filter change; while the new query loads, the old result is still shown, so
// a tap opened the previous organisation / player (as in the ranking rows).
//   gamesOrgComp (Meine Games)  -> OrganisationPage: game.organization_id
//   impactComp (Energy)         -> OrganisationPage: game.organization_id
//   recentGameHome (Home)       -> OrganisationPage: game.organization_id
//   recentGameHome (Home)       -> userProfilePage:  game.creator_user_id
// The value is copied from the row's query filter (same parameter and field).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const targets = {
  'gamesOrgComp': {'OrganisationPage': 'organization_id'},
  'impactComp': {'OrganisationPage': 'organization_id'},
  'recentGameHome': {'OrganisationPage': 'organization_id', 'userProfilePage': 'creator_user_id'},
};

final class RowNavFromParams extends FlutterFlowAITask {
  @override
  String get name => 'gg-row-nav-from-params';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final pageKey = {for (final w in p.widgetClasses.values) w.name: w.node.key};
    final report = <String>[];
    targets.forEach((cls, pages) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      // game.<field> as the row's query filter reads it.
      Map? gameField(String field) {
        Map? r;
        void s(dynamic x) {
          if (r != null) return;
          if (x is Map) {
            final ops = (x['operations'] as List?) ?? const [];
            if (x['source'] == 'WIDGET_CLASS_PARAMETER' &&
                x['baseVariable']?['widgetClass']?['paramIdentifier']?['name'] == 'game' &&
                ops.length == 1 &&
                (ops.single as Map)['accessPostgresRowField']?['fieldIdentifier']?['name'] == field) {
              r = x;
              return;
            }
            x.values.forEach(s);
          } else if (x is List) {
            x.forEach(s);
          }
        }
        s(w['node']);
        return r;
      }

      var n = 0;
      pages.forEach((page, field) {
        final src = gameField(field) ?? (throw StateError('$cls: game.$field not found'));
        final key = pageKey[page] ?? (throw StateError('page $page missing'));
        void walk(dynamic x) {
          if (x is Map) {
            final nav = x['navigate'];
            if (nav is Map && nav['pageNodeKeyRef']?['key'] == key) {
              for (final pass in ((nav['passedParameters']?['parameterPasses'] as Map?) ?? {}).values) {
                final v = (pass as Map)['variable'] as Map?;
                if (v != null && v['source'] == 'POSTGRES_QUERY') {
                  pass['variable'] = jsonDecode(jsonEncode(src))..remove('defaultValue');
                  n++;
                }
              }
            }
            x.values.forEach(walk);
          } else if (x is List) {
            x.forEach(walk);
          }
        }
        walk(w['node']);
      });
      if (n == 0) {
        report.add('$cls: navigations already use the game parameter');
        return;
      }
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      report.add('$cls: $n navigation(s) -> game parameter');
    });
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RowNavFromParams()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Game rows open the organisation / player of their own game',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
