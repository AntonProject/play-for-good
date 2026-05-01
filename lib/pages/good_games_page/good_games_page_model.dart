import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/dialogs/good_games_players_filters/good_games_players_filters_widget.dart';
import '/components/games_org_comp/games_org_comp_widget.dart';
import '/components/games_user_comp/games_user_comp_widget.dart';
import '/components/image/image_widget.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/request_manager.dart';

import '/index.dart';
import 'good_games_page_widget.dart' show GoodGamesPageWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GoodGamesPageModel extends FlutterFlowModel<GoodGamesPageWidget> {
  ///  Local state fields for this page.

  int tab = 2;

  String? valuePageUser = 'valuable';

  String? periodPageUser = 'gesamt';

  String? valuePageGame = 'valuable';

  String? periodPageGame = 'gesamt';

  int? pageNumberGames = 1;

  int? pageNumberUsers = 1;

  bool visible = true;

  int? limit = 10;

  ///  State fields for stateful widgets in this page.

  Stream<List<GamesRow>>? gamesContainerSupabaseStream1;
  // State field(s) for Column widget.
  ScrollController? columnController1;
  // Model for Image component.
  late ImageModel imageModel1;
  // Model for Image component.
  late ImageModel imageModel2;
  // Model for Image component.
  late ImageModel imageModel3;
  // Model for Image component.
  late ImageModel imageModel4;
  // Model for gamesUserComp component.
  late GamesUserCompModel gamesUserCompModel2;
  Stream<List<GamesRow>>? gamesContainerSupabaseStream2;
  // State field(s) for Column widget.
  ScrollController? columnController2;
  // Model for Image component.
  late ImageModel imageModel5;
  // Model for Image component.
  late ImageModel imageModel6;
  // Model for Image component.
  late ImageModel imageModel7;
  // Model for Image component.
  late ImageModel imageModel8;
  // Model for gamesUserComp component.
  late GamesUserCompModel gamesUserCompModel4;
  // Model for navbar component.
  late NavbarModel navbarModel;

  /// Query cache managers for this widget.

  final _user2Manager = FutureRequestManager<List<UsersRow>>();
  Future<List<UsersRow>> user2({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<UsersRow>> Function() requestFn,
  }) =>
      _user2Manager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearUser2Cache() => _user2Manager.clear();
  void clearUser2CacheKey(String? uniqueKey) =>
      _user2Manager.clearRequest(uniqueKey);

  final _user3Manager = FutureRequestManager<List<UsersRow>>();
  Future<List<UsersRow>> user3({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<UsersRow>> Function() requestFn,
  }) =>
      _user3Manager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearUser3Cache() => _user3Manager.clear();
  void clearUser3CacheKey(String? uniqueKey) =>
      _user3Manager.clearRequest(uniqueKey);

  final _user1Manager = FutureRequestManager<List<UsersRow>>();
  Future<List<UsersRow>> user1({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<UsersRow>> Function() requestFn,
  }) =>
      _user1Manager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearUser1Cache() => _user1Manager.clear();
  void clearUser1CacheKey(String? uniqueKey) =>
      _user1Manager.clearRequest(uniqueKey);

  @override
  void initState(BuildContext context) {
    columnController1 = ScrollController();
    imageModel1 = createModel(context, () => ImageModel());
    imageModel2 = createModel(context, () => ImageModel());
    imageModel3 = createModel(context, () => ImageModel());
    imageModel4 = createModel(context, () => ImageModel());
    gamesUserCompModel2 = createModel(context, () => GamesUserCompModel());
    columnController2 = ScrollController();
    imageModel5 = createModel(context, () => ImageModel());
    imageModel6 = createModel(context, () => ImageModel());
    imageModel7 = createModel(context, () => ImageModel());
    imageModel8 = createModel(context, () => ImageModel());
    gamesUserCompModel4 = createModel(context, () => GamesUserCompModel());
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    columnController1?.dispose();
    imageModel1.dispose();
    imageModel2.dispose();
    imageModel3.dispose();
    imageModel4.dispose();
    gamesUserCompModel2.dispose();
    columnController2?.dispose();
    imageModel5.dispose();
    imageModel6.dispose();
    imageModel7.dispose();
    imageModel8.dispose();
    gamesUserCompModel4.dispose();
    navbarModel.dispose();

    /// Dispose query cache managers for this widget.

    clearUser2Cache();

    clearUser3Cache();

    clearUser1Cache();
  }
}
