// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Guest gates (16.10.2026, owner request):
//  1 userProfilePage, guest "Mein Profil": "Meine Favoriten", "Meine Sponsoren",
//    "Mein Good Circle" opened empty lists for a guest. They now do what the
//    guest "Profil editieren" does: the registration dialog (authDialog), after
//    signing in the own profile. "Hilfe und Feedback" (a link) stays.
//  2 Follow / favourite buttons (every tap that inserts into `followers`, admin
//    pages excluded): a guest got nothing saved (no user id). The tap now checks
//    "signed in": yes -> the actions as before, no -> the registration dialog.
// Copied actions get new keys; references to them inside the copy follow.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';

const profilePage = 'userProfilePage';
const guestEdit = 'Container_c4ldkx7r'; // guest "Profil editieren"
const guestItems = {
  'Container_wz0zbys9': 'Meine Favoriten',
  'Container_nc5w7oe6': 'Meine Sponsoren',
  'Container_8yyuozdt': 'Mein Good Circle',
};
const signedIn = {
  'source': 'GLOBAL_PROPERTIES',
  'baseVariable': {'globalProperties': {'property': 'IS_USER_LOGGED_IN'}},
};

Map<String, dynamic> copy(Object? x) => jsonDecode(jsonEncode(x)) as Map<String, dynamic>;

/// Deep copy of an action tree with new node / action keys (seeded by [seed]);
/// output variable names get [suffix] (they must be unique on a page).
Map<String, dynamic> rekey(Map source, String seed, [String suffix = '']) {
  final c = copy(source);
  if (suffix.isNotEmpty) {
    final names = <String>{};
    void outs(dynamic x) {
      if (x is Map) {
        final o = x['outputVariableName'];
        if (o is String) {
          names.add(o);
          x['outputVariableName'] = '$o$suffix';
        }
        x.values.forEach(outs);
      } else if (x is List) {
        x.forEach(outs);
      }
    }
    outs(c);
    void uses(dynamic x) {
      if (x is Map) {
        final id = x['outputVariableIdentifier'];
        if (id is Map && names.contains(id['name'])) id['name'] = '${id['name']}$suffix';
        x.values.forEach(uses);
      } else if (x is List) {
        x.forEach(uses);
      }
    }
    uses(c);
  }
  final map = <String, String>{};
  var i = 0;
  String fresh() => generateRandomAlphaNumericString(seedString: 'pfg.gg.gates.$seed.${i++}');
  void keys(dynamic x) {
    if (x is Map) {
      final isNode = x.containsKey('action') || x.containsKey('conditionActions') || x.containsKey('followUpAction');
      final isAction = x.containsKey('bottomSheet') || x.containsKey('navigate') || x.containsKey('customAction') ||
          x.containsKey('localStateUpdate') || x.containsKey('database') || x.containsKey('waitAction');
      final isCond = x.containsKey('trueActions');
      if ((isNode || isAction || isCond) && x['key'] is String) {
        final n = fresh();
        map[x['key'] as String] = n;
        x['key'] = n;
      }
      x.values.forEach(keys);
    } else if (x is List) {
      x.forEach(keys);
    }
  }
  keys(c);
  void refs(dynamic x) {
    if (x is Map) {
      final r = x['actionKeyRef'];
      if (r is Map && map.containsKey(r['key'])) r['key'] = map[r['key']];
      x.values.forEach(refs);
    } else if (x is List) {
      x.forEach(refs);
    }
  }
  refs(c);
  return c;
}

