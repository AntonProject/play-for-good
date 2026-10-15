import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pfg_rpc_check/backend/supabase/supabase.dart';
import 'package:pfg_rpc_check/custom_code/actions/sign_in_after_otp_verification.dart';

void main() {
  const userId = '00000000-0000-0000-0000-000000000009';
  for (final existingProfile in [false, true]) {
    test(
        'OTP signup preserves test environment with existingProfile=$existingProfile',
        () async {
      final writes = <Map>[];
      final methods = <String>[];
      final transport = MockClient((request) async {
        final path = request.url.path;
        if (path == '/auth/v1/token') return _session(userId);
        expect(path, '/rest/v1/users');
        if (request.method == 'GET') {
          return http.Response(
              jsonEncode(existingProfile
                  ? [
                      {'id': userId}
                    ]
                  : []),
              200,
              headers: {'content-type': 'application/json'},
              request: request);
        }
        methods.add(request.method);
        writes.add(jsonDecode(request.body) as Map);
        return http.Response('', 204, request: request);
      });
      SupaFlow.client = SupabaseClient(
          'https://example.invalid', 'local-test-key',
          httpClient: transport,
          authOptions: const AuthClientOptions(autoRefreshToken: false));
      try {
        expect(
            await signInAfterOtpVerification('fixture@example.invalid',
                'fixture-only', 'signup', 'Fixture', 'Fixture Player', true),
            true);
        expect(methods, [existingProfile ? 'PATCH' : 'POST']);
        expect(writes.single['signup_test'], true);
        expect(writes.single.containsKey('good_power'), false);
      } finally {
        await SupaFlow.client.dispose();
        transport.close();
      }
    });
  }
  test(
      'ordinary login retains five-argument compatibility and does not overwrite signup origin',
      () async {
    var profileRequests = 0;
    final transport = MockClient((request) async {
      if (request.url.path == '/auth/v1/token') return _session(userId);
      profileRequests++;
      return http.Response('', 500);
    });
    SupaFlow.client = SupabaseClient(
        'https://example.invalid', 'local-test-key',
        httpClient: transport,
        authOptions: const AuthClientOptions(autoRefreshToken: false));
    try {
      expect(
          await signInAfterOtpVerification(
              'fixture@example.invalid', 'fixture-only', 'signin', null, null),
          true);
      expect(profileRequests, 0);
    } finally {
      await SupaFlow.client.dispose();
      transport.close();
    }
  });
}

http.Response _session(String userId) {
  final header = base64Url
      .encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'))
      .replaceAll('=', '');
  final claims = base64Url
      .encode(utf8.encode(jsonEncode({'sub': userId, 'exp': 2100000000})))
      .replaceAll('=', '');
  return http.Response(
      jsonEncode({
        'access_token': '$header.$claims.fixture',
        'refresh_token': 'fixture-refresh',
        'token_type': 'bearer',
        'expires_in': 3600,
        'user': {
          'id': userId,
          'email': 'fixture@example.invalid',
          'aud': 'authenticated',
          'created_at': '2026-10-13T00:00:00Z'
        },
      }),
      200,
      headers: {'content-type': 'application/json'});
}
