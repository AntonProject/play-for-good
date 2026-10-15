// Local profile statistics example. Native FF keeps its profile header/social links.
// Custom Widget params width/height Double, userId String, test Boolean.
import 'package:flutter/material.dart';
import '/custom_code/actions/gg_v2_profile_stats.dart';
import '/custom_code/widgets/gg_stats_listener.dart';

class GgV2ProfilePanel extends StatefulWidget {
  const GgV2ProfilePanel({
    super.key,
    this.width,
    this.height,
    required this.userId,
    required this.test,
  });
  final double? width;
  final double? height;
  final String userId;
  final bool test;
  @override
  State<GgV2ProfilePanel> createState() => _GgV2ProfilePanelState();
}

class _GgV2ProfilePanelState extends State<GgV2ProfilePanel> {
  Map<String, dynamic>? _data;
  Map<String, String> _periods = {'all_time': 'All-Time'};
  String _selected = 'auto';
  String _applied = 'auto';
  String? _error;
  bool _followDefault = true;
  bool _loading = false;
  int _request = 0;
  @override
  void didUpdateWidget(covariant GgV2ProfilePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId || oldWidget.test != widget.test) {
      _data = null;
      _selected = _applied = 'auto';
      _followDefault = true;
      _load();
    }
  }

  Future<void> _load() async {
    if (widget.userId.isEmpty || widget.userId == 'guest') return;
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = Map<String, dynamic>.from(
        await ggV2ProfileStats(
              widget.userId,
              _followDefault ? 'auto' : _applied,
              widget.test,
            )
            as Map,
      );
      if (!mounted || request != _request) return;
      setState(() {
        _data = d;
        _periods = {
          for (final p in d['available_periods'] as List)
            p['key'] as String: p['label'] as String,
        };
        if (_followDefault) {
          if (_selected == _applied) _selected = d['period']['key'] as String;
          _applied = d['period']['key'] as String;
        }
        // Preserve an explicitly selected older season while the catalogue advances.
        _periods.putIfAbsent(_applied, () => d['period']['label'] as String);
      });
    } catch (e) {
      if (mounted && request == _request) setState(() => _error = '$e');
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  Widget _value(String title, dynamic metric) => ListTile(
    title: Text(title),
    trailing: Text('${metric?['value'] ?? 0}  #${metric?['rank'] ?? '—'}'),
  );
  @override
  Widget build(BuildContext context) {
    final stats = _data?['stats'] as Map? ?? {};
    final awards = _data?['awards'] as List? ?? [];
    final dirty = _selected != _applied;
    final guest = widget.userId.isEmpty || widget.userId == 'guest';
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (guest)
                const Text('100 LW — Gastvorschau')
              else ...[
                Text(
                  '${_data?['all_time']?['good_power'] ?? '—'} LW',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text('All-Time #${_data?['all_time']?['rank'] ?? '—'}'),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final a in awards)
                      Chip(
                        label: Text(
                          '${a['category'] == 'active' ? 'MAP' : 'MVP'} ${a['place']} · ${a['season_year']}',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _periods.containsKey(_selected)
                            ? _selected
                            : 'all_time',
                        items: _periods.entries
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.key,
                                child: Text(p.value),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selected = v);
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: dirty && !_loading
                          ? () {
                              setState(() {
                                _applied = _selected;
                                _followDefault = false;
                              });
                              _load();
                            }
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: dirty ? Colors.black : Colors.white,
                        foregroundColor: dirty ? Colors.white : Colors.black,
                      ),
                      icon: const Icon(Icons.check),
                    ),
                  ],
                ),
                if (_loading) const LinearProgressIndicator(),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                _value('Total Good Power', stats['good_power']),
                _value('Punkte per Game', stats['good_energy']),
                _value('Good Games', stats['games']),
                _value('Gesponserte Games', stats['sponsored_games']),
              ],
            ],
          ),
          Positioned(
            left: 0,
            top: 0,
            child: GgStatsListener(
              refreshKey: '${widget.userId}/${widget.test}',
              onRefresh: _load,
            ),
          ),
        ],
      ),
    );
  }
}
