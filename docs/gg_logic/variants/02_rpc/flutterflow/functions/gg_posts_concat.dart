import '/backend/supabase/supabase.dart';

List<PostsRow> ggPostsConcat(List<PostsRow>? current, List<PostsRow>? more) {
  // Appends the next page; a post shifted by new inserts is not duplicated.
  final seen = <String>{};
  final out = <PostsRow>[];
  for (final row in [...?current, ...?more]) {
    final id = '${row.data['id']}';
    if (seen.add(id)) out.add(row);
  }
  return out;
}
