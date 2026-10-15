import '/backend/supabase/supabase.dart';

int ggPostsWindow(List<PostsRow>? loaded) {
  // Refresh re-reads everything already shown, at least the first page (25).
  final n = loaded?.length ?? 0;
  return n < 25 ? 25 : n;
}
