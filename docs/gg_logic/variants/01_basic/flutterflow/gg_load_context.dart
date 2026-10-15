// FF Custom Action: period String, test Boolean; return JSON.
import '/backend/supabase/supabase.dart';

Future<dynamic> ggLoadContext(String period, bool test) async {
  final result = await SupaFlow.client.rpc(
    'gg_v2_context',
    params: {'p_period': period, 'p_test': test},
  );
  if (result is! Map) throw StateError('Invalid GG context');
  return Map<String, dynamic>.from(result);
}
