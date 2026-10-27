// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 23.10.2026, owner: every dynamic value shown in the app gets a Default
// Variable Value and a UI Builder Display Value, so nothing is ever blank:
//   * names / nicknames (lists of users and organisations, profile nick)
//     -> "unnamed" (the guest has its own playerforgood_N);
//   * points, sums, counts, places -> "0";
//   * photos -> the white placeholder Profilbild.png;
//   * period labels -> "All-Time" (a bare "Saison" names no season).
// Not touched:
//   * values whose widget has a visibility condition on the same field (it
//     hides a missing value, e.g. the name line in the profile);
//   * ids (user / organisation ids passed to components), dates, struct and
//     list parameters (no meaningful default);
//   * ggPlaceLabelOf: it returns '' on purpose while there is no place yet; a
//     default would show "#0" again (only the UI Builder value is set);
//   * admin pages.
// The default goes on every dynamic part of a value: inside "@" + name or
// "#" + place the default of the whole text would never apply ("@null").
// Args: --apply to write; --list to print every change.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const placeholder =
    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png';
late bool listChanges;

final class BindingDefaults extends FlutterFlowAITask {
  @override
  String get name => 'gg-binding-defaults';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final classes = {
      for (final e in p.widgetClasses.entries) e.key: jsonDecode(jsonEncode(e.value.toProto3Json())) as Map<String, dynamic>
    };
    final byNode = {for (final c in classes.values) (c['node'] as Map)['key']: c};
    final skipped = <String, int>{};
    var total = 0;

    String? lastField(Map v) {
      for (final op in ((v['operations'] as List?) ?? const []).reversed) {
        final f = ((op as Map)['accessDataStructField'] ?? op['accessPostgresRowField'])?['fieldIdentifier']?['name'];
        if (f != null) return f as String;
      }
      return null;
    }

    // Default for one leaf (a value that is not an interpolation / condition).
    // null = leave it; '' key in skipped explains why.
    var vis = '';
    String? defaultFor(Map v, String where, String paramName, String paramType) {
      final fc = v['functionCall'] as Map?;
      final fn = fc?['customFunction']?['name'] as String?;
      final field = lastField(v);
      final src = v['source'];
      final state = v['baseVariable']?['localState']?['fieldIdentifier']?['name'] as String?;
      final wparam = v['baseVariable']?['widgetClass']?['paramIdentifier']?['name'] as String?;
      String skip(String why) {
        skipped[why] = (skipped[why] ?? 0) + 1;
        if (listChanges) stdout.writeln('  skip $where: $why');
        return '';
      }

      if (src == 'GLOBAL_PROPERTIES' || src == 'SUPABASE_AUTH_USER') return skip('auth / platform value');
      if ((field != null && vis.contains('"$field"')) || (fn != null && vis.contains('"$fn"'))) {
        return skip('visibility checks the same value');
      }
      if (fn == 'ggPlaceLabelOf') return skip('ggPlaceLabelOf (empty = no place yet)');
      if (paramType == 'ImagePath' || field == 'photoUrl' || field == 'photo_url') return placeholder;
      final id = RegExp(r'(^id$|Id$|_id$)');
      if (id.hasMatch(paramName) || (field != null && id.hasMatch(field)) || (wparam != null && id.hasMatch(wparam))) {
        return skip('id');
      }
      if (src == 'LIST_ITEM' || src == 'GENERATOR_VARIABLE') {
        if (field == null) return skip('list item itself (id)');
      }
      const dates = {'game_date', 'created_at', 'used_at', 'date', 'gameDate', 'createdAt'};
      if (dates.contains(field) || dates.contains(wparam) || dates.contains(paramName)) return skip('date');
      if (field == 'display_name' || field == 'displayName' || field == 'name' || field == 'user_name') return 'unnamed';
      if (field == 'first_name' || field == 'surname' || field == 'firstName') return skip('first name / surname (may stay empty)');
      if (field == 'registration' || field == 'city') return '-';
      if (fn == 'ggPeriodLabelOf' || fn == 'ggPeriodNameOf') return 'All-Time';
      if (state == 'ggUiGgCategoryUsers' || state == 'ggUiGgCategoryGames') return 'valuable';
      if (state == 'ggUiGgPeriodUsers' || state == 'ggUiGgPeriodGames') return skip('period key state');
      if (wparam == 'desc' || field == 'desc' || field == 'description') return skip('description text');
      const numbers = {
        'value', 'rank', 'score', 'goodPower', 'totalGoodPower', 'legacyBonusUsersCount', 'sum',
        'user_money', 'team_money', 'sieg_money', 'sponsor_money', 'additional_donation_money',
        'userMoneyRate', 'teamMoneyRate', 'siegMoneyRate', 'userPoints', 'teamPoints', 'siegPoints',
        'donatMoney', 'userMoney', 'teamMoney', 'siegMoney', 'goodGamesCount',
      };
      const numberFns = {
        'numFormat', 'totalSum', 'formatCompactWithComma', 'ggRankingPlace', 'ggHomeGaugeOf', 'ratingUser',
        'getUserRatingScore',
      };
      if (numbers.contains(field) || numberFns.contains(fn) || numbers.contains(wparam) ||
          paramType == 'Double' || paramType == 'Integer') {
        return '0';
      }
      return skip('other: ${fn ?? ''}${field != null ? '.$field' : ''}${state != null ? '\$$state' : ''}${wparam != null ? 'param:$wparam' : ''} [$src]');
    }

