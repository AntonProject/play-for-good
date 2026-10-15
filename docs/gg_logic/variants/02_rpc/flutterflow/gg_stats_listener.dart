// FlutterFlow Custom Widget: GgStatsListener
// Parameters: width/height (Double), refreshKey (String), onRefresh (Action),
// tables (String, optional: comma list; empty = every change).
// Keep FlutterFlow's automatic imports above this code.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';

// Retained pages share one channel. Only the visible page runs its callback.
class _GgStatsBus {
  // Event value: the changed table ('' = unknown/reconnect -> everyone).
  static final _events = StreamController<String>.broadcast();
  static RealtimeChannel? _channel;
  static int _listeners = 0;
  static bool _syncing = false;

  // Data versions for cached FF queries: their cache keys end with App State
  // ggVerGames / ggVerOrganization / ggVerUsers, so a change of the table
  // (Realtime event) makes them load once again; '' (reconnect) bumps all.
  static const _versioned = {'games', 'organization', 'users'};
  static final _pendingVersions = <String>{};
  static Timer? _versionTimer;

  static void _bumpVersion(String table) {
    if (table.isEmpty) {
      _pendingVersions.addAll(_versioned);
    } else if (_versioned.contains(table)) {
      _pendingVersions.add(table);
    } else {
      return;
    }
    // One App State update for a burst of events.
    _versionTimer ??= Timer(const Duration(milliseconds: 300), () {
      _versionTimer = null;
      final tables = Set.of(_pendingVersions);
      _pendingVersions.clear();
      final stamp = DateTime.now().millisecondsSinceEpoch.toString();
      FFAppState().update(() {
        if (tables.contains('games')) FFAppState().ggVerGames = stamp;
        if (tables.contains('organization')) FFAppState().ggVerOrganization = stamp;
        if (tables.contains('users')) FFAppState().ggVerUsers = stamp;
      });
    });
  }

  static StreamSubscription<String> listen(void Function(String table) callback) {
    final subscription = _events.stream.listen(callback);
    _listeners++;
    unawaited(_syncChannel());
    return subscription;
  }

  static Future<void> _syncChannel() async {
    if (_syncing) return;
    _syncing = true;
    try {
      while (_listeners == 0 && _channel != null) {
        final channel = _channel!;
        _channel = null;
        await SupaFlow.client.removeChannel(channel);
      }
      if (_listeners == 0 || _channel != null) return;
      _channel = SupaFlow.client.channel('gg:v2:stats');
      _channel!
          .onBroadcast(
              event: 'changed',
              callback: (payload) {
                final inner = payload['payload'];
                final table = payload['table'] ??
                    (inner is Map ? inner['table'] : null) ??
                    '';
                _bumpVersion('$table');
                _events.add('$table');
              })
          .subscribe((status, error) {
            // Read again after reconnect: events during a disconnect can be missed.
            if (status == RealtimeSubscribeStatus.subscribed) {
              _bumpVersion('');
              _events.add('');
            }
            if (error != null) {
              debugPrint('GgStatsListener subscription error: $error');
            }
          });
    } catch (error) {
      debugPrint('GgStatsListener channel error: $error');
    } finally {
      _syncing = false;
    }
  }

  static void release(StreamSubscription<String> subscription) {
    unawaited(subscription.cancel());
    _listeners--;
    unawaited(_syncChannel());
  }
}

class GgStatsListener extends StatefulWidget {
  const GgStatsListener({
    super.key,
    this.width,
    this.height,
    required this.refreshKey,
    required this.onRefresh,
    this.tables,
  });

  final double? width;
  final double? height;
  final String refreshKey;
  final Future Function() onRefresh;
  final String? tables;

  @override
  State<GgStatsListener> createState() => _GgStatsListenerState();
}

class _GgStatsListenerState extends State<GgStatsListener>
    with WidgetsBindingObserver {
  StreamSubscription<String>? _subscription;
  bool _seen = false;
  Timer? _timer;
  bool _isCurrent = false;
  bool _resumed = true;
  bool _pending = false;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resumed =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _subscription = _GgStatsBus.listen(_onChange);
  }

  void _onChange(String table) {
    final filter = (widget.tables ?? '')
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toSet();
    if (table.isEmpty || filter.isEmpty || filter.contains(table)) {
      _requestRefresh();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ModalRoute.of registers a dependency on route visibility changes.
    // This also refreshes a retained page when another route is popped.
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    final becameCurrent = current && !_isCurrent;
    _isCurrent = current;
    // The first show is loaded by the page's On Load; refresh on later returns.
    if (becameCurrent && _seen) _requestRefresh();
    if (current) _seen = true;
  }

  @override
  void didUpdateWidget(covariant GgStatsListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) _requestRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    if (_resumed) _requestRefresh();
  }

  void _requestRefresh() {
    _pending = true;
    _schedule();
  }

  void _schedule() {
    if (!mounted || !_isCurrent || !_resumed || _running || _timer != null) {
      return;
    }
    // Coalesce a burst without postponing indefinitely during active play.
    _timer = Timer(const Duration(milliseconds: 500), () {
      _timer = null;
      unawaited(_refresh());
    });
  }

  Future<void> _refresh() async {
    if (!mounted || !_isCurrent || !_resumed || !_pending || _running) return;
    _pending = false;
    _running = true;
    try {
      await widget.onRefresh();
    } catch (error) {
      // Keep the previous successful response. Page action handles UI errors.
      debugPrint('GgStatsListener refresh error: $error');
    } finally {
      _running = false;
      if (_pending) _schedule();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    final subscription = _subscription;
    if (subscription != null) _GgStatsBus.release(subscription);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: widget.width ?? 1, height: widget.height ?? 1);
}
