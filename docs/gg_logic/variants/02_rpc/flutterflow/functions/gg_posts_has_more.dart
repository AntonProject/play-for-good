import '/backend/supabase/supabase.dart';

bool ggPostsHasMore(List<PostsRow>? page, int limit) {
  // A full page means there may be more posts after it.
  return (page?.length ?? 0) >= limit;
}
