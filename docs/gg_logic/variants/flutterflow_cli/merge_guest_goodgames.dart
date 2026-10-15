// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// GoodGamesPage: one layout for signed-in users and guests.
// The page was two copies of the same 126-widget tree behind a ConditionalBuilder
// "Is User Logged In". The signed-in copy was wrapped in a "users" single-row
// query (id = auth user) with Hide On Empty, so for a guest it hid the page; the
// guest copy was the same tree with constants. Verified by a full branch diff:
// same structure and components; besides keys/visual tweaks only the pinned
// "me" row differs (guest: place = ggPlace, always visible).
// Steps on the signed-in copy, which is kept:
//  * the users query is removed; its 4 uses read: id -> auth user id
//    (guest '' -> empty row in components), photo_url -> ggMyPhoto(ggRanking);
//  * pinned "me" row + its divider: visible if ggShowMeRow OR not signed in;
//    its place -> ggPlace(ggRanking) (own rank / guest_rank);
//  * the ConditionalBuilder is replaced by the kept copy; the guest copy goes.
// A JSON backup of the page is written before the change.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'GoodGamesPage';
const builderKey = 'ConditionalBuilder_f4a2g7fb';

final class MergeGuestGoodGames extends FlutterFlowAITask {
  @override
  String get name => 'gg-merge-guest-goodgames';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final backup = File('${Platform.environment['HOME']}/.config/pfg-gg-backups/'
        'GoodGamesPage_before_guest_merge_${DateTime.now().millisecondsSinceEpoch}.json');
    backup.writeAsStringSync(jsonEncode(w));
    final root = (w['node'] as Map)['key'];

