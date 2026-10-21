// Run inside the FlutterFlow AI workspace. Dry-run by default.
// 20.10.2026, tester (Android, new build): as a guest, opening the profile and
// signing in within 7 s of Home: the guest welcome sheet (DeinStart, "points
// for new users") popped up over the sign-in dialog and dropped the user back
// to "Mein Profil" (the first OTP was already sent -> two codes by email).
// HomePage On Load: guest + no welcome yet -> wait 7 s -> show DeinStart ->
// hasGuestGetLichtwatt = true. Nothing was checked after the 7 s.
// Now after the wait: ggWaitUntilOnTop(context, 1800) (Home is the top route
// again: no dialog / page above) and then the same condition again (still a
// guest, still no welcome). A guest who went to the profile sees the welcome
// when back on Home; a user who signed in meanwhile does not see it.
// ONE commit: transfer.dart (rpc: registers ggWaitUntilOnTop; also the period
// functions with the fixed seasons 2025/26 and 2026/27) + this change.
// Copy into dsl/ as gg_home_welcome_on_top.dart next to gg_transfer.dart.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.welcome.$seed');

final class HomeWelcomeOnTop extends FlutterFlowAITask {
  @override
  String get name => 'gg-home-welcome-on-top';
  @override
  Set<String> get dependsOn => {'register-gg-rpc'};
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final wait = findCustomAction(p, name: 'ggWaitUntilOnTop') ??
        (throw StateError('ggWaitUntilOnTop missing (transfer first)'));
    final maxArg = wait.arguments.firstWhere((a) => a.identifier.name == 'maxSeconds');
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'HomePage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final load = ((w['node']['triggerActions'] as List)
        .firstWhere((t) => t['trigger']['triggerType'] == 'ON_INIT_STATE'))['rootAction'];

    // The welcome branch: IF (no welcome AND guest) { wait -> DeinStart -> flag }.
    Map? branch;
    void find(dynamic x) {
      if (branch != null) return;
      if (x is Map) {
        final ca = x['conditionActions'];
        if (ca is Map) {
          final t = (ca['trueActions'] as List?)?.firstOrNull;
          final s = jsonEncode(t?['condition'] ?? {});
          final first = t?['trueAction'];
          if (s.contains('"hasGuestGetLichtwatt"') && s.contains('IS_USER_LOGGED_IN') &&
              first is Map && first['action']?['waitAction'] != null &&
              (first['followUpAction'] as Map?)?['action']?['bottomSheet'] != null) {
            branch = x;
            return;
          }
        }
        x.values.forEach(find);
      } else if (x is List) {
        x.forEach(find);
      }
    }
    find(load);
    if (branch == null) {
      if (jsonEncode(load).contains('"ggWaitUntilOnTop"')) {
        stdout.writeln('HomePage: welcome already waits for Home on top');
        return;
      }
      throw StateError('HomePage: welcome branch not found');
    }
    final t = (branch!['conditionActions']['trueActions'] as List).first as Map;
    final condition = jsonDecode(jsonEncode(t['condition']['variable'])) as Map<String, dynamic>;
    final waitNode = t['trueAction'] as Map;
    final sheetChain = waitNode['followUpAction'] as Map; // DeinStart -> flag

    final checkKey = key('check.action');
    waitNode['followUpAction'] = {
      'key': key('check.node'),
      'action': {
        'key': checkKey,
        'customAction': {
          'customActionIdentifier': {'name': wait.identifier.name, 'key': wait.identifier.key},
          'argumentValues': {
            'arguments': {
              maxArg.identifier.key: {
                'value': {'inputValue': {'serializedValue': '1800'}}
              }
            }
          },
        },
        'outputVariableName': 'ggHomeOnTop',
      },
      'followUpAction': {
        'key': key('gate.node'),
        'conditionActions': {
          'key': key('gate.cond'),
          'trueActions': [
            {
              'condition': {
                'variable': {
                  'source': 'FUNCTION_CALL',
                  'functionCall': {
                    'combineConditions': {'operator': 'AND_OP'},
                    'values': [
                      {
                        'variable': {
                          'source': 'FUNCTION_CALL',
                          'functionCall': {
                            'values': [
                              {
                                'variable': {
                                  'source': 'ACTION_OUTPUTS',
                                  'baseVariable': {
                                    'actionOutput': {
                                      'outputVariableIdentifier': {'name': 'ggHomeOnTop'},
                                      'actionKeyRef': {'key': checkKey},
                                    }
                                  },
                                  'nodeKeyRef': {'key': w['node']['key']},
                                }
                              },
                              {'inputValue': {'serializedValue': 'true'}},
                            ],
                            'condition': {'relation': 'EQUAL_TO'},
                          },
                        }
                      },
                      // still no welcome AND still a guest (the original AND, flattened)
                      ...((condition['functionCall']?['combineConditions'] != null)
                          ? (condition['functionCall']['values'] as List)
                          : [
                              {'variable': condition}
                            ]),
                    ],
                  },
                }
              },
              'trueAction': sheetChain,
            }
          ],
        },
      },
    };

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('HomePage: welcome sheet only when Home is on top and still a guest');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-welcome-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports), HomeWelcomeOnTop()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Home welcome sheet does not interrupt sign-in; seasons 2025/26 and 2026/27 always offered',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
