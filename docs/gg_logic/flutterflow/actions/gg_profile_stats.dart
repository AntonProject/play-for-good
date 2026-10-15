// Custom Action ggProfileStats. Required userId String, period String.
// Return JSON. Keep FF automatic imports above this code.
import '/backend/supabase/supabase.dart';

Future<dynamic> ggProfileStats(String userId, String period) async {
  // A guest has no stored profile in the current guest flow.
  if (userId == 'guest' || userId.isEmpty) {
    throw ArgumentError('A registered profile userId is required');
  }
  final result = await SupaFlow.client.rpc(
    'gg_profile_stats',
    params: {'p_user_id': userId, 'p_period': period},
  );
  if (result is! Map) throw StateError('Invalid profile response');
  return Map<String, dynamic>.from(result);
}
