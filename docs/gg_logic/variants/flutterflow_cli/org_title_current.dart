// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Supported organizations in the profile (userProfilePage, userProfile dialog,
// profileGamesOrgsDialog) showed games.org_name: the name copied into the game
// when it was paid, so a renamed organization kept its old name there.
// The game copy stays as it is (history); the title now shows the current
// organization.title, from the organization list the same item already reads
// its image from, and falls back to the game copy (ggOrgTitle).
// Requires the ggOrgTitle custom function (transfer.dart, rpc variant).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const classes = ['userProfilePage', 'userProfile', 'profileGamesOrgsDialog'];

final class OrgTitleCurrent extends FlutterFlowAITask {
  OrgTitleCurrent({this.after = const {}});
  // Task names to run first in a combined pipeline (e.g. register-gg-rpc).
  final Set<String> after;
  @override
  Set<String> get dependsOn => after;
  @override
  String get name => 'gg-org-title-current';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final fn = p.customCode.customFunctions
        .where((f) => f.identifier.name == 'ggOrgTitle')
        .firstOrNull;
    if (fn == null) throw StateError('ggOrgTitle custom function is missing');
    String lastField(Map v) {
      final ops = v['operations'] as List? ?? [];
      final last = ops.isEmpty ? null : ops.last as Map;
      return ((last?['accessPostgresRowField'] as Map?)?['fieldIdentifier'] as Map?)?['name'] as String? ?? '';
    }
    for (final name in classes) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == name);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      var changed = 0;
      void walk(Object? n) {
        if (n is Map) {
          final passes = (n['parameterValues'] as Map?)?['parameterPasses'] as Map?;
          if (passes != null) {
            Map? pass(String param) => passes.values
                .cast<Map>()
                .where((v) => (v['paramIdentifier'] as Map?)?['name'] == param)
                .firstOrNull;
            final title = pass('title');
            final image = pass('image');
            if (title != null && image != null &&
                title['variable'] is Map && lastField(title['variable']) == 'org_name' &&
                image['variable'] is Map && lastField(image['variable']) == 'image_url') {
              final snapshot = jsonDecode(jsonEncode(title['variable'])) as Map<String, dynamic>
                ..remove('defaultValue')
                ..remove('uiBuilderValue');
              final current = jsonDecode(jsonEncode(image['variable'])) as Map<String, dynamic>
                ..remove('defaultValue')
                ..remove('uiBuilderValue');
              ((current['operations'] as List).last as Map)['accessPostgresRowField'] = {
                'fieldIdentifier': {'name': 'title'}
              };
              title['variable'] = {
                'source': 'FUNCTION_CALL',
                'defaultValue': {'serializedValue': 'Organisation'},
                'functionCall': {
                  'values': [
                    {'variable': current},
                    {'variable': snapshot},
                  ],
                  'customFunction': {'name': fn.identifier.name, 'key': fn.identifier.key},
                },
                'uiBuilderValue': {'serializedValue': 'Organisation'},
              };
              changed++;
            }
          }
          n.values.forEach(walk);
        } else if (n is List) {
          n.forEach(walk);
        }
      }
      walk(w['node']);
      if (changed != 1) throw StateError('$name: expected 1 organization title, found $changed');
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      stdout.writeln('$name: organization title = ggOrgTitle(organization.title, games.org_name)');
    }
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [OrgTitleCurrent()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Profile: current organization names (game copy as fallback)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
