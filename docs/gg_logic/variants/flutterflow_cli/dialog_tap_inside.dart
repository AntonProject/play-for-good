// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Bottom-sheet dialogs (16.10.2026): a tap inside the sheet no longer closes it.
// The root Column closes the sheet on tap (that is how a tap on the dimmed
// area above the sheet closes it). Every tap inside the sheet that no row
// takes (gaps, dividers, card padding) reached that Column too. The sheet
// Container now takes the tap itself with a no-op action (wait 0 ms), so only
// the area outside the sheet closes it. Nothing else changes.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const dialogs = [
  'goodGamesPlayersFilters',
  'userProfileFilters',
  'gameTitleEdit',
  'berechnungDialog',
  'cancelGameDialog',
  'deleteAccDialog',
];

final class DialogTapInside extends FlutterFlowAITask {
  @override
  String get name => 'gg-dialog-tap-inside';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    for (final name in dialogs) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == name,
          orElse: () => throw StateError('$name not found'));
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      bool dismissOnTap(Map n) => ((n['triggerActions'] as List?) ?? []).any((t) =>
          t['trigger']?['triggerType'] == 'ON_TAP' &&
          t['rootAction']?['action']?['bottomSheet']?['isDismiss'] == true);
      final root = (w['node']['children'] as List).first as Map;
      if (!dismissOnTap(root)) throw StateError('$name: root does not close the sheet on tap');
      final sheets = (root['children'] as List).cast<Map>();
      if (sheets.length != 1 || sheets.first['type'] != 'Container') {
        throw StateError('$name: expected one sheet Container under the root');
      }
      final sheet = sheets.first;
      final triggers = (sheet['triggerActions'] as List?) ?? [];
      if (triggers.any((t) => t['trigger']?['triggerType'] == 'ON_TAP')) {
        stdout.writeln('$name: ${sheet['key']} already takes the tap');
        continue;
      }
      String key(String part) => generateRandomAlphaNumericString(seedString: 'pfg.gg.tapinside.$name.$part');
      sheet['triggerActions'] = [
        ...triggers,
        {
          'rootAction': {
            'key': key('root'),
            'action': {
              'key': key('action'),
              'waitAction': {'durationMillisValue': {'inputValue': 0}},
            },
          },
          'trigger': {'triggerType': 'ON_TAP'},
        },
      ];
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      stdout.writeln('$name: ${sheet['key']} takes taps inside the sheet');
    }
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [DialogTapInside()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Dialogs: a tap inside the sheet does not close it',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
