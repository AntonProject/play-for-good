// FF Custom Function. games/users: List<JSON>, context: JSON, category: String,
// page/pageSize: Integer, userId: optional String. Return JSON.
// Use ggBuildLocalData to adapt existing Supabase row lists.
dynamic ggLocalCalculations(
  List<dynamic> games,
  List<dynamic> users,
  dynamic context,
  String category,
  int page,
  int pageSize,
  String? userId,
) {
  if (context is! Map) throw ArgumentError('GG context must be loaded first');
  if (!['valuable', 'active'].contains(category)) {
    throw ArgumentError('Only MVP/MAP supported');
  }
  if (page < 1 || pageSize < 1 || pageSize > 100) {
    throw ArgumentError('page >= 1 and pageSize 1..100 required');
  }
  final period = Map<String, dynamic>.from(context['period'] as Map);
  final test = context['test'] == true;
  DateTime? date(dynamic d) => d == null ? null : DateTime.parse(d.toString());
  final start = date(period['period_start']);
  final end = date(period['period_end_exclusive']);
  bool selected(dynamic d) {
    if (start == null && end == null) return true;
    final day = date(d);
    return day != null &&
        (start == null || !day.isBefore(start)) &&
        (end == null || day.isBefore(end));
  }

  double number(dynamic n) => (n as num?)?.toDouble() ?? 0;
  List<Map<String, dynamic>> rows(dynamic value) => value is List
      ? value.map((v) => Map<String, dynamic>.from(v as Map)).toList()
      : [];
  final validGames = rows(games)
      .where((g) => g['status'] == 'completed' && (g['test'] == true) == test)
      .toList();
  final userRows = rows(users);
  final current = <String, Map<String, dynamic>>{};
  final allTime = <String, Map<String, dynamic>>{};
  final awards = context['awards_by_user'] as Map? ?? {};
  Map<String, dynamic> empty(Map u) => {
        'user_id': u['id'],
        'display_name': u['display_name'],
        'first_name': u['first_name'],
        'surname': u['surname'],
        'photo_url': u['photo_url'],
        'good_power': 0.0,
        'game_power': 0.0,
        'invite_power': 0.0,
        'bonus_power': 0.0,
        'games_count': 0,
        'good_energy': 0.0,
        'sponsored_games': 0,
        'good_power_per_game': 0.0,
        'good_energy_per_game': 0.0,
      };
  for (final u in userRows) {
    current[u['id'] as String] = empty(u);
    allTime[u['id'] as String] = empty(u);
  }
  void addGame(Map<String, dynamic> s, Map g) {
    s['game_power'] = number(s['game_power']) + number(g['lichtwatt']);
    s['games_count'] = (s['games_count'] as int) + 1;
    s['good_energy'] = number(s['good_energy']) +
        number(g['user_money']) +
        number(g['team_money']) +
        number(g['sieg_money']) +
        number(g['additional_donation_money']);
    if (number(g['sponsor_money']) > 0)
      s['sponsored_games'] = (s['sponsored_games'] as int) + 1;
  }

  for (final g in validGames) {
    final id = g['creator_user_id'];
    if (allTime[id] == null) continue;
    addGame(allTime[id]!, g);
    if (selected(g['game_date'])) addGame(current[id]!, g);
  }
  // Trusted aggregate contributions include all inviters despite owner-only
  // raw invitation RLS. Do not add the old invites list a second time.
  for (final c in rows(context['contributions'])) {
    final id = c['user_id'];
    if (allTime[id] == null) continue;
    allTime[id]!['invite_power'] = number(c['all_invite']);
    allTime[id]!['bonus_power'] = number(c['all_bonus']);
    current[id]!['invite_power'] = number(c['selected_invite']);
    current[id]!['bonus_power'] = number(c['selected_bonus']);
  }
  void finish(Map<String, Map<String, dynamic>> scores) {
    for (final s in scores.values) {
      final count = s['games_count'] as int;
      s['good_power'] = number(s['game_power']) +
          number(s['invite_power']) +
          number(s['bonus_power']);
      s['good_power_per_game'] =
          count > 0 ? number(s['game_power']) / count : 0.0;
      s['good_energy_per_game'] =
          count > 0 ? number(s['good_energy']) / count : 0.0;
    }
    const fields = {
      'good_power': 'power_rank',
      'games_count': 'games_rank',
      'good_power_per_game': 'power_per_game_rank',
      'good_energy': 'energy_rank',
      'good_energy_per_game': 'energy_per_game_rank',
      'sponsored_games': 'sponsored_games_rank',
    };
    for (final entry in fields.entries) {
      final sorted = scores.values.toList();
      sorted.sort((a, b) {
        if (entry.key.endsWith('per_game')) {
          final eligibleA = number(a['games_count']) > 0;
          final eligibleB = number(b['games_count']) > 0;
          if (eligibleA != eligibleB) return eligibleA ? -1 : 1;
        }
        final byValue = number(b[entry.key]).compareTo(number(a[entry.key]));
        return byValue != 0
            ? byValue
            : (a['user_id'] as String).compareTo(b['user_id'] as String);
      });
      for (var i = 0; i < sorted.length; i++) {
        final s = sorted[i];
        final eligible = entry.key.endsWith('per_game')
            ? number(s['games_count']) > 0
            : number(s[entry.key]) > 0;
        s[entry.value] = eligible ? i + 1 : null;
      }
    }
  }

  finish(current);
  finish(allTime);
  if (context['is_finalized'] == true) {
    // Closed seasons are taken from stored results, never recalculated client-side.
    for (final s in current.values) {
      final zero = empty({'id': s['user_id'], ...s});
      s.addAll(zero);
      for (final rank in [
        'power_rank',
        'games_rank',
        'power_per_game_rank',
        'energy_rank',
        'energy_per_game_rank',
        'sponsored_games_rank',
      ]) {
        s[rank] = null;
      }
    }
    for (final r in rows(context['frozen_players'])) {
      final liveUser = current[r['user_id']];
      for (final field in [
        'display_name',
        'first_name',
        'surname',
        'photo_url'
      ]) {
        if (liveUser?[field] != null) r[field] = liveUser![field];
      }
      r['bonus_power'] = number(r['good_power']) -
          number(r['game_power']) -
          number(r['invite_power']);
      current[r['user_id'] as String] = r;
    }
  }
  Map<String, dynamic> payload(Map<String, dynamic> s) => {
        ...s,
        'score': s[category == 'active' ? 'games_count' : 'good_power'],
        'rank': s[category == 'active' ? 'games_rank' : 'power_rank'],
        'awards': rows(awards[s['user_id']])
            .where((award) =>
                period['season_year'] == null ||
                award['season'] == period['key'])
            .toList(),
      };
  final ranked =
      current.values.map(payload).where((p) => number(p['score']) > 0).toList();
  ranked.sort((a, b) {
    final order = number(b['score']).compareTo(number(a['score']));
    return order != 0
        ? order
        : (a['user_id'] as String).compareTo(b['user_id'] as String);
  });
  final ownGames = validGames
      .where((g) => g['creator_user_id'] == userId && selected(g['game_date']))
      .toList();
  ownGames.sort((a, b) {
    if (category == 'valuable') {
      final byPower = number(b['lichtwatt']).compareTo(number(a['lichtwatt']));
      if (byPower != 0) return byPower;
    }
    final byDate = (b['game_date']?.toString() ?? '').compareTo(
      a['game_date']?.toString() ?? '',
    );
    return byDate != 0
        ? byDate
        : (a['id'] as String).compareTo(b['id'] as String);
  });
  Map<String, dynamic>? profile;
  final s = current[userId];
  final a = allTime[userId];
  if (s != null && a != null) {
    profile = {
      'user_id': userId,
      'period': period,
      'available_periods': context['available_periods'],
      'all_time': {
        'good_power': a['good_power'],
        'rank': a['power_rank'],
        'games_count': a['games_count'],
      },
      'stats': {
        'good_power': {'value': s['good_power'], 'rank': s['power_rank']},
        'games': {'value': s['games_count'], 'rank': s['games_rank']},
        'good_power_per_game': {
          'value': s['good_power_per_game'],
          'rank': s['power_per_game_rank'],
        },
        'good_energy': {'value': s['good_energy'], 'rank': s['energy_rank']},
        'good_energy_per_game': {
          'value': s['good_energy_per_game'],
          'rank': s['energy_per_game_rank'],
        },
        'sponsored_games': {
          'value': s['sponsored_games'],
          'rank': s['sponsored_games_rank'],
        },
      },
      'awards': awards[userId] ?? [],
    };
  }
  return {
    'test': test,
    'period': period,
    'available_periods': context['available_periods'],
    'category': category,
    'total_good_power': current.values.fold<double>(
      0,
      (sum, s) => sum + number(s['good_power']),
    ),
    'total_good_power_all_time': context['total_good_power_all_time'],
    'players': ranked.skip((page - 1) * pageSize).take(pageSize).toList(),
    'top_players': ranked.take(3).toList(),
    'current_user': s == null ? null : payload(s),
    'profile': profile,
    'games': ownGames.skip((page - 1) * pageSize).take(pageSize).toList(),
    'games_pagination': {'has_more': ownGames.length > page * pageSize},
    'pagination': {
      'page': page,
      'page_size': pageSize,
      'total_count': ranked.length,
      'has_more': ranked.length > page * pageSize,
    },
  };
}
