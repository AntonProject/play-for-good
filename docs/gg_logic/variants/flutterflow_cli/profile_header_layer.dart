// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// userProfilePage: the header-image loading widget (first_frame_headers.dart)
// landed at the bottom: the page ConditionalBuilder aligns its child to the
// bottom (y = 1) and the loader is smaller than the screen. Instead:
//  * the two profile queries get the default (transparent) loader back;
//  * the signed-in branch content sits in a Stack above a full-screen layer
//    whose top is the profile header (user_profile_background.png, 400), so
//    while loading the header is at the top, and the content covers it later.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.profilelayer.$seed');
const queries = ['Container_vja259xs', 'Container_iupbs9op'];
const content = 'Container_ggt9txkv';
const headerKey = 'Container_qob8t7pt';

final class ProfileHeaderLayer extends FlutterFlowAITask {
  @override
  String get name => 'gg-profile-header-layer';
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
    for (final q in queries) {
      final n = find(w['node'], q)!;
      n['props']['queryLoadingWidget'] = {
        'loadingWidget': {
          'loadingIndicator': {'type': 'CIRCULAR', 'color': {'value': '0'}, 'diameter': 40}
        }
      };
    }
    final header = find(w['node'], headerKey)!;
    final headerCopy = {
      'key': 'Container_${key('header')}',
      'type': 'Container',
      'props': {'container': jsonDecode(jsonEncode(header['props']['container']))},
    };
    final layer = {
      'key': 'Container_${key('layer')}',
      'type': 'Container',
      'props': {
        'container': {
          'dimensions': {
            'width': {'pixelsValue': {'inputValue': 'Infinity'}},
            'height': {'percentOfScreenSizeValue': {'inputValue': 100}},
          }
        }
      },
      'children': [
        {
          'key': 'Column_${key('layer.column')}',
          'type': 'Column',
          'props': {'column': {}},
          'children': [headerCopy],
        }
      ],
    };
    final parent = parentOf(w['node'], content)!;
    final kids = parent['children'] as List;
    final i = kids.indexWhere((c) => c['key'] == content);
    if (kids[i]['type'] != 'Container') throw StateError('unexpected content node');
    kids[i] = {
      'key': 'Stack_${key('stack')}',
      'type': 'Stack',
      'props': {'stack': {}},
      'children': [layer, kids[i]],
    };
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('userProfilePage: loaders back to default; $content above a full-screen header layer');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [ProfileHeaderLayer()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Profile: header layer at the top while loading (not the bottom)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
