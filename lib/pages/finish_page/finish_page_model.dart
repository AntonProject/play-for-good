import '/backend/supabase/supabase.dart';
import '/components/dialogs/berechnung_dialog/berechnung_dialog_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'finish_page_widget.dart' show FinishPageWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FinishPageModel extends FlutterFlowModel<FinishPageWidget> {
  ///  Local state fields for this page.

  int? tab = 1;

  bool visible = false;

  GamesRow? game;

  ///  State fields for stateful widgets in this page.

  Stream<List<TransactionsRow>>? finishPageSupabaseStream;
  // Stores action output result for [Backend Call - Query Rows] action in FinishPage widget.
  List<GamesRow>? queryGame;
  // State field(s) for Column widget.
  ScrollController? columnController;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
  }

  @override
  void dispose() {
    columnController?.dispose();
  }
}
