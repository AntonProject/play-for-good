// FF Custom Action, return JSON. Parameter test Boolean required.
import '/backend/supabase/supabase.dart';

Future<dynamic> ggClaimSignupBonus(bool test) async {
  final result = await SupaFlow.client.rpc(
    'gg_v2_claim_signup_bonus',
    params: {'p_test': test},
  );
  if (result is! Map) throw StateError('Invalid bonus response');
  return Map<String, dynamic>.from(result);
}
