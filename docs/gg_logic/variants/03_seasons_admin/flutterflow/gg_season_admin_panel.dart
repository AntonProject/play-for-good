// Local admin screen example. Recreate this form with native FF widgets.
// Custom Widget params: width/height Double, test Boolean.
import 'package:flutter/material.dart';
import '/custom_code/actions/gg_seasons_admin.dart';

class GgSeasonAdminPanel extends StatefulWidget {
  const GgSeasonAdminPanel({
    super.key,
    this.width,
    this.height,
    required this.test,
  });
  final double? width;
  final double? height;
  final bool test;
  @override
  State<GgSeasonAdminPanel> createState() => _GgSeasonAdminPanelState();
}

class _GgSeasonAdminPanelState extends State<GgSeasonAdminPanel> {
  final _key = TextEditingController();
  final _label = TextEditingController();
  final _year = TextEditingController();
  final _start = TextEditingController();
  final _last = TextEditingController();
  List<Map<String, dynamic>> _seasons = [];
  Map<String, dynamic>? _preview;
  bool _busy = false;
  bool _locked = false;
  bool _existing = false;
  String? _error;
  int _request = 0;
  @override
  void initState() {
    super.initState();
    _newSeason();
    _load();
  }

  @override
  void didUpdateWidget(covariant GgSeasonAdminPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.test != widget.test) {
      _preview = null;
      _load();
    }
  }

  @override
  void dispose() {
    for (final c in [_key, _label, _year, _start, _last]) {
      c.dispose();
    }
    super.dispose();
  }

  String _day(dynamic v) =>
      v?.toString().split('T').first.split(' ').first ?? '';
  void _newSeason() {
    final y = _seasons.fold<int>(DateTime.now().year, (year, season) {
      final endYear = season['season_year'] as int;
      return endYear > year ? endYear : year;
    });
    _key.text = 'season_${y}_${((y + 1) % 100).toString().padLeft(2, '0')}';
    _label.text = 'Saison $y/${((y + 1) % 100).toString().padLeft(2, '0')}';
    _year.text = '${y + 1}';
    _start.text = '$y-09-01';
    _last.text = '${y + 1}-06-30';
    _locked = false;
    _existing = false;
    _preview = null;
  }

  void _edit(Map<String, dynamic> s) {
    _key.text = s['season_key'] as String;
    _label.text = s['label'] as String;
    _year.text = '${s['season_year']}';
    _start.text = _day(s['starts_at']);
    _last.text = _day(s['last_day']);
    _locked = s['locked'] == true;
    _existing = true;
    _preview = null;
  }

  Future<void> _run(String operation, Map<String, dynamic> input) async {
    final request = ++_request;
    final environment = widget.test;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final answer = Map<String, dynamic>.from(
        await ggSeasonsAdmin(operation, input, environment) as Map,
      );
      final list = operation == 'list'
          ? answer
          : Map<String, dynamic>.from(
              await ggSeasonsAdmin('list', {}, environment) as Map,
            );
      if (!mounted || request != _request) return;
      setState(() {
        _seasons = (list['seasons'] as List)
            .map((v) => Map<String, dynamic>.from(v as Map))
            .toList();
        if (operation == 'preview') _preview = answer;
        final selected = _seasons.where((s) => s['season_key'] == _key.text);
        if (selected.isNotEmpty) {
          _locked = selected.first['locked'] == true;
          _existing = true;
        }
      });
    } catch (error) {
      if (mounted && request == _request) setState(() => _error = '$error');
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  Future<void> _load() => _run('list', {});
  Widget _field(
    String label,
    TextEditingController controller, {
    bool key = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      enabled: !_busy && !_locked && !(key && _existing),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
  Widget _top(String title, dynamic data) {
    final rows = data is Map && data['top_players'] is List
        ? data['top_players'] as List
        : [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        for (final row in rows)
          ListTile(
            title: Text('${row['rank']}. ${row['display_name']}'),
            trailing: Text('${row['score']}'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.width,
    height: widget.height,
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Saisons — ${widget.test ? 'TEST' : 'PRODUCTION'}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Text(
          'Enddatum einschließlich. Ab dem Folgetag werden die Ergebnisse gespeichert.',
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        for (final s in _seasons)
          ListTile(
            title: Text('${s['label']}'),
            subtitle: Text(
              '${_day(s['starts_at'])} — ${_day(s['last_day'])}\n${s['finalized_at'] == null ? 'Offen / geplant' : 'Abgeschlossen'}',
            ),
            onTap: _busy ? null : () => setState(() => _edit(s)),
          ),
        TextButton(
          onPressed: _busy ? null : () => setState(_newSeason),
          child: const Text('Neue Saison'),
        ),
        _field('Interner Schlüssel', _key, key: true),
        _field('Name', _label),
        _field('Jahr auf dem Banner', _year),
        _field('Beginn YYYY-MM-DD', _start),
        _field('Letzter Tag YYYY-MM-DD', _last),
        if (_locked) const Text('Gespeicherte Saison: Bearbeitung gesperrt.'),
        FilledButton(
          onPressed: _busy || _locked
              ? null
              : () => _run('save', {
                  'season_key': _key.text,
                  'label': _label.text,
                  'season_year': int.tryParse(_year.text),
                  'starts_on': _start.text,
                  'last_day': _last.text,
                }),
          child: const Text('Speichern'),
        ),
        OutlinedButton(
          onPressed: _busy || !_existing
              ? null
              : () => _run('preview', {'season_key': _key.text}),
          child: const Text('MVP / MAP Vorschau'),
        ),
        if (widget.test)
          OutlinedButton(
            onPressed: _busy || !_existing
                ? null
                : () => _run('finalize_test', {'season_key': _key.text}),
            child: const Text('Beendete TEST-Saison abschließen'),
          ),
        if (_preview != null) ...[
          _top('MVP', _preview),
          _top('MAP', _preview!['map']),
        ],
      ],
    ),
  );
}
