// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Payment flow fixes (16.10.2026, found on the simulator; customer's original
// code, fixed on the owner's request):
//  1 PlayPaymentPage loader before Stripe: CustomCircularProgressIndicator
//    120x120, stroke 12 -> 40x40, stroke 4.
//  2 chosen_org was "cleared" with '' (users.chosen_org is uuid): the update
//    failed with 22P02 `invalid input syntax for type uuid: ""`. organisationListPlay
//    (tap on the chosen organisation again): '' -> NULL.
//  3 PlayPaymentPage, after signing in from the guest flow: when the saved
//    organisation equals the one the guest chose, it was "cleared" ('') instead
//    of kept. Now the guest's organisation is written in both branches.
//  4 PlayPaymentPage: every users update of first_name / surname (7 places) ran
//    with the form fields; after signing in on this page the fields stayed empty
//    (filled once from the guest's empty row) and wiped the name. The updates
//    now run only when both fields are not empty.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.payfix.$seed');

const loaderKey = 'Container_dsg20k1n';
const nullValue = {
  'variable': {
    'source': 'CONSTANTS',
    'baseVariable': {'constants': {'value': 'NULL'}},
  }
};

bool isEmptyInput(dynamic v) =>
    v is Map && v.length == 1 && v['inputValue'] is Map && ((v['inputValue'] as Map)['serializedValue'] ?? '') == '';

final class PaymentFixes extends FlutterFlowAITask {
  @override
  String get name => 'gg-payment-fixes';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];

    void edit(String cls, void Function(Map<String, dynamic> w) change) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls,
          orElse: () => throw StateError('$cls not found'));
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      final before = jsonEncode(w);
      change(w);
      if (jsonEncode(w) == before) return;
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }

    // Updates of users.chosen_org: (update map, the users update) pairs.
    List<Map> chosenOrgUpdates(dynamic x) {
      final out = <Map>[];
      void walk(dynamic n) {
        if (n is Map) {
          final pa = n['postgresAction'];
          if (pa is Map && pa['tableIdentifier']?['name'] == 'users') {
            for (final u in ((pa['data']?['updates'] as List?) ?? [])) {
              if (u['fieldIdentifier']?['name'] == 'chosen_org') out.add(u as Map);
            }
          }
          n.values.forEach(walk);
        } else if (n is List) {
          n.forEach(walk);
        }
      }
      walk(x);
      return out;
    }

    // 2 organisationListPlay: '' -> NULL
    edit('organisationListPlay', (w) {
      var n = 0;
      for (final u in chosenOrgUpdates(w)) {
        if (isEmptyInput(u['value'])) {
          u['value'] = jsonDecode(jsonEncode(nullValue));
          n++;
        }
      }
      report.add('organisationListPlay: chosen_org \'\' -> NULL x$n');
    });

    edit('PlayPaymentPage', (w) {
      // 1 loader
      Map? find(dynamic x, String k) {
        if (x is Map) {
          if (x['key'] == k && x.containsKey('type')) return x;
          for (final v in x.values) {
            final r = find(v, k);
            if (r != null) return r;
          }
        } else if (x is List) {
          for (final v in x) {
            final r = find(v, k);
            if (r != null) return r;
          }
        }
        return null;
      }
      final loader = find(w['node'], loaderKey) ?? (throw StateError('$loaderKey not found'));
      final passes = loader['parameterValues']['parameterPasses'] as Map;
      Map pass(String name) => passes.values.firstWhere((x) => x['paramIdentifier']['name'] == name);
      final dims = pass('dimensions')['widgetProperty']['dimensions'] as Map;
      if (dims['width']['pixelsValue']['inputValue'] != 40) {
        dims['width']['pixelsValue']['inputValue'] = 40;
        dims['height']['pixelsValue']['inputValue'] = 40;
        pass('strokeWidth')['inputValue'] = {'serializedValue': '4.0'};
        report.add('PlayPaymentPage: loader 40x40, stroke 4');
      }

      // 3 keep the guest's organisation after signing in
      final orgUpdates = chosenOrgUpdates(w);
      final guestValue = orgUpdates.firstWhere(
          (u) => jsonEncode(u['value']).contains('"guestChosenOrgId"'),
          orElse: () => throw StateError('PlayPaymentPage: guestChosenOrgId update not found'))['value'];
      var kept = 0;
      for (final u in orgUpdates) {
        if (isEmptyInput(u['value'])) {
          u['value'] = jsonDecode(jsonEncode(guestValue));
          kept++;
        }
      }
      report.add('PlayPaymentPage: chosen_org \'\' -> guestChosenOrgId x$kept');

      // 4 names only when both fields are filled
      var guarded = 0;
      Map<String, dynamic> notEmpty(dynamic v) => {
            'source': 'FUNCTION_CALL',
            'functionCall': {
              'values': [
                {'variable': jsonDecode(jsonEncode(v))},
                {'inputValue': {}},
              ],
              'condition': {'relation': 'NOT_EQUAL_TO'},
            },
          };
      dynamic wrap(dynamic n) {
        if (n is Map) {
          for (final k in n.keys.toList()) {
            n[k] = wrap(n[k]);
          }
          final pa = n['action']?['database']?['postgresAction'];
          if (pa is Map && pa['tableIdentifier']?['name'] == 'users') {
            final ups = (pa['data']?['updates'] as List?) ?? [];
            final first = ups.where((u) => u['fieldIdentifier']?['name'] == 'first_name').firstOrNull;
            final sur = ups.where((u) => u['fieldIdentifier']?['name'] == 'surname').firstOrNull;
            if (first != null && sur != null) {
              final node = n as Map<String, dynamic>;
              guarded++;
              return {
                'key': node['key'],
                'conditionActions': {
                  'trueActions': [
                    {
                      'condition': {
                        'variable': {
                          'source': 'FUNCTION_CALL',
                          'functionCall': {
                            'combineConditions': {'operator': 'AND_OP'},
                            'values': [
                              {'variable': notEmpty(first['value']['variable'])},
                              {'variable': notEmpty(sur['value']['variable'])},
                            ],
                          },
                        }
                      },
                      'trueAction': {'key': key('names.${node['key']}'), 'action': node['action']},
                    }
                  ],
                },
                if (node['followUpAction'] != null) 'followUpAction': node['followUpAction'],
              };
            }
          }
          return n;
        }
        if (n is List) {
          for (var i = 0; i < n.length; i++) {
            n[i] = wrap(n[i]);
          }
        }
        return n;
      }
      wrap(w);
      report.add('PlayPaymentPage: first_name/surname updates only when filled x$guarded');
    });

    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [PaymentFixes()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Payment: 40px loader, chosen_org NULL / kept after sign-in, names not wiped',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
