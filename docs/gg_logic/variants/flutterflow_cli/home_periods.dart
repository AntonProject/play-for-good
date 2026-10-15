// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Home (homePageScore) period dropdown = the Good Games periods + "Diese Woche":
//   Saison 2026/27 | Saison 2025/26 | Letzten Monat | Diesen Monat | Diese Woche | All-Time
// Values are the same Period keys the Good Games filter uses (ggPeriodKey maps
// them for the RPC), default = current season (season_26_27), like Good Games.
// On select: periodState = the selected value, then ggRefreshHomeRank (kept).
// A new season needs a new row here, as in the Good Games filter.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'homePageScore';
const dropDown = 'DropDown_52vp243b';
const periods = [
  ['season_26_27', 'Saison 2026/27'],
  ['season_25_26', 'Saison 2025/26'],
  ['letzter_monat', 'Letzten Monat'],
  ['dieser_monat', 'Diesen Monat'],
  ['woche', 'Diese Woche'],
  ['all_time', 'All-Time'],
];
String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.homeperiods.$seed');

final class HomePeriods extends FlutterFlowAITask {
  @override
  String get name => 'gg-home-periods';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final root = (w['node'] as Map)['key'];
    Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
      if (n['key'] == k) return n;
      for (final c in (n['children'] as List? ?? [])) {
        final r = find(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    final node = find(w['node'], dropDown) ?? (throw StateError('$dropDown not found'));
    final d = node['props']['dropDown'] as Map<String, dynamic>;
    final relabel = !jsonEncode(d['optionsLabels']).contains('Saison');
    if (!relabel && d['optionsHasKeyValues'] == true) throw StateError('Already applied');

    final field = ((w['classModel'] as Map)['stateFields'] as List)
        .firstWhere((f) => f['parameter']['identifier']['name'] == 'periodState') as Map<String, dynamic>;
    final periodState = {
      'source': 'LOCAL_STATE',
      'baseVariable': {
        'localState': {'fieldIdentifier': field['parameter']['identifier'], 'stateVariableType': 'WIDGET_CLASS_STATE'}
      },
      'nodeKeyRef': {'key': root},
    };
    field['serializedDefaultValue'] = ['season_26_27'];

    d['optionsLabels'] = {
      'values': [
        for (final x in periods)
          {
            'translatableText': {
              'translationIdentifier': {'key': key('label.${x[0]}')},
              'textValue': {'inputValue': x[1]},
            }
          }
      ]
    };
    d['optionsValues'] = {
      'values': [for (final x in periods) {'serializedValue': x[0]}]
    };
    // Labels shown, Period keys stored (key/value options, as in the admin
    // filters); the selected value follows periodState.
    d['optionsHasKeyValues'] = true;
    d['initialOptionKeyValue'] = {'variable': periodState};
    d.remove('initialOption');
    (d['hintText'] as Map)['textValue'] = {'inputValue': 'Saison 2026/27'};
    d['dimensions']['width'] = {'pixelsValue': {'inputValue': 150}};

    // On select: periodState = value, then the existing refresh follow-up.
    if (!relabel) {
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      stdout.writeln('Home periods: key/value options enabled');
      return;
    }
    final trigger = (node['triggerActions'] as List)
        .firstWhere((t) => t['trigger']['triggerType'] == 'ON_FORM_WIDGET_SELECTED') as Map<String, dynamic>;
    final old = trigger['rootAction'] as Map<String, dynamic>;
    final refresh = old['followUpAction'];
    if (refresh == null || !jsonEncode(refresh).contains('ggRefreshHomeRank') || old['conditionActions'] == null) {
      throw StateError('Unexpected dropdown action flow');
    }
    trigger['rootAction'] = {
      'key': key('set.node'),
      'action': {
        'key': key('set.action'),
        'localStateUpdate': {
          'updates': [
            {
              'fieldIdentifier': {'key': field['parameter']['identifier']['key']},
              'setValue': {
                'variable': {
                  'source': 'WIDGET_STATE',
                  'baseVariable': {'widgetState': {'returnParameter': {'dataType': {'scalarType': 'String'}}}},
                  'nodeKeyRef': {'key': dropDown},
                }
              },
            }
          ],
          'updateType': 'WIDGET',
          'stateVariableType': 'WIDGET_CLASS_STATE',
        },
      },
      'followUpAction': refresh,
    };

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('Home periods: ${periods.map((x) => x[1]).join(' | ')}; default season_26_27');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [HomePeriods()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Home periods = Good Games periods + Diese Woche, default current season',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
