import 'package:flutter_test/flutter_test.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_period_key.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_period_label.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_total_power.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_metric_value.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_metric_rank.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_is_final_season.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_has_award.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_show_current_place.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_show_final_place.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_place.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_row_style.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_player_row.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_awards.dart';
import 'package:pfg_rpc_check/custom_code/functions/gg_filters_changed.dart';

void main() {
  final player = {
    'user_id': 'a',
    'rank': 5,
    'score': 17,
    'good_power': 20,
    'awards': [
      {
        'season': 'season_2025_26',
        'season_year': 2026,
        'category': 'valuable',
        'place': 1,
        'badge': 'mvp_gold'
      },
      {
        'season': 'season_2025_26',
        'season_year': 2026,
        'category': 'active',
        'place': 2,
        'badge': 'map_silver'
      },
      {
        'season': 'season_2024_25',
        'season_year': 2025,
        'category': 'valuable',
        'place': 3,
        'badge': 'mvp_bronze'
      },
    ],
  };
  test('enum names become backend keys and readable labels', () {
    expect(ggPeriodKey('season_26_27'), 'season_2026_27');
    expect(ggPeriodLabel('season_26_27', null), 'Saison 2026/27');
    expect(ggPeriodLabel('gesamt', null), 'All-Time');
    expect(ggPeriodLabel('dieser_monat', null), 'Diesen Monat');
    expect(
        ggPeriodLabel('auto', {
          'period': {'key': 'season_2027_07_01', 'label': 'Saison 2027/28'}
        }),
        'Saison 2027/28');
  });
  test('profile values/ranks are period data; header remains All-Time', () {
    final profile = {
      'all_time': {'good_power': 1000, 'rank': 2},
      'stats': {
        'good_power': {'value': 50, 'rank': 4},
        'good_energy': {'value': 12, 'rank': 3}
      },
      'total_good_power_all_time': 2300
    };
    expect(ggMetricValue(profile, 'good_power', false), 50);
    expect(ggMetricValue(profile, 'good_power', true), 1000);
    expect(ggMetricValue(profile, 'good_energy', false), 12);
    expect(ggMetricRank(profile, 'good_energy', false), 3);
    expect(ggMetricRank(profile, 'good_power', true), 2);
    expect(ggTotalPower(profile), 2300);
    expect(ggMetricValue(player, 'score', false), 17);
    expect(ggMetricRank(player, 'score', false), 5);
    expect(ggMetricRank(null, 'score', false), 0);
  });
  test(
      'MVP medal persists in MAP rank5; two categories and all profile seasons',
      () {
    expect(ggHasAward(player, 'valuable', 1, null), true);
    expect(ggHasAward(player, 'active', 2, null), true);
    expect(ggHasAward(player, 'active', 1, null), false);
    expect(ggHasAward(player, 'valuable', 1, 'season_26_27'), false);
    final all = ggAwards(player, null);
    expect(all.map((a) => a['category']), ['valuable', 'valuable', 'active']);
    expect(ggAwards(player, 'season_25_26').length, 2);
    expect(ggHasAward({'rank': 1, 'awards': []}, 'valuable', 1, null), false);
  });
  test(
      'row colors/current numbers depend on selected rank and period completion',
      () {
    final active = {'category': 'active', 'layout_mode': 'current'};
    final row = {'rank': 2};
    expect(ggRowStyle(active, row), 'current_second');
    expect(ggShowCurrentPlace(active, row, 'active', 2), true);
    expect(ggShowCurrentPlace(active, row, 'valuable', 2), false);
    final closed = {'category': 'active', 'layout_mode': 'final'};
    expect(ggIsFinalSeason(closed), true);
    expect(ggRowStyle(closed, row), 'final_second');
    expect(ggShowCurrentPlace(closed, row, 'active', 2), false);
    expect(ggShowFinalPlace(closed, row, 'active', 2), true);
    expect(ggShowFinalPlace(closed, row, 'valuable', 2), false);
    expect(ggShowFinalPlace(active, row, 'active', 2), false);
    expect(ggPlace({'current_user': {'rank': 7}, 'guest_rank': 40}), 7);
    expect(ggPlace({'current_user': null, 'guest_rank': 40}), 40);
    expect(ggPlace({'current_user': {'rank': null}, 'guest_rank': 40, 'pagination': {'total_count': 13}}), 14);
    expect(ggPlace(null), 0);
    expect(ggRowStyle(closed, player), 'none');
    expect(
        ggIsFinalSeason({
          'period': {'season_year': null, 'is_completed': true}
        }),
        false);
  });
  test(
      'current user outside page is available; unchanged aliases are not dirty',
      () {
    expect(
        ggPlayerRow({'players': [], 'current_user': player}, 'a')['rank'], 5);
    expect(ggPlayerRow({'players': []}, 'a'), isEmpty);
    expect(
        ggFiltersChanged(
            'season_26_27', 'season_2026_27', 'valuable', 'valuable'),
        false);
    expect(
        ggFiltersChanged(
            'season_26_27', 'season_2026_27', 'active', 'valuable'),
        true);
  });
}
