// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 21.10.2026, owner: a "TEST" mark so a test build is recognised at a glance;
// the production build shows nothing.
// apbarBG (red header of Home, Good News, Energy): a small white pill with a
// red "TEST" between the title and the avatar. Visible only when the
// environment value `test` is true (FFDevEnvironmentValues().test), so the
// Production environment never shows it.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.testbadge.$seed');

final class TestEnvBadge extends FlutterFlowAITask {
  @override
  String get name => 'gg-test-env-badge';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final env = {
      'source': 'DEV_ENVIRONMENT',
      'baseVariable': {
        'environmentValue': {
          'identifier': (findEnvironmentValue(p, 'test') ?? (throw StateError('environment value test missing')))
              .parameter
              .identifier
              .toProto3Json(),
        }
      },
    };
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'apbarBG');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final badgeKey = 'Container_${key('container')}';
    if (jsonEncode(w).contains(badgeKey)) {
      stdout.writeln('apbarBG: TEST badge already there');
      return;
    }
    Map<String, dynamic>? row;
    void find(Map<String, dynamic> n) {
      if (row != null) return;
      if (n['type'] == 'Row') {
        row = n;
        return;
      }
      for (final c in (n['children'] as List? ?? [])) find(c as Map<String, dynamic>);
    }
    find(w['node'] as Map<String, dynamic>);
    final children = (row ?? (throw StateError('apbarBG: header Row not found')))['children'] as List;
    if (children.length != 2 || children[0]['type'] != 'Column') {
      throw StateError('apbarBG: unexpected header Row (${children.map((c) => c['type']).toList()})');
    }
    Map<String, dynamic> pad(num l, num t, num r, num b) => {
          'type': 'FF_PADDING_ONLY',
          'leftValue': {'inputValue': l},
          'topValue': {'inputValue': t},
          'rightValue': {'inputValue': r},
          'bottomValue': {'inputValue': b},
        };
    final badge = {
      'key': badgeKey,
      'type': 'Container',
      'props': {
        'container': {
          'boxDecoration': {
            'colorValue': {
              'inputValue': {'themeColor': 'PRIMARY_BACKGROUND'}
            },
            'borderRadius': {
              'topLeftValue': {'inputValue': 99},
              'topRightValue': {'inputValue': 99},
              'bottomLeftValue': {'inputValue': 99},
              'bottomRightValue': {'inputValue': 99},
            },
          },
        },
        'padding': pad(0, 0, 8, 0),
        'visibility': {
          'visibleValue': {'variable': env}
        },
      },
      'children': [
        {
          'key': 'Text_${key('text')}',
          'type': 'Text',
          'props': {
            'text': {
              'themeStyle': 'BODY_SMALL',
              'translationIdentifier': {'key': key('translation').substring(0, 8).toLowerCase()},
              'selectable': false,
              'textValue': {'inputValue': 'TEST'},
              'colorValue': {
                'inputValue': {'themeColor': 'PRIMARY'}
              },
              'fontSizeValue': {'inputValue': 12},
              'fontWeightValue': {'inputValue': 'w700'},
            },
            'padding': pad(10, 4, 10, 4),
          },
        }
      ],
    };
    children.insert(1, badge);
    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('apbarBG: TEST badge (visible when environment value test = true)');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [TestEnvBadge()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Header: TEST badge in the test environment',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
