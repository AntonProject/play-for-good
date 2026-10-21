// Run inside the FlutterFlow AI workspace. Dry-run by default.
// Security / data fixes from docs/modernization/ASSESSMENT.md (19.10.2026,
// owner decisions), ONE FlutterFlow commit:
//  1 API calls that call Stripe directly with a secret key in their headers
//    (StripeAccInfo*, StripeAccPerson*; leftovers of the admin Stripe Connect
//    work, never called) are deleted. Refuses if anything references them.
//    The Stripe key itself must be rolled in the Stripe dashboard (owner).
//  2 PlayPaymentPage game insert: 'sieg_money' got the win POINTS and
//    'sieg_points' the win MONEY (swapped). The values are put right.
//    16_check_sieg.sql: no stored game is affected (rate was never 0).
//  3 transfer.dart (rpc): auth actions log nothing sensitive (no password /
//    OTP code; other logs debug builds only), orgsCount counts `organization`.
// Copy into dsl/ as gg_security_fixes.dart next to gg_transfer.dart.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

final secretKey = RegExp(r'sk_(test|live)_[A-Za-z0-9]+');

final class SecurityFixes extends FlutterFlowAITask {
  @override
  String get name => 'gg-security-fixes';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];

    // 1 Stripe API calls with a secret key
    final api = p.backend.apiConfig;
    bool hasKey(FFApiEndpoint e) => secretKey.hasMatch(jsonEncode(e.toProto3Json()));
    final doomed = <FFApiEndpoint>[
      ...api.endpoints.where(hasKey),
      for (final g in api.apiGroups) ...g.endpoints.where(hasKey),
    ];
    final doomedKeys = {for (final e in doomed) e.identifier.key};
    if (doomedKeys.isNotEmpty) {
      // References anywhere else in the project (pages, components, actions).
      final refs = <String>[];
      final everything = jsonEncode({
        'widgets': [for (final w in p.widgetClasses.values) w.toProto3Json()],
        'customCode': p.customCode.toProto3Json(),
        'appState': p.appState.toProto3Json(),
      });
      for (final e in doomed) {
        if (everything.contains('"${e.identifier.key}"')) refs.add(e.identifier.name);
      }
      if (refs.isNotEmpty) throw StateError('API calls still referenced: ${refs.join(', ')}');
      api.endpoints.removeWhere((e) => doomedKeys.contains(e.identifier.key));
      for (final g in api.apiGroups) {
        g.endpoints.removeWhere((e) => doomedKeys.contains(e.identifier.key));
      }
      api.legacyEndpoints.removeWhere((k, e) => doomedKeys.contains(e.identifier.key));
      report.add('API calls with a Stripe secret key deleted: ${doomed.map((e) => e.identifier.name).join(', ')}');
    }
    if (secretKey.hasMatch(jsonEncode(p.backend.apiConfig.toProto3Json()))) {
      throw StateError('a Stripe secret key is still in the API config');
    }

    // 2 sieg_money / sieg_points swap in game inserts
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'PlayPaymentPage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    var swapped = 0;
    void walk(dynamic x) {
      if (x is Map) {
        final pa = x['postgresAction'];
        if (pa is Map && pa['tableIdentifier']?['name'] == 'games' && pa.containsKey('insert')) {
          final ups = ((pa['data']?['updates'] as List?) ?? []).cast<Map>();
          final money = ups.where((u) => u['fieldIdentifier']?['name'] == 'sieg_money').firstOrNull;
          final points = ups.where((u) => u['fieldIdentifier']?['name'] == 'sieg_points').firstOrNull;
          if (money != null && points != null &&
              jsonEncode(money['value']).contains('"siegPoints"') &&
              jsonEncode(points['value']).contains('"siegMoney"')) {
            final v = money['value'];
            money['value'] = points['value'];
            points['value'] = v;
            swapped++;
          }
        }
        x.values.forEach(walk);
      } else if (x is List) {
        x.forEach(walk);
      }
    }
    walk(w);
    if (swapped > 0) {
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      report.add('PlayPaymentPage: games insert sieg_money <- siegMoney, sieg_points <- siegPoints x$swapped');
    }
    stdout.writeln(report.isEmpty ? 'nothing to change' : report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-security-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [SecurityFixes(), RegisterGgCode(root, 'rpc', reports)],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Security: no Stripe secret key in API calls, no sensitive logs; '
        'sieg money / points stored right; orgsCount table',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
