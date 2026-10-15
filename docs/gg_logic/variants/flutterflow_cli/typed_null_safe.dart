// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Fix after the Data Type migration: reading a field of a nullable Data Type
// page state / parameter makes FF generate `_model.ggRanking!.field`, which
// throws on the first frame (data not loaded yet) - a red error for a moment.
// Every field read of a typed state / parameter now goes through
// ggRankingOrEmpty / ggStatsOrEmpty / ggGamesOrEmpty / ggPlayerOrEmpty, which
// return an empty value (0 / '' / false, as the old JSON helpers did), and FF
// reads fields of a non-null function result without `!`.
// Values passed whole (into functions, components, actions) are unchanged.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const classes = ['GoodGamesPage', 'gamesUserComp', 'goodGamesPlayersFilters', 'userProfilePage', 'userProfile', 'homePageScore', 'energyComp'];
const wrappers = {
  'GgRanking': 'ggRankingOrEmpty',
  'GgProfileStats': 'ggStatsOrEmpty',
  'GgGamesEntry': 'ggGamesOrEmpty',
  'GgPlayer': 'ggPlayerOrEmpty',
};

final class TypedNullSafe extends FlutterFlowAITask {
  TypedNullSafe({this.after = const {}, this.only = classes});
  final Set<String> after;
  final List<String> only;
  @override
  Set<String> get dependsOn => after;
  @override
  String get name => 'gg-typed-null-safe';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    Map<String, dynamic> fn(String name) {
      final f = p.customCode.customFunctions.where((f) => f.identifier.name == name).firstOrNull ??
          (throw StateError('$name function missing'));
      return {'name': f.identifier.name, 'key': f.identifier.key};
    }
    final structNames = {
      for (final s in p.backend.dataSchemaConfig.dataStructs) s.identifier.key: s.identifier.name
    };
    String? structOf(dynamic dataType) {
      if (dataType is! Map || dataType['scalarType'] != 'DataStruct' || dataType['listType'] != null) return null;
      return structNames[dataType['subType']?['dataStructIdentifier']?['key']];
    }

    for (final cls in only) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      final typed = <String, String>{}; // state / param key -> struct
      for (final f in ((w['classModel'] as Map?)?['stateFields'] as List? ?? [])) {
        final s = structOf(f['parameter']['dataType']);
        if (s != null && wrappers.containsKey(s)) typed[f['parameter']['identifier']['key']] = s;
      }
      for (final e in ((w['params'] as Map?) ?? {}).values) {
        final s = structOf(e['dataType']);
        if (s != null && wrappers.containsKey(s)) typed[e['identifier']['key']] = s;
      }
      var wrapped = 0;
      dynamic rewrite(dynamic n) {
        if (n is Map) {
          for (final k in n.keys.toList()) {
            n[k] = rewrite(n[k]);
          }
          final source = n['source'];
          final base0 = n['baseVariable'] as Map?;
          Object? key;
          if (source == 'LOCAL_STATE') {
            key = (base0?['localState'] as Map?)?['fieldIdentifier']?['key'];
          } else if (source == 'WIDGET_CLASS_PARAMETER') {
            key = (base0?['widgetClass'] as Map?)?['paramIdentifier']?['key'];
          }
          final ops = n['operations'] as List?;
          final s = typed[key];
          if (s != null && ops != null && ops.isNotEmpty && (ops.first as Map).containsKey('accessDataStructField')) {
            final base = jsonDecode(jsonEncode(n)) as Map<String, dynamic>
              ..remove('operations')
              ..remove('defaultValue')
              ..remove('uiBuilderValue');
            wrapped++;
            return {
              'source': 'FUNCTION_CALL',
              if (n['defaultValue'] != null) 'defaultValue': n['defaultValue'],
              'functionCall': {
                'values': [
                  {'variable': base}
                ],
                'customFunction': fn(wrappers[s]!),
              },
              'operations': ops,
              if (n['uiBuilderValue'] != null) 'uiBuilderValue': n['uiBuilderValue'],
            };
          }
          return n;
        }
        if (n is List) {
          for (var i = 0; i < n.length; i++) {
            n[i] = rewrite(n[i]);
          }
        }
        return n;
      }
      rewrite(w['node']);
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      stdout.writeln('$cls: $wrapped field reads wrapped (${typed.values.toSet().join(', ')})');
    }
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [TypedNullSafe()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games: typed field reads without null assertions',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
