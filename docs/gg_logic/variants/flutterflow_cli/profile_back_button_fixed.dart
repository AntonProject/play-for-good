// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// userProfilePage: the back button scrolled away with the content (it sat in the
// header column inside the scroll view) and was invisible on white (white
// outline + white arrow). For both branches (signed in / guest):
//  * the button container moves to a Stack above the page content, top-left,
//    top padding = safe area + 8 (it used to overlap the status bar);
//  * an empty 56x40 box keeps its old place, so the header layout is unchanged;
//  * the button gets a translucent dark fill (black 25 %), visible on the red
//    header and on the white content.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.profileback.$seed');

// branch placeholder, content node in it, button container, existing stack (or null)
const branches = [
  ['PlaceholderWidget_uyhsxk0h', 'Stack_ho9zd9k3', 'Container_pjkkssbd', 'IconButton_1f2b8edr'],
  ['PlaceholderWidget_8o8egwrf', 'Container_s4gf3oc1', 'Container_ww8fnt3m', 'IconButton_myc2wxtw'],
];

final class ProfileBackButtonFixed extends FlutterFlowAITask {
  @override
  String get name => 'gg-profile-back-button-fixed';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'userProfilePage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
      if (n['key'] == k) return n;
      for (final c in (n['children'] as List? ?? [])) {
        final r = find(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    Map<String, dynamic>? parentOf(Map<String, dynamic> n, String k) {
      for (final c in (n['children'] as List? ?? [])) {
        if ((c as Map)['key'] == k) return n;
        final r = parentOf(c as Map<String, dynamic>, k);
        if (r != null) return r;
      }
      return null;
    }
    final report = <String>[];
    for (final b in branches) {
      final placeholder = find(w['node'], b[0]) ?? (throw StateError('${b[0]} not found'));
      final button = find(w['node'], b[2]) ?? (throw StateError('${b[2]} not found'));
      final iconButton = find(button, b[3]) ?? (throw StateError('${b[3]} not found'));
      // 1. Keep the old place with an empty box of the same size.
      final column = parentOf(w['node'], b[2])!;
      final kids = column['children'] as List;
      final i = kids.indexWhere((c) => c['key'] == b[2]);
      final spacerProps = jsonDecode(jsonEncode(button['props'])) as Map<String, dynamic>;
      kids[i] = {'key': 'Container_${key('spacer.${b[2]}')}', 'type': 'Container', 'props': spacerProps};
      // 2. Button container: top-left, below the status bar.
      final props = button['props'] as Map<String, dynamic>;
      props['alignment'] = {'xValue': {'inputValue': -1}, 'yValue': {'inputValue': -1}};
      final padding = (props['padding'] ??= <String, dynamic>{}) as Map<String, dynamic>;
      padding['topValue'] = {
        'variable': {
          'source': 'CUSTOM_CODE_EXPRESSION',
          'baseVariable': {
            'customCodeExpression': {'identifier': {'key': key('top.${b[2]}')}, 'code': 'MediaQuery.paddingOf(context).top + 8'}
          },
          'defaultValue': {'serializedValue': '52'},
          'uiBuilderValue': {'serializedValue': '52'},
        }
      };
      // 3. Translucent dark fill.
      (iconButton['props']['iconButton'] as Map)['fillColorValue'] = {
        'inputValue': {'value': '${0x40000000}'}
      };
      // 4. Above the content.
      final content = find(placeholder, b[1]) ?? (throw StateError('${b[1]} not found'));
      if (content['type'] == 'Stack') {
        (content['children'] as List).add(button);
      } else {
        final pk = placeholder['children'] as List;
        final j = pk.indexWhere((c) => c['key'] == b[1]);
        pk[j] = {
          'key': 'Stack_${key('stack.${b[1]}')}',
          'type': 'Stack',
          'props': {'stack': {}},
          'children': [content, button],
        };
      }
      report.add('${b[0]}: ${b[2]} fixed above the content (spacer left in ${column['key']})');
    }
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [ProfileBackButtonFixed()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Profile: back button fixed on top, visible on white',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
