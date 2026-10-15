// Custom Action ggPostsPage. Returns List<PostsRow>, newest first.
// offset Integer, limit Integer. Keep FF automatic imports above this code.
// Posts loaded in this app session are kept in memory: limit 0 returns them
// without a request (instant Good News on reopen), any other call loads the
// page and updates the memory (offset 0 replaces it, later pages append).
import '/backend/supabase/supabase.dart';

List<PostsRow> _ggPostsMemo = [];

Future<List<PostsRow>> ggPostsPage(int offset, int limit) async {
  if (limit <= 0) {
    return List.of(_ggPostsMemo);
  }
  final rows = await SupaFlow.client
      .from('posts')
      .select()
      .order('created_at', ascending: false)
      .range(offset, offset + limit - 1);
  final page = (rows as List)
      .map((r) => PostsRow(Map<String, dynamic>.from(r as Map)))
      .toList();
  _ggPostsMemo = [
    ..._ggPostsMemo.take(offset),
    ...page,
  ];
  return page;
}
