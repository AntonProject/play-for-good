import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/apbar_b_g/apbar_b_g_widget.dart';
import '/components/dialogs/dein_start/dein_start_widget.dart';
import '/components/dialogs/invite_email/invite_email_widget.dart';
import '/components/dialogs/organisation_list/organisation_list_widget.dart';
import '/components/home_page_guest_content/home_page_guest_content_widget.dart';
import '/components/home_page_score/home_page_score_widget.dart';
import '/components/home_page_score_empty/home_page_score_empty_widget.dart';
import '/components/navbar/navbar_widget.dart';
import '/components/org_comp_home/org_comp_home_widget.dart';
import '/components/organizations_home_empty/organizations_home_empty_widget.dart';
import '/components/pfg_org_sum_home/pfg_org_sum_home_widget.dart';
import '/components/recent_game_home/recent_game_home_widget.dart';
import '/components/recent_games_home_empty/recent_games_home_empty_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  Local state fields for this page.

  bool visible = true;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - isAdmin] action in HomePage widget.
  bool? adminLogin;
  InstantTimer? instantTimer;
  // State field(s) for Column widget.
  ScrollController? columnController;
  Stream<List<GamesRow>>? containerSupabaseStream;
  // Model for homePageScore component.
  late HomePageScoreModel homePageScoreModel1;
  // Model for homePageScore component.
  late HomePageScoreModel homePageScoreModel2;
  // Model for homePageScoreEmpty component.
  late HomePageScoreEmptyModel homePageScoreEmptyModel;
  // Model for homePageGuestContent component.
  late HomePageGuestContentModel homePageGuestContentModel;
  // State field(s) for Row widget.
  ScrollController? rowController;
  // Model for recentGamesHomeEmpty component.
  late RecentGamesHomeEmptyModel recentGamesHomeEmptyModel;
  // Model for pfgOrgSumHome component.
  late PfgOrgSumHomeModel pfgOrgSumHomeModel1;
  // Stores action output result for [Backend Call - Query Rows] action in pfgOrgSumHome widget.
  List<OrganizationRow>? pfg;
  // Model for organizationsHomeEmpty component.
  late OrganizationsHomeEmptyModel organizationsHomeEmptyModel;
  // Model for pfgOrgSumHome component.
  late PfgOrgSumHomeModel pfgOrgSumHomeModel2;
  // Model for navbar component.
  late NavbarModel navbarModel;
  // Model for apbarBG component.
  late ApbarBGModel apbarBGModel;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    homePageScoreModel1 = createModel(context, () => HomePageScoreModel());
    homePageScoreModel2 = createModel(context, () => HomePageScoreModel());
    homePageScoreEmptyModel =
        createModel(context, () => HomePageScoreEmptyModel());
    homePageGuestContentModel =
        createModel(context, () => HomePageGuestContentModel());
    rowController = ScrollController();
    recentGamesHomeEmptyModel =
        createModel(context, () => RecentGamesHomeEmptyModel());
    pfgOrgSumHomeModel1 = createModel(context, () => PfgOrgSumHomeModel());
    organizationsHomeEmptyModel =
        createModel(context, () => OrganizationsHomeEmptyModel());
    pfgOrgSumHomeModel2 = createModel(context, () => PfgOrgSumHomeModel());
    navbarModel = createModel(context, () => NavbarModel());
    apbarBGModel = createModel(context, () => ApbarBGModel());
  }

  @override
  void dispose() {
    instantTimer?.cancel();
    columnController?.dispose();
    homePageScoreModel1.dispose();
    homePageScoreModel2.dispose();
    homePageScoreEmptyModel.dispose();
    homePageGuestContentModel.dispose();
    rowController?.dispose();
    recentGamesHomeEmptyModel.dispose();
    pfgOrgSumHomeModel1.dispose();
    organizationsHomeEmptyModel.dispose();
    pfgOrgSumHomeModel2.dispose();
    navbarModel.dispose();
    apbarBGModel.dispose();
  }
}
