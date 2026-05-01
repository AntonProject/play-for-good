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
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (Theme.of(context).brightness == Brightness.dark) {
        setDarkModeSetting(context, ThemeMode.light);
      }
      await actions.setStatusBarColor(
        true,
      );
      FFAppState().refreshDate = getCurrentTimestamp;
      FFAppState().update(() {});
      if (isWeb) {
        if (!kDebugMode) {
          _model.adminLogin = await actions.isAdmin(
            currentUserUid,
          );
          if (_model.adminLogin!) {
            context.goNamed(
              StatisticsAdminWidget.routeName,
              extra: <String, dynamic>{
                '__transition_info__': TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.fade,
                  duration: Duration(milliseconds: 0),
                ),
              },
            );

            FFAppState().adminPage = AdminPages.statistics.name;
            FFAppState().update(() {});
          } else {
            context.goNamed(
              LoginAdminWidget.routeName,
              extra: <String, dynamic>{
                '__transition_info__': TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.fade,
                  duration: Duration(milliseconds: 0),
                ),
              },
            );
          }

          return;
        }
      }
      if (!FFAppState().hasGuestGetLichtwatt && !loggedIn) {
        await Future.delayed(
          Duration(
            milliseconds: 3500,
          ),
        );
        await showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Color(0x66000000),
          context: context,
          builder: (context) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Padding(
                padding: MediaQuery.viewInsetsOf(context),
                child: DeinStartWidget(),
              ),
            );
          },
        ).then((value) => safeSetState(() {}));

        FFAppState().hasGuestGetLichtwatt = true;
        FFAppState().update(() {});
      }
      unawaited(
        () async {}(),
      );
      _model.instantTimer = InstantTimer.periodic(
        duration: Duration(milliseconds: 5000),
        callback: (timer) async {
          await actions.setStatusBarColor(
            false,
          );
        },
        startImmediately: true,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
        title: 'HomePage',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Stack(
              children: [
                FutureBuilder<List<UsersRow>>(
                  future: FFAppState().user(
                    uniqueQueryKey:
                        '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                    requestFn: () => UsersTable().querySingleRow(
                      queryFn: (q) => q.eqOrNull(
                        'id',
                        currentUserUid,
                      ),
                    ),
                  ),
                  builder: (context, snapshot) {
                    // Customize what your widget looks like when it's loading.
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          width: 40.0,
                          height: 40.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.transparent,
                            ),
                          ),
                        ),
                      );
                    }
                    List<UsersRow> columnUsersRowList = snapshot.data!;

                    final columnUsersRow = columnUsersRowList.isNotEmpty
                        ? columnUsersRowList.first
                        : null;

                    return SingleChildScrollView(
                      controller: _model.columnController,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Stack(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            children: [
                              Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  minHeight: 350.0,
                                  maxHeight: 350.0,
                                ),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: Image.asset(
                                      'assets/images/Wallet.png',
                                    ).image,
                                  ),
                                ),
                              ),
                              StreamBuilder<List<GamesRow>>(
                                stream: FFAppState().games(
                                  uniqueQueryKey:
                                      '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                                  requestFn: () =>
                                      _model.containerSupabaseStream ??=
                                          SupaFlow.client
                                              .from("games")
                                              .stream(primaryKey: ['id'])
                                              .eqOrNull(
                                                'status',
                                                'completed',
                                              )
                                              .map((list) => list
                                                  .map((item) => GamesRow(item))
                                                  .toList()),
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  List<GamesRow> containerGamesRowList =
                                      snapshot.data!;

                                  return Container(
                                    decoration: BoxDecoration(),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: 600.0,
                                      ),
                                      decoration: BoxDecoration(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Builder(
                                            builder: (context) {
                                              if (loggedIn == true) {
                                                return Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          12.0, 0.0, 12.0, 0.0),
                                                  child: FutureBuilder<
                                                      List<InvitesRow>>(
                                                    future:
                                                        FFAppState().invites(
                                                      uniqueQueryKey:
                                                          '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                                                      requestFn: () =>
                                                          InvitesTable()
                                                              .queryRows(
                                                        queryFn: (q) => q
                                                            .eqOrNull(
                                                              'inviter_user_id',
                                                              currentUserUid,
                                                            )
                                                            .eqOrNull(
                                                              'was_used',
                                                              true,
                                                            ),
                                                      ),
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
                                                      // Customize what your widget looks like when it's loading.
                                                      if (!snapshot.hasData) {
                                                        return Center(
                                                          child: SizedBox(
                                                            width: 50,
                                                            height: 50,
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                      Color>(
                                                                Colors
                                                                    .transparent,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      List<InvitesRow>
                                                          containerInvitesRowList =
                                                          snapshot.data!;

                                                      return Container(
                                                        width: double.infinity,
                                                        constraints:
                                                            BoxConstraints(
                                                          minHeight: 560.0,
                                                          maxHeight: 650.0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      28.0),
                                                        ),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            wrapWithModel(
                                                              model: _model
                                                                  .homePageScoreModel1,
                                                              updateCallback: () =>
                                                                  safeSetState(
                                                                      () {}),
                                                              updateOnChange:
                                                                  true,
                                                              child:
                                                                  HomePageScoreWidget(
                                                                games: containerGamesRowList
                                                                    .where((e) =>
                                                                        e.status ==
                                                                        'completed')
                                                                    .toList(),
                                                                invites:
                                                                    containerInvitesRowList,
                                                              ),
                                                            ),
                                                            if (false)
                                                              Builder(
                                                                builder:
                                                                    (context) {
                                                                  if (valueOrDefault<
                                                                      bool>(
                                                                    (containerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList().length >
                                                                            0) ||
                                                                        (containerInvitesRowList.length >
                                                                            0),
                                                                    false,
                                                                  )) {
                                                                    return wrapWithModel(
                                                                      model: _model
                                                                          .homePageScoreModel2,
                                                                      updateCallback:
                                                                          () =>
                                                                              safeSetState(() {}),
                                                                      updateOnChange:
                                                                          true,
                                                                      child:
                                                                          HomePageScoreWidget(
                                                                        games: containerGamesRowList
                                                                            .where((e) =>
                                                                                e.status ==
                                                                                'completed')
                                                                            .toList(),
                                                                        invites:
                                                                            containerInvitesRowList,
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    return wrapWithModel(
                                                                      model: _model
                                                                          .homePageScoreEmptyModel,
                                                                      updateCallback:
                                                                          () =>
                                                                              safeSetState(() {}),
                                                                      child:
                                                                          HomePageScoreEmptyWidget(),
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          24.0,
                                                                          0.0,
                                                                          24.0,
                                                                          20.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            60.0,
                                                                        height:
                                                                            60.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryBackground,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              blurRadius: 2.0,
                                                                              color: Color(0x0F000000),
                                                                              offset: Offset(
                                                                                0.0,
                                                                                2.0,
                                                                              ),
                                                                              spreadRadius: 2.0,
                                                                            )
                                                                          ],
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Align(
                                                                              alignment: AlignmentDirectional(0.0, 0.0),
                                                                              child: Container(
                                                                                width: 40.0,
                                                                                height: 40.0,
                                                                                clipBehavior: Clip.antiAlias,
                                                                                decoration: BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                                child: Image.asset(
                                                                                  'assets/images/ball.png',
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Align(
                                                                              alignment: AlignmentDirectional(0.0, 0.0),
                                                                              child: FlutterFlowIconButton(
                                                                                borderRadius: 99.0,
                                                                                buttonSize: 80.0,
                                                                                icon: Icon(
                                                                                  Icons.arrow_back,
                                                                                  size: 0.0,
                                                                                ),
                                                                                showLoadingIndicator: true,
                                                                                onPressed: () async {
                                                                                  context.pushNamed(PlayPageWidget.routeName);
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        'Play',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                              fontSize: 12.0,
                                                                              letterSpacing: -0.24,
                                                                              fontWeight: FontWeight.bold,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            60.0,
                                                                        height:
                                                                            60.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryBackground,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              blurRadius: 2.0,
                                                                              color: Color(0x0F000000),
                                                                              offset: Offset(
                                                                                0.0,
                                                                                2.0,
                                                                              ),
                                                                              spreadRadius: 2.0,
                                                                            )
                                                                          ],
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Align(
                                                                              alignment: AlignmentDirectional(0.0, 0.0),
                                                                              child: Container(
                                                                                width: 40.0,
                                                                                height: 40.0,
                                                                                clipBehavior: Clip.antiAlias,
                                                                                decoration: BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                                child: Image.asset(
                                                                                  'assets/images/l48xv_.png',
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Align(
                                                                              alignment: AlignmentDirectional(0.0, 0.0),
                                                                              child: FlutterFlowIconButton(
                                                                                borderRadius: 99.0,
                                                                                buttonSize: 80.0,
                                                                                icon: Icon(
                                                                                  Icons.arrow_back,
                                                                                  size: 0.0,
                                                                                ),
                                                                                showLoadingIndicator: true,
                                                                                onPressed: () async {
                                                                                  showModalBottomSheet(
                                                                                    isScrollControlled: true,
                                                                                    backgroundColor: Colors.transparent,
                                                                                    barrierColor: Color(0x66000000),
                                                                                    context: context,
                                                                                    builder: (context) {
                                                                                      return GestureDetector(
                                                                                        onTap: () {
                                                                                          FocusScope.of(context).unfocus();
                                                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                                                        },
                                                                                        child: Padding(
                                                                                          padding: MediaQuery.viewInsetsOf(context),
                                                                                          child: InviteEmailWidget(),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  ).then((value) => safeSetState(() {}));
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        'Invite',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                              fontSize: 12.0,
                                                                              letterSpacing: -0.24,
                                                                              fontWeight: FontWeight.bold,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              } else {
                                                return Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          12.0, 0.0, 12.0, 0.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    constraints: BoxConstraints(
                                                      minHeight: 600.0,
                                                      maxHeight: 650.0,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              28.0),
                                                    ),
                                                    child: wrapWithModel(
                                                      model: _model
                                                          .homePageGuestContentModel,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          HomePageGuestContentWidget(
                                                        games:
                                                            containerGamesRowList,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    24.0, 36.0, 24.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Letzte Good Games',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 18.0,
                                                            letterSpacing:
                                                                valueOrDefault<
                                                                    double>(
                                                              -0.63,
                                                              -0.63,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            lineHeight: 1.4,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                                if (containerGamesRowList
                                                        .where((e) =>
                                                            (e.status ==
                                                                'completed') &&
                                                            (e.creatorUserId ==
                                                                currentUserUid))
                                                        .toList()
                                                        .length >
                                                    5)
                                                  InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      context.pushNamed(
                                                        GoodGamesPageWidget
                                                            .routeName,
                                                        queryParameters: {
                                                          'periodGames':
                                                              serializeParam(
                                                            Period.gesamt.name,
                                                            ParamType.String,
                                                          ),
                                                          'valueGames':
                                                              serializeParam(
                                                            RatingGamesFilter
                                                                .recent.name,
                                                            ParamType.String,
                                                          ),
                                                        }.withoutNulls,
                                                        extra: <String,
                                                            dynamic>{
                                                          '__transition_info__':
                                                              TransitionInfo(
                                                            hasTransition: true,
                                                            transitionType:
                                                                PageTransitionType
                                                                    .fade,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    0),
                                                          ),
                                                        },
                                                      );
                                                    },
                                                    child: Text(
                                                      'Mehr',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing:
                                                                valueOrDefault<
                                                                    double>(
                                                              -0.4,
                                                              -0.4,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            lineHeight: 1.5,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional(-1.0, 0.0),
                                            child: Builder(
                                              builder: (context) {
                                                if (containerGamesRowList
                                                        .where((e) =>
                                                            (e.status ==
                                                                'completed') &&
                                                            (e.creatorUserId ==
                                                                currentUserUid))
                                                        .toList()
                                                        .length >
                                                    0) {
                                                  return Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            -1.0, 0.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  8.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Builder(
                                                        builder: (context) {
                                                          final games = containerGamesRowList
                                                              .where((e) =>
                                                                  (e.status ==
                                                                      'completed') &&
                                                                  (e.creatorUserId ==
                                                                      currentUserUid))
                                                              .toList()
                                                              .sortedList(
                                                                  keyOf: (e) =>
                                                                      e.createdAt,
                                                                  desc: true)
                                                              .toList()
                                                              .take(10)
                                                              .toList();

                                                          return SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            controller: _model
                                                                .rowController,
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: List.generate(
                                                                      games
                                                                          .length,
                                                                      (gamesIndex) {
                                                                final gamesItem =
                                                                    games[
                                                                        gamesIndex];
                                                                return Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          -1.0,
                                                                          0.0),
                                                                  child:
                                                                      RecentGameHomeWidget(
                                                                    key: Key(
                                                                        'Keyuwa_${gamesIndex}_of_${games.length}'),
                                                                    game:
                                                                        gamesItem,
                                                                  ),
                                                                );
                                                              })
                                                                  .divide(SizedBox(
                                                                      width:
                                                                          24.0))
                                                                  .addToStart(
                                                                      SizedBox(
                                                                          width:
                                                                              12.0))
                                                                  .addToEnd(
                                                                      SizedBox(
                                                                          width:
                                                                              12.0)),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return wrapWithModel(
                                                    model: _model
                                                        .recentGamesHomeEmptyModel,
                                                    updateCallback: () =>
                                                        safeSetState(() {}),
                                                    child:
                                                        RecentGamesHomeEmptyWidget(),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional(-1.0, 0.0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      24.0, 36.0, 24.0, 0.0),
                                              child: Text(
                                                'Zuletzt unterstütze Organisationen',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          fontSize: 18.0,
                                                          letterSpacing:
                                                              valueOrDefault<
                                                                  double>(
                                                            -0.63,
                                                            -0.63,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          lineHeight: 1.4,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ),
                                          Builder(
                                            builder: (context) {
                                              if (valueOrDefault<bool>(
                                                containerGamesRowList
                                                        .where((e) =>
                                                            (e.status ==
                                                                'completed') &&
                                                            (e.creatorUserId ==
                                                                currentUserUid))
                                                        .toList()
                                                        .length >
                                                    0,
                                                false,
                                              )) {
                                                return Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          12.0, 8.0, 12.0, 0.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16.0),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(12.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          if (valueOrDefault<
                                                              bool>(
                                                            functions.lastGamesOrg(containerGamesRowList
                                                                        .where((e) =>
                                                                            (e.status ==
                                                                                'completed') &&
                                                                            (e.creatorUserId ==
                                                                                currentUserUid))
                                                                        .toList()) !=
                                                                    null &&
                                                                (functions.lastGamesOrg(containerGamesRowList
                                                                        .where((e) =>
                                                                            (e.status ==
                                                                                'completed') &&
                                                                            (e.creatorUserId ==
                                                                                currentUserUid))
                                                                        .toList()))!
                                                                    .isNotEmpty,
                                                            false,
                                                          ))
                                                            Builder(
                                                              builder:
                                                                  (context) {
                                                                final org = (functions
                                                                            .lastGamesOrg(containerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList())
                                                                            ?.sortedList(keyOf: (e) => e.createdAt, desc: true)
                                                                            ?.toList() ??
                                                                        [])
                                                                    .take(5)
                                                                    .toList();

                                                                return Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: List
                                                                      .generate(
                                                                          org.length,
                                                                          (orgIndex) {
                                                                    final orgItem =
                                                                        org[orgIndex];
                                                                    return Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              16.0,
                                                                              0.0,
                                                                              16.0),
                                                                          child:
                                                                              OrgCompHomeWidget(
                                                                            key:
                                                                                Key('Keyj1q_${orgIndex}_of_${org.length}'),
                                                                            game:
                                                                                orgItem,
                                                                            games:
                                                                                containerGamesRowList,
                                                                          ),
                                                                        ),
                                                                        Divider(
                                                                          height:
                                                                              1.0,
                                                                          thickness:
                                                                              1.0,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }),
                                                                );
                                                              },
                                                            ),
                                                          if (valueOrDefault<
                                                              bool>(
                                                            containerGamesRowList
                                                                .where((e) =>
                                                                    (e.additionalDonationMoney! >
                                                                        0.0) &&
                                                                    ((e.status ==
                                                                            'completed') &&
                                                                        (e.creatorUserId ==
                                                                            currentUserUid)))
                                                                .toList()
                                                                .isNotEmpty,
                                                            false,
                                                          ))
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          16.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            8.0,
                                                                            16.0),
                                                                    child:
                                                                        InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      focusColor:
                                                                          Colors
                                                                              .transparent,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () async {
                                                                        _model.pfg =
                                                                            await OrganizationTable().queryRows(
                                                                          queryFn: (q) =>
                                                                              q.eqOrNull(
                                                                            'sponsor',
                                                                            true,
                                                                          ),
                                                                        );

                                                                        context
                                                                            .pushNamed(
                                                                          OrganisationPageWidget
                                                                              .routeName,
                                                                          queryParameters:
                                                                              {
                                                                            'orgId':
                                                                                serializeParam(
                                                                              _model.pfg?.firstOrNull?.id,
                                                                              ParamType.String,
                                                                            ),
                                                                          }.withoutNulls,
                                                                          extra: <String,
                                                                              dynamic>{
                                                                            '__transition_info__':
                                                                                TransitionInfo(
                                                                              hasTransition: true,
                                                                              transitionType: PageTransitionType.fade,
                                                                              duration: Duration(milliseconds: 0),
                                                                            ),
                                                                          },
                                                                        );

                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      child:
                                                                          wrapWithModel(
                                                                        model: _model
                                                                            .pfgOrgSumHomeModel1,
                                                                        updateCallback:
                                                                            () =>
                                                                                safeSetState(() {}),
                                                                        child:
                                                                            PfgOrgSumHomeWidget(
                                                                          sum: functions.totalSum(containerGamesRowList
                                                                              .where((e) => (e.additionalDonationMoney! > 0.0) && ((e.status == 'completed') && (e.creatorUserId == currentUserUid)))
                                                                              .toList()
                                                                              .map((e) => e.additionalDonationMoney)
                                                                              .withoutNulls
                                                                              .toList()),
                                                                          date: containerGamesRowList
                                                                              .where((e) => (e.additionalDonationMoney! > 0.0) && ((e.status == 'completed') && (e.creatorUserId == currentUserUid)))
                                                                              .toList()
                                                                              .lastOrNull!
                                                                              .createdAt,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                    height: 1.0,
                                                                    thickness:
                                                                        1.0,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    16.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Container(
                                                                  width: 40.0,
                                                                  height: 40.0,
                                                                  decoration:
                                                                      BoxDecoration(),
                                                                  child: Icon(
                                                                    FFIcons
                                                                        .kdonate,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 32.0,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      if (!valueOrDefault<
                                                                          bool>(
                                                                        functions.lastGamesOrg(containerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList()) !=
                                                                                null &&
                                                                            (functions.lastGamesOrg(containerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList()))!.isNotEmpty,
                                                                        false,
                                                                      ))
                                                                        AutoSizeText(
                                                                          'Keine Organisationen gewählt',
                                                                          maxLines:
                                                                              1,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                                letterSpacing: 0.0,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      AutoSizeText(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          !valueOrDefault<bool>(
                                                                            functions.lastGamesOrg(containerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList()) != null &&
                                                                                (functions.lastGamesOrg(containerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList()))!.isNotEmpty,
                                                                            false,
                                                                          )
                                                                              ? 'Finde deine Organisation'
                                                                              : 'Neue Organisation',
                                                                          'Neue Organisation',
                                                                        ),
                                                                        maxLines:
                                                                            1,
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.4,
                                                                                -0.4,
                                                                              ),
                                                                              fontWeight: FontWeight.bold,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                            ),
                                                                      ),
                                                                      if (valueOrDefault<
                                                                          bool>(
                                                                        functions.lastGamesOrg(containerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList()) !=
                                                                                null &&
                                                                            (functions.lastGamesOrg(containerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList()))!.isNotEmpty,
                                                                        false,
                                                                      ))
                                                                        Text(
                                                                          'Als Nächstes unterstützen',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                                letterSpacing: valueOrDefault<double>(
                                                                                  -0.35,
                                                                                  -0.35,
                                                                                ),
                                                                                lineHeight: 1.5,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 56.0,
                                                                  height: 40.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            99.0),
                                                                  ),
                                                                  child:
                                                                      FlutterFlowIconButton(
                                                                    borderColor:
                                                                        Colors
                                                                            .transparent,
                                                                    borderRadius:
                                                                        99.0,
                                                                    buttonSize:
                                                                        40.0,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    icon: Icon(
                                                                      FFIcons
                                                                          .kplus,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      size:
                                                                          24.0,
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      showModalBottomSheet(
                                                                        isScrollControlled:
                                                                            true,
                                                                        backgroundColor:
                                                                            Colors.transparent,
                                                                        useSafeArea:
                                                                            true,
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(context).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: OrganisationListWidget(
                                                                                userId: currentUserUid,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ).then((value) =>
                                                                          safeSetState(
                                                                              () {}));
                                                                    },
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 16.0)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return wrapWithModel(
                                                  model: _model
                                                      .organizationsHomeEmptyModel,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child:
                                                      OrganizationsHomeEmptyWidget(
                                                    userId: currentUserUid,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          if (valueOrDefault<bool>(
                                            containerGamesRowList
                                                .where((e) =>
                                                    (e.sponsorMoney! > 0.0) &&
                                                    ((e.status ==
                                                            'completed') &&
                                                        (e.creatorUserId ==
                                                            currentUserUid)))
                                                .toList()
                                                .isNotEmpty,
                                            false,
                                          ))
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                24.0,
                                                                36.0,
                                                                24.0,
                                                                0.0),
                                                    child: Text(
                                                      'Deine Sponsoren (1)',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 18.0,
                                                            letterSpacing:
                                                                valueOrDefault<
                                                                    double>(
                                                              -0.63,
                                                              -0.63,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            lineHeight: 1.4,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          12.0, 8.0, 12.0, 0.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    constraints: BoxConstraints(
                                                      minHeight: 100.0,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16.0),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  20.0,
                                                                  16.0,
                                                                  20.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          wrapWithModel(
                                                            model: _model
                                                                .pfgOrgSumHomeModel2,
                                                            updateCallback: () =>
                                                                safeSetState(
                                                                    () {}),
                                                            child:
                                                                PfgOrgSumHomeWidget(
                                                              sum: functions.totalSum(containerGamesRowList
                                                                  .where((e) =>
                                                                      (e.sponsorMoney! >
                                                                          0.0) &&
                                                                      ((e.status ==
                                                                              'completed') &&
                                                                          (e.creatorUserId ==
                                                                              currentUserUid)))
                                                                  .toList()
                                                                  .map((e) => e
                                                                      .sponsorMoney)
                                                                  .withoutNulls
                                                                  .toList()),
                                                              date: containerGamesRowList
                                                                  .where((e) =>
                                                                      e.sponsorMoney! >
                                                                      0.0)
                                                                  .toList()
                                                                  .lastOrNull!
                                                                  .createdAt,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    12.0, 36.0, 12.0, 0.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                unawaited(
                                                  () async {
                                                    await launchURL(
                                                        FFAppConstants
                                                            .feedbacks);
                                                  }(),
                                                );
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                constraints: BoxConstraints(
                                                  minHeight: 80.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .focus,
                                                    width: 2.0,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          14.0, 4.0, 14.0, 4.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    16.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Icon(
                                                          FFIcons.khelpCircle,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          size: 32.0,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          'Hilfe & Feedback',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                letterSpacing:
                                                                    valueOrDefault<
                                                                        double>(
                                                                  -0.4,
                                                                  -0.4,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                lineHeight: 1.5,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    16.0,
                                                                    0.0),
                                                        child: Container(
                                                          width: 56.0,
                                                          height: 40.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondary,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        99.0),
                                                          ),
                                                          child:
                                                              FlutterFlowIconButton(
                                                            borderColor: Colors
                                                                .transparent,
                                                            borderRadius: 99.0,
                                                            buttonSize: 40.0,
                                                            fillColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                            icon: Icon(
                                                              FFIcons
                                                                  .krightArrow,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryBackground,
                                                              size: 24.0,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              unawaited(
                                                                () async {
                                                                  await launchURL(
                                                                      FFAppConstants
                                                                          .feedbacks);
                                                                }(),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 16.0)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].addToStart(SizedBox(height: 130.0)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                width: 50.0,
                                height: 50.0,
                                child: custom_widgets.Visibilitydetector(
                                  width: 50.0,
                                  height: 50.0,
                                  visibilityThreshold: 0.5,
                                  action: (visible, visibility) async {
                                    _model.visible = visible!;
                                    safeSetState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ].addToEnd(SizedBox(height: 150.0)),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.navbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: NavbarWidget(
                      pageNumber: 1,
                    ),
                  ),
                ),
                wrapWithModel(
                  model: _model.apbarBGModel,
                  updateCallback: () => safeSetState(() {}),
                  updateOnChange: true,
                  child: ApbarBGWidget(
                    title: 'Play For Good',
                    text: 'Play for better lives. Win for good vibes.',
                    backgroundColor: _model.visible
                        ? Colors.transparent
                        : FlutterFlowTheme.of(context).accent3,
                    gradientColor: _model.visible
                        ? Colors.transparent
                        : FlutterFlowTheme.of(context).accent2,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