    // Walks a value variable down to its leaves and sets their defaults.
    int fill(Map v, String where, String paramName, String paramType) {
      var n = 0;
      final fc = v['functionCall'] as Map?;
      if (fc?['stringInterpolation'] != null) {
        for (final part in (fc!['values'] as List)) {
          final pv = (part as Map)['variable'];
          if (pv is Map) n += fill(pv, where, paramName, 'String');
        }
        return n;
      }
      if (fc?['conditionalValue'] != null) {
        final cv = fc!['conditionalValue'] as Map;
        for (final b in (cv['ifConditionalValues'] as List)) {
          final bv = (b as Map)['value']?['variable'];
          if (bv is Map) n += fill(bv, where, paramName, paramType);
        }
        final ev = cv['elseValue']?['variable'];
        if (ev is Map) n += fill(ev, where, paramName, paramType);
        return n;
      }
      if (v['defaultValue'] != null) return 0;
      final d = defaultFor(v, where, paramName, paramType);
      if (d == null || d.isEmpty) {
        if (v['functionCall']?['customFunction']?['name'] == 'ggPlaceLabelOf' && v['uiBuilderValue'] == null) {
          v['uiBuilderValue'] = {'serializedValue': '#1'};
          n++;
        }
        return n;
      }
      v['defaultValue'] = {'serializedValue': d};
      v['uiBuilderValue'] ??= {'serializedValue': d};
      if (listChanges) stdout.writeln('  $where = "$d"');
      return n + 1;
    }

    for (final entry in p.widgetClasses.entries) {
      final c = classes[entry.key]!;
      final cls = c['name'] as String;
      if (cls.contains('Admin')) continue;
      var n = 0;
      void walk(dynamic x) {
        if (x is Map) {
          if (x['type'] != null && x['key'] is String) {
            final key = x['key'] as String;
            final props = (x['props'] as Map?) ?? {};
            vis = jsonEncode(props['visibility']?['visibleValue'] ?? '');
            {
              final tv = props['text']?['textValue']?['variable'];
              if (tv is Map) n += fill(tv, '$cls/$key text', 'text', 'String');
              final img = props['image']?['pathValue']?['variable'];
              if (img is Map) n += fill(img, '$cls/$key image', 'image', 'ImagePath');
              final pv = x['parameterValues'] as Map?;
              final ref = x['componentClassKeyRef'] ?? x['widgetClassNodeKeyRef'];
              if (pv != null && ref is Map) {
                final params = (byNode[ref['key']]?['params'] as Map?) ?? {};
                for (final e in ((pv['parameterPasses'] as Map?) ?? {}).entries) {
                  final pass = e.value as Map;
                  final v = pass['variable'];
                  if (v is! Map) continue;
                  final dt = (params[e.key] as Map?)?['dataType'] as Map?;
                  if (dt == null || dt['listType'] != null) continue;
                  final type = dt['scalarType'] as String?;
                  if (!const {'String', 'Integer', 'Double', 'ImagePath'}.contains(type)) continue;
                  final name = pass['paramIdentifier']?['name'] as String? ?? e.key;
                  n += fill(v, '$cls/$key param $name', name, type!);
                }
              }
            }
          }
          for (final e in x.entries) {
            if (e.key == 'children' || e.key == 'node') walk(e.value);
          }
        } else if (x is List) {
          x.forEach(walk);
        }
      }
      walk(c['node']);
      if (n > 0) {
        final next = FFWidgetClass()..mergeFromProto3Json(c);
        restoreUnknownFields(entry.value, next);
        p.widgetClasses[entry.key] = next;
        stdout.writeln('$cls: $n defaults');
        total += n;
      }
    }
    stdout.writeln('total: $total');
    skipped.forEach((k, v) => stdout.writeln('skipped $v: $k'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  listChanges = args.contains('--list');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [BindingDefaults()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Defaults for dynamic values: names unnamed, numbers 0, photos placeholder',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
