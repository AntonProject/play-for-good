// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// 23.10.2026, owner: the guest profile showed an empty place badge under
// "100 LW". guest_in_ranking.dart bound it to ggProfile, but the guest branch
// of userProfilePage loads only ggGuest (ranking of the Stats period).
// Guest branch of userProfilePage, all from ggGuest:
//   place badge (Text_ps6amarn)          ggRankingPlace(ggGuest)
//   "100 LW" (Text_maofougl)             ggPlayerOf(ggGuest, 'guest').goodPower LW
//   Stats "Total Good Power" (Container_b205ys9w)
//     value                              ggPlayerOf(ggGuest, 'guest').goodPower
//     place                              ggRankingPlace(ggGuest)
// So the header and Total Good Power show the same place as Good Games (the
// guest inside the list) and 0 in a closed season / last month (was a fixed
// 100 and the raw guest_places place). ggPlayerOf: 'guest' before the ranking
// arrives = the demo 100.
// Layout of the red header (owner edited the signed-in branch, 23.10.2026),
// copied to the guest branch: background image and fit (Container_snut4ocl
// <- Container_qob8t7pt), header column alignment and bottom padding 76 as in
// the own profile (Column_d3lmxphw; without it the place badge sat on the
// curve), "LW" column min size (Column_uvcseosk), "LW" and its label one line
// with auto size, label alignment (Text_maofougl, Text_gr2kfo87).
// ONE commit (with the function transfer).
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'gg_transfer.dart' show RegisterGgCode;

