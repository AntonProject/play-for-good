// Custom Widget: width/height Double, onRefresh Action.
// UTC calendar matches the prepared SQL config. Re-evaluates at midnight
// while visible, so the default/filter catalogue advances without app restart.
import 'dart:async';
import 'package:flutter/material.dart';

class GgCalendarRefresh extends StatefulWidget {
  const GgCalendarRefresh({
    super.key,
    this.width,
    this.height,
    required this.onRefresh,
  });
  final double? width;
  final double? height;
  final Future Function() onRefresh;
  @override
  State<GgCalendarRefresh> createState() => _GgCalendarRefreshState();
}

class _GgCalendarRefreshState extends State<GgCalendarRefresh>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _running = false;
  late DateTime _day;
  DateTime _today() {
    final n = DateTime.now().toUtc();
    return DateTime.utc(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _day = _today();
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final n = DateTime.now().toUtc();
    final next = DateTime.utc(
      n.year,
      n.month,
      n.day + 1,
    ).add(const Duration(milliseconds: 100));
    _timer = Timer(next.difference(n), () {
      unawaited(_changed());
      _schedule();
    });
  }

  Future<void> _changed() async {
    if (!mounted ||
        _running ||
        _today() == _day ||
        !(ModalRoute.of(context)?.isCurrent ?? true))
      return;
    _running = true;
    try {
      await widget.onRefresh();
      _day = _today();
    } catch (error) {
      debugPrint('GG calendar refresh: $error');
    } finally {
      _running = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_changed());
      _schedule();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: widget.width ?? 1, height: widget.height ?? 1);
}
