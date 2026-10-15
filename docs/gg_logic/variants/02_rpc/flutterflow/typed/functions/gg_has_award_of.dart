import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

bool ggHasAwardOf(
  List<GgAwardStruct>? awards,
  String category,
  int place,
  String? season,
) {
  // The awards contain this category / place (of one season, or any).
  if (place < 1 || place > 3) return false;
  final wantedCategory = category == 'mvp'
      ? 'valuable'
      : category == 'map'
          ? 'active'
          : category;
  const aliases = {
    'season_25_26': 'season_2025_26',
    'season_26_27': 'season_2026_27'
  };
  final wantedSeason = aliases[season] ?? season;
  return (awards ?? <GgAwardStruct>[]).any((a) =>
      a.category?.name == wantedCategory &&
      a.place == place &&
      (wantedSeason == null || wantedSeason.isEmpty || a.season == wantedSeason));
}
