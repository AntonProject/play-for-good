// Run inside a FlutterFlow AI workspace. Does not import exported Dart pages.
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutterflow_ai/src/internal_sdk.dart';

final class RegisterGgCode extends FlutterFlowAITask {
  RegisterGgCode(this.root, this.variant, this.reportDirectory);
  final String root;
  final String variant;
  final String reportDirectory;

  @override
  String get name => 'register-gg-$variant';

  @override
  bool get skipPushWhenProjectUnchanged => true;

  FFIdentifier identifier(String name, String scope) => FFIdentifier(
        name: name,
        key: generateRandomAlphaNumericString(
            seedString: 'pfg.gg.v2.$scope.$name'),
      );

  FFDataTypeV2 dataType(FFProject project, String name, bool nullable) {
    final type = switch (name) {
      'string' => FFDataTypeV2(scalarType: FFBaseDataType.String),
      'image' => FFDataTypeV2(scalarType: FFBaseDataType.ImagePath),
      'int' => FFDataTypeV2(scalarType: FFBaseDataType.Integer),
      'double' => FFDataTypeV2(scalarType: FFBaseDataType.Double),
      'bool' => FFDataTypeV2(scalarType: FFBaseDataType.Boolean),
      'json' => FFDataTypeV2(scalarType: FFBaseDataType.JSON),
      'json[]' => FFDataTypeV2(
          listType: FFDataTypeV2(scalarType: FFBaseDataType.JSON),
        ),
      'int[]' => FFDataTypeV2(
          listType: FFDataTypeV2(scalarType: FFBaseDataType.Integer),
        ),
      'string[]' => FFDataTypeV2(
          listType: FFDataTypeV2(scalarType: FFBaseDataType.String),
        ),
      'games[]' || 'users[]' || 'posts[]' || 'invites[]' => FFDataTypeV2(
          listType: FFDataTypeV2(scalarType: FFBaseDataType.PostgresRow),
          subType: FFSubType(
            tableIdentifier:
                findTable(project, name: name.split('[').first)!.identifier,
          ),
        ),
      'users' => FFDataTypeV2(
          scalarType: FFBaseDataType.PostgresRow,
          subType: FFSubType(tableIdentifier: findTable(project, name: 'users')!.identifier),
        ),
      'builder' => FFDataTypeV2(scalarType: FFBaseDataType.WidgetBuilder),
      'action' => FFDataTypeV2(scalarType: FFBaseDataType.Action),
      // Data Types (FF structs): 'GgRanking', list 'GgRankingEntry[]'.
      _ when name.startsWith('Gg') => () {
          final structName = name.replaceAll('[]', '');
          final struct = findDataStruct(project, name: structName) ??
              (throw ArgumentError('Unknown Data Type: $structName'));
          final single = FFDataTypeV2(
            scalarType: FFBaseDataType.DataStruct,
            subType: FFSubType(dataStructIdentifier: struct.identifier),
          );
          if (!name.endsWith('[]')) return single;
          // List as the SDK's listOf helper builds it: subType on the outer type.
          return FFDataTypeV2(listType: single)..subType = single.subType.deepCopy();
        }(),
      _ => throw ArgumentError('Unsupported metadata type: $name'),
    };
    type.nonNullable = !nullable;
    return type;
  }

  String functionBody(String source, String name) {
    final unit = parseString(content: source, throwIfDiagnostics: true).unit;
    final declaration = unit.declarations
        .whereType<FunctionDeclaration>()
        .where((d) => d.name.lexeme == name)
        .single;
    final body = declaration.functionExpression.body;
    if (body is! BlockFunctionBody) {
      throw StateError('$name must have a block body');
    }
    return source.substring(
      body.block.leftBracket.end,
      body.block.rightBracket.offset,
    );
  }

