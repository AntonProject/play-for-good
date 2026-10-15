// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Profile awards the same way as the Good Games row (owner decision 15.10.2026):
// a fixed row of images, each visible when the user has that award, instead of
// a generated list (one stack of 4 images per award).
//   Row_l459ypck: generator over ggSortAwards(...) removed; its children are the
//   4 award images (MVP gold, silver, bronze, MAP gold), each visible by
//   ggStatsOrEmpty(ggProfile).awardFlags.<flag> (awards of all seasons).
// A repeated win shows one image (as in the Good Games row).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const awardsRow = 'Row_l459ypck';
const order = ['mvp_gold', 'mvp_silver', 'mvp_bronze', 'active_fire'];
const flags = {
  'mvp_gold': 'mvpGold',
  'mvp_silver': 'mvpSilver',
  'mvp_bronze': 'mvpBronze',
  'active_fire': 'activeFire',
};

final class ProfileAwardsFlags extends FlutterFlowAITask {
  @override
  String get name => 'gg-profile-awards-flags';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    Map<String, dynamic> id(FFIdentifier i) => {'name': i.name, 'key': i.key};
    Map<String, dynamic> field(String struct, String name) => {
          'accessDataStructField': {
            'fieldIdentifier': id(findDataStruct(p, name: struct)!.fields.firstWhere((f) => f.identifier.name == name).identifier)
          }
        };
    final orEmpty = p.customCode.customFunctions.firstWhere((f) => f.identifier.name == 'ggStatsOrEmpty').identifier;

    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'userProfilePage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    Map<String, dynamic>? find(Map<String, dynamic> n) {
      if (n['key'] == awardsRow) return n;
      for (final c in (n['children'] as List? ?? [])) {
        final r = find(c as Map<String, dynamic>);
        if (r != null) return r;
      }
      return null;
    }
    final row = find(w['node']) ?? (throw StateError('$awardsRow not found'));
    if (row['generatorVariable'] == null) {
      stdout.writeln('userProfilePage: awards row is already fixed images');
      return;
    }
    final stack = (row['children'] as List).single as Map<String, dynamic>;
    if (stack['type'] != 'Stack') throw StateError('awards item is not a Stack');
    final field0 = ((w['classModel'] as Map)['stateFields'] as List)
        .firstWhere((f) => f['parameter']['identifier']['name'] == 'ggProfile');
    final profile = {
      'source': 'LOCAL_STATE',
      'baseVariable': {
        'localState': {'fieldIdentifier': field0['parameter']['identifier'], 'stateVariableType': 'WIDGET_CLASS_STATE'}
      },
      'nodeKeyRef': {'key': w['node']['key']},
    };
    final byBadge = <String, Map<String, dynamic>>{};
    for (final img in (stack['children'] as List).cast<Map<String, dynamic>>()) {
      final vis = jsonEncode(img['props']?['visibility']);
      final badge = RegExp(r'"enumElementIdentifier":\{"name":"([a-z_]+)"').firstMatch(vis)?.group(1);
      if (badge == null || !flags.containsKey(badge)) throw StateError('${img['key']}: award badge not found');
      (img['props'] as Map)['visibility'] = {
        'visibleValue': {
          'variable': {
            'source': 'FUNCTION_CALL',
            'functionCall': {
              'values': [
                {'variable': profile}
              ],
              'customFunction': id(orEmpty),
            },
            'operations': [field('GgProfileStats', 'awardFlags'), field('GgAwardFlags', flags[badge]!)],
          },
          'mostRecentInputValue': true,
        }
      };
      byBadge[badge] = img;
    }
    if (byBadge.length != 4) throw StateError('expected 4 award images, found ${byBadge.length}');
    row.remove('generatorVariable');
    row['children'] = [for (final b in order) byBadge[b]];
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('userProfilePage: awards = ${order.map((b) => '${byBadge[b]!['key']} if ${flags[b]}').join(', ')}');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [ProfileAwardsFlags()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Profile: award images with visibility by awardFlags (as in Good Games)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
