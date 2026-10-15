// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Batch 2 (REST audit, tools/figma_text_audit.py): Play, Play payment, Energy,
// Good Games, Home. Batch 1 (MCP): Good Games + profile, commit nLXx8qbLxgAziW4YrTrl.
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
  'PlayPage': {
    'Text_0jdneegt': {'fs': [18, 16]}, // Eigene Punkte
    'Text_qgexu8we': {'fs': [18, 16]}, // Team-Punkte
    'Text_j623awvt': {'fs': [18, 16]}, // Einsatz hinzufügen
    'Button_shavj4gt': {'fs': [18, 16]}, // Weiter
    'Text_vb1vz22h': {'fs': [16, 14]}, // Deine Game €nergy
  },
  'PlayPaymentPage': {
    'Text_cngu645z': {'fs': [18, 16]}, // PayPal
    'Text_mugb3ryz': {'fs': [18, 16]}, // PayPal (guest)
    'Text_ppgy0lbu': {'fs': [16, 14]}, // ... diese App weiterentwickeln
    'Text_w9mk4h4p': {'fs': [16, 14]}, // same (guest)
    'Button_x81s7kdt': {'fs': [18, 16]}, // €nergy senden
    'Button_xywaqkpx': {'fs': [18, 16]}, // Weiter (guest)
  },
  'EnergyPage': {
    'Text_v09svvym': {'fs': [18, 16]}, // PayPal
  },
  'GoodGamesPage': {
    'Button_72drsja2': {'fw': [500, 600]}, // tab Meine Games (as Meisterschaft)
    'Text_364mucfa': {'fs': [18, 16]}, // Mehr sehen
  },
  'homePageScore': {
    'Text_3kvw6134': {'fs': [18, 24], 'fw': [600, 500], 'ls': [-0.63, -0.96], 'lh': [1.5, 1.4]}, // Good Power title
    'Text_mxtzluqa': {'fs': [13, 11]}, // Good Circle
    'Text_kec4a5md': {'fs': [13, 11]}, // Good Games
  },
  'HomePage': {
    'Text_5v5f10u3': {'fs': [16, 12], 'fw': [400, 500], 'ls': [null, -0.24], 'lh': [null, 1.5]}, // Keine Organisationen gewählt
    'Text_q8vt1zad': {'fw': [500, 400], 'lh': [1.1, 1.5]}, // Als Nächstes unterstützen
  },
  'organizationsHomeEmpty': {
    'Text_mgtw0m0b': {'lh': [1.1, 1.5]}, // Finde deine Organisation
  },
  'recentGamesHomeEmpty': {
    'Text_5mdv6jsp': {'lh': [1.2, 1.5]}, // Noch keine Games
    'Text_0by3tmm6': {'lh': [1.1, 1.5]}, // Starte dein erstes Game
  },
};

const themeWeights = <String, num>{
  'DISPLAY_LARGE': 600, 'DISPLAY_MEDIUM': 600, 'DISPLAY_SMALL': 700, 'HEADLINE_LARGE': 600,
  'HEADLINE_MEDIUM': 600, 'HEADLINE_SMALL': 500, 'TITLE_LARGE': 600, 'TITLE_MEDIUM': 600,
  'TITLE_SMALL': 500, 'LABEL_LARGE': 400, 'LABEL_MEDIUM': 400, 'LABEL_SMALL': 400,
  'BODY_LARGE': 400, 'BODY_MEDIUM': 400, 'BODY_SMALL': 600,
};
const themeSizes = <String, num>{
  'DISPLAY_LARGE': 66, 'DISPLAY_MEDIUM': 46, 'DISPLAY_SMALL': 36, 'HEADLINE_LARGE': 34,
  'HEADLINE_MEDIUM': 30, 'HEADLINE_SMALL': 26, 'TITLE_LARGE': 22, 'TITLE_MEDIUM': 20,
  'TITLE_SMALL': 18, 'LABEL_LARGE': 18, 'LABEL_MEDIUM': 16, 'LABEL_SMALL': 14,
  'BODY_LARGE': 18, 'BODY_MEDIUM': 16, 'BODY_SMALL': 12,
};

final class FigmaTextStyles extends FlutterFlowAITask {
  @override
  String get name => 'gg-figma-text-styles-2';
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
          final field = {'fs': 'fontSizeValue', 'lh': 'heightValue', 'ls': 'letterSpacingValue', 'fw': 'fontWeightValue'}[e.key]!;
          // No own size: the theme style's size applies (mobile typography).
          final style = t['themeStyle'] ?? 'BODY_MEDIUM';
          final explicitWeight = (t['fontWeightValue'] as Map?)?['inputValue'];
          final current = e.key == 'fw'
              ? (explicitWeight is String ? num.tryParse(explicitWeight.substring(1)) : themeWeights[style])
              : read(t[field]) ?? (e.key == 'fs' ? themeSizes[style] : null);
          final expected = e.value[0] as num?;
          final next = e.value[1] as num;
          if (current != expected && !(current != null && expected != null && (current - expected).abs() < 1e-9)) {
            skipped.add('$cls/$k ${e.key}: now $current, expected $expected');
            continue;
          }
          t[field] = e.key == 'ls'
              ? spacing(next)
              : e.key == 'fw'
                  ? {'inputValue': 'w$next'}
                  : {'inputValue': next};
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
    commitMessage: 'Text styles aligned with Figma, batch 2 (Play, payment, Energy, Home)',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
