// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// The red header shown while PlayPage / PlayPaymentPage load (first_frame_headers.dart)
// filled ~the whole screen: it sat directly in the Scaffold body, whose
// constraints are tight (full screen), so the 420 px header and the 420 px
// loading image were stretched. Now:
//  1. PlayPage and PlayPaymentPage guards (game / gamePage not set yet): the
//     header placeholder sits in a Column -> top, its own 420 px height.
//  2. PlayPaymentPage users query (Stack_708o4kk0): the loading image is replaced
//     by the default transparent loader; the query sits in a Stack above a
//     header layer (Column with a copy of the header), so the header is at the
//     top while loading; a page-colored full-size container is the query
//     content's first child, so the layer does not show through when scrolling.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.playheader.$seed');

const payQuery = 'Stack_708o4kk0';
const payHeader = 'Container_e61bz945';

final class PlayHeaderPlaceholders extends FlutterFlowAITask {
  @override
  String get name => 'gg-play-header-placeholders';
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

  Map<String, dynamic>? parentOf(Map<String, dynamic> n, String k) {
    for (final c in (n['children'] as List? ?? [])) {
      if ((c as Map)['key'] == k) return n;
      final r = parentOf(c as Map<String, dynamic>, k);
      if (r != null) return r;
    }
    return null;
  }

  // Guard else branch: [header placeholder] -> [Column[header placeholder]].
  String wrapGuard(Map<String, dynamic> root, String page) {
    final body = (root['children'] as List).single as Map<String, dynamic>;
    if (body['type'] != 'ConditionalBuilder') throw StateError('$page body is not the guard');
    final elseBranch = (body['children'] as List)[1] as Map<String, dynamic>;
    final kids = elseBranch['children'] as List;
    if (kids.length != 1) throw StateError('$page guard else: unexpected children');
    final child = kids.single as Map<String, dynamic>;
    if (child['type'] == 'Column') return '$page: guard header already in a Column';
    if (child['type'] != 'Container') throw StateError('$page guard else is not the header');
    elseBranch['children'] = [
      {
        'key': 'Column_${key('$page.guard')}',
        'type': 'Column',
        'props': {'column': {}},
        'children': [child],
      }
    ];
    return '$page: guard header at the top (Column)';
  }

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    void edit(String cls, void Function(Map<String, dynamic>) f) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      f(w);
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }

    edit('PlayPage', (w) => report.add(wrapGuard(w['node'] as Map<String, dynamic>, 'PlayPage')));

    edit('PlayPaymentPage', (w) {
      final root = w['node'] as Map<String, dynamic>;
      report.add(wrapGuard(root, 'PlayPaymentPage'));

      final q = find(root, payQuery) ?? (throw StateError('$payQuery not found'));
      final header = find(root, payHeader) ?? (throw StateError('$payHeader not found'));
      if (q['databaseRequest'] == null) throw StateError('$payQuery has no query');
      final parent = parentOf(root, payQuery)!;
      if (parent['type'] == 'Stack' && (parent['key'] as String).startsWith('Stack_') &&
          jsonEncode(parent['children']).contains(key('pay.layer'))) {
        report.add('PlayPaymentPage: header layer already present');
        return;
      }
      // 2a. default transparent loader
      (q['props'] as Map)['queryLoadingWidget'] = {
        'loadingWidget': {
          'loadingIndicator': {'type': 'CIRCULAR', 'color': {'value': '0'}, 'diameter': 40}
        }
      };
      // 2b. page-colored full-size background as the query content's first child
      (q['children'] as List).insert(0, {
        'key': 'Container_${key('pay.bg')}',
        'type': 'Container',
        'props': {
          'container': {
            'dimensions': {
              'width': {'pixelsValue': {'inputValue': 'Infinity'}},
              'height': {'pixelsValue': {'inputValue': 'Infinity'}},
            },
            'boxDecoration': {
              'colorValue': {
                'inputValue': {'themeColor': 'PRIMARY_BACKGROUND'}
              }
            },
          }
        },
      });
      // 2c. header layer behind the query
      final layer = {
        'key': 'Column_${key('pay.layer')}',
        'type': 'Column',
        'props': {'column': {}},
        'children': [
          {
            'key': 'Container_${key('pay.layer.header')}',
            'type': 'Container',
            'props': {'container': jsonDecode(jsonEncode(header['props']['container']))},
          }
        ],
      };
      final kids = parent['children'] as List;
      final i = kids.indexWhere((c) => c['key'] == payQuery);
      final stack = {
        'key': 'Stack_${key('pay.stack')}',
        'type': 'Stack',
        'props': {'stack': {}},
        'children': [layer, q],
      };
      kids[i] = stack;
      for (final r in (parent['childPropertyMap'] as Map? ?? {}).values) {
        for (final ref in ((r as Map)['keyRefs'] as List? ?? [])) {
          if (ref['key'] == payQuery) ref['key'] = stack['key'];
        }
      }
      report.add('PlayPaymentPage: users query -> transparent loader above a header layer');
    });
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PlayHeaderPlaceholders()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Play / payment: loading header at the top, not stretched',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
