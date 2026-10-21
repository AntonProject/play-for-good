// Run inside the FlutterFlow AI workspace. Dry-run by default.
// Guest profile places + dialogs (16.10.2026) in ONE FlutterFlow commit:
//   1 guest_places_schema.dart   Data Type GgGuestPlaces, GgRanking.guestPlaces
//   2 transfer.dart (rpc)        ggLoadRanking reads guest_places, ggPlaceLabelOf
//   3 guest_places_profile.dart  profile guest bindings, real season in the filter
//   4 dialog_tap_inside.dart     a tap inside a sheet dialog does not close it
// Needs SQL 02_rpc/iteration1/12_guest_places.sql in Supabase (guest_places);
// without it the guest rows show no place (empty badge), nothing breaks.
// Copy into dsl/ with the gg_ prefix (gg_guest_places_all.dart, gg_transfer.dart,
// gg_guest_places_schema.dart, gg_guest_places_profile.dart, gg_dialog_tap_inside.dart).
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'gg_transfer.dart' show RegisterGgCode;
import 'gg_guest_places_schema.dart' show GuestPlacesSchema;
import 'gg_guest_places_profile.dart' show GuestPlacesProfile;
import 'gg_dialog_tap_inside.dart' show DialogTapInside;

/// Runs [inner] after [after] (the pipeline orders tasks by dependsOn only).
final class Step extends FlutterFlowAITask {
  Step(this.inner, [this.after = const {}]);
  final FlutterFlowAITask inner;
  final Set<String> after;
  @override
  String get name => inner.name;
  @override
  Set<String> get dependsOn => after;
  @override
  bool get skipPushWhenProjectUnchanged => true;
  @override
  void run(TaskContext ctx) => inner.run(ctx);
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = '/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
  final reports = Directory.systemTemp.createTempSync('pfg-gg-guest-places-').path;
  final schema = Step(GuestPlacesSchema());
  final code = Step(RegisterGgCode(root, 'rpc', reports), {schema.name});
  final profile = Step(GuestPlacesProfile(), {code.name});
  final dialogs = Step(DialogTapInside());
  final result = await FlutterFlowAIPipeline(
    apiKey: Platform.environment['FF_API_KEY']!,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [schema, code, profile, dialogs],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Guest profile places per period, real season in the filter, '
        'Supporters value; tap inside sheet dialogs does not close them',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
