// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Device cache (stale-while-revalidate) for the RPC screens. In every refresh
// block each RPC call becomes:
//   [state empty?  -> state = ggCacheGet(cache, key)]  (instant, updatePage)
//   -> RPC call -> cache = ggCachePut(cache, key, response) -> state = response
// Caches are persisted App State JSON fields (one per response kind), keyed by
// the request parameters (period, category, page, environment, user).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';

class Spec {
  const Spec(this.state, this.cache, this.prefix, this.parts, {this.user = true});
  final String state; // page/component state set from the response
  final String cache; // persisted App State field
  final String prefix;
  final List<String> parts; // state fields or 'param:<name>'
  final bool user;
}

const specs = {
  'GoodGamesPage': {
    'ggV2Rankings': Spec('ggRanking', 'ggCacheRanking', 'r', ['periodPageUser', 'valuePageUser', 'pageNumberUsers']),
    'ggV2ProfileStats': Spec('ggMyStats', 'ggCacheStats', 's', ['periodPageGame']),
    'ggV2Games': Spec('ggHistory', 'ggCacheHistory', 'h', ['periodPageGame', 'valuePageGame', 'pageNumberGames']),
  },
  'userProfilePage': {
    'ggV2ProfileStats': Spec('ggProfile', 'ggCacheProfile', 'p', ['param:userId', 'infoStatsPeriod'], user: false),
    'ggV2Rankings': Spec('ggGuest', 'ggCacheGuest', 'g', [], user: false),
  },
  'userProfile': {
    'ggV2ProfileStats': Spec('ggProfile', 'ggCacheProfile', 'p', ['param:userId', 'infoStatsPeriod'], user: false),
    'ggV2Rankings': Spec('ggGuest', 'ggCacheGuest', 'g', [], user: false),
  },
  'homePageScore': {
    'ggV2Rankings': Spec('ggHomeRank', 'ggCacheHome', 'm', ['periodState']),
  },
};
const blocks = {
  'GoodGamesPage': 'ggRefreshGoodGames',
  'userProfilePage': 'ggRefreshProfile',
  'userProfile': 'ggRefreshProfile',
  'homePageScore': 'ggRefreshHomeRank',
};

