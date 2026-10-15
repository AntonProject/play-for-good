// Runs in the isolated Flutter test harness described in VALIDATION.md.
import 'package:flutter_test/flutter_test.dart';
import 'package:pfg_rpc_check/backend/supabase/supabase.dart';
import 'package:pfg_rpc_check/flutter_flow/custom_functions.dart';

GamesRow game(String id, String? date, {String user = 'a', double gp = 1}) =>
    GamesRow({
      'id': id,
      'game_date': date,
      'creator_user_id': user,
      'lichtwatt': gp,
    });

void main() {
  test('default remains the last started season through summer gaps', () {
    expect(ggDefaultPeriod(DateTime.utc(2025, 11, 19)), 'all_time');
    expect(ggDefaultPeriod(DateTime.utc(2025, 11, 20)), 'season_2025_26');
    expect(
      ggDefaultPeriod(DateTime.utc(2026, 8, 31, 23, 59, 59)),
      'season_2025_26',
    );
    expect(ggDefaultPeriod(DateTime.utc(2026, 9, 1)), 'season_2026_27');
    expect(ggDefaultPeriod(DateTime.utc(2027, 8, 31)), 'season_2026_27');
    expect(ggDefaultPeriod(DateTime.utc(2027, 9, 1)), 'season_2027_28');
    expect(ggDefaultPeriod(DateTime.utc(2028, 7, 1)), 'season_2027_28');
    expect(ggDefaultPeriod(DateTime.utc(2099, 9, 1)), 'season_2099_00');
  });
  test('recurring seasons end after the last full day of June', () {
    final bounds = ggPeriodBounds('season_2027_28', null) as Map;
    expect(bounds['period_start'], '2027-09-01T00:00:00.000');
    expect(bounds['period_end_exclusive'], '2028-07-01T00:00:00.000');
    expect(() => ggPeriodBounds('season_2027_29', null), throwsArgumentError);
  });
  test('calendar months have exact start and exclusive next-month end', () {
    final previous =
        ggPeriodBounds('letzter_monat', DateTime.utc(2026, 1, 10)) as Map;
    expect(previous['period_start'], '2025-12-01T00:00:00.000');
    expect(previous['period_end_exclusive'], '2026-01-01T00:00:00.000');
    final leap = ggPeriodBounds('this_month', DateTime.utc(2024, 2, 10)) as Map;
    expect(leap['period_end_exclusive'], '2024-03-01T00:00:00.000');
    expect(() => ggPeriodBounds('bad', null), throwsArgumentError);
  });
  test(
    'season filtering includes last-day microseconds, excludes next season and undated',
    () {
      final games = [
        game('1', '2025-11-19T23:59:59.999999'),
        game('2', '2025-11-20T00:00:00'),
        game('3', '2026-08-31T23:59:59.999999'),
        game('4', '2026-09-01T00:00:00'),
        game('5', null),
        game('6', '2026-08-20T00:00:00', user: 'b'),
      ];
      expect(gamesForPeriod('season_2025_26', games, 'a')!.map((g) => g.id), [
        '2',
        '3',
      ]);
      expect(gamesForPeriod('gesamt', games, 'a')!.map((g) => g.id), [
        '1',
        '2',
        '3',
        '4',
        '5',
      ]);
    },
  );
  test(
    'game sort and pagination remain deterministic and do not mutate input',
    () {
      final games = [
        game('3', '2026-09-02', gp: 2),
        game('2', '2026-09-02', gp: 2),
        game('1', '2026-09-01', gp: 3),
        game('4', '2026-09-03', gp: 1),
      ];
      expect(
        filterAllGames(
          games,
          'season_2026_27',
          'valuable',
          2,
          1,
        )!.map((g) => g.id),
        ['1', '2'],
      );
      expect(
        filterAllGames(
          games,
          'season_2026_27',
          'valuable',
          2,
          2,
        )!.map((g) => g.id),
        ['3', '4'],
      );
      expect(
        filterAllGames(
          games,
          'season_2026_27',
          'active',
          2,
          1,
        )!.map((g) => g.id),
        ['4', '2'],
      );
      expect(games.first.id, '3');
      expect(filterAllGames(games, 'all_time', 'valuable', 2, 5), isEmpty);
    },
  );
  test(
    'paginated SQL JSON converts to actual exported GamesRow numeric/date fields',
    () {
      final rows = ggGamesRows({
        'games': [
          {
            'id': 'x',
            'lichtwatt': 10,
            'game_date': '2026-09-01T12:30:00',
            'creator_user_id': 'a',
          },
        ],
      });
      expect(rows.single.lichtwatt, 10.0);
      expect(rows.single.gameDate!.day, 1);
      expect(ggGamesRows({'games': []}), isEmpty);
    },
  );
}
