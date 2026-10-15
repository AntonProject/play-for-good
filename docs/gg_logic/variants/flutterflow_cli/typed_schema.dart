// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Step 1a of the typed Good Games data (docs/gg_logic/TYPED_SCHEMA.md):
// enums, Data Types mirroring the gg_v2_* RPC responses (all fields, service
// ones included) and persisted App State caches typed with them.
// Nothing else changes: pages, actions and the JSON caches stay as they are.
// Existing items with the same name are left untouched (re-run safe).
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';

final class TypedSchema extends FlutterFlowAITask {
  @override
  String get name => 'gg-typed-schema';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    final report = <String>[];

    FFIdentifier enum_(String name, List<String> values, String description) {
      final e = findEnum(p, name: name);
      if (e != null) {
        report.add('enum $name: exists, kept');
        return e.identifier;
      }
      report.add('enum $name: ${values.join(', ')}');
      return addEnum(p, name: name, values: values, description: description);
    }

    final structs = <String, FFIdentifier>{};
    FFDataTypeV2 t(String name) => dataStructType(structs[name] ?? (throw StateError('$name not defined yet')));
    void struct(String name, String description, List<FFParameter> fields) {
      final s = findDataStruct(p, name: name);
      if (s != null) {
        structs[name] = s.identifier;
        report.add('data type $name: exists, kept');
        return;
      }
      structs[name] = addDataStruct(p, name: name, fields: fields, description: description);
      report.add('data type $name: ${fields.length} fields');
    }

    FFParameter f(String name, FFDataTypeV2 type, String description, {bool list = false}) =>
        structField(name, type, description: description, isList: list);

    // Enums
    final category = enumType(enum_('GgCategory', ['valuable', 'active', 'generous', 'social'],
        'Good Games ranking category (valuable = MVP / Good Power, active = MAP / games).'));
    final badge = enumType(enum_('GgBadge',
        ['mvp_gold', 'mvp_silver', 'mvp_bronze', 'active_fire', 'map_silver', 'map_bronze'],
        'Season award badge (MAP 1st place = active_fire).'));
    final layout = enumType(enum_('GgLayoutMode', ['current', 'finished'],
        'Ranking layout: current period, or finished = a closed season (RPC "final").'));