  void register(FFProject project) {
    final manifest = jsonDecode(
      File('$root/flutterflow_cli/custom_code.json').readAsStringSync(),
    ) as Map;
    final definitions = (manifest['variants'] as Map)[variant] as List;
    // Detect page drift separately during UI work; this task must not mutate UI.
    final before = jsonEncode(
      project.widgetClasses.map((k, v) => MapEntry(k, v.toProto3Json())),
    );
    final report = <Map<String, dynamic>>[];
    for (final raw in definitions) {
      final spec = raw as Map;
      final kind = spec['kind'] as String;
      final name = spec['name'] as String;
      final sourceFile = '$root/${spec['file']}';
      final source = File(sourceFile).readAsStringSync();
      final oldFunction = findCustomFunction(project, name: name);
      final oldAction = findCustomAction(project, name: name);
      final oldWidget = findCustomWidget(project, name: name);
      if (spec['code_only'] == true && kind == 'widget') {
        // Existing FF widget: replace the source only, keep its parameters.
        if (oldWidget == null) throw StateError('code_only needs an existing FF widget: $name');
        updateCustomWidget(project, name: name, code: source);
        report.add({'kind': kind, 'name': name, 'file': spec['file'], 'code_only': true});
        continue;
      }
      if (spec['code_only'] == true && kind == 'action') {
        // Existing FF action: replace the source only, keep its signature.
        if (oldAction == null) throw StateError('code_only needs an existing FF action: $name');
        updateCustomAction(project, name: name, code: source);
        report.add({'kind': kind, 'name': name, 'file': spec['file'], 'code_only': true});
        continue;
      }
      if (spec['code_only'] == true) {
        // Existing FF function: replace the body only and keep its signature
        // (List<GamesRow> etc.). ff_key covers an FF name differing from Dart.
        final key = spec['ff_key'] as String?;
        final existing = (key == null
                ? null
                : project.customCode.customFunctions
                    .where((f) => f.identifier.key == key)
                    .firstOrNull) ??
            oldFunction;
        if (kind != 'function' || existing == null) {
          throw StateError('code_only needs an existing FF function: $name');
        }
        updateCustomFunction(
          project,
          name: existing.identifier.name,
          code: functionBody(source, name),
        );
        report.add({
          'kind': kind,
          'name': existing.identifier.name,
          'file': spec['file'],
          'code_only': true,
        });
        continue;
      }
      final oldParameters = switch (kind) {
        'function' => oldFunction?.arguments ?? <FFParameter>[],
        'action' => oldAction?.arguments ?? <FFParameter>[],
        'widget' => oldWidget?.parameters ?? <FFParameter>[],
        _ => throw ArgumentError('Unsupported kind: $kind'),
      };
      final parameters = <FFParameter>[];
      for (final rawArg in spec['arguments'] as List) {
        final arg = rawArg as Map;
        final argName = arg['name'] as String;
        final old = oldParameters
            .where((p) => p.identifier.name == argName)
            .firstOrNull;
        parameters.add(
          FFParameter(
            identifier: old?.identifier ?? identifier(argName, name),
            dataType: dataType(
              project,
              arg['type'] as String,
              arg['nullable'] == true,
            ),
          ),
        );
      }
      final resultType = spec['returns'] as String?;
      final result = resultType == null
          ? null
          : FFParameter(
              identifier: oldFunction?.returnParameter.identifier ??
                  oldAction?.returnParameter.identifier ??
                  identifier('result', name),
              dataType: dataType(project, resultType, spec['returnsNullable'] == true),
            );
      const description =
          'Prepared Good Games v2 package. Wire native FF widgets separately.';
      switch (kind) {
        case 'function':
          final body = functionBody(source, name);
          if (oldFunction == null) {
            final id = addCustomFunction(
              project,
              name: name,
              code: body,
              arguments: parameters,
              returnParameter: result,
              description: description,
            );
            id.key = identifier(name, 'function').key;
          } else {
            updateCustomFunction(
              project,
              name: name,
              code: body,
              arguments: parameters,
              returnParameter: result,
              description: description,
            );
          }
        case 'action':
          if (oldAction == null) {
            final id = addCustomAction(
              project,
              name: name,
              code: source,
              arguments: parameters,
              returnParameter: result,
              description: description,
              includeContext: spec['includeContext'] == true,
            );
            id.key = identifier(name, 'action').key;
          } else {
            updateCustomAction(
              project,
              name: name,
              code: source,
              arguments: parameters,
              returnParameter: result,
              description: description,
            );
            if (spec['includeContext'] == true) oldAction.includeContext = true;
          }
        case 'widget':
          if (oldWidget == null) {
            final id = addCustomWidget(
              project,
              name: name,
              code: source,
              parameters: parameters,
              description: description,
            );
            id.key = identifier(name, 'widget').key;
          } else {
            // Preserve the existing dimensions identifier and its bounds.
            final dimensions = oldWidget.parameters
                .where((p) => p.identifier.name == 'dimensions')
                .firstOrNull;
            updateCustomWidget(
              project,
              name: name,
              code: source,
              parameters: [if (dimensions != null) dimensions, ...parameters],
              description: description,
            );
          }
      }
      report.add({
        'kind': kind,
        'name': name,
        'file': spec['file'],
        'arguments': spec['arguments'],
        'returns': resultType,
      });
    }
    final after = jsonEncode(
      project.widgetClasses.map((k, v) => MapEntry(k, v.toProto3Json())),
    );
    if (before != after)
      throw StateError(
        'Code registration unexpectedly changed a page/component',
      );
    final directory = Directory(reportDirectory)..createSync(recursive: true);
    File('${directory.path}/$variant-code-report.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'variant': variant,
        'scope': 'custom-code-only',
        'pages_changed': false,
        'definitions': report,
      }),
    );
    stdout.writeln(
      'Prepared ${report.length} Custom Code definitions; native pages unchanged.',
    );
  }

  @override
  void run(TaskContext ctx) {
    final directory = Directory(reportDirectory)..createSync(recursive: true);
    final backup = File('${directory.path}/before-$variant.pb');
    // Private binary includes backend config. Never copy it into the repository.
    backup.writeAsBytesSync(ctx.project.writeToBuffer());
    Process.runSync('chmod', ['600', backup.path]);
    register(ctx.project);
  }
}