    Map<String, dynamic>? parentOf(Map<String, dynamic> n, String k) {
      for (final c in (n['children'] as List? ?? [])) {
        if ((c as Map)['key'] == k) return n;
        final r = parentOf(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    final parent = parentOf(w['node'], builderKey) ?? (throw StateError('$builderKey not found'));
    final builder = (parent['children'] as List).firstWhere((c) => c['key'] == builderKey) as Map<String, dynamic>;
    final branches = builder['children'] as List;
    final loggedIf = jsonEncode(branches[0]['props']['visibility']);
    if (branches.length != 2 || !loggedIf.contains('IS_USER_LOGGED_IN')) {
      throw StateError('Unexpected builder branches');
    }
    final kept = (branches[0]['children'] as List).single as Map<String, dynamic>;

    // The signed-in copy's users query (id = auth user).
    final queries = <Map<String, dynamic>>[];
    void q(Map<String, dynamic> n) {
      if (n['databaseRequest'] != null) queries.add(n);
      for (final c in (n['children'] as List? ?? [])) q(c as Map<String, dynamic>);
    }
    q(kept);
    if (queries.length != 1) throw StateError('Expected 1 query in the kept copy, found ${queries.length}');
    final query = queries.single;
    final dr = jsonEncode(query['databaseRequest']);
    if (!dr.contains('"name":"users"') || !dr.contains('SUPABASE_AUTH_USER') || !dr.contains('"isSingleRow":true')) {
      throw StateError('Kept query is not the current user row');
    }
    final queryKey = query['key'] as String;

    Map<String, dynamic> fnIdent(String n) =>
        findCustomFunction(p, name: n)!.identifier.toProto3Json() as Map<String, dynamic>;
    final ranking = {
      'source': 'LOCAL_STATE',
      'baseVariable': {
        'localState': {
          'fieldIdentifier': ((w['classModel'] as Map)['stateFields'] as List)
              .firstWhere((f) => f['parameter']['identifier']['name'] == 'ggRanking')['parameter']['identifier'],
          'stateVariableType': 'WIDGET_CLASS_STATE',
        }
      },
      'nodeKeyRef': {'key': root},
    };
    final authId = {'source': 'SUPABASE_AUTH_USER', 'baseVariable': {'auth': {'property': 'USER_ID'}}};
    final notSignedIn = {
      'source': 'FUNCTION_CALL',
      'functionCall': {
        'condition': {'relation': 'EQUAL_TO'},
        'values': [
          {'variable': {'source': 'GLOBAL_PROPERTIES', 'baseVariable': {'globalProperties': {'property': 'IS_USER_LOGGED_IN'}}}},
          {'inputValue': {'serializedValue': 'false'}},
        ],
      },
    };
    final counts = <String, int>{};
    void count(String k) => counts[k] = (counts[k] ?? 0) + 1;

    void rewrite(dynamic x) {
      if (x is Map<String, dynamic>) {
        if (x['source'] == 'POSTGRES_QUERY' && x['nodeKeyRef']?['key'] == queryKey) {
          final field = x['operations']?[0]?['accessPostgresRowField']?['fieldIdentifier']?['name'];
          final keep = {for (final k in ['defaultValue', 'uiBuilderValue']) if (x[k] != null) k: x[k]};
          final Map<String, dynamic> next;
          if (field == 'id') {
            next = jsonDecode(jsonEncode(authId)) as Map<String, dynamic>;
          } else if (field == 'photo_url') {
            next = {
              'source': 'FUNCTION_CALL',
              'functionCall': {'customFunction': fnIdent('ggMyPhoto'), 'values': [{'variable': ranking}]},
            };
          } else {
            throw StateError('Unexpected users field $field');
          }
          x
            ..clear()
            ..addAll(next)
            ..addAll(keep);
          count('query.$field');
          return;
        }
        // Pinned "me" row and its divider: also shown to guests.
        final vis = x['props']?['visibility']?['visibleValue'];
        if (vis is Map && jsonEncode(vis['variable'] ?? {}).contains('"name":"ggShowMeRow"') &&
            !jsonEncode(vis).contains('IS_USER_LOGGED_IN')) {
          final showMe = vis['variable'];
          vis['variable'] = {
            'source': 'FUNCTION_CALL',
            'functionCall': {
              'combineConditions': {'operator': 'OR_OP'},
              'values': [
                {'variable': showMe},
                {'variable': notSignedIn},
              ],
            },
          };
          count('meRow.visible');
          // Its place: one function for both (own rank or guest_rank).
          final passes = x['parameterValues']?['parameterPasses'] as Map?;
          if (passes != null) {
            for (final pass in passes.values) {
              if (pass['paramIdentifier']?['name'] == 'rating') {
                pass['variable'] = {
                  'source': 'FUNCTION_CALL',
                  'functionCall': {'customFunction': fnIdent('ggPlace'), 'values': [{'variable': ranking}]},
                };
                count('meRow.place');
              }
            }
          }
        }
        x.values.forEach(rewrite);
      } else if (x is List) {
        x.forEach(rewrite);
      }
    }
    rewrite(kept);
    query.remove('databaseRequest');
    if (counts['meRow.visible'] != 2 || counts['meRow.place'] != 1 || (counts['query.id'] ?? 0) == 0 ||
        counts['query.photo_url'] != 1) {
      throw StateError('Unexpected rewrite counts: $counts');
    }
    final left = jsonEncode(kept).contains('"key":"$queryKey"') &&
        jsonEncode(kept).contains('POSTGRES_QUERY');
    if (left) {
      final s = <String>[];
      void scan(dynamic x) {
        if (x is Map) {
          if (x['source'] == 'POSTGRES_QUERY' && x['nodeKeyRef']?['key'] == queryKey) s.add('ref');
          x.values.forEach(scan);
        } else if (x is List) {
          x.forEach(scan);
        }
      }
      scan(w);
      if (s.isNotEmpty) throw StateError('References to the removed query left: ${s.length}');
    }
    // Replace the ConditionalBuilder with the kept copy (same slot in the Stack).
    final i = (parent['children'] as List).indexWhere((c) => c['key'] == builderKey);
    (parent['children'] as List)[i] = kept;

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('GoodGamesPage merged: kept ${kept['key']}, removed guest copy; $counts; backup ${backup.path}');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [MergeGuestGoodGames()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'GoodGamesPage: one layout for signed-in users and guests',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
