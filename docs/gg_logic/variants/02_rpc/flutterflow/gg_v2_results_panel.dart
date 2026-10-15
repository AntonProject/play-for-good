// FlutterFlow Custom Widget: GgV2ResultsPanel.
// Renders the Good Games ranking or the current user's paginated games from RPC.
import '/custom_code/actions/gg_v2_rankings.dart';
import '/custom_code/actions/gg_v2_games.dart';
import '/custom_code/actions/gg_v2_profile_stats.dart';
import '/custom_code/widgets/gg_stats_listener.dart';
import 'package:flutter/material.dart';

class GgV2ResultsPanel extends StatefulWidget {
  const GgV2ResultsPanel({
    super.key,
    this.width,
    this.height,
    required this.tab,
    required this.userId,
    required this.test,
  });

  final double? width;
  final double? height;
  // 2 = Good Heart Games ranking, 1 = Meine Games.
  final int tab;
  final String? userId;
  final bool test;

  @override
  State<GgV2ResultsPanel> createState() => _GgV2ResultsPanelState();
}

class _GgV2ResultsPanelState extends State<GgV2ResultsPanel> {
  late String _period;
  late String _appliedPeriod;
  String _category = 'valuable';
  String _appliedCategory = 'valuable';
  int _page = 1;
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _ranking;
  Map<String, dynamic>? _games;
  Map<String, dynamic>? _stats;
  int _request = 0;
  bool _followDefault = true;

  Map<String, String> _periods = <String, String>{
    'season_2026_27': 'Saison 2026/27',
    'season_2025_26': 'Saison 2025/26',
    'last_month': 'Letzten Monat',
    'this_month': 'Diesen Monat',
    'all_time': 'All-Time',
  };

  @override
  void initState() {
    super.initState();
    _period = 'auto';
    _appliedPeriod = _period;
    _addDefaultSeason();
  }

  void _addDefaultSeason() {
    if (_period == 'auto') return;
    if (!_periods.containsKey(_period)) {
      final parts = _period.split('_');
      _periods = {_period: 'Saison ${parts[1]}/${parts[2]}', ..._periods};
    }
  }

  void _updatePeriods(Map response) {
    final active = response['period'] as Map?;
    if (_followDefault && active?['key'] is String) {
      if (_period == _appliedPeriod) _period = active!['key'] as String;
      _appliedPeriod = active!['key'] as String;
    }
    final rows = response['available_periods'];
    if (rows is! List) return;
    final periods = <String, String>{
      for (final row in rows.whereType<Map>())
        if (row['key'] is String && row['label'] is String)
          row['key'] as String: row['label'] as String,
    };
    if (periods.isNotEmpty) {
      _periods = periods;
      _addDefaultSeason();
    }
  }

