import '/backend/supabase/supabase.dart';
import '/components/dialogs/berechnung_dialog/berechnung_dialog_widget.dart';
import '/components/image/image_widget.dart';
import '/components/org_comp/org_comp_widget.dart';
import '/components/pfg_org_sum/pfg_org_sum_widget.dart';
import '/components/team_sum/team_sum_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'game_page_widget.dart' show GamePageWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GamePageModel extends FlutterFlowModel<GamePageWidget> {
  ///  Local state fields for this page.

  bool visible = true;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController;
  // Model for Image component.
  late ImageModel imageModel;
  // Model for orgComp component.
  late OrgCompModel orgCompModel1;
  // Model for teamSum component.
  late TeamSumModel teamSumModel1;
  // Model for teamSum component.
  late TeamSumModel teamSumModel2;
  // Model for orgComp component.
  late OrgCompModel orgCompModel2;
  // Model for pfgOrgSum component.
  late PfgOrgSumModel pfgOrgSumModel1;
  // Model for pfgOrgSum component.
  late PfgOrgSumModel pfgOrgSumModel2;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    imageModel = createModel(context, () => ImageModel());
    orgCompModel1 = createModel(context, () => OrgCompModel());
    teamSumModel1 = createModel(context, () => TeamSumModel());
    teamSumModel2 = createModel(context, () => TeamSumModel());
    orgCompModel2 = createModel(context, () => OrgCompModel());
    pfgOrgSumModel1 = createModel(context, () => PfgOrgSumModel());
    pfgOrgSumModel2 = createModel(context, () => PfgOrgSumModel());
  }

  @override
  void dispose() {
    columnController?.dispose();
    imageModel.dispose();
    orgCompModel1.dispose();
    teamSumModel1.dispose();
    teamSumModel2.dispose();
    orgCompModel2.dispose();
    pfgOrgSumModel1.dispose();
    pfgOrgSumModel2.dispose();
  }
}
