import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

List<GgAwardStruct> ggSortAwards(
  List<GgAwardStruct>? awards,
  String? season,
) {
  // Awards of one season (all when season is empty): MVP first, then MAP,
  // newest season first, then by badge.
  const aliases = {
    'season_25_26': 'season_2025_26',
    'season_26_27': 'season_2026_27'
  };
  final wanted = aliases[season] ?? season;
  int order(GgCategory? c) => c == GgCategory.valuable
      ? 0
      : c == GgCategory.active
          ? 1
          : 2;
  final result = [
    for (final a in awards ?? <GgAwardStruct>[])
      if (wanted == null || wanted.isEmpty || a.season == wanted) a
  ];
  result.sort((a, b) {
    final category = order(a.category).compareTo(order(b.category));
    if (category != 0) return category;
    final start = (b.seasonStart ?? DateTime(b.seasonYear))
        .compareTo(a.seasonStart ?? DateTime(a.seasonYear));
    if (start != 0) return start;
    return '${a.badge?.name}'.compareTo('${b.badge?.name}');
  });
  return result;
}
