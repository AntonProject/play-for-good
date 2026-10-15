// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// +100 only for a registration that started as a guest (05_guest_signup_bonus.sql):
//  * signInAfterOtpVerification gets a new argument `fromGuest` (bool, nullable)
//    and its code from 02_rpc/flutterflow/legacy_env (claims the bonus only when
//    fromGuest is true and actionType is 'signup');
//  * authDialog (the guest registration/login dialog) passes true;
//  * Confirm and ConfirmAdmin (the regular signup / admin login) pass false.
// After this, transfer.dart (code_only for this action) keeps the new argument.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const actionName = 'signInAfterOtpVerification';
const argName = 'fromGuest';
const calls = {'authDialog': 'true', 'Confirm': 'false', 'ConfirmAdmin': 'false'};
final sourceFile = '${Platform.environment['GG_VARIANTS_ROOT'] ?? '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants'}'
    '/02_rpc/flutterflow/legacy_env/sign_in_after_otp_verification.dart';

final class GuestSignupFlag extends FlutterFlowAITask {
  @override
  String get name => 'gg-guest-signup-flag';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final action = findCustomAction(p, name: actionName) ?? (throw StateError('$actionName missing'));
    final code = File(sourceFile).readAsStringSync();
    if (!code.contains('bool? fromGuest')) throw StateError('source has no fromGuest argument');
    var arg = action.arguments.where((a) => a.identifier.name == argName).firstOrNull;
    if (arg == null) {
      final json = jsonDecode(jsonEncode(action.arguments.last.toProto3Json())) as Map<String, dynamic>;
      json['identifier'] = {
        'name': argName,
        'key': generateRandomAlphaNumericString(seedString: 'pfg.gg.v2.$actionName.$argName'),
      };
      json['dataType'] = {'scalarType': 'Boolean', 'nonNullable': false};
      arg = FFParameter()..mergeFromProto3Json(json);
      updateCustomAction(p, name: actionName, code: code, arguments: [...action.arguments, arg]);
    } else {
      updateCustomAction(p, name: actionName, code: code);
    }
    final argKey = arg.identifier.key;
    final actionKey = action.identifier.key;
    for (final MapEntry(key: className, value: flag) in calls.entries) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == className);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      var changed = 0;
      void walk(Object? n) {
        if (n is Map) {
          final ca = n['customAction'];
          if (ca is Map && (ca['customActionIdentifier'] as Map?)?['key'] == actionKey) {
            final values = (ca['argumentValues'] ??= <String, dynamic>{}) as Map;
            final args = (values['arguments'] ??= <String, dynamic>{}) as Map;
            args[argKey] = {
              'value': {
                'inputValue': {'serializedValue': flag}
              }
            };
            changed++;
          }
          n.values.forEach(walk);
        } else if (n is List) {
          n.forEach(walk);
        }
      }
      walk(w['node']);
      if (changed == 0) throw StateError('$className: no $actionName call');
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      stdout.writeln('$className: $actionName(..., $argName: $flag) x$changed');
    }
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [GuestSignupFlag()],
    source: PipelineSource.paths([Platform.script.toFilePath(), sourceFile]),
    commitMessage: 'Signup: +100 only for registrations from the guest dialog',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