    // Data Types, dependencies first
    struct('GgPeriod', 'A period from gg_v2 (season or fixed period).', [
      f('key', stringType, 'Period key (season_2026_27, this_month, all_time, ...).'),
      f('label', stringType, 'Display name.'),
      f('seasonYear', intType, 'Season end year; null for non-season periods.'),
      f('isCompleted', boolType, 'The period has ended.'),
      f('start', dateTimeType, 'Start (UTC, inclusive); null for All-Time.'),
      f('endExclusive', dateTimeType, 'End (UTC, exclusive).'),
      f('timezone', stringType, 'Time zone of the boundaries (UTC).'),
    ]);
    struct('GgAward', 'A season award of a player.', [
      f('badge', badge, 'Badge.'),
      f('place', intType, 'Place 1-3.'),
      f('category', category, 'Category of the award.'),
      f('season', stringType, 'Season key.'),
      f('seasonLabel', stringType, 'Season name.'),
      f('seasonYear', intType, 'Season end year.'),
      f('seasonStart', dateTimeType, 'Season start (UTC).'),
    ]);
    struct('GgAwardFlags', 'Which badges a player has.', [
      f('mvpGold', boolType, 'MVP 1st place.'),
      f('mvpSilver', boolType, 'MVP 2nd place.'),
      f('mvpBronze', boolType, 'MVP 3rd place.'),
      f('activeFire', boolType, 'MAP 1st place.'),
      f('mapSilver', boolType, 'MAP 2nd place.'),
      f('mapBronze', boolType, 'MAP 3rd place.'),
    ]);
    struct('GgPlayer', 'A ranking row.', [
      f('userId', stringType, 'User id.'),
      f('rank', intType, 'Place in the selected category.'),
      f('score', doubleType, 'Value of the selected category.'),
      f('displayName', stringType, 'Username.'),
      f('firstName', stringType, 'First name.'),
      f('surname', stringType, 'Surname.'),
      f('photoUrl', imagePathType, 'Avatar.'),
      f('goodPower', doubleType, 'Good Power = game + invite + bonus power.'),
      f('gamePower', doubleType, 'Power from completed games.'),
      f('invitePower', doubleType, 'Power from used invites.'),
      f('bonusPower', doubleType, 'Signup bonus (+100) in the period.'),
      f('gamesCount', intType, 'Completed games.'),
      f('awards', t('GgAward'), 'Season awards.', list: true),
      f('awardFlags', t('GgAwardFlags'), 'Badge flags.'),
    ]);
    struct('GgMetric', 'One profile metric.', [
      f('value', doubleType, 'Value.'),
      f('rank', intType, 'Place among all players.'),
    ]);
    struct('GgRanking', 'Response of gg_v2_rankings.', [
      f('requestedPeriod', stringType, 'Period as requested.'),
      f('requestedCategory', stringType, 'Category as requested.'),
      f('requestedUserId', stringType, 'User id as requested.'),
      f('period', t('GgPeriod'), 'Resolved period.'),
      f('availablePeriods', t('GgPeriod'), 'Seasons and fixed periods.', list: true),
      f('category', category, 'Resolved category.'),
      f('layoutMode', layout, 'current / finished.'),
      f('resultsFinalized', boolType, 'Frozen season results are shown.'),
      f('awardsSeason', stringType, 'Season whose medals are shown.'),
      f('topPlayers', t('GgPlayer'), 'Top players.', list: true),
      f('players', t('GgPlayer'), 'Players of the current page.', list: true),
      f('currentUser', t('GgPlayer'), 'Row of the requested user.'),
      f('guestRank', intType, 'Place a guest would get.'),
      f('page', intType, 'Page number.'),
      f('pageSize', intType, 'Page size.'),
      f('totalCount', intType, 'Players in the ranking.'),
      f('hasMore', boolType, 'More pages exist.'),
      f('totalGoodPower', doubleType, 'Sum of Good Power in the period.'),
      f('totalGoodPowerAllTime', doubleType, 'Sum of Good Power all time.'),
      f('maxGoodPower', doubleType, 'Highest Good Power in the period.'),
      f('test', boolType, 'Environment: true = test builds.'),
      f('signupBonusMigrated', boolType, 'Signup +100 is read from the ledger.'),
      f('legacyBonusUsersCount', intType, 'Users counted by the legacy +100.'),
    ]);
    struct('GgProfileStats', 'Response of gg_v2_profile_stats.', [
      f('userId', stringType, 'User id.'),
      f('displayName', stringType, 'Username.'),
      f('photoUrl', imagePathType, 'Avatar.'),
      f('requestedPeriod', stringType, 'Period as requested.'),
      f('period', t('GgPeriod'), 'Resolved period.'),
      f('availablePeriods', t('GgPeriod'), 'Seasons and fixed periods.', list: true),
      f('layoutMode', layout, 'current / finished.'),
      f('resultsFinalized', boolType, 'Frozen season results are shown.'),
      f('awardsSeason', stringType, 'Season whose medals are shown.'),
      f('goodPower', t('GgMetric'), 'Good Power.'),
      f('games', t('GgMetric'), 'Completed games.'),
      f('goodPowerPerGame', t('GgMetric'), 'Good Power per game.'),
      f('goodEnergy', t('GgMetric'), 'Good Energy.'),
      f('goodEnergyPerGame', t('GgMetric'), 'Good Energy per game.'),
      f('sponsoredGames', t('GgMetric'), 'Sponsored games.'),
      f('allTimeRank', intType, 'All-time Good Power place.'),
      f('allTimeGoodPower', doubleType, 'All-time Good Power.'),
      f('allTimeGamesCount', intType, 'All-time games.'),
      f('awards', t('GgAward'), 'Awards of all seasons.', list: true),
      f('awardFlags', t('GgAwardFlags'), 'Badge flags.'),
      f('totalGoodPower', doubleType, 'Sum of Good Power in the period.'),
      f('totalGoodPowerAllTime', doubleType, 'Sum of Good Power all time.'),
      f('test', boolType, 'Environment: true = test builds.'),
      f('signupBonusMigrated', boolType, 'Signup +100 is read from the ledger.'),
      f('legacyBonusUsersCount', intType, 'Users counted by the legacy +100.'),
    ]);
    struct('GgGamesPage', 'Response of gg_v2_games without the games (they are GamesRow).', [
      f('userId', stringType, 'User id.'),
      f('requestedPeriod', stringType, 'Period as requested.'),
      f('requestedCategory', stringType, 'Category as requested.'),
      f('period', t('GgPeriod'), 'Resolved period.'),
      f('availablePeriods', t('GgPeriod'), 'Seasons and fixed periods.', list: true),
      f('category', category, 'Resolved category.'),
      f('layoutMode', layout, 'current / finished.'),
      f('resultsFinalized', boolType, 'Frozen season results are shown.'),
      f('awardsSeason', stringType, 'Season whose medals are shown.'),
      f('page', intType, 'Page number.'),
      f('pageSize', intType, 'Page size.'),
      f('hasMore', boolType, 'More pages exist.'),
      f('test', boolType, 'Environment: true = test builds.'),
      f('signupBonusMigrated', boolType, 'Signup +100 is read from the ledger.'),
      f('legacyBonusUsersCount', intType, 'Users counted by the legacy +100.'),
    ]);
    List<FFParameter> entry(FFParameter data) => [
          f('key', stringType, 'Cache key (period, category, page, environment, user).'),
          f('savedAt', dateTimeType, 'When the response was saved.'),
          f('version', intType, 'Schema version; entries of another version are ignored.'),
          data,
        ];
    struct('GgRankingEntry', 'Cached gg_v2_rankings response.',
        entry(f('data', t('GgRanking'), 'Response.')));
    struct('GgStatsEntry', 'Cached gg_v2_profile_stats response.',
        entry(f('data', t('GgProfileStats'), 'Response.')));
    struct('GgGamesEntry', 'Cached gg_v2_games response.', [
      ...entry(f('meta', t('GgGamesPage'), 'Response without games.')),
      f('games', jsonType, 'Rows of the games table (read as GamesRow).', list: true),
    ]);

    // Persisted App State caches
    void cache(String name, String struct, String description) {
      if (p.appState.fields.any((x) => x.parameter.identifier.name == name)) {
        report.add('app state $name: exists, kept');
        return;
      }
      final inner = t(struct);
      // List type as the SDK's listOf helper builds it: subType on the outer type.
      final type = FFDataTypeV2(listType: inner)..subType = inner.subType.deepCopy();
      addAppStateField(p, name: name, type: type, description: description, persisted: true);
      report.add('app state $name: List<$struct>, persisted');
    }
    cache('ggRankingCache', 'GgRankingEntry', 'Last ranking responses (Good Games, Home, guest profile).');
    cache('ggStatsCache', 'GgStatsEntry', 'Last profile statistics responses.');
    cache('ggGamesCache', 'GgGamesEntry', 'Last games list responses.');

    stdout.writeln(report.join('\n'));
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [TypedSchema()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Good Games: Data Types, enums and typed caches',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
