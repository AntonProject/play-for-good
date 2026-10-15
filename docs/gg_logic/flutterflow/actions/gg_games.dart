// Custom Action ggGames. Required userId/period/category String,
// page/pageSize Integer. Return JSON. Keep FF automatic imports above this code.
import '/backend/supabase/supabase.dart';

Future<dynamic> ggGames(
  String userId,
  String period,
  String category,
  int page,
  int pageSize,
) async {
  if (userId == 'guest' || userId.isEmpty) {
    throw ArgumentError('A registered userId is required');
  }
  if (page < 1 || pageSize < 1 || pageSize > 100) {
    throw ArgumentError('page >= 1 and pageSize 1..100 required');
  }
  final result = await SupaFlow.client.rpc(
    'gg_games',
    params: {
      'p_user_id': userId,
      'p_period': period,
      'p_category': category,
      'p_page': page,
      'p_page_size': pageSize,
    },
  );
  if (result is! Map) throw StateError('Invalid games response');
  return Map<String, dynamic>.from(result);
}
