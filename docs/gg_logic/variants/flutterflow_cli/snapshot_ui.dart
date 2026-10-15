// Run inside the FlutterFlow AI workspace (copied to dsl/). Reads the live
// project, keeps a private proto backup, creates an FF backup commit and dumps
// the UI scopes, code references and assets for build_ui_overlay.py.
import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';

const id = 'play-for-good-o0lpcq';
const scopes = [
  'GoodGamesPage', 'userProfilePage', 'gamesUserComp', 'userProfile',
  'userProfileFilters', 'goodGamesPlayersFilters', 'userProfileInfoStatsRow',
];

Future<void> main(List<String> args) async {
  final client = FlutterFlowAI(apiKey: Platform.environment['FF_API_KEY']!);
  final data = await client.getProject(id);
  final p = data.proto;
  final dir = Directory(args.first)..createSync(recursive: true);
  final proto = File('${dir.path}/before-ui.pb')
    ..writeAsBytesSync(p.writeToBuffer());
  Process.runSync('chmod', ['600', proto.path]);
  for (final name in scopes) {
    final wc = p.widgetClasses.values.firstWhere((w) => w.name == name);
    File('/private/tmp/pfg-ui-$name.json')
        .writeAsStringSync(jsonEncode(wc.toProto3Json()));
  }
  File('/private/tmp/pfg-ui-code-refs.json').writeAsStringSync(jsonEncode({
    'functions': {
      for (final f in p.customCode.customFunctions)
        f.identifier.name: f.toProto3Json()
    },
    'actions': {
      for (final a in p.customCode.customActions)
        a.identifier.name: a.toProto3Json()
    },
  }));
  final assets = await client.assets.list(id);
  File('/private/tmp/pfg-ui-assets.json').writeAsStringSync(jsonEncode([
    for (final a in assets) {'filename': a.filename, 'storagePath': a.storagePath}
  ]));
  final commit = await client.commit(id,
      message: 'Backup before Good Games RPC UI bindings via CLI');
  File('${dir.path}/backup.json').writeAsStringSync(jsonEncode({
    'project_id': id,
    'revision': data.updatedAtMs,
    'commit_id': commit,
    'proto': proto.path,
  }));
  stdout.writeln(jsonEncode(
      {'backup_commit': commit, 'revision': data.updatedAtMs, 'proto': proto.path}));
}
