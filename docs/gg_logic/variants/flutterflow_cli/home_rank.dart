// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Home (homePageScore): the place chip uses the same server ranking as Good
// Games / profile: ggV2Rankings(period, 'valuable', 1, 1, uid, test) -> ggPlace.
// Adds state ggHomeRank, a refresh block, an On Init trigger and a refresh
// after the period dropdown. Old text stays as fallback until the JSON loads.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const scope = 'homePageScore';
const rankText = 'Text_lugykmtr';
const dropdown = 'DropDown_52vp243b';
String key(String seed) => generateRandomAlphaNumericString(seedString: 'pfg.gg.home.$seed');

final class HomeRank extends FlutterFlowAITask {
  @override
  String get name => 'gg-home-rank';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == scope);
    final json = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    final root = json['node'] as Map<String, dynamic>;
    final fields = ((json['classModel'] as Map)['stateFields'] as List);
    if (fields.any((f) => f['parameter']['identifier']['name'] == 'ggHomeRank')) {
      throw StateError('ggHomeRank already exists');
    }
    final stateIdent = {'name': 'ggHomeRank', 'key': key('state')};
    fields.add({
      'parameter': {'identifier': stateIdent, 'dataType': {'scalarType': 'JSON', 'nonNullable': true}},
      'serializedDefaultValue': ['{}'],
    });
    Map<String, dynamic> stateVar() => {
          'source': 'LOCAL_STATE',
          'baseVariable': {
            'localState': {'fieldIdentifier': stateIdent, 'stateVariableType': 'WIDGET_CLASS_STATE'}
          },
          'nodeKeyRef': {'key': root['key']},
        };
    Map<String, dynamic> fn(String name, List<Map<String, dynamic>> values) => {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'customFunction': findCustomFunction(p, name: name)!.identifier.toProto3Json(),
            'values': values,
          },
        };
    // Rank text: "#<ggPlace>" when loaded, the old client value otherwise.
    Map<String, dynamic>? text;
    void find(Map<String, dynamic> n) {
      if (n['key'] == rankText) text = n;
      for (final c in (n['children'] as List? ?? [])) find(c as Map<String, dynamic>);
    }
    find(root);
    final tv = ((text!['props'] as Map)['text'] as Map)['textValue'] as Map<String, dynamic>;
    final old = Map<String, dynamic>.from(tv);
    tv
      ..clear()
      ..['variable'] = {
        'source': 'FUNCTION_CALL',
        'functionCall': {
          'conditionalValue': {
            'ifConditionalValues': [
              {
                'condition': fn('ggHasData', [{'variable': stateVar()}]),
                'value': {
                  'variable': {
                    'source': 'FUNCTION_CALL',
                    'functionCall': {
                      'stringInterpolation': {},
                      'values': [
                        {'inputValue': {'serializedValue': '#'}},
                        {'variable': fn('ggPlace', [{'variable': stateVar()}])},
                      ],
                    },
                  },
                },
              }
            ],
            'elseValue': old,
            'returnParameter': {'dataType': {'scalarType': 'String', 'nonNullable': true}},
          },
        },
      };
    final next = FFWidgetClass()..mergeFromProto3Json(json);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;

    // Refresh block: ranking for the selected Home period (MVP).
    final w = p.widgetClasses[entry.key]!;
    final period = varFromPageState(w.classModel.stateFields
        .firstWhere((f) => f.parameter.identifier.name == 'periodState')
        .parameter
        .identifier)
      ..nodeKeyRef = FFNodeKeyReference(key: w.node.key);
    final test = varFromEnvironmentSecret('test')
      ..baseVariable.environmentValue.identifier =
          findEnvironmentValue(p, 'test')!.parameter.identifier;
    final action = findCustomAction(p, name: 'ggV2Rankings')!;
    final values = FFFunctionCallValues();
    FFValue lit(Object v) => FFValue(inputValue: FFParameterValue(serializedValue: '$v'));
    final args = <String, FFValue>{
      'period': FFValue(variable: FFVariable(
          source: FFVariableSource.FUNCTION_CALL,
          functionCall: FFFunctionCall(
              customFunction: findCustomFunction(p, name: 'ggPeriodKey')!.identifier,
              values: [FFValue(variable: period)]))),
      'category': lit('valuable'),
      'page': lit(1),
      'pageSize': lit(1),
      'userId': FFValue(variable: varFromSupabaseAuthUser(FFAuthVariable_AuthProperty.USER_ID)),
      'test': FFValue(variable: test),
    };
    for (final a in action.arguments) {
      values.arguments[a.identifier.key] = FFFunctionCallValues_FFArgument(value: args[a.identifier.name]!);
    }
    final actionKey = key('action');
    final callNode = FFActionNode(
        key: key('node'),
        action: FFAction(
            key: actionKey,
            customAction: FFCustomActionCall(customActionIdentifier: action.identifier, argumentValues: values),
            outputVariableName: 'ggHomeRankOut'));
    callNode.followUpAction = FFActionNode(
        key: key('set'),
        action: Actions.updatePageState(p, widgetClassName: scope, updates: [
          StateFieldUpdate.setFromVariable(
              'ggHomeRank', varFromActionOutput(actionKey: actionKey, outputName: 'ggHomeRankOut')),
        ]));
    final block = addActionBlock(p,
        name: 'ggRefreshHomeRank',
        rootAction: callNode,
        widgetClass: w,
        description: 'Home place via ranking RPC (same place as Good Games/profile).',
        identifier: FFIdentifier(name: 'ggRefreshHomeRank', key: key('block')));
    var n = 0;
    FFActionNode refresh() {
      final node = FFActionNode(
          key: key('refresh${n++}'),
          action: Actions.executeActionBlock(p, actionBlockName: block.name, widgetClass: w));
      node.action.executeActionComponent.shouldSetState = true;
      return node;
    }
    // On Init of the component.
    w.node.triggerActions.add(FFTriggerActions()
      ..mergeFromProto3Json({'trigger': {'triggerType': 'ON_INIT_STATE'}})
      ..rootAction = refresh());
    // After the period dropdown changed periodState.
    void attach(FFNode node) {
      if (node.key == dropdown) {
        for (final t in node.triggerActions) {
          var tail = t.rootAction;
          while (tail.hasFollowUpAction()) tail = tail.followUpAction;
          tail.followUpAction = refresh();
        }
      }
      for (final c in node.children) attach(c);
    }
    attach(w.node);
    stdout.writeln('Home rank: state + block + $n refresh points.');
    if (n < 2) throw StateError('Dropdown trigger not found');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [HomeRank()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Home: place from the ranking RPC (ggPlace)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