final class DeviceCache extends FlutterFlowAITask {
  @override
  String get name => 'gg-device-cache';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    for (final f in {for (final s in specs.values) for (final x in s.values) x.cache}) {
      ensureAppStateField(p,
          name: f,
          type: FFDataTypeV2(scalarType: FFBaseDataType.JSON),
          description: 'Good Games v2 device cache (request key -> last response).',
          persisted: true,
          defaultValue: '{}');
    }
    final appField = {
      for (final f in p.appState.fields) f.parameter.identifier.name: f.parameter.identifier
    };
    FFVariable fv(Map<String, dynamic> j) => FFVariable()..mergeFromProto3Json(j);
    Map<String, dynamic> fn(String n, List<Map<String, dynamic>> values) => {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'customFunction': findCustomFunction(p, name: n)!.identifier.toProto3Json(),
            'values': values,
          },
        };
    final env = {
      'source': 'DEV_ENVIRONMENT',
      'baseVariable': {
        'environmentValue': {'identifier': findEnvironmentValue(p, 'test')!.parameter.identifier.toProto3Json()}
      },
    };
    final uid = {'source': 'SUPABASE_AUTH_USER', 'baseVariable': {'auth': {'property': 'USER_ID'}}};
    final report = <String>[];

    for (final scope in specs.keys) {
      final w = p.widgetClasses.values.firstWhere((w) => w.name == scope);
      final root = w.node.key;
      Map<String, dynamic> local(String n) => {
            'source': 'LOCAL_STATE',
            'baseVariable': {
              'localState': {
                'fieldIdentifier': w.classModel.stateFields
                    .firstWhere((f) => f.parameter.identifier.name == n)
                    .parameter
                    .identifier
                    .toProto3Json(),
                'stateVariableType': 'WIDGET_CLASS_STATE',
              }
            },
            'nodeKeyRef': {'key': root},
          };
      Map<String, dynamic> param(String n) => {
            'source': 'WIDGET_CLASS_PARAMETER',
            'baseVariable': {
              'widgetClass': {
                'paramIdentifier': w.params.values.firstWhere((x) => x.identifier.name == n).identifier.toProto3Json()
              }
            },
            'nodeKeyRef': {'key': root},
          };
      Map<String, dynamic> app(String n) => {
            'source': 'LOCAL_STATE',
            'baseVariable': {
              'localState': {'fieldIdentifier': appField[n]!.toProto3Json(), 'stateVariableType': 'APP_STATE'}
            },
          };
      Map<String, dynamic> keyVar(Spec s) {
        final values = <Map<String, dynamic>>[
          {'inputValue': {'serializedValue': '${s.prefix}|'}}
        ];
        for (final part in s.parts) {
          values.add({'variable': part.startsWith('param:') ? param(part.substring(6)) : local(part)});
          values.add({'inputValue': {'serializedValue': '|'}});
        }
        values.add({'variable': env});
        if (s.user) {
          values.add({'inputValue': {'serializedValue': '|'}});
          values.add({'variable': uid});
        }
        return {'source': 'FUNCTION_CALL', 'functionCall': {'stringInterpolation': {}, 'values': values}};
      }

      final block = w.classModel.actionComponentsConfig.actionComponents
          .firstWhere((c) => c.identifier.name == blocks[scope]);
      if (jsonEncode(block.toProto3Json()).contains('ggCacheGet')) throw StateError('$scope already cached');
      FFActionNode wrap(FFActionNode n) {
        if (n.hasParallelActions()) {
          final branches = n.parallelActions.actions.map(wrap).toList();
          n.parallelActions.actions
            ..clear()
            ..addAll(branches);
        }
        if (n.hasConditionActions()) {
          for (final b in n.conditionActions.trueActions) b.trueAction = wrap(b.trueAction);
          if (n.conditionActions.hasFalseAction()) {
            n.conditionActions.falseAction = wrap(n.conditionActions.falseAction);
          }
        }
        final name = n.hasAction() && n.action.hasCustomAction()
            ? n.action.customAction.customActionIdentifier.name
            : null;
        final spec = name == null ? null : specs[scope]![name];
        if (spec == null) {
          if (n.hasFollowUpAction()) n.followUpAction = wrap(n.followUpAction);
          return n;
        }
        // n = RPC call; its follow-up sets the page state from the response.
        final setNode = n.followUpAction;
        final out = varFromActionOutput(actionKey: n.action.key, outputName: n.action.outputVariableName);
        // Outputs read inside an action block must reference the block.
        out.actionComponentKeyRef = FFActionComponentKeyReference(key: block.identifier.key);
        final put = FFActionNode(
            key: generateActionKey(),
            action: Actions.updateAppState(p, updates: [
              StateFieldUpdate.setFromVariable(
                  spec.cache,
                  fv(fn('ggCachePut', [
                    {'variable': app(spec.cache)},
                    {'variable': keyVar(spec)},
                    {'variable': out.toProto3Json()},
                  ]))),
            ]));
        put.followUpAction = setNode;
        n.followUpAction = put;
        final fromCache = FFActionNode(
            key: generateActionKey(),
            action: Actions.updatePageState(p, widgetClassName: scope, updates: [
              StateFieldUpdate.setFromVariable(
                  spec.state, fv(fn('ggCacheGet', [{'variable': app(spec.cache)}, {'variable': keyVar(spec)}]))),
            ]));
        final empty = fv({
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'condition': {'relation': 'EQUAL_TO'},
            'values': [
              {'variable': fn('ggHasData', [{'variable': local(spec.state)}])},
              {'inputValue': {'serializedValue': 'false'}},
            ],
          },
        });
        final head = Actions.conditional(condition: empty, trueActions: fromCache);
        head.followUpAction = n;
        report.add('$scope $name -> ${spec.state} via ${spec.cache}');
        return head;
      }
      block.actions.rootAction = wrap(block.actions.rootAction);
    }
    stdout.writeln('Device cache:\n${report.join('\n')}');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [DeviceCache()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Device cache for Good Games, profile and Home (instant reopen)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
