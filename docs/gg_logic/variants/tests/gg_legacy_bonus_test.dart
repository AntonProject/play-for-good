import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pfg_rpc_check/backend/supabase/supabase.dart';
import 'package:pfg_rpc_check/custom_code/actions/gg_v2_rankings.dart';
import 'package:pfg_rpc_check/custom_code/actions/gg_v2_profile_stats.dart';

void main() {
  const user = '00000000-0000-0000-0000-000000000001';
  for (final migrated in [false, true]) {
    for (final category in ['valuable', 'active', 'generous', 'social']) {
      test('ranking $category: migrated=$migrated, server values without client +100',
          () async {
        final transport = MockClient((request) async {
          final body = jsonDecode(request.body) as Map;
          expect(body['p_category'], category);
          expect(body['p_test'], true);
          final row = {
            'user_id': user,
            'good_power': 20,
            'score': 20,
            'rank': 2
          };
          return http.Response(
              jsonEncode({
                'signup_bonus_migrated': migrated,
                'category': category,
                'legacy_bonus_users_count': 3,
                'total_good_power': 50,
                'total_good_power_all_time': 80,
                'players': [row],
                'top_players': [row],
                'current_user': row,
              }),
              200,
              headers: {'content-type': 'application/json'},
              request: request);
        });
        SupaFlow.client = SupabaseClient('https://example.invalid', 'test-key',
            httpClient: transport,
            authOptions: const AuthClientOptions(autoRefreshToken: false));
        try {
          final data =
              await ggV2Rankings('season_2026_27', category, 1, 10, user, true);
          expect(data['players'][0]['good_power'], 20);
          expect(data['players'][0]['score'], 20);
          expect(data['players'][0]['rank'], 2);
          expect(data['current_user']['good_power'], 20);
          expect(data['top_players'][0]['good_power'], 20);
          expect(data['total_good_power_all_time'], 80);
          expect(data['players'][0].containsKey('server_good_power'), false);
        } finally {
          await SupaFlow.client.dispose();
          transport.close();
        }
      });
    }
    test('profile: migrated=$migrated, energy and ranks preserved', () async {
      final transport = MockClient((request) async => http.Response(
          jsonEncode({
            'signup_bonus_migrated': migrated,
            'legacy_bonus_users_count': 3,
            'all_time': {'good_power': 20, 'rank': 2},
            'stats': {
              'good_power': {'value': 10, 'rank': 3},
              'good_energy': {'value': 4, 'rank': 5}
            },
            'total_good_power': 50,
            'total_good_power_all_time': 80,
          }),
          200,
          headers: {'content-type': 'application/json'},
          request: request));
      SupaFlow.client = SupabaseClient('https://example.invalid', 'test-key',
          httpClient: transport,
          authOptions: const AuthClientOptions(autoRefreshToken: false));
      try {
        final data = await ggV2ProfileStats(user, 'season_2026_27', false);
        expect(data['all_time']['good_power'], 20);
        expect(data['stats']['good_power']['value'], 10);
        expect(data['stats']['good_power']['rank'], 3);
        expect(data['stats']['good_energy']['value'], 4);
      } finally {
        await SupaFlow.client.dispose();
        transport.close();
      }
    });
  }
}
