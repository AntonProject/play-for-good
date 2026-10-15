// FF Custom Action: operation String, input JSON, test Boolean; return JSON.
import '/backend/supabase/supabase.dart';

Future<dynamic> ggSeasonsAdmin(
  String operation,
  dynamic input,
  bool test,
) async {
  final result = await SupaFlow.client.rpc(
    'gg_v2_seasons_admin',
    params: {
      'p_operation': operation,
      'p_input': input is Map
          ? Map<String, dynamic>.from(input)
          : <String, dynamic>{},
      'p_test': test,
    },
  );
  if (result is! Map) throw StateError('Invalid season admin response');
  return Map<String, dynamic>.from(result);
}
