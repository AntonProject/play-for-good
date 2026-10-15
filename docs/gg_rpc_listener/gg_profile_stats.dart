// FlutterFlow Custom Action: ggProfileStats
// Arguments: userId (String), period (String). Return type: JSON.
// Keep FlutterFlow's automatic imports above this code.
import '/backend/supabase/supabase.dart';

Future<dynamic> ggProfileStats(String userId, String period) async {
  if (userId.isEmpty) {
    throw ArgumentError('A profile userId is required');
  }
  final response = await SupaFlow.client.rpc(
    'gg_profile_stats',
    params: {'p_user_id': userId, 'p_period': period},
  );
  if (response is! Map) {
    throw StateError('Profile statistics were not returned');
  }
  return Map<String, dynamic>.from(response);
}
