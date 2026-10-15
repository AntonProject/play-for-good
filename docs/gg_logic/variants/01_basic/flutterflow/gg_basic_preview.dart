// Local visual adapter for data produced by ggBuildLocalData.
// FF params width/height Double, response JSON, profile Boolean.
// Existing FF filter controls/query actions remain outside this widget.
import 'package:flutter/material.dart';

class GgBasicPreview extends StatelessWidget {
  const GgBasicPreview({
    super.key,
    this.width,
    this.height,
    required this.response,
    required this.profile,
  });
  final double? width;
  final double? height;
  final dynamic response;
  final bool profile;
  @override
  Widget build(BuildContext context) {
    final d = response is Map ? response as Map : <String, dynamic>{};
    final p = d['profile'] as Map?;
    final stats = p?['stats'] as Map? ?? {};
    final period = d['period'] as Map? ?? {};
    return SizedBox(
      width: width,
      height: height,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${period['label'] ?? ''}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (profile && p != null) ...[
            Text(
              '${p['all_time']['good_power']} LW',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final a in p['awards'] as List)
                  Chip(
                    label: Text(
                      '${a['category'] == 'active' ? 'MAP' : 'MVP'} ${a['place']} · ${a['season_year']}',
                    ),
                  ),
              ],
            ),
            for (final key in [
              'good_power',
              'good_energy_per_game',
              'games',
              'sponsored_games',
            ])
              ListTile(
                title: Text(key),
                trailing: Text(
                  '${stats[key]['value']} #${stats[key]['rank'] ?? '—'}',
                ),
              ),
          ] else ...[
            Text('Total Good Power: ${d['total_good_power_all_time'] ?? 0}'),
            for (final row in d['players'] as List? ?? [])
              ListTile(
                leading: Text('${row['rank']}'),
                title: Text('${row['display_name'] ?? 'Player'}'),
                subtitle: Text(
                  (row['awards'] as List)
                      .map(
                        (a) =>
                            '${a['category']} ${a['place']} · ${a['season_year']}',
                      )
                      .join(' · '),
                ),
                trailing: Text('${row['score']}'),
              ),
          ],
        ],
      ),
    );
  }
}
