import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pfg_rpc_check/backend/supabase/supabase.dart';
import 'package:pfg_rpc_check/custom_code/actions/gg_v2_profile_stats.dart';

void main() {
  for (final testEnvironment in [false, true]) {
    test('profile action forwards environment=$testEnvironment to RPC', () async {
      const userId = '00000000-0000-0000-0000-000000000001';
      var calls = 0;
      final transport = MockClient((request) async {
        calls++;
        expect(request.method, 'POST');
        expect(request.url.path, '/rest/v1/rpc/gg_v2_profile_stats');
        final body = jsonDecode(request.body) as Map;
        expect(body['p_test'], testEnvironment);
        expect(body['p_user_id'], userId);
        expect(body['p_period'], 'season_2026_27');
        return http.Response(jsonEncode({'user_id': userId, 'test': body['p_test']}),
          200, headers: {'content-type': 'application/json'}, request: request);
      });
      SupaFlow.client = SupabaseClient('https://example.invalid', 'local-test-key',
        httpClient: transport,
        authOptions: const AuthClientOptions(autoRefreshToken: false));
      try {
        final result = await ggV2ProfileStats(userId, 'season_2026_27', testEnvironment);
        expect(result['test'], testEnvironment);
        expect(calls, 1);
      } finally {
        await SupaFlow.client.dispose();
        transport.close();
      }
    });
  }
}
