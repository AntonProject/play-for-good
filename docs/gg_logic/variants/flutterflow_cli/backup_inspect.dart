import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';

Future<void> main(List<String> args) async {
  final client=FlutterFlowAI(apiKey:Platform.environment['FF_API_KEY']!);
  const id='play-for-good-o0lpcq';
  final data=await client.getProject(id);
  final dir=Directory('/Users/a123/.config/pfg-gg-backups/20261013');
  dir.createSync(recursive:true);
  final file=File('${dir.path}/before-ui.pb')..writeAsBytesSync(data.proto.writeToBuffer());
  Process.runSync('chmod',['600',file.path]);
  final scopes=['GoodGamesPage','userProfilePage','gamesUserComp','userProfile','userProfileFilters','goodGamesPlayersFilters'];
  for(final name in scopes) {
    final wc=data.proto.widgetClasses.values.firstWhere((w)=>w.name==name);
    File('/private/tmp/pfg-ui-$name.json').writeAsStringSync(jsonEncode(wc.toProto3Json()));
  }
  final commit=await client.commit(id,message:'Backup before Good Games RPC UI bindings (13 Oct 2026)');
  File('${dir.path}/backup.json').writeAsStringSync(jsonEncode({'project_id':id,'revision':data.updatedAtMs,'commit_id':commit,'proto':file.path}));
  print(jsonEncode({'backup_commit':commit,'revision':data.updatedAtMs,'private_backup':file.path}));
}
