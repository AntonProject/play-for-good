// Isolated widget lifecycle verification; no network or Supabase keys.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pfg_rpc_check/backend/supabase/supabase.dart';
import 'package:pfg_rpc_check/gg_stats_listener.dart';

class FakeChannel implements RealtimeChannel {
  void Function(Map<String, dynamic>)? broadcast;
  void Function(RealtimeSubscribeStatus, Object?)? status;
  @override
  RealtimeChannel onBroadcast({
    required String event,
    required void Function(Map<String, dynamic>) callback,
  }) {
    broadcast = callback;
    return this;
  }

  @override
  RealtimeChannel subscribe([
    void Function(RealtimeSubscribeStatus, Object?)? callback,
    Duration? timeout,
  ]) {
    status = callback;
    return this;
  }

  void changed() => broadcast?.call({'changed_at': 'test'});
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeClient implements SupabaseClient {
  final channels = <FakeChannel>[];
  int removed = 0;
  @override
  RealtimeChannel channel(
    String name, {
    RealtimeChannelConfig opts = const RealtimeChannelConfig(),
  }) {
    final c = FakeChannel();
    channels.add(c);
    return c;
  }

  @override
  Future<String> removeChannel(RealtimeChannel channel) async {
    removed++;
    return 'ok';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'bursts coalesce and in-flight changes cause one subsequent refresh',
    (tester) async {
      final client = FakeClient();
      SupaFlow.client = client;
      final first = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: GgStatsListener(
            refreshKey: 'a',
            onRefresh: () async {
              calls++;
              if (calls == 1) await first.future;
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(calls, 1);
      client.channels.single.changed();
      client.channels.single.changed();
      await tester.pump(const Duration(milliseconds: 600));
      expect(calls, 1);
      first.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(calls, 2);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(client.removed, 1);
    },
  );
  testWidgets(
    'retained pages share a channel; only current page refreshes; Back refreshes',
    (tester) async {
      final client = FakeClient();
      SupaFlow.client = client;
      final nav = GlobalKey<NavigatorState>();
      var a = 0;
      var b = 0;
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: nav,
          home: Scaffold(
            body: GgStatsListener(
              refreshKey: 'a',
              onRefresh: () async {
                a++;
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(a, 1);
      unawaited(
        nav.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              body: GgStatsListener(
                refreshKey: 'b',
                onRefresh: () async {
                  b++;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      expect(client.channels.length, 1);
      final beforeA = a;
      final beforeB = b;
      client.channels.single.changed();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(a, beforeA);
      expect(b, beforeB + 1);
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      expect(a, beforeA + 1);
      expect(client.removed, 0);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(client.removed, 1);
    },
  );
  testWidgets('resume, reconnect and filter-key changes trigger fresh reads', (
    tester,
  ) async {
    final client = FakeClient();
    SupaFlow.client = client;
    var calls = 0;
    final key = GlobalKey();
    Widget page(String filter) => MaterialApp(
      home: GgStatsListener(
        key: key,
        refreshKey: filter,
        onRefresh: () async {
          calls++;
        },
      ),
    );
    await tester.pumpWidget(page('season_2025_26'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(calls, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    client.channels.single.changed();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(calls, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 600));
    expect(calls, 2);
    client.channels.single.status?.call(
      RealtimeSubscribeStatus.subscribed,
      null,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(calls, 3);
    await tester.pumpWidget(page('season_2026_27'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(calls, 4);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
