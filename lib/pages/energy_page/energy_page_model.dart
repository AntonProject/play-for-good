import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/apbar_b_g/apbar_b_g_widget.dart';
import '/components/energy_comp/energy_comp_widget.dart';
import '/components/energy_comp_guest/energy_comp_guest_widget.dart';
import '/components/impact_comp/impact_comp_widget.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'energy_page_widget.dart' show EnergyPageWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EnergyPageModel extends FlutterFlowModel<EnergyPageWidget> {
  ///  Local state fields for this page.

  int? pageNumber = 1;

  bool visible = true;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController;
  // Model for energyComp component.
  late EnergyCompModel energyCompModel;
  // Model for energyCompGuest component.
  late EnergyCompGuestModel energyCompGuestModel;
  // Model for navbar component.
  late NavbarModel navbarModel;
  // Model for apbarBG component.
  late ApbarBGModel apbarBGModel;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    energyCompModel = createModel(context, () => EnergyCompModel());
    energyCompGuestModel = createModel(context, () => EnergyCompGuestModel());
    navbarModel = createModel(context, () => NavbarModel());
    apbarBGModel = createModel(context, () => ApbarBGModel());
  }

  @override
  void dispose() {
    columnController?.dispose();
    energyCompModel.dispose();
    energyCompGuestModel.dispose();
    navbarModel.dispose();
    apbarBGModel.dispose();
  }
}