final class GuestProfileHeader extends FlutterFlowAITask {
  @override
  String get name => 'gg-guest-profile-header';
  @override
  Set<String> get dependsOn => {'register-gg-rpc'};
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == 'userProfilePage');
    final w = jsonDecode(jsonEncode(entry.value.toProto3Json())) as Map<String, dynamic>;
    Map node(String key) {
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

    Map<String, dynamic> fn(String name) {
      final f = p.customCode.customFunctions.where((f) => f.identifier.name == name).firstOrNull ??
          (throw StateError('$name function missing'));
      return {'name': f.identifier.name, 'key': f.identifier.key};
    }

    final player = findDataStruct(p, name: 'GgPlayer') ?? (throw StateError('GgPlayer missing'));
    final gp = player.fields.firstWhere((f) => f.identifier.name == 'goodPower').identifier;
    const guestVar = {
      'source': 'LOCAL_STATE',
      'baseVariable': {
        'localState': {
          'fieldIdentifier': {'name': 'ggGuest', 'key': 'gg46d3373c15'},
          'stateVariableType': 'WIDGET_CLASS_STATE'
        }
      },
      'nodeKeyRef': {'key': 'Scaffold_kvtv6adx'},
    };
    Map place() => {
          'source': 'FUNCTION_CALL',
          'functionCall': {
            'values': [
              {'variable': jsonDecode(jsonEncode(guestVar))}
            ],
            'customFunction': fn('ggRankingPlace'),
          },
        };
    Map power() => {
          'source': 'FUNCTION_CALL',
          'operations': [
            {
              'accessDataStructField': {
                'fieldIdentifier': {'name': gp.name, 'key': gp.key}
              }
            },
            {
              'numberFormat': {'formatType': 'CUSTOM', 'customFormat': '#,##0', 'customLocale': 'de_DE'}
            }
          ],
          'functionCall': {
            'values': [
              {'variable': jsonDecode(jsonEncode(guestVar))},
              {
                'inputValue': {'serializedValue': 'guest'}
              }
            ],
            'customFunction': fn('ggPlayerOf'),
          },
        };

    // Layout: guest branch as the signed-in branch.
    var layout = 0;
    void copy(String from, String to, List<String> path) {
      dynamic src = node(from)['props'];
      for (final k in path) {
        src = src is Map ? src[k] : null;
      }
      Map dst = node(to)['props'] as Map;
      for (final k in path.take(path.length - 1)) {
        dst = (dst[k] ??= <String, dynamic>{}) as Map;
      }
      final before = jsonEncode(dst[path.last]);
      if (src == null) {
        dst.remove(path.last);
      } else {
        dst[path.last] = jsonDecode(jsonEncode(src));
      }
      if (jsonEncode(dst[path.last]) != before) layout++;
    }
    copy('Container_qob8t7pt', 'Container_snut4ocl', ['container', 'boxDecoration', 'image']);
    copy('Column_l73iba5u', 'Column_d3lmxphw', ['alignment']);
    final pad = (node('Column_d3lmxphw')['props']['padding'] ??= <String, dynamic>{}) as Map;
    if (pad['bottomValue']?['inputValue'] != 76) {
      pad['bottomValue'] = {'inputValue': 76};
      layout++;
    }
    copy('Column_vfo16dj1', 'Column_uvcseosk', ['column', 'minSizeValue']);
    for (final pair in [
      ['Text_wn608uvw', 'Text_maofougl'],
      ['Text_39dz8n14', 'Text_gr2kfo87'],
    ]) {
      copy(pair[0], pair[1], ['text', 'autoSize']);
      copy(pair[0], pair[1], ['text', 'maxLinesValue']);
    }
    copy('Text_39dz8n14', 'Text_gr2kfo87', ['alignment']);

    if (jsonEncode(node('Text_maofougl')).contains('"ggPlayerOf"')) {
      if (layout == 0) {
        stdout.writeln('userProfilePage: guest header already done');
        return;
      }
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
      stdout.writeln('userProfilePage: guest header layout as signed-in ($layout props)');
      return;
    }

    // Badge: ggPlaceLabelOf(<place>).
    final badge = node('Text_ps6amarn')['props']['text']['textValue']['variable'] as Map;
    if (badge['functionCall']?['customFunction']?['name'] != 'ggPlaceLabelOf') {
      throw StateError('Text_ps6amarn: unexpected binding');
    }
    ((badge['functionCall']['values'] as List).first as Map)['variable'] = place();

    // "100 LW".
    final header = node('Text_maofougl')['props']['text'] as Map;
    if (header['textValue']?['inputValue'] != '100 LW') throw StateError('Text_maofougl: not "100 LW"');
    header['textValue'] = {
      'variable': {
        'source': 'FUNCTION_CALL',
        'functionCall': {
          'stringInterpolation': {},
          'values': [
            {'variable': power()},
            {
              'inputValue': {'serializedValue': ' LW'}
            }
          ],
        },
      },
      'mostRecentInputValue': '100 LW',
    };

    // Stats "Total Good Power".
    Map? pv;
    void findPv(dynamic x) {
      if (pv != null) return;
      if (x is Map) {
        if (x['parameterValues'] is Map) {
          pv = x['parameterValues'] as Map;
          return;
        }
        x.values.forEach(findPv);
      } else if (x is List) {
        x.forEach(findPv);
      }
    }
    findPv(node('Container_b205ys9w'));
    final passes = (pv ?? (throw StateError('Container_b205ys9w: no parameters')))['parameterPasses'] as Map;
    if (passes['04vs5w']?['inputValue']?['serializedValue'] != 'Total Good Power') {
      throw StateError('Container_b205ys9w: not Total Good Power');
    }
    final number = passes['ae5qed']['variable'] as Map;
    if (number['functionCall']?['customFunction']?['name'] != 'ggPlaceLabelOf') {
      throw StateError('Container_b205ys9w: unexpected place binding');
    }
    ((number['functionCall']['values'] as List).first as Map)['variable'] = place();
    final value = passes['gfik2u'] as Map;
    value.remove('inputValue');
    value['variable'] = power();

    final next = FFWidgetClass()..mergeFromProto3Json(w);
    restoreUnknownFields(entry.value, next);
    p.widgetClasses[entry.key] = next;
    stdout.writeln('userProfilePage: guest badge, "LW" and Total Good Power from ggGuest; '
        'header layout as signed-in ($layout props)');
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-guesthead-').path;
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [RegisterGgCode(root, 'rpc', reports), GuestProfileHeader()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Guest profile: header place and Good Power of the period; header layout as the signed-in profile',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
