// FlutterFlow Custom Widget: GgStatsListener
// Parameters: width/height (Double), refreshKey (String), onRefresh (Action).
// Keep FlutterFlow's automatic imports above this code.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/backend/supabase/supabase.dart';

// Retained pages share one channel. Only the visible page runs its callback.
class _GgStatsBus {
  static final _events = StreamController<void>.broadcast();
  static RealtimeChannel? _channel;
  static int _listeners = 0;
  static bool _syncing = false;

  static StreamSubscription<void> listen(VoidCallback callback) {
    final subscription = _events.stream.listen((_) => callback());
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
      _channel = SupaFlow.client.channel('gg:stats');
      _channel!
          .onBroadcast(event: 'changed', callback: (_) => _events.add(null))
          .subscribe((status, error) {
            // Read again after reconnect: events during a disconnect can be missed.
            if (status == RealtimeSubscribeStatus.subscribed) {
              _events.add(null);
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

  static void release(StreamSubscription<void> subscription) {
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
  });

  final double? width;
  final double? height;
  final String refreshKey;
  final Future Function() onRefresh;

  @override
  State<GgStatsListener> createState() => _GgStatsListenerState();
}

class _GgStatsListenerState extends State<GgStatsListener>
    with WidgetsBindingObserver {
  StreamSubscription<void>? _subscription;
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
    _subscription = _GgStatsBus.listen(_requestRefresh);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ModalRoute.of registers a dependency on route visibility changes.
    // This also refreshes a retained page when another route is popped.
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    final becameCurrent = current && !_isCurrent;
    _isCurrent = current;
    if (becameCurrent) _requestRefresh();
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
