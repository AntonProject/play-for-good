String ggMyPhoto(dynamic ranking) {
  // Signed-in user's avatar from the ranking RPC; guest/no photo -> '' (default image).
  if (ranking is! Map) return '';
  final me = ranking['current_user'];
  if (me is! Map) return '';
  return '${me['photo_url'] ?? ''}';
}
