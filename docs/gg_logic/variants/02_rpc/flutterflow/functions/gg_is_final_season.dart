bool ggIsFinalSeason(dynamic ranking) {
  if (ranking is! Map) return false;
  if (ranking['layout_mode'] != null) return ranking['layout_mode'] == 'final';
  final period = ranking['period'];
  return period is Map &&
      period['season_year'] != null &&
      period['is_completed'] == true;
}
