"""Create a disposable Flutter harness for the prepared Custom Code only.

No cloud/Git writes. Run flutter pub get separately in the returned directory.
"""
import argparse
import shutil
from pathlib import Path

p=argparse.ArgumentParser()
p.add_argument('--output',required=True)
a=p.parse_args()
h=Path(a.output).resolve()
assert str(h).startswith('/private/tmp/'), 'Use a disposable /private/tmp directory'
r=Path(__file__).resolve().parents[1]
project=r.parents[2]
for name in ['lib/backend/supabase/database/tables','lib/custom_code/actions',
             'lib/custom_code/widgets','lib/custom_code/functions','test']:
    (h/name).mkdir(parents=True,exist_ok=True)
(h/'pubspec.yaml').write_text('''name: pfg_rpc_check
environment:
  sdk: ">=3.0.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: 2.9.0
  supabase: 2.7.0
  realtime_client: 2.5.0
dev_dependencies:
  flutter_test:
    sdk: flutter
  http: ^1.2.0
''')
(h/'lib/backend/supabase/supabase.dart').write_text("""import 'package:supabase_flutter/supabase_flutter.dart';
export 'database/database.dart';
class SupaFlow { static late SupabaseClient client; }
""")
(h/'lib/backend/supabase/database/database.dart').write_text("""export 'row.dart';
export 'tables/games.dart';
export 'tables/users.dart';
abstract class SupabaseTable<T> {
  String get tableName;
  T createRow(Map<String,dynamic> data);
}
class LatLng { const LatLng(this.latitude,this.longitude); final double latitude,longitude; }
class PostgresTime {
  static PostgresTime? tryParse(String value)=>null;
  String toIso8601String()=>'';
}
""")
for file in ['row.dart','tables/games.dart','tables/users.dart']:
    shutil.copyfile(project/'lib/backend/supabase/database'/file,h/'lib/backend/supabase/database'/file)
for folder in ['shared','01_basic/flutterflow','02_rpc/flutterflow','02_rpc/integration','03_seasons_admin/flutterflow']:
    for f in (r/folder).glob('*.dart'):
        dest='functions' if f.name in ['gg_local_calculations.dart','gg_local_from_rows.dart','gg_games_rows.dart'] else 'widgets' if any(
            x in f.name for x in ['panel','preview','refresh','listener','boundary']) else 'actions'
        s=f.read_text().replace("import '/","import 'package:pfg_rpc_check/")
        if f.name in ['gg_build_local_data.dart','gg_local_from_rows.dart']:
            s=s.replace('package:pfg_rpc_check/flutter_flow/custom_functions.dart',
                        'package:pfg_rpc_check/custom_code/functions/gg_local_calculations.dart')
        (h/'lib/custom_code'/dest/f.name).write_text(s)
for f in (r/'02_rpc/flutterflow/functions').glob('*.dart'):
    shutil.copyfile(f,h/'lib/custom_code/functions'/f.name)
shutil.copyfile(r/'tests/gg_local_calculations_test.dart',h/'test/gg_local_calculations_test.dart')
shutil.copyfile(r/'tests/gg_profile_environment_test.dart',h/'test/gg_profile_environment_test.dart')
shutil.copyfile(r/'tests/gg_signup_environment_test.dart',h/'test/gg_signup_environment_test.dart')
shutil.copyfile(r/'tests/gg_legacy_bonus_test.dart',h/'test/gg_legacy_bonus_test.dart')
shutil.copyfile(r/'tests/gg_native_bindings_test.dart',h/'test/gg_native_bindings_test.dart')
s=(r.parent/'tests/scroll_boundary_test.dart').read_text().replace(
    "package:pfg_rpc_check/gg_scroll_boundary.dart",'package:pfg_rpc_check/custom_code/widgets/gg_scroll_boundary.dart')
(h/'test/scroll_boundary_test.dart').write_text(s)
print(f'Prepared local harness: {h}')
print('Run flutter pub get, then dart analyze lib/custom_code.')
print(f'GG_VARIANTS_FIXTURE={r}/tests/parity_fixture.json flutter test --no-pub')
