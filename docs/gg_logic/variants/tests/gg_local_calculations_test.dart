import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_local_calculations.dart';

void main() {
  final fixture = jsonDecode(
    File(
      Platform.environment['GG_VARIANTS_FIXTURE']!,
    ).readAsStringSync(),
  ) as Map;
  for (final mode in ['live', 'frozen']) {
    test(
      '$mode: basic calculations equal server ranking/profile on identical data',
      () {
        final f = fixture[mode] as Map;
        final expected = f['ranking'] as Map;
        final actual = ggLocalCalculations(
          f['games'] as List,
          f['users'] as List,
          f['context'],
          'valuable',
          1,
          100,
          '00000000-0000-0000-0000-000000000003',
        ) as Map;
        expect(actual['total_good_power'], expected['total_good_power']);
        expect(
          actual['total_good_power_all_time'],
          expected['total_good_power_all_time'],
        );
        expect(actual['pagination'], expected['pagination']);
        for (var i = 0; i < (expected['players'] as List).length; i++) {
          final e = expected['players'][i] as Map;
          final x = actual['players'][i] as Map;
          for (final field in [
            'user_id',
            'display_name',
            'rank',
            'score',
            'good_power',
            'game_power',
            'invite_power',
            'bonus_power',
            'games_count',
            'awards',
          ]) {
            expect(
              x[field],
              e[field],
              reason: '$mode user ${e['user_id']} $field',
            );
          }
        }
        expect(actual['profile']['stats'], f['profile']['stats']);
        expect(actual['profile']['all_time'], f['profile']['all_time']);
      },
    );
  }
  test(
    'basic MAP counts games only; test games and bonus cannot increase it',
    () {
      final f = fixture['live'] as Map;
      final actual = ggLocalCalculations(
        f['games'] as List,
        f['users'] as List,
        f['context'],
        'active',
        1,
        100,
        null,
      ) as Map;
      expect(
        actual['players'][0]['user_id'],
        '00000000-0000-0000-0000-000000000004',
      );
      expect(actual['players'][0]['score'], 5);
      expect(
        (actual['players'] as List).any(
          (p) => p['user_id'] == '00000000-0000-0000-0000-000000000006',
        ),
        false,
      );
    },
  );
  test('basic ranking filters badges by season; profile retains all seasons',
      () {
    const userId = '00000000-0000-0000-0000-000000000003';
    final f = fixture['frozen'] as Map;
    final context = jsonDecode(jsonEncode(f['context'])) as Map;
    final badges = [
      {
        'season': 'season_2026_27',
        'season_year': 2027,
        'category': 'valuable',
        'place': 1
      },
      {
        'season': 'season_2025_26',
        'season_year': 2026,
        'category': 'valuable',
        'place': 2
      },
      {
        'season': 'season_2026_27',
        'season_year': 2027,
        'category': 'active',
        'place': 2
      },
      {
        'season': 'season_2025_26',
        'season_year': 2026,
        'category': 'active',
        'place': 3
      },
    ];
    context['awards_by_user'][userId] = badges;
    Map calculate() => ggLocalCalculations(
          f['games'] as List,
          f['users'] as List,
          context,
          'valuable',
          1,
          100,
          userId,
        ) as Map;
    final season = calculate();
    expect(season['current_user']['awards'], [badges[1], badges[3]]);
    expect(season['profile']['awards'], badges);
    context['is_finalized'] = false;
    for (final key in ['all_time', 'this_month', 'last_month']) {
      context['period'] = {
        ...context['period'] as Map,
        'key': key,
        'season_year': null
      };
      final result = calculate();
      expect(result['current_user']['awards'], badges);
      expect(result['profile']['awards'], badges);
    }
  });
}
