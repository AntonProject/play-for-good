import '/backend/supabase/supabase.dart';

List<int> ggPostPages(List<PostsRow>? posts) {
  // Good News renders posts page by page (25 each, as loaded). A loaded page
  // keeps its length, so its cards keep their keys when the next page arrives.
  final n = posts?.length ?? 0;
  return List<int>.generate((n + 24) ~/ 25, (i) => i);
}
