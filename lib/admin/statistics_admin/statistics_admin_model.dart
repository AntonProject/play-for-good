import '/admin/drawer_admin/drawer_admin_widget.dart';
import '/admin/header_admin/header_admin_widget.dart';
import '/admin/statistic_card_admin/statistic_card_admin_widget.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'statistics_admin_widget.dart' show StatisticsAdminWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StatisticsAdminModel extends FlutterFlowModel<StatisticsAdminWidget> {
  ///  Local state fields for this page.

  int? gamesNum = 0;

  int? usersNum = 0;

  int? postsNum = 0;

  int? orgsNum = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - isAdmin] action in StatisticsAdmin widget.
  bool? admin;
  // Stores action output result for [Custom Action - gamesCount] action in StatisticsAdmin widget.
  int? gamesCount;
  // Stores action output result for [Custom Action - usersCount] action in StatisticsAdmin widget.
  int? usersCount;
  // Stores action output result for [Custom Action - postsCount] action in StatisticsAdmin widget.
  int? postsCount;
  // Stores action output result for [Custom Action - orgsCount] action in StatisticsAdmin widget.
  int? orgCount;
  // Model for DrawerAdmin component.
  late DrawerAdminModel drawerAdminModel1;
  // Model for headerAdmin component.
  late HeaderAdminModel headerAdminModel;
  // State field(s) for Column widget.
  ScrollController? columnController;
  // Model for goodPower.
  late StatisticCardAdminModel goodPowerModel;
  // Model for games.
  late StatisticCardAdminModel gamesModel;
  // Model for users.
  late StatisticCardAdminModel usersModel;
  // Model for posts.
  late StatisticCardAdminModel postsModel;
  // Model for orgs.
  late StatisticCardAdminModel orgsModel;
  // Model for DrawerAdmin component.
  late DrawerAdminModel drawerAdminModel2;

  @override
  void initState(BuildContext context) {
    drawerAdminModel1 = createModel(context, () => DrawerAdminModel());
    headerAdminModel = createModel(context, () => HeaderAdminModel());
    columnController = ScrollController();
    goodPowerModel = createModel(context, () => StatisticCardAdminModel());
    gamesModel = createModel(context, () => StatisticCardAdminModel());
    usersModel = createModel(context, () => StatisticCardAdminModel());
    postsModel = createModel(context, () => StatisticCardAdminModel());
    orgsModel = createModel(context, () => StatisticCardAdminModel());
    drawerAdminModel2 = createModel(context, () => DrawerAdminModel());
  }

  @override
  void dispose() {
    drawerAdminModel1.dispose();
    headerAdminModel.dispose();
    columnController?.dispose();
    goodPowerModel.dispose();
    gamesModel.dispose();
    usersModel.dispose();
    postsModel.dispose();
    orgsModel.dispose();
    drawerAdminModel2.dispose();
  }
}
