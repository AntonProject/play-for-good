import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/dialogs/auth_dialog/auth_dialog_widget.dart';
import '/components/dialogs/followers_list/followers_list_widget.dart';
import '/components/dialogs/invites_list/invites_list_widget.dart';
import '/components/dialogs/profile_edit_dialog/profile_edit_dialog_widget.dart';
import '/components/dialogs/profile_games_orgs_dialog/profile_games_orgs_dialog_widget.dart';
import '/components/dialogs/sponsor_list/sponsor_list_widget.dart';
import '/components/empty_post_profile/empty_post_profile_widget.dart';
import '/components/image/image_widget.dart';
import '/components/org_profile/org_profile_widget.dart';
import '/components/post_comp/post_comp_widget.dart';
import '/components/profile_option/profile_option_widget.dart';
import '/components/user_profile_info_stats_row/user_profile_info_stats_row_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'user_profile_page_widget.dart' show UserProfilePageWidget;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserProfilePageModel extends FlutterFlowModel<UserProfilePageWidget> {
  ///  Local state fields for this page.

  int tab = 1;

  /// Stats's period tab type in info tab: 1 - Aktuelle Saison, 2 - All-Time
  int infoStatsPeriod = 1;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController1;
  // Model for Image component.
  late ImageModel imageModel1;
  Stream<List<GamesRow>>? containerSupabaseStream1;
  // Stores action output result for [Backend Call - Insert Row] action in IconButton widget.
  FollowersRow? follow;
  // Stores action output result for [Backend Call - Delete Row(s)] action in IconButton widget.
  List<FollowersRow>? deleteFollower;
  Stream<List<GamesRow>>? containerSupabaseStream2;
  // Model for userProfileInfoStatsRow component.
  late UserProfileInfoStatsRowModel userProfileInfoStatsRowModel1;
  // Model for userProfileInfoStatsRow component.
  late UserProfileInfoStatsRowModel userProfileInfoStatsRowModel2;
  // Model for userProfileInfoStatsRow component.
  late UserProfileInfoStatsRowModel userProfileInfoStatsRowModel3;
  // Model for userProfileInfoStatsRow component.
  late UserProfileInfoStatsRowModel userProfileInfoStatsRowModel4;
  // Model for userProfileInfoStatsRow component.
  late UserProfileInfoStatsRowModel userProfileInfoStatsRowModel5;
  // Model for userProfileInfoStatsRow component.
  late UserProfileInfoStatsRowModel userProfileInfoStatsRowModel6;
  // Model for userProfileInfoStatsRow component.
  late UserProfileInfoStatsRowModel userProfileInfoStatsRowModel7;
  // Model for userProfileInfoStatsRow component.
  late UserProfileInfoStatsRowModel userProfileInfoStatsRowModel8;
  Stream<List<PostsRow>>? columnSupabaseStream;
  // Model for emptyPostProfile component.
  late EmptyPostProfileModel emptyPostProfileModel1;
  // Model for profileOption component.
  late ProfileOptionModel profileOptionModel1;
  // Stores action output result for [Bottom Sheet - authDialog] action in profileOption widget.
  bool? success;
  // Model for profileOption component.
  late ProfileOptionModel profileOptionModel2;
  // Model for profileOption component.
  late ProfileOptionModel profileOptionModel3;
  // Model for profileOption component.
  late ProfileOptionModel profileOptionModel4;
  // Model for profileOption component.
  late ProfileOptionModel profileOptionModel5;
  // State field(s) for Column widget.
  ScrollController? columnController2;
  // Model for Image component.
  late ImageModel imageModel2;
  // Model for userProfileInfoStatsRow component.
  late UserProfileInfoStatsRowModel userProfileInfoStatsRowModel9;
  // Model for userProfileInfoStatsRow component.
  late UserProfileInfoStatsRowModel userProfileInfoStatsRowModel10;
  // Model for userProfileInfoStatsRow component.
  late UserProfileInfoStatsRowModel userProfileInfoStatsRowModel11;
  // Model for userProfileInfoStatsRow component.
  late UserProfileInfoStatsRowModel userProfileInfoStatsRowModel12;
  // Model for emptyPostProfile component.
  late EmptyPostProfileModel emptyPostProfileModel2;
  // Model for profileOption component.
  late ProfileOptionModel profileOptionModel6;
  // Stores action output result for [Bottom Sheet - authDialog] action in profileOption widget.
  bool? successAuth;
  // Model for profileOption component.
  late ProfileOptionModel profileOptionModel7;
  // Model for profileOption component.
  late ProfileOptionModel profileOptionModel8;
  // Model for profileOption component.
  late ProfileOptionModel profileOptionModel9;
  // Model for profileOption component.
  late ProfileOptionModel profileOptionModel10;
  // Stores action output result for [Bottom Sheet - authDialog] action in Button widget.
  bool? wasSuccessAuth;

  @override
  void initState(BuildContext context) {
    columnController1 = ScrollController();
    imageModel1 = createModel(context, () => ImageModel());
    userProfileInfoStatsRowModel1 =
        createModel(context, () => UserProfileInfoStatsRowModel());
    userProfileInfoStatsRowModel2 =
        createModel(context, () => UserProfileInfoStatsRowModel());
    userProfileInfoStatsRowModel3 =
        createModel(context, () => UserProfileInfoStatsRowModel());
    userProfileInfoStatsRowModel4 =
        createModel(context, () => UserProfileInfoStatsRowModel());
    userProfileInfoStatsRowModel5 =
        createModel(context, () => UserProfileInfoStatsRowModel());
    userProfileInfoStatsRowModel6 =
        createModel(context, () => UserProfileInfoStatsRowModel());
    userProfileInfoStatsRowModel7 =
        createModel(context, () => UserProfileInfoStatsRowModel());
    userProfileInfoStatsRowModel8 =
        createModel(context, () => UserProfileInfoStatsRowModel());
    emptyPostProfileModel1 =
        createModel(context, () => EmptyPostProfileModel());
    profileOptionModel1 = createModel(context, () => ProfileOptionModel());
    profileOptionModel2 = createModel(context, () => ProfileOptionModel());
    profileOptionModel3 = createModel(context, () => ProfileOptionModel());
    profileOptionModel4 = createModel(context, () => ProfileOptionModel());
    profileOptionModel5 = createModel(context, () => ProfileOptionModel());
    columnController2 = ScrollController();
    imageModel2 = createModel(context, () => ImageModel());
    userProfileInfoStatsRowModel9 =
        createModel(context, () => UserProfileInfoStatsRowModel());
    userProfileInfoStatsRowModel10 =
        createModel(context, () => UserProfileInfoStatsRowModel());
    userProfileInfoStatsRowModel11 =
        createModel(context, () => UserProfileInfoStatsRowModel());
    userProfileInfoStatsRowModel12 =
        createModel(context, () => UserProfileInfoStatsRowModel());
    emptyPostProfileModel2 =
        createModel(context, () => EmptyPostProfileModel());
    profileOptionModel6 = createModel(context, () => ProfileOptionModel());
    profileOptionModel7 = createModel(context, () => ProfileOptionModel());
    profileOptionModel8 = createModel(context, () => ProfileOptionModel());
    profileOptionModel9 = createModel(context, () => ProfileOptionModel());
    profileOptionModel10 = createModel(context, () => ProfileOptionModel());
  }

  @override
  void dispose() {
    columnController1?.dispose();
    imageModel1.dispose();
    userProfileInfoStatsRowModel1.dispose();
    userProfileInfoStatsRowModel2.dispose();
    userProfileInfoStatsRowModel3.dispose();
    userProfileInfoStatsRowModel4.dispose();
    userProfileInfoStatsRowModel5.dispose();
    userProfileInfoStatsRowModel6.dispose();
    userProfileInfoStatsRowModel7.dispose();
    userProfileInfoStatsRowModel8.dispose();
    emptyPostProfileModel1.dispose();
    profileOptionModel1.dispose();
    profileOptionModel2.dispose();
    profileOptionModel3.dispose();
    profileOptionModel4.dispose();
    profileOptionModel5.dispose();
    columnController2?.dispose();
    imageModel2.dispose();
    userProfileInfoStatsRowModel9.dispose();
    userProfileInfoStatsRowModel10.dispose();
    userProfileInfoStatsRowModel11.dispose();
    userProfileInfoStatsRowModel12.dispose();
    emptyPostProfileModel2.dispose();
    profileOptionModel6.dispose();
    profileOptionModel7.dispose();
    profileOptionModel8.dispose();
    profileOptionModel9.dispose();
    profileOptionModel10.dispose();
  }
}
