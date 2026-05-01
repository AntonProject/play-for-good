import '/admin/drawer_admin/drawer_admin_widget.dart';
import '/admin/header_admin/header_admin_widget.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'organisation_details_admin_widget.dart'
    show OrganisationDetailsAdminWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class OrganisationDetailsAdminModel
    extends FlutterFlowModel<OrganisationDetailsAdminWidget> {
  ///  Local state fields for this page.

  String? photo;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - isAdmin] action in OrganisationDetailsAdmin widget.
  bool? admin;
  // Model for DrawerAdmin component.
  late DrawerAdminModel drawerAdminModel1;
  // Model for headerAdmin component.
  late HeaderAdminModel headerAdminModel;
  // Stores action output result for [Backend Call - API (getInfoStripe)] action in IconButton widget.
  ApiCallResponse? getInfo;
  // Stores action output result for [Backend Call - API (updatePayout)] action in IconButton widget.
  ApiCallResponse? updatePayout;
  // Stores action output result for [Backend Call - API (syncStripeAccount)] action in IconButton widget.
  ApiCallResponse? sync;
  // Stores action output result for [Backend Call - Query Rows] action in IconButton widget.
  List<OrganizationRow>? org;
  // State field(s) for Column widget.
  ScrollController? columnController;
  Stream<List<OrganizationRow>>? columnSupabaseStream;
  // Model for DrawerAdmin component.
  late DrawerAdminModel drawerAdminModel2;

  @override
  void initState(BuildContext context) {
    drawerAdminModel1 = createModel(context, () => DrawerAdminModel());
    headerAdminModel = createModel(context, () => HeaderAdminModel());
    columnController = ScrollController();
    drawerAdminModel2 = createModel(context, () => DrawerAdminModel());
  }

  @override
  void dispose() {
    drawerAdminModel1.dispose();
    headerAdminModel.dispose();
    columnController?.dispose();
    drawerAdminModel2.dispose();
  }
}
