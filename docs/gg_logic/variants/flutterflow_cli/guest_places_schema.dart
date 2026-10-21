// Run inside the FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Guest profile places (16.10.2026), step 1 of 3: Data Types only.
//   new Data Type GgGuestPlaces = gg_v2_rankings guest_places
//   GgRanking.guestPlaces (GgGuestPlaces)
// Step 2: transfer.dart (ggLoadRanking reads guest_places, ggPlaceLabelOf).
// Step 3: guest_places_profile.dart (profile page bindings).
// Existing items are left untouched (re-run safe).
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';

final class GuestPlacesSchema extends FlutterFlowAITask {
  @override
  String get name => 'gg-guest-places-schema';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final p = ctx.project;
    FFParameter f(String name, String description) =>
        structField(name, intType, description: description);

    var places = findDataStruct(p, name: 'GgGuestPlaces');
    if (places == null) {
      addDataStruct(p,
          name: 'GgGuestPlaces',
          description: 'Places of the guest demo 100 points (gg_v2_rankings guest_places).',
          fields: [
            f('goodPower', 'Place of 100 Good Power in the period.'),
            f('games', 'Last place: players with games, plus 1.'),
            f('goodPowerPerGame', 'Last place: players with games, plus 1.'),
            f('goodEnergy', 'Last place: players with Good Energy, plus 1.'),
            f('goodEnergyPerGame', 'Last place: players with games, plus 1.'),
            f('sponsoredGames', 'Last place: players with sponsored games, plus 1.'),
            f('allTimeGoodPower', 'Place of 100 Good Power in All-Time (profile header).'),
          ]);
      places = findDataStruct(p, name: 'GgGuestPlaces')!;
      stdout.writeln('data type GgGuestPlaces: 7 fields');
    } else {
      stdout.writeln('data type GgGuestPlaces: exists, kept');
    }

    final ranking = findDataStruct(p, name: 'GgRanking') ?? (throw StateError('GgRanking missing'));
    if (ranking.fields.any((x) => x.identifier.name == 'guestPlaces')) {
      stdout.writeln('GgRanking.guestPlaces: exists, kept');
    } else {
      ranking.fields.add(structField('guestPlaces', dataStructType(places.identifier),
          description: 'Places of the guest demo 100 points.'));
      stdout.writeln('GgRanking.guestPlaces: added');
    }
  }
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [GuestPlacesSchema()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Data Type GgGuestPlaces, GgRanking.guestPlaces',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
