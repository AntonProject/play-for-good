// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// First frame of pages with a red header: the header instead of white.
//  1. Every navigation to userProfilePage gets the INSTANT transition (as the
//     navbar), instead of the default slide.
//  2. Queries wrapping a page header show the header image while loading
//     (loading widget = image, full width, header height) instead of an empty
//     transparent loader: profile (games + users), organisation, play payment.
//  3. PlayPage / PlayPaymentPage guards (body built only when game / gamePage is
//     set) show the Wallet header while the state is not set yet.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.firstframe.$seed');

// page -> [query node, header node]
const loaders = [
  ['userProfilePage', 'Container_vja259xs', 'Container_qob8t7pt'],
  ['userProfilePage', 'Container_iupbs9op', 'Container_qob8t7pt'],
  ['OrganisationPage', 'Stack_684vqsr2', 'Container_utx0s0n1'],
  ['PlayPaymentPage', 'Stack_708o4kk0', 'Container_e61bz945'],
];

final class FirstFrameHeaders extends FlutterFlowAITask {
  @override
  String get name => 'gg-first-frame-headers';
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

  // Header image as an FFImage (full width, the header's min height).
  Map<String, dynamic> headerImage(Map<String, dynamic> header) {
    final c = header['props']['container'] as Map<String, dynamic>;
    final img = jsonDecode(jsonEncode(c['boxDecoration']['image'])) as Map<String, dynamic>;
    final h = c['minDimensions']?['height']?['pixelsValue']?['inputValue'];
    img['dimensions'] = {
      'width': {'pixelsValue': {'inputValue': 'Infinity'}},
      'height': {'pixelsValue': {'inputValue': h}},
    };
    return img;
  }

  // A plain container painting the header (same decoration, no children).
  Map<String, dynamic> headerPlaceholder(Map<String, dynamic> header, String seed) {
    final c = jsonDecode(jsonEncode(header['props']['container'])) as Map<String, dynamic>;
    return {'key': 'Container_${key(seed)}', 'type': 'Container', 'props': {'container': c}};
  }

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    final profileKey = p.widgetClasses.values.firstWhere((w) => w.name == 'userProfilePage').node.key;
    final edits = <String, void Function(Map<String, dynamic>)>{};
    void edit(String cls, void Function(Map<String, dynamic>) f) {
      final prev = edits[cls];
      edits[cls] = prev == null ? f : (w) {
        prev(w);
        f(w);
      };
    }

    // 1. Instant transitions to the profile (all classes).
    for (final w in p.widgetClasses.values) {
      if (!jsonEncode(w.toProto3Json()).contains('"$profileKey"')) continue;
      edit(w.name, (j) {
        var n = 0;
        void walk(dynamic x) {
          if (x is Map) {
            final nav = x['navigate'];
            if (nav is Map && nav['pageNodeKeyRef']?['key'] == profileKey && nav['transition'] == null) {
              nav['transition'] = {'transitionType': 'INSTANT'};
              n++;
            }
            x.values.forEach(walk);
          } else if (x is List) {
            x.forEach(walk);
          }
        }
        walk(j);
        if (n > 0) report.add('${w.name}: $n navigation(s) to the profile -> INSTANT');
      });
    }

    // 2. Loading widgets = header image.
    for (final l in loaders) {
      edit(l[0], (j) {
        final q = find(j['node'], l[1]) ?? (throw StateError('${l[0]}/${l[1]} not found'));
        final header = find(j['node'], l[2]) ?? (throw StateError('${l[0]}/${l[2]} not found'));
        if (q['databaseRequest'] == null) throw StateError('${l[1]} has no query');
        (q['props'] as Map)['queryLoadingWidget'] = {
          'loadingWidget': {'image': headerImage(header)},
        };
        report.add('${l[0]}/${l[1]}: loading widget = header image');
      });
    }

    // 3a. PlayPage guard: else branch shows the header.
    edit('PlayPage', (j) {
      final body = (j['node']['children'] as List).single as Map<String, dynamic>;
      if (body['type'] != 'ConditionalBuilder') throw StateError('PlayPage body is not the guard');
      final header = find(j['node'], 'Container_cv5aa3iw')!;
      final elseBranch = (body['children'] as List)[1] as Map<String, dynamic>;
      elseBranch['children'] = [headerPlaceholder(header, 'play.else')];
      report.add('PlayPage: guard else -> Wallet header');
    });

    // 3b. PlayPaymentPage guard: visibility -> ConditionalBuilder with the header.
    edit('PlayPaymentPage', (j) {
      final root = j['node'] as Map<String, dynamic>;
      final body = (root['children'] as List).single as Map<String, dynamic>;
      final vis = body['props']?['visibility'];
      if (vis == null || !jsonEncode(vis).contains('gamePage')) throw StateError('PlayPaymentPage guard not found');
      (body['props'] as Map).remove('visibility');
      final header = find(root, 'Container_e61bz945')!;
      final wrapper = {
        'key': 'ConditionalBuilder_${key('pay.builder')}',
        'type': 'ConditionalBuilder',
        'props': {'conditionalBuilder': {}},
        'children': [
          {
            'key': 'PlaceholderWidget_${key('pay.if')}',
            'type': 'PlaceholderWidget',
            'props': {'placeholderWidget': {}, 'visibility': vis},
            'children': [body],
          },
          {
            'key': 'PlaceholderWidget_${key('pay.else')}',
            'type': 'PlaceholderWidget',
            'props': {'placeholderWidget': {}, 'visibility': {'visibleValue': {'mostRecentInputValue': false}}},
            'children': [headerPlaceholder(header, 'pay.header')],
          },
        ],
      };
      root['children'] = [wrapper];
      for (final r in (root['childPropertyMap']?['body']?['keyRefs'] as List? ?? [])) {
        if (r['key'] == body['key']) r['key'] = wrapper['key'];
      }
      report.add('PlayPaymentPage: guard -> ConditionalBuilder, else Wallet header');
    });

    for (final cls in edits.keys) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      edits[cls]!(w);
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [FirstFrameHeaders()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Instant profile transition; header instead of white while loading',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
