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
import '/index.dart';
import 'package:styled_divider/styled_divider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'good_games_page_model.dart';
export 'good_games_page_model.dart';

class GoodGamesPageWidget extends StatefulWidget {
  const GoodGamesPageWidget({
    super.key,
    String? periodGames,
    String? valueGames,
    int? tab,
  })  : this.periodGames = periodGames ?? 'gesamt',
        this.valueGames = valueGames ?? 'valuable',
        this.tab = tab ?? 2;

  final String periodGames;
  final String valueGames;
  final int tab;

  static String routeName = 'GoodGamesPage';
  static String routePath = '/goodGamesPage';

  @override
  State<GoodGamesPageWidget> createState() => _GoodGamesPageWidgetState();
}

class _GoodGamesPageWidgetState extends State<GoodGamesPageWidget> {
  late GoodGamesPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GoodGamesPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([]);
      if (widget!.tab != null) {
        _model.tab = widget!.tab;
        safeSetState(() {});
      }
      await actions.setStatusBarColor(
        false,
      );
      _model.periodPageGame = valueOrDefault<String>(
        widget!.periodGames,
        'gesamt',
      );
      _model.valuePageGame = valueOrDefault<String>(
        widget!.valueGames,
        'valuable',
      );
      safeSetState(() {});
      FFAppState().refreshDate = getCurrentTimestamp;
      FFAppState().update(() {});
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
        title: 'GoodGamesPage',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Align(
              alignment: AlignmentDirectional(0.0, -1.0),
              child: Stack(
                alignment: AlignmentDirectional(0.0, -1.0),
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, -1.0),
                    child: FutureBuilder<List<UsersRow>>(
                      future: UsersTable().queryRows(
                        queryFn: (q) => q,
                      ),
                      builder: (context, snapshot) {
                        // Customize what your widget looks like when it's loading.
                        if (!snapshot.hasData) {
                          return Center(
                            child: SizedBox(
                              width: 20.0,
                              height: 20.0,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            ),
                          );
                        }
                        List<UsersRow> allUsersContainerUsersRowList =
                            snapshot.data!;

                        return Container(
                          decoration: BoxDecoration(),
                          child: Builder(
                            builder: (context) {
                              if (loggedIn) {
                                return FutureBuilder<List<InvitesRow>>(
                                  future: FFAppState().invites(
                                    uniqueQueryKey:
                                        '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                                    requestFn: () => InvitesTable().queryRows(
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
                                  builder: (context, snapshot) {
                                    // Customize what your widget looks like when it's loading.
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SizedBox(
                                          width: 40.0,
                                          height: 40.0,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    List<InvitesRow>
                                        invitesContainerInvitesRowList =
                                        snapshot.data!;

                                    return Container(
                                      constraints: BoxConstraints(
                                        minHeight:
                                            MediaQuery.sizeOf(context).height *
                                                1.0,
                                      ),
                                      decoration: BoxDecoration(),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, -1.0),
                                        child: StreamBuilder<List<GamesRow>>(
                                          stream: FFAppState().games(
                                            uniqueQueryKey:
                                                '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                                            requestFn: () => _model
                                                    .gamesContainerSupabaseStream1 ??=
                                                SupaFlow.client
                                                    .from("games")
                                                    .stream(primaryKey: ['id'])
                                                    .eqOrNull(
                                                      'status',
                                                      'completed',
                                                    )
                                                    .map((list) => list
                                                        .map((item) =>
                                                            GamesRow(item))
                                                        .toList()),
                                          ),
                                          builder: (context, snapshot) {
                                            // Customize what your widget looks like when it's loading.
                                            if (!snapshot.hasData) {
                                              return Center(
                                                child: SizedBox(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            List<GamesRow>
                                                gamesContainerGamesRowList =
                                                snapshot.data!;

                                            return Container(
                                              decoration: BoxDecoration(),
                                              child: SingleChildScrollView(
                                                controller:
                                                    _model.columnController1,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Stack(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, -1.0),
                                                      children: [
                                                        FutureBuilder<
                                                            List<UsersRow>>(
                                                          future:
                                                              FFAppState().user(
                                                            uniqueQueryKey:
                                                                '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                                                            requestFn: () =>
                                                                UsersTable()
                                                                    .querySingleRow(
                                                              queryFn: (q) =>
                                                                  q.eqOrNull(
                                                                'id',
                                                                currentUserUid,
                                                              ),
                                                            ),
                                                          ),
                                                          builder: (context,
                                                              snapshot) {
                                                            // Customize what your widget looks like when it's loading.
                                                            if (!snapshot
                                                                .hasData) {
                                                              return Center(
                                                                child: SizedBox(
                                                                  width: 40.0,
                                                                  height: 40.0,
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
                                                            List<UsersRow>
                                                                containerUsersRowList =
                                                                snapshot.data!;

                                                            // Return an empty Container when the item does not exist.
                                                            if (snapshot.data!
                                                                .isEmpty) {
                                                              return Container();
                                                            }
                                                            final containerUsersRow =
                                                                containerUsersRowList
                                                                        .isNotEmpty
                                                                    ? containerUsersRowList
                                                                        .first
                                                                    : null;

                                                            return Container(
                                                              decoration:
                                                                  BoxDecoration(),
                                                              child: Builder(
                                                                builder:
                                                                    (context) {
                                                                  if (_model
                                                                          .tab ==
                                                                      1) {
                                                                    return Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Align(
                                                                          alignment: AlignmentDirectional(
                                                                              0.0,
                                                                              -1.0),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                double.infinity,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              image: DecorationImage(
                                                                                fit: BoxFit.fill,
                                                                                image: Image.asset(
                                                                                  'assets/images/Good_Games_-_My_games.png',
                                                                                ).image,
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Align(
                                                                              alignment: AlignmentDirectional(0.0, -1.0),
                                                                              child: Container(
                                                                                height: 500.0,
                                                                                constraints: BoxConstraints(
                                                                                  minHeight: 500.0,
                                                                                  maxWidth: 600.0,
                                                                                ),
                                                                                decoration: BoxDecoration(),
                                                                                child: Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 100.0, 0.0, 0.0),
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 60.0, 0.0, 8.0),
                                                                                        child: Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 48.0, 0.0, 0.0),
                                                                                                child: Column(
                                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                                  children: [
                                                                                                    Align(
                                                                                                      alignment: AlignmentDirectional(0.0, 1.0),
                                                                                                      child: Text(
                                                                                                        valueOrDefault<String>(
                                                                                                          formatNumber(
                                                                                                            functions.gamesForPeriod(_model.periodPageUser, gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), currentUserUid)?.length,
                                                                                                            formatType: FormatType.custom,
                                                                                                            format: '0',
                                                                                                            locale: '',
                                                                                                          ),
                                                                                                          '0',
                                                                                                        ),
                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                              fontFamily: 'Dela Gothic One',
                                                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                              fontSize: 32.0,
                                                                                                              letterSpacing: -1.12,
                                                                                                              lineHeight: 1.5,
                                                                                                            ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Padding(
                                                                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                                                                                                      child: Text(
                                                                                                        'Games',
                                                                                                        textAlign: TextAlign.center,
                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                              fontSize: 11.0,
                                                                                                              letterSpacing: -0.22,
                                                                                                              fontWeight: FontWeight.w500,
                                                                                                              lineHeight: 1.5,
                                                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                            ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Row(
                                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      children: [
                                                                                                        Container(
                                                                                                          height: 24.0,
                                                                                                          constraints: BoxConstraints(
                                                                                                            minWidth: 54.0,
                                                                                                          ),
                                                                                                          decoration: BoxDecoration(
                                                                                                            color: FlutterFlowTheme.of(context).primary,
                                                                                                            boxShadow: [
                                                                                                              BoxShadow(
                                                                                                                blurRadius: 4.0,
                                                                                                                color: Color(0x14000000),
                                                                                                                offset: Offset(
                                                                                                                  0.0,
                                                                                                                  2.0,
                                                                                                                ),
                                                                                                                spreadRadius: 0.0,
                                                                                                              )
                                                                                                            ],
                                                                                                            borderRadius: BorderRadius.circular(99.0),
                                                                                                          ),
                                                                                                          child: Align(
                                                                                                            alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                            child: Text(
                                                                                                              valueOrDefault<String>(
                                                                                                                '#${valueOrDefault<String>(
                                                                                                                  functions.ratingUsersPerUser(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageGame, RatingGamesFilter.active.name, invitesContainerInvitesRowList.toList(), currentUserUid, gamesContainerGamesRowList.length).toString(),
                                                                                                                  '0',
                                                                                                                )}',
                                                                                                                '0',
                                                                                                              ),
                                                                                                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                                    fontSize: 12.0,
                                                                                                                    letterSpacing: -0.24,
                                                                                                                    lineHeight: 1.5,
                                                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                                  ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ].divide(SizedBox(height: 6.0)),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Container(
                                                                                              width: 96.0,
                                                                                              height: 96.0,
                                                                                              decoration: BoxDecoration(
                                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                boxShadow: [
                                                                                                  BoxShadow(
                                                                                                    blurRadius: 8.0,
                                                                                                    color: Color(0x0A000000),
                                                                                                    offset: Offset(
                                                                                                      0.0,
                                                                                                      4.0,
                                                                                                    ),
                                                                                                    spreadRadius: 12.0,
                                                                                                  )
                                                                                                ],
                                                                                                shape: BoxShape.circle,
                                                                                                border: Border.all(
                                                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                  width: 4.0,
                                                                                                ),
                                                                                              ),
                                                                                              child: wrapWithModel(
                                                                                                model: _model.imageModel1,
                                                                                                updateCallback: () => safeSetState(() {}),
                                                                                                child: ImageWidget(
                                                                                                  size: 96.0,
                                                                                                  image: valueOrDefault<String>(
                                                                                                    containerUsersRow?.photoUrl,
                                                                                                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/42sgzx6uejhj/Vector.png',
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Expanded(
                                                                                              child: Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 48.0, 0.0, 0.0),
                                                                                                child: Column(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  children: [
                                                                                                    Align(
                                                                                                      alignment: AlignmentDirectional(0.0, 1.0),
                                                                                                      child: Text(
                                                                                                        valueOrDefault<String>(
                                                                                                          functions.formatCompactWithComma(valueOrDefault<double>(
                                                                                                            functions.totalSumPeriodGoodPowerPerGame(gamesContainerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList(), _model.periodPageGame),
                                                                                                            0.0,
                                                                                                          )),
                                                                                                          '0',
                                                                                                        ),
                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                              fontFamily: 'Dela Gothic One',
                                                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                              fontSize: 32.0,
                                                                                                              letterSpacing: -1.12,
                                                                                                              lineHeight: 1.5,
                                                                                                            ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Padding(
                                                                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                                                                                                      child: Text(
                                                                                                        '€nergy per Game',
                                                                                                        textAlign: TextAlign.center,
                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                              fontSize: 11.0,
                                                                                                              letterSpacing: -0.22,
                                                                                                              fontWeight: FontWeight.w500,
                                                                                                              lineHeight: 1.5,
                                                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                            ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Row(
                                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      children: [
                                                                                                        Container(
                                                                                                          height: 24.0,
                                                                                                          constraints: BoxConstraints(
                                                                                                            minWidth: 54.0,
                                                                                                          ),
                                                                                                          decoration: BoxDecoration(
                                                                                                            color: FlutterFlowTheme.of(context).primary,
                                                                                                            boxShadow: [
                                                                                                              BoxShadow(
                                                                                                                blurRadius: 4.0,
                                                                                                                color: Color(0x14000000),
                                                                                                                offset: Offset(
                                                                                                                  0.0,
                                                                                                                  2.0,
                                                                                                                ),
                                                                                                                spreadRadius: 0.0,
                                                                                                              )
                                                                                                            ],
                                                                                                            borderRadius: BorderRadius.circular(99.0),
                                                                                                          ),
                                                                                                          child: Align(
                                                                                                            alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                            child: Text(
                                                                                                              valueOrDefault<String>(
                                                                                                                '#${valueOrDefault<String>(
                                                                                                                  formatNumber(
                                                                                                                    functions.ratingUserGamesByGoodEnergyPerGame(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), currentUserUid, _model.periodPageGame),
                                                                                                                    formatType: FormatType.custom,
                                                                                                                    format: '0',
                                                                                                                    locale: '',
                                                                                                                  ),
                                                                                                                  '0',
                                                                                                                )}',
                                                                                                                '0',
                                                                                                              ),
                                                                                                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                                    fontSize: 12.0,
                                                                                                                    letterSpacing: -0.24,
                                                                                                                    lineHeight: 1.5,
                                                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                                  ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ].divide(SizedBox(height: 6.0)),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      Column(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        children: [
                                                                                          Align(
                                                                                            alignment: AlignmentDirectional(0.0, 1.0),
                                                                                            child: Text(
                                                                                              valueOrDefault<String>(
                                                                                                functions.formatCompactWithComma(valueOrDefault<double>(
                                                                                                  functions.totalSumPeriodLichtwattPerGame(gamesContainerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList(), _model.periodPageGame),
                                                                                                  0.0,
                                                                                                )),
                                                                                                '0',
                                                                                              ),
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    fontFamily: 'Dela Gothic One',
                                                                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                    fontSize: 32.0,
                                                                                                    letterSpacing: -1.12,
                                                                                                    lineHeight: 1.5,
                                                                                                  ),
                                                                                            ),
                                                                                          ),
                                                                                          Padding(
                                                                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                                                                                            child: Text(
                                                                                              'Good Power per Game',
                                                                                              textAlign: TextAlign.center,
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                    fontSize: 11.0,
                                                                                                    letterSpacing: -0.22,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    lineHeight: 1.5,
                                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                  ),
                                                                                            ),
                                                                                          ),
                                                                                          Align(
                                                                                            alignment: AlignmentDirectional(0.0, 0.0),
                                                                                            child: Container(
                                                                                              height: 24.0,
                                                                                              constraints: BoxConstraints(
                                                                                                minWidth: 54.0,
                                                                                              ),
                                                                                              decoration: BoxDecoration(
                                                                                                color: FlutterFlowTheme.of(context).primary,
                                                                                                boxShadow: [
                                                                                                  BoxShadow(
                                                                                                    blurRadius: 4.0,
                                                                                                    color: Color(0x14000000),
                                                                                                    offset: Offset(
                                                                                                      0.0,
                                                                                                      2.0,
                                                                                                    ),
                                                                                                    spreadRadius: 0.0,
                                                                                                  )
                                                                                                ],
                                                                                                borderRadius: BorderRadius.circular(99.0),
                                                                                              ),
                                                                                              child: Row(
                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                children: [
                                                                                                  Align(
                                                                                                    alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                    child: Text(
                                                                                                      valueOrDefault<String>(
                                                                                                        '#${valueOrDefault<String>(
                                                                                                          functions.ratingUserGamesByGoodEnergyPerGame(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), currentUserUid, _model.periodPageGame).toString(),
                                                                                                          '0',
                                                                                                        )}',
                                                                                                        '0',
                                                                                                      ),
                                                                                                      style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                            fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                            color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                            fontSize: 12.0,
                                                                                                            letterSpacing: -0.24,
                                                                                                            lineHeight: 1.5,
                                                                                                            useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ].divide(SizedBox(height: 6.0)),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          constraints:
                                                                              BoxConstraints(
                                                                            maxWidth:
                                                                                600.0,
                                                                          ),
                                                                          decoration:
                                                                              BoxDecoration(),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children: [
                                                                              if ((gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList().length > 0) ||
                                                                                  valueOrDefault<bool>(
                                                                                    functions.filterAllGames(
                                                                                                gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(),
                                                                                                _model.periodPageGame,
                                                                                                _model.valuePageGame,
                                                                                                _model.limit,
                                                                                                valueOrDefault<int>(
                                                                                                  _model.pageNumberGames,
                                                                                                  1,
                                                                                                )) !=
                                                                                            null &&
                                                                                        (functions.filterAllGames(
                                                                                                gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(),
                                                                                                _model.periodPageGame,
                                                                                                _model.valuePageGame,
                                                                                                _model.limit,
                                                                                                valueOrDefault<int>(
                                                                                                  _model.pageNumberGames,
                                                                                                  1,
                                                                                                )))!
                                                                                            .isNotEmpty,
                                                                                    false,
                                                                                  ))
                                                                                Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      InkWell(
                                                                                        splashColor: Colors.transparent,
                                                                                        focusColor: Colors.transparent,
                                                                                        hoverColor: Colors.transparent,
                                                                                        highlightColor: Colors.transparent,
                                                                                        onTap: () async {
                                                                                          if (gamesContainerGamesRowList.where((e) => e.status == 'completed').toList().length > 0) {
                                                                                            showModalBottomSheet(
                                                                                              isScrollControlled: true,
                                                                                              backgroundColor: Colors.transparent,
                                                                                              useSafeArea: true,
                                                                                              context: context,
                                                                                              builder: (context) {
                                                                                                return GestureDetector(
                                                                                                  onTap: () {
                                                                                                    FocusScope.of(context).unfocus();
                                                                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                                                                  },
                                                                                                  child: Padding(
                                                                                                    padding: MediaQuery.viewInsetsOf(context),
                                                                                                    child: GoodGamesPlayersFiltersWidget(
                                                                                                      period: _model.periodPageGame!,
                                                                                                      value: _model.valuePageGame!,
                                                                                                      tab: _model.tab,
                                                                                                      update: (period, value) async {
                                                                                                        _model.valuePageGame = value;
                                                                                                        _model.periodPageGame = period;
                                                                                                        safeSetState(() {});
                                                                                                      },
                                                                                                    ),
                                                                                                  ),
                                                                                                );
                                                                                              },
                                                                                            ).then((value) => safeSetState(() {}));
                                                                                          }
                                                                                        },
                                                                                        child: Container(
                                                                                          height: 56.0,
                                                                                          decoration: BoxDecoration(
                                                                                            color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                            borderRadius: BorderRadius.circular(99.0),
                                                                                            border: Border.all(
                                                                                              color: FlutterFlowTheme.of(context).secondary,
                                                                                              width: 2.0,
                                                                                            ),
                                                                                          ),
                                                                                          child: Padding(
                                                                                            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                                                                            child: Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                Text(
                                                                                                  valueOrDefault<String>(
                                                                                                    _model.valuePageGame == RatingGamesFilter.recent.name ? 'LETZTE GAMES' : 'MOST ${(_model.valuePageGame!).toUpperCase()} GAMES',
                                                                                                    'MOST VALUABLE GAMES',
                                                                                                  ),
                                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                        fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                        fontSize: 15.0,
                                                                                                        letterSpacing: -0.525,
                                                                                                        fontWeight: FontWeight.w900,
                                                                                                        fontStyle: FontStyle.italic,
                                                                                                        lineHeight: 1.5,
                                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                      ),
                                                                                                ),
                                                                                                Icon(
                                                                                                  FFIcons.karrowSeparateVertical,
                                                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                                                  size: 24.0,
                                                                                                ),
                                                                                              ].divide(SizedBox(width: 12.0)),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ].divide(SizedBox(width: 12.0)),
                                                                                  ),
                                                                                ),
                                                                              Builder(
                                                                                builder: (context) {
                                                                                  if ((gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList().length > 0) ||
                                                                                      valueOrDefault<bool>(
                                                                                        functions.filterAllGames(
                                                                                                    gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(),
                                                                                                    _model.periodPageGame,
                                                                                                    _model.valuePageGame,
                                                                                                    _model.limit,
                                                                                                    valueOrDefault<int>(
                                                                                                      _model.pageNumberGames,
                                                                                                      1,
                                                                                                    )) !=
                                                                                                null &&
                                                                                            (functions.filterAllGames(
                                                                                                    gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(),
                                                                                                    _model.periodPageGame,
                                                                                                    _model.valuePageGame,
                                                                                                    _model.limit,
                                                                                                    valueOrDefault<int>(
                                                                                                      _model.pageNumberGames,
                                                                                                      1,
                                                                                                    )))!
                                                                                                .isNotEmpty,
                                                                                        false,
                                                                                      )) {
                                                                                    return Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: EdgeInsetsDirectional.fromSTEB(12.0, 24.0, 12.0, 0.0),
                                                                                          child: Row(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                            children: [
                                                                                              Expanded(
                                                                                                child: Align(
                                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                  child: Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 0.0, 0.0),
                                                                                                    child: Text(
                                                                                                      '#',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                            fontSize: 12.0,
                                                                                                            letterSpacing: -0.24,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            lineHeight: 1.5,
                                                                                                            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Expanded(
                                                                                                flex: 5,
                                                                                                child: Align(
                                                                                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                                  child: Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                                    child: Text(
                                                                                                      'Details',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                            fontSize: 12.0,
                                                                                                            letterSpacing: -0.24,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            lineHeight: 1.5,
                                                                                                            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Expanded(
                                                                                                flex: 3,
                                                                                                child: Align(
                                                                                                  alignment: AlignmentDirectional(1.0, 0.0),
                                                                                                  child: Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                                                                                                    child: Text(
                                                                                                      'P€',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                            fontSize: 12.0,
                                                                                                            letterSpacing: -0.24,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            lineHeight: 1.5,
                                                                                                            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Expanded(
                                                                                                flex: 3,
                                                                                                child: Align(
                                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                  child: Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                                                                                                    child: Text(
                                                                                                      'Good Power',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                            fontSize: 12.0,
                                                                                                            letterSpacing: -0.24,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            lineHeight: 1.5,
                                                                                                            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 0.0),
                                                                                          child: Container(
                                                                                            width: double.infinity,
                                                                                            decoration: BoxDecoration(
                                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                              borderRadius: BorderRadius.circular(16.0),
                                                                                            ),
                                                                                            child: Padding(
                                                                                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 12.0, 8.0, 12.0),
                                                                                              child: Column(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                                                                                    child: Builder(
                                                                                                      builder: (context) {
                                                                                                        final games = (functions
                                                                                                                    .filterAllGames(
                                                                                                                        gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(),
                                                                                                                        _model.periodPageGame,
                                                                                                                        _model.valuePageGame,
                                                                                                                        _model.limit,
                                                                                                                        valueOrDefault<int>(
                                                                                                                          _model.pageNumberGames,
                                                                                                                          1,
                                                                                                                        ))
                                                                                                                    ?.toList() ??
                                                                                                                [])
                                                                                                            .take(10)
                                                                                                            .toList();

                                                                                                        return Column(
                                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                                          children: List.generate(games.length, (gamesIndex) {
                                                                                                            final gamesItem = games[gamesIndex];
                                                                                                            return Column(
                                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                                              children: [
                                                                                                                if (gamesIndex > 0)
                                                                                                                  Divider(
                                                                                                                    height: 1.0,
                                                                                                                    thickness: 1.0,
                                                                                                                    indent: 16.0,
                                                                                                                    endIndent: 16.0,
                                                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                                                  ),
                                                                                                                Padding(
                                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                                                                                                                  child: InkWell(
                                                                                                                    splashColor: Colors.transparent,
                                                                                                                    focusColor: Colors.transparent,
                                                                                                                    hoverColor: Colors.transparent,
                                                                                                                    highlightColor: Colors.transparent,
                                                                                                                    onTap: () async {
                                                                                                                      context.pushNamed(
                                                                                                                        GamePageWidget.routeName,
                                                                                                                        queryParameters: {
                                                                                                                          'gameRow': serializeParam(
                                                                                                                            gamesItem,
                                                                                                                            ParamType.SupabaseRow,
                                                                                                                          ),
                                                                                                                        }.withoutNulls,
                                                                                                                      );
                                                                                                                    },
                                                                                                                    child: GamesOrgCompWidget(
                                                                                                                      key: Key('Keyme4_${gamesIndex}_of_${games.length}'),
                                                                                                                      index: valueOrDefault<int>(
                                                                                                                        gamesIndex,
                                                                                                                        0,
                                                                                                                      ),
                                                                                                                      game: gamesItem,
                                                                                                                      pageNumber: valueOrDefault<int>(
                                                                                                                        _model.pageNumberGames,
                                                                                                                        1,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            );
                                                                                                          }),
                                                                                                        );
                                                                                                      },
                                                                                                    ),
                                                                                                  ),
                                                                                                  if (valueOrDefault<bool>(
                                                                                                    functions.hasMoreGames(gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(), _model.periodPageGame, _model.valuePageGame, 10, 1),
                                                                                                    true,
                                                                                                  ))
                                                                                                    Column(
                                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                                      children: [
                                                                                                        Divider(
                                                                                                          height: 1.0,
                                                                                                          thickness: 1.0,
                                                                                                          indent: 16.0,
                                                                                                          endIndent: 16.0,
                                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                                        ),
                                                                                                        Padding(
                                                                                                          padding: EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 16.0),
                                                                                                          child: Row(
                                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                                            children: [
                                                                                                              Icon(
                                                                                                                FFIcons.keye,
                                                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                                                size: 32.0,
                                                                                                              ),
                                                                                                              Expanded(
                                                                                                                child: Column(
                                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                  children: [
                                                                                                                    AutoSizeText(
                                                                                                                      'Mehr sehen',
                                                                                                                      maxLines: 1,
                                                                                                                      style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                                            fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                                            fontSize: 18.0,
                                                                                                                            letterSpacing: -0.4,
                                                                                                                            fontWeight: FontWeight.bold,
                                                                                                                            lineHeight: 1.5,
                                                                                                                            useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                                          ),
                                                                                                                    ),
                                                                                                                  ],
                                                                                                                ),
                                                                                                              ),
                                                                                                              if (_model.pageNumberGames! > 1)
                                                                                                                Container(
                                                                                                                  width: 56.0,
                                                                                                                  height: 40.0,
                                                                                                                  decoration: BoxDecoration(
                                                                                                                    color: FlutterFlowTheme.of(context).secondary,
                                                                                                                    borderRadius: BorderRadius.circular(99.0),
                                                                                                                  ),
                                                                                                                  child: FlutterFlowIconButton(
                                                                                                                    borderColor: Colors.transparent,
                                                                                                                    borderRadius: 99.0,
                                                                                                                    buttonSize: 40.0,
                                                                                                                    fillColor: FlutterFlowTheme.of(context).secondary,
                                                                                                                    icon: Icon(
                                                                                                                      FFIcons.karrowLeftLong,
                                                                                                                      color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                                      size: 24.0,
                                                                                                                    ),
                                                                                                                    onPressed: () async {
                                                                                                                      _model.pageNumberGames = _model.pageNumberGames! + -1;
                                                                                                                      safeSetState(() {});
                                                                                                                    },
                                                                                                                  ),
                                                                                                                ),
                                                                                                              if (valueOrDefault<bool>(
                                                                                                                functions.hasMoreGames(gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(), _model.periodPageGame, _model.valuePageGame, _model.limit, _model.pageNumberGames),
                                                                                                                true,
                                                                                                              ))
                                                                                                                Container(
                                                                                                                  width: 56.0,
                                                                                                                  height: 40.0,
                                                                                                                  decoration: BoxDecoration(
                                                                                                                    color: FlutterFlowTheme.of(context).secondary,
                                                                                                                    borderRadius: BorderRadius.circular(99.0),
                                                                                                                  ),
                                                                                                                  child: FlutterFlowIconButton(
                                                                                                                    borderColor: Colors.transparent,
                                                                                                                    borderRadius: 99.0,
                                                                                                                    buttonSize: 40.0,
                                                                                                                    fillColor: FlutterFlowTheme.of(context).secondary,
                                                                                                                    icon: Icon(
                                                                                                                      FFIcons.krightArrow,
                                                                                                                      color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                                      size: 24.0,
                                                                                                                    ),
                                                                                                                    onPressed: () async {
                                                                                                                      _model.pageNumberGames = _model.pageNumberGames! + 1;
                                                                                                                      safeSetState(() {});
                                                                                                                    },
                                                                                                                  ),
                                                                                                                ),
                                                                                                            ].divide(SizedBox(width: 16.0)),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  } else {
                                                                                    return Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(14.0, 26.0, 14.0, 0.0),
                                                                                      child: ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(8.0),
                                                                                        child: Image.asset(
                                                                                          'assets/images/gamesEmpty.png',
                                                                                          width: double.infinity,
                                                                                          fit: BoxFit.fill,
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  } else {
                                                                    return Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              500.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            image:
                                                                                DecorationImage(
                                                                              fit: BoxFit.fill,
                                                                              image: Image.asset(
                                                                                'assets/images/Good_Games_-_My_games.png',
                                                                              ).image,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, -1.0),
                                                                            child:
                                                                                Container(
                                                                              constraints: BoxConstraints(
                                                                                maxWidth: 600.0,
                                                                              ),
                                                                              decoration: BoxDecoration(),
                                                                              child: Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 100.0, 0.0, 0.0),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Padding(
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                                            0.0,
                                                                                            0.0,
                                                                                            0.0,
                                                                                            valueOrDefault<double>(
                                                                                              (gamesContainerGamesRowList.where((e) => e.status == 'completed').toList().length > 0) || (invitesContainerInvitesRowList.length > 0) ? 0.0 : 100.0,
                                                                                              0.0,
                                                                                            )),
                                                                                        child: ClipRRect(
                                                                                          borderRadius: BorderRadius.circular(0.0),
                                                                                          child: Image.asset(
                                                                                            'assets/images/Logo_Good_Games_2026.png',
                                                                                            width: double.infinity,
                                                                                            fit: BoxFit.contain,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    if ((gamesContainerGamesRowList.where((e) => e.status == 'completed').toList().length > 0) || (invitesContainerInvitesRowList.length > 0))
                                                                                      Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                        children: [
                                                                                          Align(
                                                                                            alignment: AlignmentDirectional(0.0, 0.0),
                                                                                            child: FutureBuilder<List<UsersRow>>(
                                                                                              future: _model.user1(
                                                                                                uniqueQueryKey: valueOrDefault<String>(
                                                                                                  containerUsersRow?.id,
                                                                                                  '0',
                                                                                                ),
                                                                                                requestFn: () => UsersTable().querySingleRow(
                                                                                                  queryFn: (q) => q.eqOrNull(
                                                                                                    'id',
                                                                                                    functions.ratingUsersIds(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, 10, _model.pageNumberUsers, invitesContainerInvitesRowList.toList())?.elementAtOrNull(1),
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
                                                                                                List<UsersRow> stackUsersRowList = snapshot.data!;

                                                                                                // Return an empty Container when the item does not exist.
                                                                                                if (snapshot.data!.isEmpty) {
                                                                                                  return Container();
                                                                                                }
                                                                                                final stackUsersRow = stackUsersRowList.isNotEmpty ? stackUsersRowList.first : null;

                                                                                                return Stack(
                                                                                                  alignment: AlignmentDirectional(1.0, 1.0),
                                                                                                  children: [
                                                                                                    Container(
                                                                                                      width: 96.0,
                                                                                                      height: 96.0,
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                        boxShadow: [
                                                                                                          BoxShadow(
                                                                                                            blurRadius: 8.0,
                                                                                                            color: Color(0x0A000000),
                                                                                                            offset: Offset(
                                                                                                              0.0,
                                                                                                              4.0,
                                                                                                            ),
                                                                                                            spreadRadius: 12.0,
                                                                                                          )
                                                                                                        ],
                                                                                                        shape: BoxShape.circle,
                                                                                                        border: Border.all(
                                                                                                          color: FlutterFlowTheme.of(context).silver,
                                                                                                          width: 4.0,
                                                                                                        ),
                                                                                                      ),
                                                                                                      child: InkWell(
                                                                                                        splashColor: Colors.transparent,
                                                                                                        focusColor: Colors.transparent,
                                                                                                        hoverColor: Colors.transparent,
                                                                                                        highlightColor: Colors.transparent,
                                                                                                        onTap: () async {
                                                                                                          unawaited(
                                                                                                            () async {
                                                                                                              context.pushNamed(
                                                                                                                UserProfilePageWidget.routeName,
                                                                                                                queryParameters: {
                                                                                                                  'userId': serializeParam(
                                                                                                                    stackUsersRow?.id,
                                                                                                                    ParamType.String,
                                                                                                                  ),
                                                                                                                }.withoutNulls,
                                                                                                              );
                                                                                                            }(),
                                                                                                          );
                                                                                                        },
                                                                                                        child: wrapWithModel(
                                                                                                          model: _model.imageModel2,
                                                                                                          updateCallback: () => safeSetState(() {}),
                                                                                                          child: ImageWidget(
                                                                                                            size: 96.0,
                                                                                                            image: valueOrDefault<String>(
                                                                                                              stackUsersRow?.photoUrl,
                                                                                                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(8.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/second.png',
                                                                                                        width: 40.0,
                                                                                                        height: 48.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                );
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                          Align(
                                                                                            alignment: AlignmentDirectional(0.0, 0.0),
                                                                                            child: Padding(
                                                                                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 48.0),
                                                                                              child: FutureBuilder<List<UsersRow>>(
                                                                                                future: _model.user2(
                                                                                                  uniqueQueryKey: valueOrDefault<String>(
                                                                                                    containerUsersRow?.id,
                                                                                                    '0',
                                                                                                  ),
                                                                                                  requestFn: () => UsersTable().querySingleRow(
                                                                                                    queryFn: (q) => q.eqOrNull(
                                                                                                      'id',
                                                                                                      functions.ratingUsersIds(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, 10, _model.pageNumberUsers, invitesContainerInvitesRowList.toList())?.firstOrNull,
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
                                                                                                  List<UsersRow> stackUsersRowList = snapshot.data!;

                                                                                                  // Return an empty Container when the item does not exist.
                                                                                                  if (snapshot.data!.isEmpty) {
                                                                                                    return Container();
                                                                                                  }
                                                                                                  final stackUsersRow = stackUsersRowList.isNotEmpty ? stackUsersRowList.first : null;

                                                                                                  return Stack(
                                                                                                    alignment: AlignmentDirectional(1.0, 1.0),
                                                                                                    children: [
                                                                                                      Padding(
                                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                                                                                                        child: Container(
                                                                                                          width: 96.0,
                                                                                                          height: 96.0,
                                                                                                          decoration: BoxDecoration(
                                                                                                            color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                            boxShadow: [
                                                                                                              BoxShadow(
                                                                                                                blurRadius: 8.0,
                                                                                                                color: Color(0x0A000000),
                                                                                                                offset: Offset(
                                                                                                                  0.0,
                                                                                                                  4.0,
                                                                                                                ),
                                                                                                                spreadRadius: 12.0,
                                                                                                              )
                                                                                                            ],
                                                                                                            shape: BoxShape.circle,
                                                                                                            border: Border.all(
                                                                                                              color: FlutterFlowTheme.of(context).gold,
                                                                                                              width: 4.0,
                                                                                                            ),
                                                                                                          ),
                                                                                                          child: InkWell(
                                                                                                            splashColor: Colors.transparent,
                                                                                                            focusColor: Colors.transparent,
                                                                                                            hoverColor: Colors.transparent,
                                                                                                            highlightColor: Colors.transparent,
                                                                                                            onTap: () async {
                                                                                                              unawaited(
                                                                                                                () async {
                                                                                                                  context.pushNamed(
                                                                                                                    UserProfilePageWidget.routeName,
                                                                                                                    queryParameters: {
                                                                                                                      'userId': serializeParam(
                                                                                                                        stackUsersRow?.id,
                                                                                                                        ParamType.String,
                                                                                                                      ),
                                                                                                                    }.withoutNulls,
                                                                                                                  );
                                                                                                                }(),
                                                                                                              );
                                                                                                            },
                                                                                                            child: wrapWithModel(
                                                                                                              model: _model.imageModel3,
                                                                                                              updateCallback: () => safeSetState(() {}),
                                                                                                              child: ImageWidget(
                                                                                                                size: 96.0,
                                                                                                                image: valueOrDefault<String>(
                                                                                                                  stackUsersRow?.photoUrl,
                                                                                                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      Padding(
                                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                                                                                        child: ClipRRect(
                                                                                                          borderRadius: BorderRadius.circular(8.0),
                                                                                                          child: Image.asset(
                                                                                                            'assets/images/first.png',
                                                                                                            width: 40.0,
                                                                                                            height: 48.0,
                                                                                                            fit: BoxFit.cover,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  );
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Align(
                                                                                            alignment: AlignmentDirectional(0.0, 0.0),
                                                                                            child: FutureBuilder<List<UsersRow>>(
                                                                                              future: _model.user3(
                                                                                                uniqueQueryKey: valueOrDefault<String>(
                                                                                                  containerUsersRow?.id,
                                                                                                  '0',
                                                                                                ),
                                                                                                requestFn: () => UsersTable().querySingleRow(
                                                                                                  queryFn: (q) => q.eqOrNull(
                                                                                                    'id',
                                                                                                    functions.ratingUsersIds(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, 10, _model.pageNumberUsers, invitesContainerInvitesRowList.toList())?.elementAtOrNull(2),
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
                                                                                                List<UsersRow> stackUsersRowList = snapshot.data!;

                                                                                                // Return an empty Container when the item does not exist.
                                                                                                if (snapshot.data!.isEmpty) {
                                                                                                  return Container();
                                                                                                }
                                                                                                final stackUsersRow = stackUsersRowList.isNotEmpty ? stackUsersRowList.first : null;

                                                                                                return Stack(
                                                                                                  alignment: AlignmentDirectional(1.0, 1.0),
                                                                                                  children: [
                                                                                                    Padding(
                                                                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                                                                                                      child: Container(
                                                                                                        width: 96.0,
                                                                                                        height: 96.0,
                                                                                                        decoration: BoxDecoration(
                                                                                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                          boxShadow: [
                                                                                                            BoxShadow(
                                                                                                              blurRadius: 8.0,
                                                                                                              color: Color(0x0A000000),
                                                                                                              offset: Offset(
                                                                                                                0.0,
                                                                                                                4.0,
                                                                                                              ),
                                                                                                              spreadRadius: 12.0,
                                                                                                            )
                                                                                                          ],
                                                                                                          shape: BoxShape.circle,
                                                                                                          border: Border.all(
                                                                                                            color: FlutterFlowTheme.of(context).bronze,
                                                                                                            width: 4.0,
                                                                                                          ),
                                                                                                        ),
                                                                                                        child: InkWell(
                                                                                                          splashColor: Colors.transparent,
                                                                                                          focusColor: Colors.transparent,
                                                                                                          hoverColor: Colors.transparent,
                                                                                                          highlightColor: Colors.transparent,
                                                                                                          onTap: () async {
                                                                                                            unawaited(
                                                                                                              () async {
                                                                                                                context.pushNamed(
                                                                                                                  UserProfilePageWidget.routeName,
                                                                                                                  queryParameters: {
                                                                                                                    'userId': serializeParam(
                                                                                                                      stackUsersRow?.id,
                                                                                                                      ParamType.String,
                                                                                                                    ),
                                                                                                                  }.withoutNulls,
                                                                                                                );
                                                                                                              }(),
                                                                                                            );
                                                                                                          },
                                                                                                          child: wrapWithModel(
                                                                                                            model: _model.imageModel4,
                                                                                                            updateCallback: () => safeSetState(() {}),
                                                                                                            child: ImageWidget(
                                                                                                              size: 96.0,
                                                                                                              image: valueOrDefault<String>(
                                                                                                                stackUsersRow?.photoUrl,
                                                                                                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(8.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/third.png',
                                                                                                        width: 40.0,
                                                                                                        height: 48.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                );
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                        ].addToStart(SizedBox(width: 24.0)).addToEnd(SizedBox(width: 24.0)),
                                                                                      ),
                                                                                  ].addToStart(SizedBox(height: 24.0)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          constraints:
                                                                              BoxConstraints(
                                                                            maxWidth:
                                                                                600.0,
                                                                          ),
                                                                          decoration:
                                                                              BoxDecoration(),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children: [
                                                                              if ((gamesContainerGamesRowList.where((e) => e.status == 'completed').toList().length > 0) || (invitesContainerInvitesRowList.length > 0))
                                                                                Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      InkWell(
                                                                                        splashColor: Colors.transparent,
                                                                                        focusColor: Colors.transparent,
                                                                                        hoverColor: Colors.transparent,
                                                                                        highlightColor: Colors.transparent,
                                                                                        onTap: () async {
                                                                                          if (gamesContainerGamesRowList.where((e) => e.status == 'completed').toList().length > 0) {
                                                                                            showModalBottomSheet(
                                                                                              isScrollControlled: true,
                                                                                              backgroundColor: Colors.transparent,
                                                                                              useSafeArea: true,
                                                                                              context: context,
                                                                                              builder: (context) {
                                                                                                return GestureDetector(
                                                                                                  onTap: () {
                                                                                                    FocusScope.of(context).unfocus();
                                                                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                                                                  },
                                                                                                  child: Padding(
                                                                                                    padding: MediaQuery.viewInsetsOf(context),
                                                                                                    child: GoodGamesPlayersFiltersWidget(
                                                                                                      period: _model.periodPageUser!,
                                                                                                      value: _model.valuePageUser!,
                                                                                                      tab: _model.tab,
                                                                                                      update: (period, value) async {
                                                                                                        _model.valuePageUser = value;
                                                                                                        _model.periodPageUser = period;
                                                                                                        safeSetState(() {});
                                                                                                        _model.clearUser2Cache();
                                                                                                        _model.clearUser1Cache();
                                                                                                        _model.clearUser3Cache();

                                                                                                        FFAppState().update(() {});
                                                                                                      },
                                                                                                    ),
                                                                                                  ),
                                                                                                );
                                                                                              },
                                                                                            ).then((value) => safeSetState(() {}));
                                                                                          }
                                                                                        },
                                                                                        child: Container(
                                                                                          height: 56.0,
                                                                                          decoration: BoxDecoration(
                                                                                            color: FlutterFlowTheme.of(context).tertiary,
                                                                                            borderRadius: BorderRadius.circular(99.0),
                                                                                            border: Border.all(
                                                                                              color: FlutterFlowTheme.of(context).tertiary,
                                                                                              width: 2.0,
                                                                                            ),
                                                                                          ),
                                                                                          child: Padding(
                                                                                            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                                                                            child: Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                Text(
                                                                                                  'MOST ${(_model.valuePageUser!).toUpperCase()} PLAYER',
                                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                        fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                        color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                        fontSize: 15.0,
                                                                                                        letterSpacing: -0.525,
                                                                                                        fontWeight: FontWeight.w900,
                                                                                                        fontStyle: FontStyle.italic,
                                                                                                        lineHeight: 1.5,
                                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                      ),
                                                                                                ),
                                                                                                Icon(
                                                                                                  FFIcons.karrowSeparateVertical,
                                                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                  size: 24.0,
                                                                                                ),
                                                                                              ].divide(SizedBox(width: 12.0)),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ].divide(SizedBox(width: 12.0)),
                                                                                  ),
                                                                                ),
                                                                              Builder(
                                                                                builder: (context) {
                                                                                  if (functions.ratingUsersIds(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, 10, _model.pageNumberUsers, invitesContainerInvitesRowList.toList())!.length > 0) {
                                                                                    return Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: EdgeInsetsDirectional.fromSTEB(12.0, 24.0, 12.0, 0.0),
                                                                                          child: Row(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                            children: [
                                                                                              Align(
                                                                                                alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                                child: Container(
                                                                                                  width: 30.0,
                                                                                                  decoration: BoxDecoration(),
                                                                                                  child: Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 0.0, 0.0),
                                                                                                    child: Text(
                                                                                                      '#',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                            fontSize: 12.0,
                                                                                                            letterSpacing: -0.24,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            lineHeight: 1.5,
                                                                                                            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Expanded(
                                                                                                child: Text(
                                                                                                  'Name',
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                        fontSize: 12.0,
                                                                                                        letterSpacing: -0.24,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        lineHeight: 1.5,
                                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                      ),
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                ' ',
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                      fontSize: 12.0,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.bold,
                                                                                                      useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                    ),
                                                                                              ),
                                                                                              Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 50.0, 0.0),
                                                                                                child: Text(
                                                                                                  valueOrDefault<String>(
                                                                                                    () {
                                                                                                      if (_model.valuePageUser == RatingGamesFilter.generous.name) {
                                                                                                        return 'P€        ';
                                                                                                      } else if (_model.valuePageUser == RatingGamesFilter.social.name) {
                                                                                                        return 'Sponsoren';
                                                                                                      } else if (_model.valuePageUser == RatingGamesFilter.active.name) {
                                                                                                        return 'Games';
                                                                                                      } else {
                                                                                                        return 'Good Power';
                                                                                                      }
                                                                                                    }(),
                                                                                                    'Good Power',
                                                                                                  ),
                                                                                                  maxLines: 1,
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                        fontSize: 12.0,
                                                                                                        letterSpacing: -0.24,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        lineHeight: 1.5,
                                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                      ),
                                                                                                ),
                                                                                              ),
                                                                                            ].divide(SizedBox(width: 32.0)),
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 0.0),
                                                                                          child: Container(
                                                                                            width: double.infinity,
                                                                                            decoration: BoxDecoration(
                                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                              borderRadius: BorderRadius.circular(16.0),
                                                                                            ),
                                                                                            child: Padding(
                                                                                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 12.0, 8.0, 12.0),
                                                                                              child: Column(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Builder(
                                                                                                    builder: (context) {
                                                                                                      final ratingUsers = (functions.ratingUsersIds(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, _model.limit, _model.pageNumberUsers, invitesContainerInvitesRowList.toList())?.toList() ?? []).take(10).toList();

                                                                                                      return Column(
                                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                                        children: List.generate(ratingUsers.length, (ratingUsersIndex) {
                                                                                                          final ratingUsersItem = ratingUsers[ratingUsersIndex];
                                                                                                          return Column(
                                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                                            children: [
                                                                                                              if (ratingUsersIndex > 0)
                                                                                                                Divider(
                                                                                                                  height: 1.0,
                                                                                                                  thickness: 1.0,
                                                                                                                  indent: 16.0,
                                                                                                                  endIndent: 16.0,
                                                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                                                ),
                                                                                                              Padding(
                                                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                                                                                                                child: GamesUserCompWidget(
                                                                                                                  key: Key('Keyx6x_${ratingUsersIndex}_of_${ratingUsers.length}'),
                                                                                                                  rating: valueOrDefault<int>(
                                                                                                                    ratingUsersIndex + 1,
                                                                                                                    1,
                                                                                                                  ),
                                                                                                                  userId: ratingUsersItem,
                                                                                                                  games: gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(),
                                                                                                                  invites: invitesContainerInvitesRowList,
                                                                                                                  value: _model.valuePageUser!,
                                                                                                                  period: _model.periodPageUser!,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ],
                                                                                                          );
                                                                                                        }),
                                                                                                      );
                                                                                                    },
                                                                                                  ),
                                                                                                  if (functions.ratingUsersPerUser(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, invitesContainerInvitesRowList.toList(), containerUsersRow?.id, allUsersContainerUsersRowList.length) >
                                                                                                      (valueOrDefault<int>(
                                                                                                            _model.limit,
                                                                                                            10,
                                                                                                          ) *
                                                                                                          (_model.pageNumberUsers!)))
                                                                                                    StyledDivider(
                                                                                                      height: 1.0,
                                                                                                      thickness: 2.0,
                                                                                                      indent: 16.0,
                                                                                                      endIndent: 16.0,
                                                                                                      color: FlutterFlowTheme.of(context).primary,
                                                                                                      lineStyle: DividerLineStyle.dotted,
                                                                                                    ),
                                                                                                  if (functions.ratingUsersPerUser(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, invitesContainerInvitesRowList.toList(), containerUsersRow?.id, allUsersContainerUsersRowList.length) >
                                                                                                      (valueOrDefault<int>(
                                                                                                            _model.limit,
                                                                                                            10,
                                                                                                          ) *
                                                                                                          (_model.pageNumberUsers!)))
                                                                                                    Padding(
                                                                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                                                                                                      child: wrapWithModel(
                                                                                                        model: _model.gamesUserCompModel2,
                                                                                                        updateCallback: () => safeSetState(() {}),
                                                                                                        updateOnChange: true,
                                                                                                        child: GamesUserCompWidget(
                                                                                                          rating: functions.ratingUsersPerUser(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, invitesContainerInvitesRowList.toList(), containerUsersRow?.id, allUsersContainerUsersRowList.length),
                                                                                                          userId: containerUsersRow!.id,
                                                                                                          games: functions.gamesForPeriod(_model.periodPageUser, gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), null)!,
                                                                                                          invites: invitesContainerInvitesRowList,
                                                                                                          value: _model.valuePageUser!,
                                                                                                          period: _model.periodPageUser!,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  } else {
                                                                                    return Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(14.0, 26.0, 14.0, 0.0),
                                                                                      child: ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(8.0),
                                                                                        child: Image.asset(
                                                                                          'assets/images/gamesEmpty.png',
                                                                                          width: double.infinity,
                                                                                          fit: BoxFit.fill,
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        Container(
                                                          width: 50.0,
                                                          height: 50.0,
                                                          child: custom_widgets
                                                              .Visibilitydetector(
                                                            width: 50.0,
                                                            height: 50.0,
                                                            visibilityThreshold:
                                                                0.5,
                                                            action: (visible,
                                                                visibility) async {
                                                              _model.visible =
                                                                  visible!;
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ].addToEnd(
                                                      SizedBox(height: 180.0)),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Container(
                                  constraints: BoxConstraints(
                                    minHeight:
                                        MediaQuery.sizeOf(context).height * 1.0,
                                  ),
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, -1.0),
                                    child: StreamBuilder<List<GamesRow>>(
                                      stream: FFAppState().games(
                                        uniqueQueryKey:
                                            '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                                        requestFn: () => _model
                                                .gamesContainerSupabaseStream2 ??=
                                            SupaFlow.client
                                                .from("games")
                                                .stream(primaryKey: ['id'])
                                                .eqOrNull(
                                                  'status',
                                                  'completed',
                                                )
                                                .map((list) => list
                                                    .map((item) =>
                                                        GamesRow(item))
                                                    .toList()),
                                      ),
                                      builder: (context, snapshot) {
                                        // Customize what your widget looks like when it's loading.
                                        if (!snapshot.hasData) {
                                          return Center(
                                            child: SizedBox(
                                              width: 40.0,
                                              height: 40.0,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.transparent,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        List<GamesRow>
                                            gamesContainerGamesRowList =
                                            snapshot.data!;

                                        return Container(
                                          decoration: BoxDecoration(),
                                          child: SingleChildScrollView(
                                            controller:
                                                _model.columnController2,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Stack(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, -1.0),
                                                  children: [
                                                    FutureBuilder<
                                                        List<UsersRow>>(
                                                      future: FFAppState().user(
                                                        uniqueQueryKey:
                                                            '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                                                        requestFn: () =>
                                                            UsersTable()
                                                                .querySingleRow(
                                                          queryFn: (q) =>
                                                              q.eqOrNull(
                                                            'id',
                                                            currentUserUid,
                                                          ),
                                                        ),
                                                      ),
                                                      builder:
                                                          (context, snapshot) {
                                                        // Customize what your widget looks like when it's loading.
                                                        if (!snapshot.hasData) {
                                                          return Center(
                                                            child: SizedBox(
                                                              width: 40.0,
                                                              height: 40.0,
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
                                                        List<UsersRow>
                                                            containerUsersRowList =
                                                            snapshot.data!;

                                                        final containerUsersRow =
                                                            containerUsersRowList
                                                                    .isNotEmpty
                                                                ? containerUsersRowList
                                                                    .first
                                                                : null;

                                                        return Container(
                                                          decoration:
                                                              BoxDecoration(),
                                                          child: Builder(
                                                            builder: (context) {
                                                              if (_model.tab ==
                                                                  1) {
                                                                return Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              -1.0),
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          image:
                                                                              DecorationImage(
                                                                            fit:
                                                                                BoxFit.fill,
                                                                            image:
                                                                                Image.asset(
                                                                              'assets/images/Good_Games_-_My_games.png',
                                                                            ).image,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Align(
                                                                          alignment: AlignmentDirectional(
                                                                              0.0,
                                                                              -1.0),
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                500.0,
                                                                            constraints:
                                                                                BoxConstraints(
                                                                              minHeight: 500.0,
                                                                              maxWidth: 600.0,
                                                                            ),
                                                                            decoration:
                                                                                BoxDecoration(),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 100.0, 0.0, 0.0),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 60.0, 0.0, 8.0),
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                      children: [
                                                                                        Expanded(
                                                                                          child: Padding(
                                                                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 48.0, 0.0, 0.0),
                                                                                            child: Column(
                                                                                              mainAxisSize: MainAxisSize.min,
                                                                                              children: [
                                                                                                Align(
                                                                                                  alignment: AlignmentDirectional(0.0, 1.0),
                                                                                                  child: Text(
                                                                                                    valueOrDefault<String>(
                                                                                                      formatNumber(
                                                                                                        functions.gamesForPeriod(_model.periodPageUser, gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), currentUserUid)?.length,
                                                                                                        formatType: FormatType.custom,
                                                                                                        format: '0',
                                                                                                        locale: '',
                                                                                                      ),
                                                                                                      '0',
                                                                                                    ),
                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                          fontFamily: 'Dela Gothic One',
                                                                                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                          fontSize: 32.0,
                                                                                                          letterSpacing: -1.12,
                                                                                                          lineHeight: 1.5,
                                                                                                        ),
                                                                                                  ),
                                                                                                ),
                                                                                                Padding(
                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                                                                                                  child: Text(
                                                                                                    'Games',
                                                                                                    textAlign: TextAlign.center,
                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                          fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                          fontSize: 11.0,
                                                                                                          letterSpacing: -0.22,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          lineHeight: 1.5,
                                                                                                          useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                        ),
                                                                                                  ),
                                                                                                ),
                                                                                                Row(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                  children: [
                                                                                                    Container(
                                                                                                      height: 24.0,
                                                                                                      constraints: BoxConstraints(
                                                                                                        minWidth: 54.0,
                                                                                                      ),
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: FlutterFlowTheme.of(context).primary,
                                                                                                        boxShadow: [
                                                                                                          BoxShadow(
                                                                                                            blurRadius: 4.0,
                                                                                                            color: Color(0x14000000),
                                                                                                            offset: Offset(
                                                                                                              0.0,
                                                                                                              2.0,
                                                                                                            ),
                                                                                                            spreadRadius: 0.0,
                                                                                                          )
                                                                                                        ],
                                                                                                        borderRadius: BorderRadius.circular(99.0),
                                                                                                      ),
                                                                                                      child: Align(
                                                                                                        alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                        child: Text(
                                                                                                          '#0',
                                                                                                          style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                                fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                                fontSize: 12.0,
                                                                                                                letterSpacing: -0.24,
                                                                                                                lineHeight: 1.5,
                                                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                              ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ].divide(SizedBox(height: 6.0)),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          width: 96.0,
                                                                                          height: 96.0,
                                                                                          decoration: BoxDecoration(
                                                                                            color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                            boxShadow: [
                                                                                              BoxShadow(
                                                                                                blurRadius: 8.0,
                                                                                                color: Color(0x0A000000),
                                                                                                offset: Offset(
                                                                                                  0.0,
                                                                                                  4.0,
                                                                                                ),
                                                                                                spreadRadius: 12.0,
                                                                                              )
                                                                                            ],
                                                                                            shape: BoxShape.circle,
                                                                                            border: Border.all(
                                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                              width: 4.0,
                                                                                            ),
                                                                                          ),
                                                                                          child: wrapWithModel(
                                                                                            model: _model.imageModel5,
                                                                                            updateCallback: () => safeSetState(() {}),
                                                                                            child: ImageWidget(
                                                                                              size: 96.0,
                                                                                              image: valueOrDefault<String>(
                                                                                                containerUsersRow?.photoUrl,
                                                                                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/42sgzx6uejhj/Vector.png',
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Padding(
                                                                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 48.0, 0.0, 0.0),
                                                                                            child: Column(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                Align(
                                                                                                  alignment: AlignmentDirectional(0.0, 1.0),
                                                                                                  child: Text(
                                                                                                    valueOrDefault<String>(
                                                                                                      functions.formatCompactWithComma(valueOrDefault<double>(
                                                                                                        functions.totalSumPeriodGoodPowerPerGame(gamesContainerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList(), _model.periodPageGame),
                                                                                                        0.0,
                                                                                                      )),
                                                                                                      '0',
                                                                                                    ),
                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                          fontFamily: 'Dela Gothic One',
                                                                                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                          fontSize: 32.0,
                                                                                                          letterSpacing: -1.12,
                                                                                                          lineHeight: 1.5,
                                                                                                        ),
                                                                                                  ),
                                                                                                ),
                                                                                                Padding(
                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                                                                                                  child: Text(
                                                                                                    '€nergy per Game',
                                                                                                    textAlign: TextAlign.center,
                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                          fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                          fontSize: 11.0,
                                                                                                          letterSpacing: -0.22,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          lineHeight: 1.5,
                                                                                                          useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                        ),
                                                                                                  ),
                                                                                                ),
                                                                                                Row(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                  children: [
                                                                                                    Container(
                                                                                                      height: 24.0,
                                                                                                      constraints: BoxConstraints(
                                                                                                        minWidth: 54.0,
                                                                                                      ),
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: FlutterFlowTheme.of(context).primary,
                                                                                                        boxShadow: [
                                                                                                          BoxShadow(
                                                                                                            blurRadius: 4.0,
                                                                                                            color: Color(0x14000000),
                                                                                                            offset: Offset(
                                                                                                              0.0,
                                                                                                              2.0,
                                                                                                            ),
                                                                                                            spreadRadius: 0.0,
                                                                                                          )
                                                                                                        ],
                                                                                                        borderRadius: BorderRadius.circular(99.0),
                                                                                                      ),
                                                                                                      child: Align(
                                                                                                        alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                        child: Text(
                                                                                                          '#0',
                                                                                                          style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                                fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                                fontSize: 12.0,
                                                                                                                letterSpacing: -0.24,
                                                                                                                lineHeight: 1.5,
                                                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                              ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ].divide(SizedBox(height: 6.0)),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Column(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      Align(
                                                                                        alignment: AlignmentDirectional(0.0, 1.0),
                                                                                        child: Text(
                                                                                          valueOrDefault<String>(
                                                                                            functions.formatCompactWithComma(valueOrDefault<double>(
                                                                                              functions.totalSumPeriodLichtwattPerGame(gamesContainerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList(), _model.periodPageGame),
                                                                                              0.0,
                                                                                            )),
                                                                                            '0',
                                                                                          ),
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                fontFamily: 'Dela Gothic One',
                                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                fontSize: 32.0,
                                                                                                letterSpacing: -1.12,
                                                                                                lineHeight: 1.5,
                                                                                              ),
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                                                                                        child: Text(
                                                                                          'Good Power per Game',
                                                                                          textAlign: TextAlign.center,
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                fontSize: 11.0,
                                                                                                letterSpacing: -0.22,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                lineHeight: 1.5,
                                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                              ),
                                                                                        ),
                                                                                      ),
                                                                                      Align(
                                                                                        alignment: AlignmentDirectional(0.0, 0.0),
                                                                                        child: Container(
                                                                                          height: 24.0,
                                                                                          constraints: BoxConstraints(
                                                                                            minWidth: 54.0,
                                                                                          ),
                                                                                          decoration: BoxDecoration(
                                                                                            color: FlutterFlowTheme.of(context).primary,
                                                                                            boxShadow: [
                                                                                              BoxShadow(
                                                                                                blurRadius: 4.0,
                                                                                                color: Color(0x14000000),
                                                                                                offset: Offset(
                                                                                                  0.0,
                                                                                                  2.0,
                                                                                                ),
                                                                                                spreadRadius: 0.0,
                                                                                              )
                                                                                            ],
                                                                                            borderRadius: BorderRadius.circular(99.0),
                                                                                          ),
                                                                                          child: Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              Align(
                                                                                                alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                child: Text(
                                                                                                  '#0',
                                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                        fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                        color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                        fontSize: 12.0,
                                                                                                        letterSpacing: -0.24,
                                                                                                        lineHeight: 1.5,
                                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                      ),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ].divide(SizedBox(height: 6.0)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      constraints:
                                                                          BoxConstraints(
                                                                        maxWidth:
                                                                            600.0,
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          if ((gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList().length > 0) ||
                                                                              valueOrDefault<bool>(
                                                                                functions.filterAllGames(
                                                                                            gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(),
                                                                                            _model.periodPageGame,
                                                                                            _model.valuePageGame,
                                                                                            _model.limit,
                                                                                            valueOrDefault<int>(
                                                                                              _model.pageNumberGames,
                                                                                              1,
                                                                                            )) !=
                                                                                        null &&
                                                                                    (functions.filterAllGames(
                                                                                            gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(),
                                                                                            _model.periodPageGame,
                                                                                            _model.valuePageGame,
                                                                                            _model.limit,
                                                                                            valueOrDefault<int>(
                                                                                              _model.pageNumberGames,
                                                                                              1,
                                                                                            )))!
                                                                                        .isNotEmpty,
                                                                                false,
                                                                              ))
                                                                            Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
                                                                              child: Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  InkWell(
                                                                                    splashColor: Colors.transparent,
                                                                                    focusColor: Colors.transparent,
                                                                                    hoverColor: Colors.transparent,
                                                                                    highlightColor: Colors.transparent,
                                                                                    onTap: () async {
                                                                                      if (gamesContainerGamesRowList.where((e) => e.status == 'completed').toList().length > 0) {
                                                                                        showModalBottomSheet(
                                                                                          isScrollControlled: true,
                                                                                          backgroundColor: Colors.transparent,
                                                                                          useSafeArea: true,
                                                                                          context: context,
                                                                                          builder: (context) {
                                                                                            return GestureDetector(
                                                                                              onTap: () {
                                                                                                FocusScope.of(context).unfocus();
                                                                                                FocusManager.instance.primaryFocus?.unfocus();
                                                                                              },
                                                                                              child: Padding(
                                                                                                padding: MediaQuery.viewInsetsOf(context),
                                                                                                child: GoodGamesPlayersFiltersWidget(
                                                                                                  period: _model.periodPageGame!,
                                                                                                  value: _model.valuePageGame!,
                                                                                                  tab: _model.tab,
                                                                                                  update: (period, value) async {
                                                                                                    _model.valuePageGame = value;
                                                                                                    _model.periodPageGame = period;
                                                                                                    safeSetState(() {});
                                                                                                  },
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                        ).then((value) => safeSetState(() {}));
                                                                                      }
                                                                                    },
                                                                                    child: Container(
                                                                                      height: 56.0,
                                                                                      decoration: BoxDecoration(
                                                                                        color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                        borderRadius: BorderRadius.circular(99.0),
                                                                                        border: Border.all(
                                                                                          color: FlutterFlowTheme.of(context).secondary,
                                                                                          width: 2.0,
                                                                                        ),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                                                                        child: Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            Text(
                                                                                              valueOrDefault<String>(
                                                                                                _model.valuePageGame == RatingGamesFilter.recent.name ? 'LETZTE GAMES' : 'MOST ${(_model.valuePageGame!).toUpperCase()} GAMES',
                                                                                                'MOST VALUABLE GAMES',
                                                                                              ),
                                                                                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                    fontSize: 15.0,
                                                                                                    letterSpacing: -0.525,
                                                                                                    fontWeight: FontWeight.w900,
                                                                                                    fontStyle: FontStyle.italic,
                                                                                                    lineHeight: 1.5,
                                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                  ),
                                                                                            ),
                                                                                            Icon(
                                                                                              FFIcons.karrowSeparateVertical,
                                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                                              size: 24.0,
                                                                                            ),
                                                                                          ].divide(SizedBox(width: 12.0)),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ].divide(SizedBox(width: 12.0)),
                                                                              ),
                                                                            ),
                                                                          Builder(
                                                                            builder:
                                                                                (context) {
                                                                              if ((gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList().length > 0) ||
                                                                                  valueOrDefault<bool>(
                                                                                    functions.filterAllGames(
                                                                                                gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(),
                                                                                                _model.periodPageGame,
                                                                                                _model.valuePageGame,
                                                                                                _model.limit,
                                                                                                valueOrDefault<int>(
                                                                                                  _model.pageNumberGames,
                                                                                                  1,
                                                                                                )) !=
                                                                                            null &&
                                                                                        (functions.filterAllGames(
                                                                                                gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(),
                                                                                                _model.periodPageGame,
                                                                                                _model.valuePageGame,
                                                                                                _model.limit,
                                                                                                valueOrDefault<int>(
                                                                                                  _model.pageNumberGames,
                                                                                                  1,
                                                                                                )))!
                                                                                            .isNotEmpty,
                                                                                    false,
                                                                                  )) {
                                                                                return Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(12.0, 24.0, 12.0, 0.0),
                                                                                      child: Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Align(
                                                                                              alignment: AlignmentDirectional(0.0, 0.0),
                                                                                              child: Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 0.0, 0.0),
                                                                                                child: Text(
                                                                                                  '#',
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                        fontSize: 12.0,
                                                                                                        letterSpacing: -0.24,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        lineHeight: 1.5,
                                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                      ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Expanded(
                                                                                            flex: 5,
                                                                                            child: Align(
                                                                                              alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                              child: Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                                child: Text(
                                                                                                  'Details',
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                        fontSize: 12.0,
                                                                                                        letterSpacing: -0.24,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        lineHeight: 1.5,
                                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                      ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Expanded(
                                                                                            flex: 3,
                                                                                            child: Align(
                                                                                              alignment: AlignmentDirectional(1.0, 0.0),
                                                                                              child: Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                                                                                                child: Text(
                                                                                                  'P€',
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                        fontSize: 12.0,
                                                                                                        letterSpacing: -0.24,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        lineHeight: 1.5,
                                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                      ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Expanded(
                                                                                            flex: 3,
                                                                                            child: Align(
                                                                                              alignment: AlignmentDirectional(0.0, 0.0),
                                                                                              child: Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                                                                                                child: Text(
                                                                                                  'Good Power',
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                        fontSize: 12.0,
                                                                                                        letterSpacing: -0.24,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        lineHeight: 1.5,
                                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                      ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 0.0),
                                                                                      child: Container(
                                                                                        width: double.infinity,
                                                                                        decoration: BoxDecoration(
                                                                                          color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                          borderRadius: BorderRadius.circular(16.0),
                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsetsDirectional.fromSTEB(8.0, 12.0, 8.0, 12.0),
                                                                                          child: Column(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            children: [
                                                                                              Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                                                                                child: Builder(
                                                                                                  builder: (context) {
                                                                                                    final games = (functions
                                                                                                                .filterAllGames(
                                                                                                                    gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(),
                                                                                                                    _model.periodPageGame,
                                                                                                                    _model.valuePageGame,
                                                                                                                    _model.limit,
                                                                                                                    valueOrDefault<int>(
                                                                                                                      _model.pageNumberGames,
                                                                                                                      1,
                                                                                                                    ))
                                                                                                                ?.toList() ??
                                                                                                            [])
                                                                                                        .take(10)
                                                                                                        .toList();

                                                                                                    return Column(
                                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                                      children: List.generate(games.length, (gamesIndex) {
                                                                                                        final gamesItem = games[gamesIndex];
                                                                                                        return Column(
                                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                                          children: [
                                                                                                            if (gamesIndex > 0)
                                                                                                              Divider(
                                                                                                                height: 1.0,
                                                                                                                thickness: 1.0,
                                                                                                                indent: 16.0,
                                                                                                                endIndent: 16.0,
                                                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                                              ),
                                                                                                            Padding(
                                                                                                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                                                                                                              child: InkWell(
                                                                                                                splashColor: Colors.transparent,
                                                                                                                focusColor: Colors.transparent,
                                                                                                                hoverColor: Colors.transparent,
                                                                                                                highlightColor: Colors.transparent,
                                                                                                                onTap: () async {
                                                                                                                  context.pushNamed(
                                                                                                                    GamePageWidget.routeName,
                                                                                                                    queryParameters: {
                                                                                                                      'gameRow': serializeParam(
                                                                                                                        gamesItem,
                                                                                                                        ParamType.SupabaseRow,
                                                                                                                      ),
                                                                                                                    }.withoutNulls,
                                                                                                                  );
                                                                                                                },
                                                                                                                child: GamesOrgCompWidget(
                                                                                                                  key: Key('Key3if_${gamesIndex}_of_${games.length}'),
                                                                                                                  index: valueOrDefault<int>(
                                                                                                                    gamesIndex,
                                                                                                                    0,
                                                                                                                  ),
                                                                                                                  game: gamesItem,
                                                                                                                  pageNumber: valueOrDefault<int>(
                                                                                                                    _model.pageNumberGames,
                                                                                                                    1,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ],
                                                                                                        );
                                                                                                      }),
                                                                                                    );
                                                                                                  },
                                                                                                ),
                                                                                              ),
                                                                                              if (valueOrDefault<bool>(
                                                                                                functions.hasMoreGames(gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(), _model.periodPageGame, _model.valuePageGame, 10, 1),
                                                                                                true,
                                                                                              ))
                                                                                                Column(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  children: [
                                                                                                    Divider(
                                                                                                      height: 1.0,
                                                                                                      thickness: 1.0,
                                                                                                      indent: 16.0,
                                                                                                      endIndent: 16.0,
                                                                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                                                                    ),
                                                                                                    Padding(
                                                                                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 16.0),
                                                                                                      child: Row(
                                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                                        children: [
                                                                                                          Icon(
                                                                                                            FFIcons.keye,
                                                                                                            color: FlutterFlowTheme.of(context).primaryText,
                                                                                                            size: 32.0,
                                                                                                          ),
                                                                                                          Expanded(
                                                                                                            child: Column(
                                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                              children: [
                                                                                                                AutoSizeText(
                                                                                                                  'Mehr sehen',
                                                                                                                  maxLines: 1,
                                                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                                        fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                                        fontSize: 18.0,
                                                                                                                        letterSpacing: -0.4,
                                                                                                                        fontWeight: FontWeight.bold,
                                                                                                                        lineHeight: 1.5,
                                                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                                      ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                          if (_model.pageNumberGames! > 1)
                                                                                                            Container(
                                                                                                              width: 56.0,
                                                                                                              height: 40.0,
                                                                                                              decoration: BoxDecoration(
                                                                                                                color: FlutterFlowTheme.of(context).secondary,
                                                                                                                borderRadius: BorderRadius.circular(99.0),
                                                                                                              ),
                                                                                                              child: FlutterFlowIconButton(
                                                                                                                borderColor: Colors.transparent,
                                                                                                                borderRadius: 99.0,
                                                                                                                buttonSize: 40.0,
                                                                                                                fillColor: FlutterFlowTheme.of(context).secondary,
                                                                                                                icon: Icon(
                                                                                                                  FFIcons.karrowLeftLong,
                                                                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                                  size: 24.0,
                                                                                                                ),
                                                                                                                onPressed: () async {
                                                                                                                  _model.pageNumberGames = _model.pageNumberGames! + -1;
                                                                                                                  safeSetState(() {});
                                                                                                                },
                                                                                                              ),
                                                                                                            ),
                                                                                                          if (valueOrDefault<bool>(
                                                                                                            functions.hasMoreGames(gamesContainerGamesRowList.where((e) => (e.creatorUserId == currentUserUid) && (e.status == 'completed')).toList(), _model.periodPageGame, _model.valuePageGame, _model.limit, _model.pageNumberGames),
                                                                                                            true,
                                                                                                          ))
                                                                                                            Container(
                                                                                                              width: 56.0,
                                                                                                              height: 40.0,
                                                                                                              decoration: BoxDecoration(
                                                                                                                color: FlutterFlowTheme.of(context).secondary,
                                                                                                                borderRadius: BorderRadius.circular(99.0),
                                                                                                              ),
                                                                                                              child: FlutterFlowIconButton(
                                                                                                                borderColor: Colors.transparent,
                                                                                                                borderRadius: 99.0,
                                                                                                                buttonSize: 40.0,
                                                                                                                fillColor: FlutterFlowTheme.of(context).secondary,
                                                                                                                icon: Icon(
                                                                                                                  FFIcons.krightArrow,
                                                                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                                  size: 24.0,
                                                                                                                ),
                                                                                                                onPressed: () async {
                                                                                                                  _model.pageNumberGames = _model.pageNumberGames! + 1;
                                                                                                                  safeSetState(() {});
                                                                                                                },
                                                                                                              ),
                                                                                                            ),
                                                                                                        ].divide(SizedBox(width: 16.0)),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              } else {
                                                                                return Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(14.0, 26.0, 14.0, 0.0),
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                                    child: Image.asset(
                                                                                      'assets/images/gamesEmpty.png',
                                                                                      width: double.infinity,
                                                                                      fit: BoxFit.fill,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              } else {
                                                                return Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          500.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        image:
                                                                            DecorationImage(
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          image:
                                                                              Image.asset(
                                                                            'assets/images/Good_Games_-_My_games.png',
                                                                          ).image,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            -1.0),
                                                                        child:
                                                                            Container(
                                                                          constraints:
                                                                              BoxConstraints(
                                                                            maxWidth:
                                                                                600.0,
                                                                          ),
                                                                          decoration:
                                                                              BoxDecoration(),
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                100.0,
                                                                                0.0,
                                                                                0.0),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(
                                                                                        0.0,
                                                                                        0.0,
                                                                                        0.0,
                                                                                        valueOrDefault<double>(
                                                                                          gamesContainerGamesRowList.where((e) => e.status == 'completed').toList().length > 0 ? 0.0 : 100.0,
                                                                                          0.0,
                                                                                        )),
                                                                                    child: ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(0.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/Logo_Good_Games_2026.png',
                                                                                        width: double.infinity,
                                                                                        fit: BoxFit.contain,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                if (gamesContainerGamesRowList.where((e) => e.status == 'completed').toList().length > 0)
                                                                                  Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                    children: [
                                                                                      Align(
                                                                                        alignment: AlignmentDirectional(0.0, 0.0),
                                                                                        child: FutureBuilder<List<UsersRow>>(
                                                                                          future: _model.user1(
                                                                                            uniqueQueryKey: valueOrDefault<String>(
                                                                                              containerUsersRow?.id,
                                                                                              '0',
                                                                                            ),
                                                                                            requestFn: () => UsersTable().querySingleRow(
                                                                                              queryFn: (q) => q.eqOrNull(
                                                                                                'id',
                                                                                                functions.ratingUsersIds(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, 10, _model.pageNumberUsers, functions.getEmptyInvitesList().toList())?.elementAtOrNull(1),
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
                                                                                            List<UsersRow> stackUsersRowList = snapshot.data!;

                                                                                            // Return an empty Container when the item does not exist.
                                                                                            if (snapshot.data!.isEmpty) {
                                                                                              return Container();
                                                                                            }
                                                                                            final stackUsersRow = stackUsersRowList.isNotEmpty ? stackUsersRowList.first : null;

                                                                                            return Stack(
                                                                                              alignment: AlignmentDirectional(1.0, 1.0),
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: 96.0,
                                                                                                  height: 96.0,
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                    boxShadow: [
                                                                                                      BoxShadow(
                                                                                                        blurRadius: 8.0,
                                                                                                        color: Color(0x0A000000),
                                                                                                        offset: Offset(
                                                                                                          0.0,
                                                                                                          4.0,
                                                                                                        ),
                                                                                                        spreadRadius: 12.0,
                                                                                                      )
                                                                                                    ],
                                                                                                    shape: BoxShape.circle,
                                                                                                    border: Border.all(
                                                                                                      color: FlutterFlowTheme.of(context).silver,
                                                                                                      width: 4.0,
                                                                                                    ),
                                                                                                  ),
                                                                                                  child: InkWell(
                                                                                                    splashColor: Colors.transparent,
                                                                                                    focusColor: Colors.transparent,
                                                                                                    hoverColor: Colors.transparent,
                                                                                                    highlightColor: Colors.transparent,
                                                                                                    onTap: () async {
                                                                                                      unawaited(
                                                                                                        () async {
                                                                                                          context.pushNamed(
                                                                                                            UserProfilePageWidget.routeName,
                                                                                                            queryParameters: {
                                                                                                              'userId': serializeParam(
                                                                                                                stackUsersRow?.id,
                                                                                                                ParamType.String,
                                                                                                              ),
                                                                                                            }.withoutNulls,
                                                                                                          );
                                                                                                        }(),
                                                                                                      );
                                                                                                    },
                                                                                                    child: wrapWithModel(
                                                                                                      model: _model.imageModel6,
                                                                                                      updateCallback: () => safeSetState(() {}),
                                                                                                      child: ImageWidget(
                                                                                                        size: 96.0,
                                                                                                        image: valueOrDefault<String>(
                                                                                                          stackUsersRow?.photoUrl,
                                                                                                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                                  child: Image.asset(
                                                                                                    'assets/images/second.png',
                                                                                                    width: 40.0,
                                                                                                    height: 48.0,
                                                                                                    fit: BoxFit.cover,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            );
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                      Align(
                                                                                        alignment: AlignmentDirectional(0.0, 0.0),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 48.0),
                                                                                          child: FutureBuilder<List<UsersRow>>(
                                                                                            future: _model.user2(
                                                                                              uniqueQueryKey: valueOrDefault<String>(
                                                                                                containerUsersRow?.id,
                                                                                                '0',
                                                                                              ),
                                                                                              requestFn: () => UsersTable().querySingleRow(
                                                                                                queryFn: (q) => q.eqOrNull(
                                                                                                  'id',
                                                                                                  functions.ratingUsersIds(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, 10, _model.pageNumberUsers, functions.getEmptyInvitesList().toList())?.firstOrNull,
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
                                                                                              List<UsersRow> stackUsersRowList = snapshot.data!;

                                                                                              // Return an empty Container when the item does not exist.
                                                                                              if (snapshot.data!.isEmpty) {
                                                                                                return Container();
                                                                                              }
                                                                                              final stackUsersRow = stackUsersRowList.isNotEmpty ? stackUsersRowList.first : null;

                                                                                              return Stack(
                                                                                                alignment: AlignmentDirectional(1.0, 1.0),
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                                                                                                    child: Container(
                                                                                                      width: 96.0,
                                                                                                      height: 96.0,
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                        boxShadow: [
                                                                                                          BoxShadow(
                                                                                                            blurRadius: 8.0,
                                                                                                            color: Color(0x0A000000),
                                                                                                            offset: Offset(
                                                                                                              0.0,
                                                                                                              4.0,
                                                                                                            ),
                                                                                                            spreadRadius: 12.0,
                                                                                                          )
                                                                                                        ],
                                                                                                        shape: BoxShape.circle,
                                                                                                        border: Border.all(
                                                                                                          color: FlutterFlowTheme.of(context).gold,
                                                                                                          width: 4.0,
                                                                                                        ),
                                                                                                      ),
                                                                                                      child: InkWell(
                                                                                                        splashColor: Colors.transparent,
                                                                                                        focusColor: Colors.transparent,
                                                                                                        hoverColor: Colors.transparent,
                                                                                                        highlightColor: Colors.transparent,
                                                                                                        onTap: () async {
                                                                                                          unawaited(
                                                                                                            () async {
                                                                                                              context.pushNamed(
                                                                                                                UserProfilePageWidget.routeName,
                                                                                                                queryParameters: {
                                                                                                                  'userId': serializeParam(
                                                                                                                    stackUsersRow?.id,
                                                                                                                    ParamType.String,
                                                                                                                  ),
                                                                                                                }.withoutNulls,
                                                                                                              );
                                                                                                            }(),
                                                                                                          );
                                                                                                        },
                                                                                                        child: wrapWithModel(
                                                                                                          model: _model.imageModel7,
                                                                                                          updateCallback: () => safeSetState(() {}),
                                                                                                          child: ImageWidget(
                                                                                                            size: 96.0,
                                                                                                            image: valueOrDefault<String>(
                                                                                                              stackUsersRow?.photoUrl,
                                                                                                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(8.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/first.png',
                                                                                                        width: 40.0,
                                                                                                        height: 48.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Align(
                                                                                        alignment: AlignmentDirectional(0.0, 0.0),
                                                                                        child: FutureBuilder<List<UsersRow>>(
                                                                                          future: _model.user3(
                                                                                            uniqueQueryKey: valueOrDefault<String>(
                                                                                              containerUsersRow?.id,
                                                                                              '0',
                                                                                            ),
                                                                                            requestFn: () => UsersTable().querySingleRow(
                                                                                              queryFn: (q) => q.eqOrNull(
                                                                                                'id',
                                                                                                functions.ratingUsersIds(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, 10, _model.pageNumberUsers, functions.getEmptyInvitesList().toList())?.elementAtOrNull(2),
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
                                                                                            List<UsersRow> stackUsersRowList = snapshot.data!;

                                                                                            // Return an empty Container when the item does not exist.
                                                                                            if (snapshot.data!.isEmpty) {
                                                                                              return Container();
                                                                                            }
                                                                                            final stackUsersRow = stackUsersRowList.isNotEmpty ? stackUsersRowList.first : null;

                                                                                            return Stack(
                                                                                              alignment: AlignmentDirectional(1.0, 1.0),
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                                                                                                  child: Container(
                                                                                                    width: 96.0,
                                                                                                    height: 96.0,
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                      boxShadow: [
                                                                                                        BoxShadow(
                                                                                                          blurRadius: 8.0,
                                                                                                          color: Color(0x0A000000),
                                                                                                          offset: Offset(
                                                                                                            0.0,
                                                                                                            4.0,
                                                                                                          ),
                                                                                                          spreadRadius: 12.0,
                                                                                                        )
                                                                                                      ],
                                                                                                      shape: BoxShape.circle,
                                                                                                      border: Border.all(
                                                                                                        color: FlutterFlowTheme.of(context).bronze,
                                                                                                        width: 4.0,
                                                                                                      ),
                                                                                                    ),
                                                                                                    child: InkWell(
                                                                                                      splashColor: Colors.transparent,
                                                                                                      focusColor: Colors.transparent,
                                                                                                      hoverColor: Colors.transparent,
                                                                                                      highlightColor: Colors.transparent,
                                                                                                      onTap: () async {
                                                                                                        unawaited(
                                                                                                          () async {
                                                                                                            context.pushNamed(
                                                                                                              UserProfilePageWidget.routeName,
                                                                                                              queryParameters: {
                                                                                                                'userId': serializeParam(
                                                                                                                  stackUsersRow?.id,
                                                                                                                  ParamType.String,
                                                                                                                ),
                                                                                                              }.withoutNulls,
                                                                                                            );
                                                                                                          }(),
                                                                                                        );
                                                                                                      },
                                                                                                      child: wrapWithModel(
                                                                                                        model: _model.imageModel8,
                                                                                                        updateCallback: () => safeSetState(() {}),
                                                                                                        child: ImageWidget(
                                                                                                          size: 96.0,
                                                                                                          image: valueOrDefault<String>(
                                                                                                            stackUsersRow?.photoUrl,
                                                                                                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                                  child: Image.asset(
                                                                                                    'assets/images/third.png',
                                                                                                    width: 40.0,
                                                                                                    height: 48.0,
                                                                                                    fit: BoxFit.cover,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            );
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ].addToStart(SizedBox(width: 24.0)).addToEnd(SizedBox(width: 24.0)),
                                                                                  ),
                                                                              ].addToStart(SizedBox(height: 24.0)),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      constraints:
                                                                          BoxConstraints(
                                                                        maxWidth:
                                                                            600.0,
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          if (gamesContainerGamesRowList.where((e) => e.status == 'completed').toList().length >
                                                                              0)
                                                                            Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
                                                                              child: Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  InkWell(
                                                                                    splashColor: Colors.transparent,
                                                                                    focusColor: Colors.transparent,
                                                                                    hoverColor: Colors.transparent,
                                                                                    highlightColor: Colors.transparent,
                                                                                    onTap: () async {
                                                                                      if (gamesContainerGamesRowList.where((e) => e.status == 'completed').toList().length > 0) {
                                                                                        showModalBottomSheet(
                                                                                          isScrollControlled: true,
                                                                                          backgroundColor: Colors.transparent,
                                                                                          useSafeArea: true,
                                                                                          context: context,
                                                                                          builder: (context) {
                                                                                            return GestureDetector(
                                                                                              onTap: () {
                                                                                                FocusScope.of(context).unfocus();
                                                                                                FocusManager.instance.primaryFocus?.unfocus();
                                                                                              },
                                                                                              child: Padding(
                                                                                                padding: MediaQuery.viewInsetsOf(context),
                                                                                                child: GoodGamesPlayersFiltersWidget(
                                                                                                  period: _model.periodPageUser!,
                                                                                                  value: _model.valuePageUser!,
                                                                                                  tab: _model.tab,
                                                                                                  update: (period, value) async {
                                                                                                    _model.valuePageUser = value;
                                                                                                    _model.periodPageUser = period;
                                                                                                    safeSetState(() {});
                                                                                                    _model.clearUser2Cache();
                                                                                                    _model.clearUser1Cache();
                                                                                                    _model.clearUser3Cache();

                                                                                                    FFAppState().update(() {});
                                                                                                  },
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                        ).then((value) => safeSetState(() {}));
                                                                                      }
                                                                                    },
                                                                                    child: Container(
                                                                                      height: 56.0,
                                                                                      decoration: BoxDecoration(
                                                                                        color: FlutterFlowTheme.of(context).tertiary,
                                                                                        borderRadius: BorderRadius.circular(99.0),
                                                                                        border: Border.all(
                                                                                          color: FlutterFlowTheme.of(context).tertiary,
                                                                                          width: 2.0,
                                                                                        ),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                                                                        child: Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            Text(
                                                                                              'MOST ${(_model.valuePageUser!).toUpperCase()} PLAYER',
                                                                                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                                    fontSize: 15.0,
                                                                                                    letterSpacing: -0.525,
                                                                                                    fontWeight: FontWeight.w900,
                                                                                                    fontStyle: FontStyle.italic,
                                                                                                    lineHeight: 1.5,
                                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                  ),
                                                                                            ),
                                                                                            Icon(
                                                                                              FFIcons.karrowSeparateVertical,
                                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                              size: 24.0,
                                                                                            ),
                                                                                          ].divide(SizedBox(width: 12.0)),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ].divide(SizedBox(width: 12.0)),
                                                                              ),
                                                                            ),
                                                                          Builder(
                                                                            builder:
                                                                                (context) {
                                                                              if (functions.ratingUsersIds(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, 10, _model.pageNumberUsers, functions.getEmptyInvitesList().toList())!.length > 0) {
                                                                                return Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(12.0, 24.0, 12.0, 0.0),
                                                                                      child: Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                        children: [
                                                                                          Align(
                                                                                            alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                            child: Container(
                                                                                              width: 30.0,
                                                                                              decoration: BoxDecoration(),
                                                                                              child: Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 0.0, 0.0),
                                                                                                child: Text(
                                                                                                  '#',
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                        fontSize: 14.0,
                                                                                                        letterSpacing: -0.24,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        lineHeight: 1.5,
                                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                      ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              'Name',
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                    fontSize: 14.0,
                                                                                                    letterSpacing: -0.24,
                                                                                                    fontWeight: FontWeight.bold,
                                                                                                    lineHeight: 1.5,
                                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                  ),
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            ' ',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                  fontSize: 12.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                ),
                                                                                          ),
                                                                                          Padding(
                                                                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 50.0, 0.0),
                                                                                            child: Text(
                                                                                              valueOrDefault<String>(
                                                                                                () {
                                                                                                  if (_model.valuePageUser == RatingGamesFilter.generous.name) {
                                                                                                    return 'P€        ';
                                                                                                  } else if (_model.valuePageUser == RatingGamesFilter.social.name) {
                                                                                                    return 'Sponsoren';
                                                                                                  } else if (_model.valuePageUser == RatingGamesFilter.active.name) {
                                                                                                    return 'Games';
                                                                                                  } else {
                                                                                                    return 'Good Power';
                                                                                                  }
                                                                                                }(),
                                                                                                'Good Power',
                                                                                              ),
                                                                                              maxLines: 1,
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                    fontSize: 14.0,
                                                                                                    letterSpacing: -0.24,
                                                                                                    fontWeight: FontWeight.bold,
                                                                                                    lineHeight: 1.5,
                                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                  ),
                                                                                            ),
                                                                                          ),
                                                                                        ].divide(SizedBox(width: 32.0)),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 0.0),
                                                                                      child: Container(
                                                                                        width: double.infinity,
                                                                                        decoration: BoxDecoration(
                                                                                          color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                          borderRadius: BorderRadius.circular(16.0),
                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsetsDirectional.fromSTEB(8.0, 12.0, 8.0, 12.0),
                                                                                          child: Column(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            children: [
                                                                                              Builder(
                                                                                                builder: (context) {
                                                                                                  final ratingUsers = (functions.ratingUsersIds(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, _model.limit, _model.pageNumberUsers, functions.getEmptyInvitesList().toList())?.toList() ?? []).take(10).toList();

                                                                                                  return Column(
                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                    children: List.generate(ratingUsers.length, (ratingUsersIndex) {
                                                                                                      final ratingUsersItem = ratingUsers[ratingUsersIndex];
                                                                                                      return Column(
                                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                                        children: [
                                                                                                          if (ratingUsersIndex > 0)
                                                                                                            Divider(
                                                                                                              height: 1.0,
                                                                                                              thickness: 1.0,
                                                                                                              indent: 16.0,
                                                                                                              endIndent: 16.0,
                                                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                                                            ),
                                                                                                          Padding(
                                                                                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                                                                                                            child: GamesUserCompWidget(
                                                                                                              key: Key('Keypm6_${ratingUsersIndex}_of_${ratingUsers.length}'),
                                                                                                              rating: valueOrDefault<int>(
                                                                                                                ratingUsersIndex + 1,
                                                                                                                1,
                                                                                                              ),
                                                                                                              userId: ratingUsersItem,
                                                                                                              games: gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(),
                                                                                                              invites: functions.getEmptyInvitesList(),
                                                                                                              value: _model.valuePageUser!,
                                                                                                              period: _model.periodPageUser!,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      );
                                                                                                    }),
                                                                                                  );
                                                                                                },
                                                                                              ),
                                                                                              if (functions.ratingUsersPerUser(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, functions.getEmptyInvitesList().toList(), containerUsersRow?.id, allUsersContainerUsersRowList.length) >
                                                                                                  (valueOrDefault<int>(
                                                                                                        _model.limit,
                                                                                                        10,
                                                                                                      ) *
                                                                                                      (_model.pageNumberUsers!)))
                                                                                                StyledDivider(
                                                                                                  height: 1.0,
                                                                                                  thickness: 2.0,
                                                                                                  indent: 16.0,
                                                                                                  endIndent: 16.0,
                                                                                                  color: FlutterFlowTheme.of(context).primary,
                                                                                                  lineStyle: DividerLineStyle.dotted,
                                                                                                ),
                                                                                              if (functions.ratingUsersPerUser(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, functions.getEmptyInvitesList().toList(), containerUsersRow?.id, allUsersContainerUsersRowList.length) >
                                                                                                  (valueOrDefault<int>(
                                                                                                        _model.limit,
                                                                                                        10,
                                                                                                      ) *
                                                                                                      (_model.pageNumberUsers!)))
                                                                                                Padding(
                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                                                                                                  child: wrapWithModel(
                                                                                                    model: _model.gamesUserCompModel4,
                                                                                                    updateCallback: () => safeSetState(() {}),
                                                                                                    updateOnChange: true,
                                                                                                    child: GamesUserCompWidget(
                                                                                                      rating: functions.ratingUsersPerUser(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), _model.periodPageUser, _model.valuePageUser, functions.getEmptyInvitesList().toList(), containerUsersRow?.id, allUsersContainerUsersRowList.length),
                                                                                                      userId: containerUsersRow!.id,
                                                                                                      games: functions.gamesForPeriod(_model.periodPageUser, gamesContainerGamesRowList.where((e) => e.status == 'completed').toList(), null)!,
                                                                                                      invites: functions.getEmptyInvitesList(),
                                                                                                      value: _model.valuePageUser!,
                                                                                                      period: _model.periodPageUser!,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              } else {
                                                                                return Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(14.0, 26.0, 14.0, 0.0),
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                                    child: Image.asset(
                                                                                      'assets/images/gamesEmpty.png',
                                                                                      width: double.infinity,
                                                                                      fit: BoxFit.fill,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    Container(
                                                      width: 50.0,
                                                      height: 50.0,
                                                      child: custom_widgets
                                                          .Visibilitydetector(
                                                        width: 50.0,
                                                        height: 50.0,
                                                        visibilityThreshold:
                                                            0.5,
                                                        action: (visible,
                                                            visibility) async {
                                                          _model.visible =
                                                              visible!;
                                                          safeSetState(() {});
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ].addToEnd(
                                                  SizedBox(height: 180.0)),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, 1.0),
                    child: wrapWithModel(
                      model: _model.navbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: NavbarWidget(
                        pageNumber: 4,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, -1.0),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: 150.0,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            valueOrDefault<Color>(
                              _model.visible
                                  ? Colors.transparent
                                  : FlutterFlowTheme.of(context).accent3,
                              FlutterFlowTheme.of(context).accent3,
                            ),
                            valueOrDefault<Color>(
                              _model.visible
                                  ? Colors.transparent
                                  : FlutterFlowTheme.of(context).accent2,
                              FlutterFlowTheme.of(context).accent2,
                            )
                          ],
                          stops: [0.0, 1.0],
                          begin: AlignmentDirectional(1.0, 0.0),
                          end: AlignmentDirectional(-1.0, 0),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                30.0, 80.0, 30.0, 12.0),
                            child: Container(
                              width: double.infinity,
                              height: 38.0,
                              constraints: BoxConstraints(
                                maxWidth: 600.0,
                              ),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                borderRadius: BorderRadius.circular(32.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(1.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: FFButtonWidget(
                                        onPressed: () async {
                                          _model.tab = 2;
                                          safeSetState(() {});
                                        },
                                        text: 'Meisterschaft',
                                        options: FFButtonOptions(
                                          height: 32.0,
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 0.0, 16.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          color: valueOrDefault<Color>(
                                            _model.tab == 1
                                                ? Colors.transparent
                                                : FlutterFlowTheme.of(context)
                                                    .primary,
                                            Colors.transparent,
                                          ),
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                color: valueOrDefault<Color>(
                                                  _model.tab == 1
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primaryBackground,
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                                ),
                                                fontSize: 16.0,
                                                letterSpacing: -0.35,
                                                fontWeight: FontWeight.w600,
                                                lineHeight: 1.5,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmallIsCustom,
                                              ),
                                          elevation: 0.0,
                                          borderRadius:
                                              BorderRadius.circular(99.0),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: FFButtonWidget(
                                        onPressed: () async {
                                          _model.tab = 1;
                                          safeSetState(() {});
                                        },
                                        text: 'Meine Games',
                                        options: FFButtonOptions(
                                          height: 32.0,
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 0.0, 16.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          color: valueOrDefault<Color>(
                                            _model.tab == 1
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : Colors.transparent,
                                            FlutterFlowTheme.of(context)
                                                .secondary,
                                          ),
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                color: valueOrDefault<Color>(
                                                  _model.tab == 1
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primaryBackground
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                                ),
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmallIsCustom,
                                              ),
                                          elevation: 0.0,
                                          borderRadius:
                                              BorderRadius.circular(99.0),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 4.0)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