final class GuestAuthGates extends FlutterFlowAITask {
  @override
  String get name => 'gg-guest-auth-gates';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];
    Map<String, dynamic> load(String cls) =>
        copy(p.widgetClasses.values.firstWhere((w) => w.name == cls).toProto3Json());
    void save(String cls, Map<String, dynamic> w) {
      final entry = p.widgetClasses.entries.firstWhere((e) => e.value.name == cls);
      final next = FFWidgetClass()..mergeFromProto3Json(w);
      restoreUnknownFields(entry.value, next);
      p.widgetClasses[entry.key] = next;
    }
    Map? node(dynamic x, String k) {
      if (x is Map) {
        if (x['key'] == k && x.containsKey('type')) return x;
        for (final v in x.values) {
          final r = node(v, k);
          if (r != null) return r;
        }
      } else if (x is List) {
        for (final v in x) {
          final r = node(v, k);
          if (r != null) return r;
        }
      }
      return null;
    }

    // The registration dialog action, from the guest "Profil editieren".
    final profile = load(profilePage);
    final edit = node(profile['node'], guestEdit) ?? (throw StateError('$guestEdit not found'));
    final editTrigger = (edit['triggerActions'] as List).firstWhere((t) => t['trigger']['triggerType'] == 'ON_TAP') as Map;
    final authRoot = editTrigger['rootAction'] as Map;
    final bs = authRoot['action']?['bottomSheet'];
    if (bs == null || authRoot['action']['outputVariableName'] != 'successAuth') {
      throw StateError('$guestEdit: the tap is not the auth dialog any more');
    }
    final authOnly = <String, dynamic>{
      'key': 'x',
      'action': {
        'key': 'y',
        'bottomSheet': copy(bs),
        'nonBlocking': false,
      },
    };

    // 1 guest profile items
    var items = 0;
    guestItems.forEach((k, title) {
      final n = node(profile['node'], k) ?? (throw StateError('$k ($title) not found'));
      if (!jsonEncode(n).contains('"$title"')) throw StateError('$k is not "$title"');
      final triggers = n['triggerActions'] as List;
      final i = triggers.indexWhere((t) => t['trigger']['triggerType'] == 'ON_TAP');
      if (jsonEncode(triggers[i]).contains('"successAuth')) return; // done before
      final t = rekey(editTrigger, 'item.$k', title.replaceAll(RegExp(r'[^A-Za-z]'), ''));
      // References to the source widget point at this item.
      void retarget(dynamic x) {
        if (x is Map) {
          final r = x['nodeKeyRef'];
          if (r is Map && r['key'] == guestEdit) r['key'] = k;
          x.values.forEach(retarget);
        } else if (x is List) {
          x.forEach(retarget);
        }
      }
      retarget(t);
      triggers[i] = t;
      items++;
    });
    if (items > 0) report.add('$profilePage: guest items -> registration dialog x$items');

    // 2 follow buttons in every class
    final classes = p.widgetClasses.values.map((w) => w.name).where((n) => !n.toLowerCase().contains('admin')).toList();
    for (final cls in classes) {
      final w = cls == profilePage ? profile : load(cls);
      var gates = 0;
      void walk(dynamic x) {
        if (x is Map) {
          final ta = x['triggerActions'];
          if (ta is List) {
            for (final t in ta) {
              final root = t['rootAction'];
              if (root is! Map) continue;
              final s = jsonEncode(root);
              final inserts = s.contains('"followers"') && s.contains('"insert"');
              final gated = root['conditionActions']?['trueActions']?[0]?['condition']?['variable']?['source'] == 'GLOBAL_PROPERTIES' &&
                  s.contains('IS_USER_LOGGED_IN') && root['conditionActions']?['falseAction'] != null &&
                  jsonEncode(root['conditionActions']['falseAction']).contains('"bottomSheet"');
              if (!inserts || gated) continue;
              final seed = '$cls.${x['key']}';
              final auth = rekey(authOnly, 'auth.$seed');
              t['rootAction'] = {
                'key': generateRandomAlphaNumericString(seedString: 'pfg.gg.gates.root.$seed'),
                'conditionActions': {
                  'key': generateRandomAlphaNumericString(seedString: 'pfg.gg.gates.cond.$seed'),
                  'trueActions': [
                    {
                      'condition': {'variable': signedIn},
                      'trueAction': root,
                    }
                  ],
                  'falseAction': auth,
                },
              };
              gates++;
            }
          }
          x.values.forEach(walk);
        } else if (x is List) {
          x.forEach(walk);
        }
      }
      walk(w['node']);
      if (gates > 0) {
        report.add('$cls: follow taps -> signed in ? as before : registration dialog x$gates');
        if (cls != profilePage) save(cls, w);
      }
    }
    save(profilePage, profile);
    stdout.writeln(report.isEmpty ? 'nothing to change' : report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [GuestAuthGates()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Guest: favourites / sponsors / circle and follow buttons open the registration dialog',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
