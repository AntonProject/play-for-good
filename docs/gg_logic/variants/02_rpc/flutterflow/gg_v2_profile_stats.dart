// Custom Action ggV2ProfileStats. Required userId String, period String.
// Return JSON. Keep FF automatic imports above this code.
import '/backend/supabase/supabase.dart';

Future<dynamic> ggV2ProfileStats(
  String userId,
  String period,
  bool test,
) async {
  // A guest has no stored profile in the current guest flow.
  if (userId == 'guest' || userId.isEmpty) {
    throw ArgumentError('A registered profile userId is required');
  }
  final result = await SupaFlow.client.rpc(
    'gg_v2_profile_stats',
    params: {'p_user_id': userId, 'p_period': period, 'p_test': test},
  );
  if (result is! Map) throw StateError('Invalid profile response');
  final data = Map<String, dynamic>.from(result);
  // Server values as-is: the signup +100 is added only by the backend ledger.
  return data;
}
