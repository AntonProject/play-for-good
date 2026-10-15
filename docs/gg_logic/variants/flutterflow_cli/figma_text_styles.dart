// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Text styles aligned with Figma (file "Players For Good (Copy)", page
// "Batch 2-26": Good Games – Championship Season – MVP 60640:4783 and
// User profile page_Update_March2026 60571:14653). Only size / line height /
// letter spacing; texts and colors unchanged. Each change checks the current
// value first, so a node edited in FF since the comparison is reported, not
// overwritten.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

// class -> node -> {prop: [expected current, new]}; ls = letter spacing.
const changes = <String, Map<String, Map<String, List<Object?>>>>{
  'GoodGamesPage': {
    'Text_5m4bxljx': {'fs': [32, 36], 'lh': [1, 1.5]}, // Total Good Power
    'Button_ac2vi0vu': {'fs': [16, 14]}, // tab Meisterschaft
    'Button_72drsja2': {'fs': [16, 14], 'ls': [null, -0.35], 'lh': [null, 1.5]}, // tab Meine Games
    'Text_dfgvihzg': {'ls': [null, -0.9], 'lh': [null, 1.2]}, // podium 2
    'Text_e571b0wa': {'ls': [null, -0.9], 'lh': [null, 1.2]}, // podium 3
  },
  'gamesUserComp': {
    'Text_tnfcf2yg': {'lh': [1.1, 1.5]}, // row name
  },
  'userProfilePage': {
    'Text_7hrwnnhn': {'fs': [14, 12], 'ls': [-0.2, -0.24]}, // name under @handle
    'Text_cs71phjv': {'fs': [14, 12], 'ls': [-0.2, -0.24]}, // Gastnutzer
    'Text_qi125hq3': {'fs': [16, 14]}, // bio
    'Text_yjfbgcra': {'fs': [20, 18]}, // Unterstützte Organisationen
    'Text_sz9o2xzg': {'fs': [20, 18]}, // Stats
    'Text_d6bxflft': {'fs': [20, 18]}, // Unterstützte Organisationen (guest)
    'Text_jxvcmiub': {'fs': [20, 18]}, // Stats (guest)
    'Text_gr2kfo87': {'fs': [1, 11]}, // Good Power (guest), was size 1
  },
  'userProfile': {
    'Text_ys8rnigv': {'fs': [14, 12], 'ls': [-0.2, -0.24]},
    'Text_4ipz1znb': {'fs': [14, 12], 'ls': [-0.2, -0.24]},
    'Text_97s48r0t': {'fs': [16, 14]},
    'Text_wq6aek7g': {'fs': [16, 14]},
    'Text_b5juojm8': {'fs': [20, 18]},
    'Text_1v6njj7f': {'fs': [20, 18]},
    'Text_7i4lfb0u': {'fs': [20, 18]},
    'Text_z4x1p47p': {'fs': [20, 18]},
    'Text_ij9cgw0t': {'fs': [20, 18]},
    'Text_bzgjdj9b': {'fs': [20, 18]},
  },
};

const themeSizes = <String, num>{
  'DISPLAY_LARGE': 66, 'DISPLAY_MEDIUM': 46, 'DISPLAY_SMALL': 36, 'HEADLINE_LARGE': 34,
  'HEADLINE_MEDIUM': 30, 'HEADLINE_SMALL': 26, 'TITLE_LARGE': 22, 'TITLE_MEDIUM': 20,
  'TITLE_SMALL': 18, 'LABEL_LARGE': 18, 'LABEL_MEDIUM': 16, 'LABEL_SMALL': 14,
  'BODY_LARGE': 18, 'BODY_MEDIUM': 16, 'BODY_SMALL': 12,
};

final class FigmaTextStyles extends FlutterFlowAITask {
  @override
  String get name => 'gg-figma-text-styles';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    final skipped = <String>[];
    num? read(dynamic v) {
      if (v is! Map) return null;
      final iv = v['inputValue'];
      if (iv is num) return iv;
      final code = v['variable']?['functionCall']?['codeExpression']?['expression'] ??
          v['variable']?['baseVariable']?['customCodeExpression']?['code'];
      return code == null ? null : num.tryParse('$code');
    }
    Map<String, dynamic> spacing(num value) => {
          'variable': {
            'source': 'FUNCTION_CALL',
            'functionCall': {
              'codeExpression': {
                'returnParameter': {'dataType': {'scalarType': 'Double', 'nonNullable': true}},
                'expression': '$value',
                'valid': true,
              }
            },
          }
        };
    for (final cls in changes.keys) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
      Map<String, dynamic>? find(Map<String, dynamic> n, String k) {
        if (n['key'] == k) return n;
        for (final c in (n['children'] as List? ?? [])) {
          final r = find(c as Map<String, dynamic>, k);
          if (r != null) return r;
        }
        return null;
      }
      for (final k in changes[cls]!.keys) {
        final n = find(w['node'], k);
        if (n == null) {
          skipped.add('$cls/$k missing');
          continue;
        }
        final props = n['props'] as Map<String, dynamic>;
        final t = (n['type'] == 'Button' ? props['button']['text'] : props['text']) as Map<String, dynamic>;
        for (final e in changes[cls]![k]!.entries) {
          final field = {'fs': 'fontSizeValue', 'lh': 'heightValue', 'ls': 'letterSpacingValue'}[e.key]!;
          // No own size: the theme style's size applies (mobile typography).
          final current = read(t[field]) ?? (e.key == 'fs' ? themeSizes[t['themeStyle'] ?? 'BODY_MEDIUM'] : null);
          final expected = e.value[0] as num?;
          final next = e.value[1] as num;
          if (current != expected && !(current != null && expected != null && (current - expected).abs() < 1e-9)) {
            skipped.add('$cls/$k ${e.key}: now $current, expected $expected');
            continue;
          }
          t[field] = e.key == 'ls' ? spacing(next) : {'inputValue': next};
          report.add('$cls/$k ${e.key} $current -> $next');
        }
      }
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }
    stdout.writeln('Changed ${report.length}:\n  ${report.join('\n  ')}');
    if (skipped.isNotEmpty) stdout.writeln('Skipped ${skipped.length}:\n  ${skipped.join('\n  ')}');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [FigmaTextStyles()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Text styles aligned with Figma (Good Games, profile page and dialog)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
