// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 22.10.2026, customer feedback:
//  6  Good Heart Games list header: "#" over the place digits and "Name" over
//     the names (as in the design). Before: "#" at 36 and "Name" at 58 while
//     the rows put the place at 40 and the name at 126 (after the avatar).
//     Container_5ihcidre width 30 -> 95, "#" (Text_9k1ssv1q) left padding 24 -> 28.
//  2  Payment step 3 (PlayPaymentPage) and Energy payment: "Card / Apple Pay"
//     had no font size, so the theme's TITLE_SMALL size (18 on phones) next to
//     "PayPal" with 16. Now 16 as PayPal: PlayPaymentPage Text_rw88b54z,
//     EnergyPage Text_rv73b37n ("Card") and Text_qq493lcz ("Apple Pay").
//     The other payment block (Text_wyimeg5y) already had 16.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

final class HeaderAlignPaymentFont extends FlutterFlowAITask {
  @override
  String get name => 'gg-header-align-payment-font';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    Map<String, dynamic> load(String cls) =>
        jsonDecode(jsonEncode(p.widgetClasses.values.firstWhere((e) => e.name == cls).toProto3Json()));
    void save(String cls, Map<String, dynamic> w) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }

    Map node(Map w, String key) {
      Map? r;
      void s(dynamic x) {
        if (r != null) return;
        if (x is Map) {
          if (x['key'] == key && x['type'] != null) {
            r = x;
            return;
          }
          x.values.forEach(s);
        } else if (x is List) {
          x.forEach(s);
        }
      }
      s(w['node']);
      return r ?? (throw StateError('node $key missing'));
    }

    // 1. Good Games list header.
    {
      final w = load('GoodGamesPage');
      final box = node(w, 'Container_5ihcidre');
      final width = box['props']['container']['dimensions']['width']['pixelsValue'] as Map;
      final hash = node(w, 'Text_9k1ssv1q');
      final text = hash['props']['text']['textValue']?['inputValue'];
      if (text != '#') throw StateError('GoodGamesPage: Text_9k1ssv1q is not "#"');
      final padding = hash['props']['padding'] as Map;
      if (width['inputValue'] == 95 && padding['leftValue']?['inputValue'] == 28) {
        report.add('GoodGamesPage: header already aligned');
      } else {
        if (width['inputValue'] != 30) throw StateError('GoodGamesPage: header box width ${width['inputValue']}');
        width['inputValue'] = 95;
        padding['leftValue'] = {'inputValue': 28};
        save('GoodGamesPage', w);
        report.add('GoodGamesPage: "#" over the places, "Name" over the names');
      }
    }

    // 2. Payment method font size.
    const texts = {
      'PlayPaymentPage': ['Text_rw88b54z'],
      'EnergyPage': ['Text_rv73b37n', 'Text_qq493lcz'],
    };
    texts.forEach((cls, keys) {
      final w = load(cls);
      var n = 0;
      for (final key in keys) {
        final t = node(w, key)['props']['text'] as Map;
        final e = jsonEncode(t['textValue']);
        if (!e.contains('Card') && !e.contains('Apple Pay')) throw StateError('$cls: $key is not a payment method');
        if (t['fontSizeValue']?['inputValue'] == 16) continue;
        t['fontSizeValue'] = {'inputValue': 16};
        n++;
      }
      if (n > 0) {
        save(cls, w);
        report.add('$cls: payment method font 16 ($n texts)');
      } else {
        report.add('$cls: payment method font already 16');
      }
    });
    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [HeaderAlignPaymentFont()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games header aligned with rows; Card / Apple Pay font as PayPal',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
