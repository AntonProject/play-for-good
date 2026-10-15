// Custom Function ggDefaultPeriod. now DateTime optional. Return String.
String ggDefaultPeriod(DateTime? now) {
  // Match gg_internal.config timezone=UTC. Compare calendar dates, not instants.
  final clock = (now ?? DateTime.now()).toUtc();
  final date = DateTime(clock.year, clock.month, clock.day);
  if (!date.isBefore(DateTime(2026, 9, 1))) {
    final startYear = clock.year - (clock.month < 9 ? 1 : 0);
    final endSuffix = ((startYear + 1) % 100).toString().padLeft(2, '0');
    return 'season_${startYear}_$endSuffix';
  }
  if (!date.isBefore(DateTime(2025, 11, 20))) return 'season_2025_26';
  return 'all_time';
}
