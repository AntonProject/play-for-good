import '/backend/supabase/supabase.dart';

List<PostsRow> ggPostsSlice(
  List<PostsRow>? posts,
  int page,
) {
  // Posts of one Good News page (25 each), see ggPostPages.
  final all = posts ?? [];
  final start = page * 25;
  if (start >= all.length || start < 0) return [];
  final end = start + 25 < all.length ? start + 25 : all.length;
  return all.sublist(start, end);
}