Future<void> main(List<String> args) async {
  String? option(String key) {
    final index = args.indexOf(key);
    if (index < 0) return null;
    if (index + 1 >= args.length || args[index + 1].startsWith('--')) {
      throw ArgumentError('Value required for $key');
    }
    return args[index + 1];
  }

  final variant = option('--variant') ?? 'basic';
  if (!['basic', 'rpc', 'admin'].contains(variant))
    throw ArgumentError('Unknown variant');
  final root = option('--variants-root');
  if (root == null) throw ArgumentError('--variants-root required');
  final projectId = option('--project-id');
  final reportDir = option('--report-dir') ??
      Directory.systemTemp.createTempSync('pfg-gg-transfer-').path;
  final task = RegisterGgCode(root, variant, reportDir);
  final offline = option('--offline-snapshot');
  if (offline != null) {
    if (args.contains('--apply'))
      throw ArgumentError('--offline-snapshot cannot be used with --apply');
    final p = FFProject.fromBuffer(File(offline).readAsBytesSync());
    task.register(p);
    final first = base64Encode(p.writeToBuffer());
    task.register(p);
    if (first != base64Encode(p.writeToBuffer()))
      throw StateError('Registration is not idempotent');
    final candidate = File('$reportDir/candidate-$variant.pb')
      ..writeAsBytesSync(p.writeToBuffer());
    Process.runSync('chmod', ['600', candidate.path]);
    stdout.writeln(
      'Offline registration and idempotency passed. No network calls.',
    );
    return;
  }
  if (projectId == null)
    throw ArgumentError('--project-id required for live read/dry-run');
  final key = Platform.environment['FF_API_KEY'] ??
      Platform.environment['FLUTTERFLOW_API_KEY'];
  if (key == null || key.isEmpty)
    throw StateError('FlutterFlow key missing from secret environment');
  final apply = args.contains('--apply');
  if (apply && (option('--backup-commit') ?? '').isEmpty) {
    throw StateError(
      'Save a FlutterFlow Commit before applying; pass its ID with --backup-commit',
    );
  }
  await FlutterFlowAIPipeline(
    apiKey: key,
    project: PipelineProject.existing(projectId),
    tasks: [task],
    source: PipelineSource.paths([
      Platform.script.toFilePath(),
      '$root/flutterflow_cli/custom_code.json',
      ...((jsonDecode(
        File(
          '$root/flutterflow_cli/custom_code.json',
        ).readAsStringSync(),
      ) as Map)['variants'][variant] as List)
          .map((s) => '$root/${s['file']}'),
    ]),
    commitMessage: 'Register Good Games v2 $variant Custom Code',
    dryRun: !apply,
    refreshContext: false,
  ).run();
}
