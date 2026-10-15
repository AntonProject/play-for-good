String ggOrgTitle(
  String? current,
  String? snapshot,
) {
  // Organization name for a played game: the current title from
  // `organization`; the copy saved in the game when the organization is not
  // in the list (hidden/removed); otherwise 'Organisation'.
  final now = current?.trim() ?? '';
  if (now.isNotEmpty) return now;
  final saved = snapshot?.trim() ?? '';
  return saved.isNotEmpty ? saved : 'Organisation';
}
