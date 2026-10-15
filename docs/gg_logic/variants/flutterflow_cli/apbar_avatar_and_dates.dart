// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
//  1. apbarBG (header of Energy, Good News, Home): the avatar is a "users"
//     FutureBuilder; its loading widget is Center(SizedBox 40x40), and a Center in
//     the header Row takes the full row height, so the row is taller for a frame
//     and the title jumps when the 40x40 avatar arrives (every page visit: a
//     FutureBuilder shows the loader for at least one frame). The avatar now sits
//     in a fixed 40x40 Container, so the loader has the avatar's size.
//  2. Texts showing a game date (game_date / created_at) without a default are
//     hidden when the date is missing (owner's rule: missing DB text -> hidden).
//     Plan: tools/text_defaults_plan.py (4 hide_if_empty ops).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.apbardates.$seed');

const dateTexts = {
  'impactComp': 'Text_rtosm2yw',
  'GamePage': 'Text_19m2zkgh',
  'recentGameHome': 'Text_6kq70g5y',
  'orgCompHome': 'Text_04qz3tii',
};

final class ApbarAvatarAndDates extends FlutterFlowAITask {
  @override
  String get name => 'gg-apbar-avatar-and-dates';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
    if (n['key'] == k) return n;
    for (final c in (n['children'] as List? ?? [])) {
      final r = find(c as Map<String, dynamic>, k);
      if (r != null) return r;
    }
    return null;
  }

  void replace(FFProject p, String cls, void Function(Map<String, dynamic> w) edit) {
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    edit(w);
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
  }

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];

    // 1. apbarBG avatar in a fixed box.
    replace(p, 'apbarBG', (w) {
      Map<String, dynamic>? parent;
      Map<String, dynamic>? avatar;
      void walk(Map<String, dynamic> n) {
        for (final c in (n['children'] as List? ?? [])) {
          final m = c as Map<String, dynamic>;
          if (m['databaseRequest'] != null && jsonEncode(m['databaseRequest']).contains('"name":"users"')) {
            parent = n;
            avatar = m;
          }
          walk(m);
        }
      }
      walk(w['node']);
      if (avatar == null) throw StateError('apbarBG: avatar query not found');
      if (parent!['type'] == 'Container' && jsonEncode(parent!['props']).contains('"inputValue":40')) {
        throw StateError('apbarBG: avatar already wrapped');
      }
      final children = parent!['children'] as List;
      final i = children.indexOf(avatar);
      children[i] = {
        'key': 'Container_${key('avatarbox')}',
        'type': 'Container',
        'props': {
          'container': {
            'dimensions': {
              'width': {'pixelsValue': {'inputValue': 40}},
              'height': {'pixelsValue': {'inputValue': 40}},
            }
          }
        },
        'children': [avatar],
      };
      report.add('apbarBG: avatar ${avatar!['key']} inside a 40x40 box (parent ${parent!['key']})');
    });

    // 2. Dates hidden when missing.
    for (final cls in dateTexts.keys) {
      replace(p, cls, (w) {
        final n = find(w['node'], dateTexts[cls]!) ?? (throw StateError('$cls/${dateTexts[cls]} not found'));
        final props = n['props'] as Map<String, dynamic>;
        final leaf = jsonDecode(jsonEncode(props['text']['textValue']['variable'])) as Map<String, dynamic>;
        if (leaf['defaultValue'] != null) throw StateError('$cls: has a default now');
        // Condition on the raw date: without the dateTimeFormat operation.
        leaf['operations'] = (leaf['operations'] as List).where((o) => !(o as Map).containsKey('dateTimeFormat')).toList();
        final exists = {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'condition': {'relation': 'EXISTS_AND_NON_EMPTY'},
            'values': [
              {'variable': leaf}
            ],
          },
        };
        final old = props['visibility']?['visibleValue']?['variable'];
        props['visibility'] = {
          'visibleValue': {
            'variable': old == null
                ? exists
                : {
                    'source': 'FUNCTION_CALL',
                    'functionCall': {
                      'combineConditions': {'operator': 'AND_OP'},
                      'values': [
                        {'variable': old},
                        {'variable': exists},
                      ],
                    },
                  }
          }
        };
        report.add('$cls/${n['key']}: hidden without a date${old == null ? '' : ' (AND existing condition)'}');
      });
    }
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [ApbarAvatarAndDates()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Header avatar in a fixed box (no jump); game dates hidden when missing',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
