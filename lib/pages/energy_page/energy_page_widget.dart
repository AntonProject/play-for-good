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
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'energy_page_model.dart';
export 'energy_page_model.dart';

class EnergyPageWidget extends StatefulWidget {
  const EnergyPageWidget({super.key});

  static String routeName = 'EnergyPage';
  static String routePath = '/energyPage';

  @override
  State<EnergyPageWidget> createState() => _EnergyPageWidgetState();
}

class _EnergyPageWidgetState extends State<EnergyPageWidget> {
  late EnergyPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EnergyPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.setStatusBarColor(
        false,
      );
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
        title: 'EnergyPage',
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
                SingleChildScrollView(
                  controller: _model.columnController,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Stack(
                        alignment: AlignmentDirectional(0.0, -1.0),
                        children: [
                          Builder(
                            builder: (context) {
                              if (loggedIn) {
                                return FutureBuilder<List<GamesRow>>(
                                  future: FFAppState().gamesUser(
                                    uniqueQueryKey:
                                        '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                                    requestFn: () => GamesTable().queryRows(
                                      queryFn: (q) => q.eqOrNull(
                                        'creator_user_id',
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
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            constraints: BoxConstraints(
                                              minHeight: 350.0,
                                              maxWidth: double.infinity,
                                            ),
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: Image.asset(
                                                  'assets/images/Good_Games_-_My_games.png',
                                                ).image,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                wrapWithModel(
                                                  model: _model.energyCompModel,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: EnergyCompWidget(),
                                                ),
                                              ].addToStart(
                                                  SizedBox(height: 130.0)),
                                            ),
                                          ),
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: 600.0,
                                            ),
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          12.0, 0.0, 12.0, 0.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          width: 200.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16.0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        8.0,
                                                                        20.0,
                                                                        12.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          0.0,
                                                                          4.0,
                                                                          0.0,
                                                                          0.0),
                                                                      child:
                                                                          Icon(
                                                                        FFIcons
                                                                            .kgroup2,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                        size:
                                                                            28.0,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Align(
                                                                        alignment: AlignmentDirectional(
                                                                            1.0,
                                                                            0.0),
                                                                        child:
                                                                            Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                            functions.formatCompactWithComma(valueOrDefault<double>(
                                                                              functions.totalSum(containerGamesRowList.where((e) => e.status == 'completed').toList().map((e) => e.sponsorMoney).withoutNulls.toList()),
                                                                              0.0,
                                                                            )),
                                                                            '0',
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: 'Dela Gothic One',
                                                                                color: FlutterFlowTheme.of(context).tertiary,
                                                                                fontSize: 32.0,
                                                                                letterSpacing: 0.0,
                                                                                lineHeight: 1.5,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  'Community €nergy',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                        fontSize:
                                                                            11.0,
                                                                        letterSpacing:
                                                                            -0.22,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        lineHeight:
                                                                            2.18,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          width: 200.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16.0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        8.0,
                                                                        20.0,
                                                                        12.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          0.0,
                                                                          4.0,
                                                                          0.0,
                                                                          0.0),
                                                                      child:
                                                                          Icon(
                                                                        FFIcons
                                                                            .kuser2,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                        size:
                                                                            24.0,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Align(
                                                                        alignment: AlignmentDirectional(
                                                                            1.0,
                                                                            0.0),
                                                                        child:
                                                                            Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                            functions.formatCompactWithComma(valueOrDefault<double>(
                                                                              functions.totalSumPeriodGoodPower(containerGamesRowList.where((e) => (e.status == 'completed') && (e.creatorUserId == currentUserUid)).toList(), Period.gesamt.name),
                                                                              0.0,
                                                                            )),
                                                                            '0',
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: 'Dela Gothic One',
                                                                                color: FlutterFlowTheme.of(context).tertiary,
                                                                                fontSize: 32.0,
                                                                                letterSpacing: 0.0,
                                                                                lineHeight: 1.5,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  'Persönliche €nergy',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                        fontSize:
                                                                            11.0,
                                                                        letterSpacing:
                                                                            -0.22,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        lineHeight:
                                                                            2.18,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 20.0)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          12.0, 0.0, 12.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      12.0,
                                                                      0.0,
                                                                      12.0,
                                                                      0.0),
                                                          child: Text(
                                                            'Letzte Wirkung',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  fontSize:
                                                                      20.0,
                                                                  letterSpacing:
                                                                      -0.8,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  lineHeight:
                                                                      1.4,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmallIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      Builder(
                                                        builder: (context) {
                                                          if (valueOrDefault<
                                                              bool>(
                                                            functions.filterAllGames(
                                                                        containerGamesRowList
                                                                            .where((e) =>
                                                                                e.status ==
                                                                                'completed')
                                                                            .toList(),
                                                                        Period
                                                                            .gesamt
                                                                            .name,
                                                                        RatingGamesFilter
                                                                            .recent
                                                                            .name,
                                                                        10,
                                                                        _model
                                                                            .pageNumber) !=
                                                                    null &&
                                                                (functions.filterAllGames(
                                                                        containerGamesRowList
                                                                            .where((e) =>
                                                                                e.status ==
                                                                                'completed')
                                                                            .toList(),
                                                                        Period
                                                                            .gesamt
                                                                            .name,
                                                                        RatingGamesFilter
                                                                            .recent
                                                                            .name,
                                                                        10,
                                                                        _model
                                                                            .pageNumber))!
                                                                    .isNotEmpty,
                                                            true,
                                                          )) {
                                                            return Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16.0),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            12.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Builder(
                                                                      builder:
                                                                          (context) {
                                                                        final containerVar = (functions.filterAllGames(containerGamesRowList.where((e) => e.status == 'completed').toList(), Period.gesamt.name, RatingGamesFilter.recent.name, 10, _model.pageNumber)?.toList() ??
                                                                                [])
                                                                            .take(10)
                                                                            .toList();
                                                                        if (containerVar
                                                                            .isEmpty) {
                                                                          return Image
                                                                              .asset(
                                                                            'assets/images/energyEmpty.png',
                                                                          );
                                                                        }

                                                                        return Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: List.generate(
                                                                              containerVar.length,
                                                                              (containerVarIndex) {
                                                                            final containerVarItem =
                                                                                containerVar[containerVarIndex];
                                                                            return Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                if (containerVarIndex > 0)
                                                                                  Divider(
                                                                                    height: 1.0,
                                                                                    thickness: 1.0,
                                                                                    indent: 16.0,
                                                                                    endIndent: 16.0,
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                  ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.all(16.0),
                                                                                  child: ImpactCompWidget(
                                                                                    key: Key('Key2dq_${containerVarIndex}_of_${containerVar.length}'),
                                                                                    game: containerVarItem,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          }),
                                                                        );
                                                                      },
                                                                    ),
                                                                    if (functions.hasMoreGames(
                                                                        containerGamesRowList
                                                                            .where((e) =>
                                                                                e.status ==
                                                                                'completed')
                                                                            .toList(),
                                                                        Period
                                                                            .gesamt
                                                                            .name,
                                                                        RatingGamesFilter
                                                                            .recent
                                                                            .name,
                                                                        10,
                                                                        1))
                                                                      Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          Divider(
                                                                            height:
                                                                                1.0,
                                                                            thickness:
                                                                                1.0,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                8.0,
                                                                                16.0,
                                                                                8.0,
                                                                                16.0),
                                                                            child:
                                                                                Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Icon(
                                                                                  FFIcons.keye,
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  size: 24.0,
                                                                                ),
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    'See more',
                                                                                    style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                          fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                          fontSize: 18.0,
                                                                                          letterSpacing: -0.4,
                                                                                          fontWeight: FontWeight.bold,
                                                                                          lineHeight: 1.5,
                                                                                          useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                        ),
                                                                                  ),
                                                                                ),
                                                                                if (_model.pageNumber! > 1)
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
                                                                                        _model.pageNumber = _model.pageNumber! + -1;
                                                                                        safeSetState(() {});
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                if (functions.hasMoreGames(containerGamesRowList.where((e) => e.status == 'completed').toList(), Period.gesamt.name, RatingGamesFilter.recent.name, 10, _model.pageNumber))
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
                                                                                        _model.pageNumber = _model.pageNumber! + 1;
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
                                                            );
                                                          } else {
                                                            return ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/energyEmpty.png',
                                                                width: double
                                                                    .infinity,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ]
                                                        .divide(SizedBox(
                                                            height: 12.0))
                                                        .addToStart(SizedBox(
                                                            height: 12.0)),
                                                  ),
                                                ),
                                                if (responsiveVisibility(
                                                  context: context,
                                                  phone: false,
                                                  tablet: false,
                                                  tabletLandscape: false,
                                                  desktop: false,
                                                ))
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(14.0, 0.0,
                                                                14.0, 0.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  -1.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        10.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Text(
                                                              'Transformation method',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .titleSmallFamily,
                                                                    fontSize:
                                                                        18.0,
                                                                    letterSpacing:
                                                                        -0.63,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    lineHeight:
                                                                        1.4,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .titleSmallIsCustom,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        FutureBuilder<
                                                            List<UsersRow>>(
                                                          future:
                                                              FFAppState().user(
                                                            uniqueQueryKey: '',
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
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16.0),
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        32.0,
                                                                        24.0,
                                                                        32.0,
                                                                        24.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Builder(
                                                                      builder:
                                                                          (context) {
                                                                        if (containerUsersRow?.paymentMethod ==
                                                                            PaymentMethods
                                                                                .google.name) {
                                                                          return Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children:
                                                                                [
                                                                              Container(
                                                                                width: 40.0,
                                                                                height: 40.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                                child: Icon(
                                                                                  FFIcons.kgoogle,
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  size: 16.0,
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'Google Pay',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                        letterSpacing: -0.4,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                              Icon(
                                                                                FFIcons.kcheckCircle,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                size: 24.0,
                                                                              ),
                                                                            ].divide(SizedBox(width: 16.0)).addToEnd(SizedBox(width: 8.0)),
                                                                          );
                                                                        } else if (containerUsersRow?.paymentMethod ==
                                                                            PaymentMethods
                                                                                .paypal.name) {
                                                                          return Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children:
                                                                                [
                                                                              Container(
                                                                                width: 40.0,
                                                                                height: 40.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                                child: Icon(
                                                                                  FFIcons.kpaypal,
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  size: 16.0,
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'PayPal',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                        letterSpacing: -0.4,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                              Icon(
                                                                                FFIcons.kcheckCircle,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                size: 24.0,
                                                                              ),
                                                                            ].divide(SizedBox(width: 16.0)).addToEnd(SizedBox(width: 8.0)),
                                                                          );
                                                                        } else if (containerUsersRow?.paymentMethod ==
                                                                            PaymentMethods.apple.name) {
                                                                          return Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children:
                                                                                [
                                                                              Container(
                                                                                width: 40.0,
                                                                                height: 40.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                                child: Icon(
                                                                                  FFIcons.kappleMac,
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  size: 16.0,
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'Apple Pay',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                        letterSpacing: -0.4,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                              Icon(
                                                                                FFIcons.kcheckCircle,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                size: 24.0,
                                                                              ),
                                                                            ].divide(SizedBox(width: 16.0)).addToEnd(SizedBox(width: 8.0)),
                                                                          );
                                                                        } else {
                                                                          return Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children:
                                                                                [
                                                                              Container(
                                                                                width: 40.0,
                                                                                height: 40.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                                child: Icon(
                                                                                  FFIcons.kcard,
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  size: 16.0,
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'Card',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                        letterSpacing: -0.4,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                              Icon(
                                                                                FFIcons.kcheckCircle,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                size: 24.0,
                                                                              ),
                                                                            ].divide(SizedBox(width: 16.0)).addToEnd(SizedBox(width: 8.0)),
                                                                          );
                                                                        }
                                                                      },
                                                                    ),
                                                                    Divider(
                                                                      height:
                                                                          32.0,
                                                                      thickness:
                                                                          1.0,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                    ),
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
                                                                        Icon(
                                                                          FFIcons
                                                                              .klist,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          size:
                                                                              24.0,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            'Change',
                                                                            style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                  letterSpacing: -0.4,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  lineHeight: 1.5,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              56.0,
                                                                          height:
                                                                              40.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondary,
                                                                            borderRadius:
                                                                                BorderRadius.circular(99.0),
                                                                          ),
                                                                          child:
                                                                              FlutterFlowIconButton(
                                                                            borderColor:
                                                                                Colors.transparent,
                                                                            borderRadius:
                                                                                99.0,
                                                                            buttonSize:
                                                                                40.0,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).secondary,
                                                                            icon:
                                                                                Icon(
                                                                              FFIcons.krightArrow,
                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                              size: 24.0,
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              print('IconButton pressed ...');
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ].divide(SizedBox(width: 16.0)).addToStart(SizedBox(width: 8.0)).addToEnd(
                                                                              SizedBox(width: 8.0)),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ]
                                                          .divide(SizedBox(
                                                              height: 12.0))
                                                          .addToStart(SizedBox(
                                                              height: 12.0)),
                                                    ),
                                                  ),
                                              ].divide(SizedBox(height: 20.0)),
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 20.0)),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Container(
                                  decoration: BoxDecoration(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        constraints: BoxConstraints(
                                          minHeight: 350.0,
                                          maxWidth: double.infinity,
                                        ),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: Image.asset(
                                              'assets/images/Good_Games_-_My_games.png',
                                            ).image,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            wrapWithModel(
                                              model:
                                                  _model.energyCompGuestModel,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: EnergyCompGuestWidget(),
                                            ),
                                          ].addToStart(SizedBox(height: 130.0)),
                                        ),
                                      ),
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 600.0,
                                        ),
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      12.0, 0.0, 12.0, 0.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      width: 200.0,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    20.0,
                                                                    8.0,
                                                                    20.0,
                                                                    12.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          4.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    FFIcons
                                                                        .kgroup2,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 28.0,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            1.0,
                                                                            0.0),
                                                                    child: Text(
                                                                      '0',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                'Dela Gothic One',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).tertiary,
                                                                            fontSize:
                                                                                32.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            lineHeight:
                                                                                1.5,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              'Community €nergy',
                                                              textAlign:
                                                                  TextAlign.end,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    fontSize:
                                                                        11.0,
                                                                    letterSpacing:
                                                                        -0.22,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    lineHeight:
                                                                        2.18,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      width: 200.0,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    20.0,
                                                                    8.0,
                                                                    20.0,
                                                                    12.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          4.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    FFIcons
                                                                        .kuser2,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            1.0,
                                                                            0.0),
                                                                    child: Text(
                                                                      '0',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                'Dela Gothic One',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).tertiary,
                                                                            fontSize:
                                                                                32.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            lineHeight:
                                                                                1.5,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              'Persönliche €nergy',
                                                              textAlign:
                                                                  TextAlign.end,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    fontSize:
                                                                        11.0,
                                                                    letterSpacing:
                                                                        -0.22,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    lineHeight:
                                                                        2.18,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(width: 20.0)),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      12.0, 0.0, 12.0, 0.0),
                                              child: Column(
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
                                                                  12.0,
                                                                  0.0,
                                                                  12.0,
                                                                  0.0),
                                                      child: Text(
                                                        'Letzte Wirkung',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .titleSmall
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                              fontSize: 20.0,
                                                              letterSpacing:
                                                                  -0.8,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              lineHeight: 1.4,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallIsCustom,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0.0,
                                                                0.0,
                                                                0.0,
                                                                valueOrDefault<
                                                                    double>(
                                                                  MediaQuery.paddingOf(
                                                                              context)
                                                                          .bottom +
                                                                      48,
                                                                  48.0,
                                                                )),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16.0),
                                                      child: Image.asset(
                                                        'assets/images/energyEmpty.png',
                                                        width: double.infinity,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  ),
                                                ]
                                                    .divide(
                                                        SizedBox(height: 12.0))
                                                    .addToStart(
                                                        SizedBox(height: 12.0)),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 20.0)),
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 20.0)),
                                  ),
                                );
                              }
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
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.navbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: NavbarWidget(
                      pageNumber: 5,
                    ),
                  ),
                ),
                wrapWithModel(
                  model: _model.apbarBGModel,
                  updateCallback: () => safeSetState(() {}),
                  updateOnChange: true,
                  child: ApbarBGWidget(
                    title: 'Good €nergy',
                    text: 'Deine Spielenergie wird zur echten Hilfe!',
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
