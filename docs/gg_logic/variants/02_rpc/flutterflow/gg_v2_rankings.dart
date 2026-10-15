// Custom Action ggV2Rankings. Return JSON (not List of JSON).
// Required: period String, category String, page Integer, pageSize Integer.
// Optional: userId String. Keep FF automatic imports above this code.
import '/backend/supabase/supabase.dart';

Future<dynamic> ggV2Rankings(
  String period,
  String category,
  int page,
  int pageSize,
  String? userId,
  bool test,
) async {
  if (page < 1 || pageSize < 1 || pageSize > 100) {
    throw ArgumentError('page >= 1 and pageSize 1..100 required');
  }
  final result = await SupaFlow.client.rpc(
    'gg_v2_rankings',
    params: {
      'p_period': period,
      'p_test': test,
      'p_category': category,
      'p_page': page,
      'p_page_size': pageSize,
      'p_user_id':
          userId == null || userId.isEmpty || userId == 'guest' ? null : userId,
    },
  );
  if (result is! Map) throw StateError('Invalid ranking response');
  final data = Map<String, dynamic>.from(result);
  // Server values as-is: the signup +100 is added only by the backend ledger.
  return data;
}
