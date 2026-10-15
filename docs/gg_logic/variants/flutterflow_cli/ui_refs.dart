import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'transfer.dart';

Future<void> main() async {
  final p=FFProject.fromBuffer(File('/Users/a123/.config/pfg-gg-backups/20261013/before-ui.pb').readAsBytesSync());
  RegisterGgCode('/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants','rpc','/private/tmp/pfg-ui-reports').register(p);
  File('/private/tmp/pfg-ui-code-refs.json').writeAsStringSync(jsonEncode({
    'functions':{for(final f in p.customCode.customFunctions) f.identifier.name:f.toProto3Json()},
    'actions':{for(final a in p.customCode.customActions) a.identifier.name:a.toProto3Json()},
  }));
  for(final w in p.widgetClasses.values) {
    if(['userProfileInfoStatsRow','Image'].contains(w.name)) {
      File('/private/tmp/pfg-ui-${w.name}.json').writeAsStringSync(jsonEncode(w.toProto3Json()));
    }
  }
  final client=FlutterFlowAI(apiKey:Platform.environment['FF_API_KEY']!);
  final assets=await client.assets.list('play-for-good-o0lpcq');
  File('/private/tmp/pfg-ui-assets.json').writeAsStringSync(jsonEncode([
    for(final a in assets){'filename':a.filename,'storagePath':a.storagePath}
  ]));
  print('Prepared code references and read-only asset list.');
}
