// Run inside a FlutterFlow AI workspace (copied to dsl/). Dry-run by default.
// Sets Clamping scroll physics on the outermost vertical scrollable of the
// user pages whose red header image sits on a white background: no iOS bounce
// that pulls the header away from the top. Nothing else on the pages changes.
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';

const pages = [
  'HomePage', 'GoodNewsPage', 'EnergyPage', 'PlayPage', 'PlayPaymentPage',
  'FinishPage', 'OrganisationPage', 'GamePage', 'GoodGamesPage',
  'userProfilePage',
];

final class ClampPageScroll extends FlutterFlowAITask {
  @override
  String get name => 'clamp-page-scroll';
  @override
  bool get skipPushWhenProjectUnchanged => true;

  @override
  void run(TaskContext ctx) {
    final changed = <String>[];
    for (final w in ctx.project.widgetClasses.values) {
      if (!pages.contains(w.name)) continue;
      void walk(FFNode n, bool inside) {
        var scroll = false;
        if (n.type.name == 'Column' && n.props.column.scrollable) {
          scroll = true;
          if (!inside) {
            n.props.column.scrollPhysics = FFScrollPhysics.FF_SCROLL_PHYSICS_CLAMPING;
            changed.add('${w.name}/${n.key}');
          }
        } else if (n.type.name == 'ListView' &&
            n.props.listView.axis.name != 'HORIZONTAL') {
          scroll = true;
          if (!inside) {
            n.props.listView.scrollPhysics = FFScrollPhysics.FF_SCROLL_PHYSICS_CLAMPING;
            changed.add('${w.name}/${n.key}');
          }
        }
        for (final c in n.children) walk(c, inside || scroll);
      }
      walk(w.node, false);
    }
    final missing = pages.where((p) => !changed.any((c) => c.startsWith('$p/')));
    if (missing.isNotEmpty) throw StateError('No page scroll found: $missing');
    stdout.writeln('Clamping set on ${changed.length} scrollables: $changed');
  }
}

Future<void> main(List<String> args) async {
  final key = Platform.environment['FF_API_KEY'] ??
      Platform.environment['FLUTTERFLOW_API_KEY'];
  if (key == null || key.isEmpty) throw StateError('FlutterFlow key missing');
  final apply = args.contains('--apply');
  final result = await FlutterFlowAIPipeline(
    apiKey: key,
    project: PipelineProject.existing('play-for-good-o0lpcq'),
    tasks: [ClampPageScroll()],
    source: PipelineSource.paths([Platform.script.toFilePath()]),
    commitMessage: 'Clamp page scroll: no top overscroll under red headers',
    dryRun: !apply,
    refreshContext: false,
  ).run();
  for (final t in result.taskResults) stdout.writeln(t.summary);
  for (final d in result.diagnostics) if (d.isError) stdout.writeln(d);
  stdout.writeln('success=${result.success} blocked=${result.validationBlocked} '
      'dryRun=${!apply} commit=${result.commitId}');
  if (!result.success || result.validationBlocked) exitCode = 1;
}