  @override
  void didUpdateWidget(covariant GgV2ResultsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab ||
        oldWidget.userId != widget.userId ||
        oldWidget.test != widget.test) {
      _page = 1;
      _load();
    }
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.tab == 2) {
        final response = await ggV2Rankings(
          _followDefault ? 'auto' : _appliedPeriod,
          _appliedCategory,
          _page,
          10,
          widget.userId,
          widget.test,
        );
        if (!mounted || request != _request) return;
        setState(() {
          _ranking = Map<String, dynamic>.from(response as Map);
          _updatePeriods(_ranking!);
        });
      } else if (widget.userId != null &&
          widget.userId!.isNotEmpty &&
          widget.userId != 'guest') {
        final results = await Future.wait<dynamic>([
          ggV2Games(
            widget.userId!,
            _followDefault ? 'auto' : _appliedPeriod,
            _appliedCategory,
            _page,
            10,
            widget.test,
          ),
          ggV2ProfileStats(
            widget.userId!,
            _followDefault ? 'auto' : _appliedPeriod,
            widget.test,
          ),
        ]);
        if (!mounted || request != _request) return;
        setState(() {
          _games = Map<String, dynamic>.from(results[0] as Map);
          _stats = Map<String, dynamic>.from(results[1] as Map);
          _updatePeriods(_stats!);
        });
      }
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(() => _error = 'Не удалось загрузить данные: $error');
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  String _number(dynamic value) {
    if (value == null) return '0';
    if (value is num)
      return value % 1 == 0
          ? value.toInt().toString()
          : value.toStringAsFixed(1);
    return value.toString();
  }

  List<Map<String, dynamic>> _rows(dynamic value) => value is List
      ? value
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList()
      : const [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 150, 20, 110),
            children: [
              Row(
                children: [
                  Expanded(child: _periodPicker(theme)),
                  const SizedBox(width: 8),
                  Expanded(child: _categoryPicker(theme)),
                  IconButton.filled(
                    tooltip: 'Filter anwenden',
                    onPressed: _filtersChanged ? _applyFilters : null,
                    style: IconButton.styleFrom(
                      backgroundColor: _filtersChanged
                          ? Colors.black
                          : Colors.white,
                      foregroundColor: _filtersChanged
                          ? Colors.white
                          : Colors.black,
                    ),
                    icon: const Icon(Icons.check),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_loading && _ranking == null && _games == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                _message(theme, _error!)
              else if (widget.tab == 2)
                _rankingBody(theme)
              else
                _gamesBody(theme),
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

  Widget _periodPicker(ThemeData theme) => DropdownButtonFormField<String>(
    isExpanded: true,
    value: _periods.containsKey(_period) ? _period : 'all_time',
    decoration: const InputDecoration(
      labelText: 'Zeitrahmen',
      border: OutlineInputBorder(),
    ),
    items: _periods.entries
        .map(
          (entry) =>
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        )
        .toList(),
    onChanged: (value) {
      if (value == null) return;
      setState(() => _period = value);
    },
  );

  Widget _categoryPicker(ThemeData theme) => DropdownButtonFormField<String>(
    isExpanded: true,
    value: _category,
    decoration: const InputDecoration(
      labelText: 'Kategorie',
      border: OutlineInputBorder(),
    ),
    items: const [
      DropdownMenuItem(value: 'valuable', child: Text('Most Valuable Player')),
      DropdownMenuItem(value: 'active', child: Text('Most Active Player')),
    ],
    onChanged: (value) {
      if (value == null) return;
      setState(() => _category = value);
    },
  );

  bool get _filtersChanged =>
      _period != _appliedPeriod || _category != _appliedCategory;

  void _applyFilters() {
    setState(() {
      _followDefault = false;
      _appliedPeriod = _period;
      _appliedCategory = _category;
      _page = 1;
    });
    _load();
  }

  Widget _card(ThemeData theme, Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );

  Widget _rankingBody(ThemeData theme) {
    final data = _ranking ?? const <String, dynamic>{};
    final period = data['period'] is Map
        ? Map<String, dynamic>.from(data['period'] as Map)
        : const <String, dynamic>{};
    final players = _rows(data['players']);
    final top = _rows(data['top_players']);
    final current = data['current_user'] is Map
        ? Map<String, dynamic>.from(data['current_user'] as Map)
        : null;
    final shown = players.map((row) => row['user_id']).toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _card(
          theme,
          Column(
            children: [
              Text(
                'GOOD HEART GAMES ${period['season_year'] ?? ''}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _number(data['total_good_power_all_time']),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text('Total Good Power'),
            ],
          ),
        ),
        if (top.isNotEmpty)
          _card(
            theme,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: top
                  .asMap()
                  .entries
                  .map(
                    (entry) => Flexible(
                      child: Column(
                        children: [
                          Text(
                            period['is_completed'] == true
                                ? ['🥇', '🥈', '🥉'][entry.key]
                                : '${entry.key + 1}',
                            style: const TextStyle(fontSize: 28),
                          ),
                          Text(
                            '${entry.value['display_name'] ?? 'Player'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(_number(entry.value['score'])),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        _card(
          theme,
          Column(
            children: [
              for (final row in players) _playerRow(theme, row),
              if (players.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Noch keine Ergebnisse für diesen Zeitraum.'),
                ),
              if (current != null &&
                  !shown.contains(current['user_id']) &&
                  current['rank'] != null)
                _playerRow(theme, current, highlight: true),
            ],
          ),
        ),
        if (_loading) const LinearProgressIndicator(),
        Text(
          'Good Power im Zeitraum: ${_number(data['total_good_power'])}',
          textAlign: TextAlign.center,
        ),
        Text(
          'Zeitraum: ${period['label'] ?? _periods[_period]}',
          textAlign: TextAlign.center,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _page > 1 && !_loading
                  ? () {
                      setState(() => _page--);
                      _load();
                    }
                  : null,
              child: const Text('Zurück'),
            ),
            Text('Seite $_page'),
            TextButton(
              onPressed: data['pagination']?['has_more'] == true && !_loading
                  ? () {
                      setState(() => _page++);
                      _load();
                    }
                  : null,
              child: const Text('Weiter'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _playerRow(
    ThemeData theme,
    Map<String, dynamic> row, {
    bool highlight = false,
  }) {
    final badges = _rows(row['awards']).map((award) {
      final place = award['place'];
      final active = award['category'] == 'active';
      final icon = active && place == 1
          ? '🔥'
          : place == 1
          ? '🏆'
          : place == 2
          ? '🥈'
          : '🥉';
      return '$icon ${active ? 'MAP' : 'MVP'} ${award['season_year']}';
    }).toList();
    return Container(
      color: highlight ? theme.colorScheme.primaryContainer : null,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 34, child: Text('${row['rank'] ?? '—'}')),
          if (row['photo_url'] is String &&
              (row['photo_url'] as String).isNotEmpty)
            CircleAvatar(
              radius: 17,
              backgroundImage: NetworkImage(row['photo_url'] as String),
            )
          else
            const CircleAvatar(
              radius: 17,
              child: Icon(Icons.person_outline, size: 18),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${row['display_name'] ?? 'Player'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (badges.isNotEmpty)
                  Text(
                    badges.join('  '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            _number(row['score']),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _gamesBody(ThemeData theme) {
    if (widget.userId == null || widget.userId == 'guest') {
      return _message(theme, 'Melde dich an, um deine Good Games zu sehen.');
    }
    final data = _games ?? const <String, dynamic>{};
    final stats = _stats?['stats'] is Map
        ? Map<String, dynamic>.from(_stats!['stats'] as Map)
        : const <String, dynamic>{};
    final games = _rows(data['games']);
    final pagination = data['pagination'] is Map
        ? Map<String, dynamic>.from(data['pagination'] as Map)
        : const <String, dynamic>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _card(
          theme,
          Column(
            children: [
              Text('Total Good Power', style: theme.textTheme.titleMedium),
              Text(
                _number(
                  stats['good_power'] is Map
                      ? ((stats['good_power'] as Map)['value'] as num? ?? 0)
                      : 0,
                ),
                style: theme.textTheme.headlineMedium,
              ),
              Text(
                'Rang #${stats['good_power'] is Map ? (stats['good_power'] as Map)['rank'] ?? '—' : '—'}',
              ),
            ],
          ),
        ),
        _card(
          theme,
          Column(
            children: [
              for (var index = 0; index < games.length; index++)
                ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    child: Text('${(_page - 1) * 10 + index + 1}'),
                  ),
                  title: Text(
                    '${games[index]['name'] ?? games[index]['title'] ?? 'Good Game'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(_number(games[index]['lichtwatt'])),
                  subtitle: Text('${games[index]['game_date'] ?? ''}'),
                ),
              if (games.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Keine Good Games in diesem Zeitraum.'),
                ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _page > 1
                  ? () {
                      setState(() => _page--);
                      _load();
                    }
                  : null,
              child: const Text('Zurück'),
            ),
            Text('Seite $_page'),
            TextButton(
              onPressed: pagination['has_more'] == true
                  ? () {
                      setState(() => _page++);
                      _load();
                    }
                  : null,
              child: const Text('Weiter'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _message(ThemeData theme, String text) => _card(theme, Text(text));
}
