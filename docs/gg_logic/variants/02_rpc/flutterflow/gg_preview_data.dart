// Temporary native FF preview. No network calls or database writes.
// Enable only in test environment via ggUsePreviewData page state.
Future<dynamic> ggPreviewData(String period, String category, String? userId,
    int page, int pageSize, bool enabled) async {
  if (!enabled) return <String, dynamic>{};
  const aliases = {
    'gesamt': 'all_time',
    'saison': 'auto',
    'season_25_26': 'season_2025_26',
    'season_26_27': 'season_2026_27',
    'dieser_monat': 'this_month',
    'letzter_monat': 'last_month'
  };
  var key = aliases[period] ?? period;
  if (key == 'auto') key = 'season_2026_27';
  const periods = [
    {
      'key': 'season_2026_27',
      'label': 'Saison 2026/27',
      'season_year': 2027,
      'period_start': '2026-09-01T00:00:00',
      'period_end_exclusive': '2027-07-01T00:00:00',
      'is_completed': false
    },
    {
      'key': 'season_2025_26',
      'label': 'Saison 2025/26',
      'season_year': 2026,
      'period_start': '2025-11-20T00:00:00',
      'period_end_exclusive': '2026-09-01T00:00:00',
      'is_completed': true
    },
    {
      'key': 'last_month',
      'label': 'Letzten Monat',
      'season_year': null,
      'is_completed': false
    },
    {
      'key': 'this_month',
      'label': 'Diesen Monat',
      'season_year': null,
      'is_completed': false
    },
    {
      'key': 'all_time',
      'label': 'All-Time',
      'season_year': null,
      'is_completed': false
    },
  ];
  final selected =
      periods.firstWhere((p) => p['key'] == key, orElse: () => periods.last);
  final registered = userId != null && userId.isNotEmpty && userId != 'guest';
  final ids = [
    registered ? userId : '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000004',
    '00000000-0000-0000-0000-000000000005'
  ];
  final finalSeason = key == 'season_2025_26';
  final power =
      finalSeason ? [1100, 900, 700, 300, 100] : [2630, 2225, 2057, 1996, 1441];
  final games =
      finalSeason ? [180, 200, 150, 140, 130] : [120, 200, 150, 140, 130];
  final energy = [10, 30, 20, 5, 1];
  final social = [2, 5, 4, 3, 1];
  final all = <Map<String, dynamic>>[];
  for (var i = 0; i < 5; i++) {
    final awards = <Map<String, dynamic>>[];
    void award(String cat, int place) {
      awards.add({
        'season': 'season_2025_26',
        'season_year': 2026,
        'season_label': 'Saison 2025/26',
        'period_start': '2025-11-20T00:00:00',
        'category': cat,
        'place': place,
        'badge': cat == 'valuable'
            ? ['mvp_gold', 'mvp_silver', 'mvp_bronze'][place - 1]
            : ['active_fire', 'map_silver', 'map_bronze'][place - 1]
      });
    }

    if (i < 3) award('valuable', i + 1);
    if (i == 1) award('active', 1);
    if (i == 0) award('active', 2);
    if (i == 2) award('active', 3);
    all.add({
      'user_id': ids[i],
      'display_name': '[TEST] Player ${i + 1}',
      'photo_url': 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
      'good_power': power[i],
      'game_power': power[i] - 100,
      'invite_power': 0,
      'games_count': games[i],
      'good_energy': energy[i],
      'score': category == 'active'
          ? games[i]
          : category == 'generous'
              ? energy[i]
              : category == 'social'
                  ? social[i]
                  : power[i],
      'all_awards': awards,
      'awards': key == 'season_2026_27' ? [] : awards
    });
  }
  all.sort((a, b) => (b['score'] as num).compareTo(a['score'] as num));
  for (var i = 0; i < all.length; i++) all[i]['rank'] = i + 1;
  final current = all.firstWhere((r) => r['user_id'] == ids[0]);
  final start = ((page < 1 ? 1 : page) - 1) * pageSize;
  final paged = start >= all.length
      ? <Map<String, dynamic>>[]
      : all.skip(start).take(pageSize).toList();
  Map<String, dynamic> metric(num value, int? rank) =>
      {'value': value, 'rank': rank};
  final profile = {
    'preview_only': true,
    'user_id': userId ?? 'guest',
    'period': selected,
    'available_periods': periods,
    'all_time': {'good_power': 2630, 'rank': 1, 'games_count': 120},
    'stats': {
      'good_power': metric(power[0], 1),
      'games': metric(games[0], finalSeason ? 2 : 5),
      'good_energy': metric(energy[0], 3),
      'sponsored_games': metric(social[0], 4),
      'good_power_per_game': metric((power[0] - 100) / games[0], 1),
      'good_energy_per_game': metric(energy[0] / games[0], 3)
    },
    'awards': registered ? current['all_awards'] : [],
    'total_good_power_all_time': 10349,
  };
  if (!registered) {
    profile['all_time'] = {'good_power':100,'rank':null,'games_count':0};
    profile['stats'] = {'good_power':metric(100,null),'games':metric(0,null),
      'good_energy':metric(0,null),'sponsored_games':metric(0,null),
      'good_power_per_game':metric(0,null),'good_energy_per_game':metric(0,null)};
  }
  return {
    'ranking': {
      'preview_only': true,
      'test': true,
      'category': category,
      'period': selected,
      'available_periods': periods,
      'layout_mode': finalSeason ? 'final' : 'current',
      'results_finalized': finalSeason,
      'total_good_power_all_time': 10349,
      'total_good_power': power.fold<int>(0, (a, b) => a + b),
      'players': paged,
      'top_players': all.take(3).toList(),
      'current_user': registered ? current : null,
      'pagination': {
        'page': page,
        'page_size': pageSize,
        'total_count': 5,
        'has_more': start + pageSize < 5
      }
    },
    'profile': profile,
    'games': {
      'period': selected,
      'available_periods': periods,
      'games': [],
      'pagination': {'page': 1, 'page_size': 10, 'has_more': false}
    },
  };
}
