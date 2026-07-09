import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/dialogs/home_info_dialog/home_info_dialog_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_page_score_model.dart';
export 'home_page_score_model.dart';

class HomePageScoreWidget extends StatefulWidget {
  const HomePageScoreWidget({
    super.key,
    this.games,
    this.invites,
  });

  final List<GamesRow>? games;
  final List<InvitesRow>? invites;

  @override
  State<HomePageScoreWidget> createState() => _HomePageScoreWidgetState();
}

class _HomePageScoreWidgetState extends State<HomePageScoreWidget> {
  late HomePageScoreModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageScoreModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      constraints: BoxConstraints(
        minHeight: 485.0,
        maxWidth: 600.0,
        maxHeight: 500.0,
      ),
      decoration: BoxDecoration(),
      child: Padding(
        padding: EdgeInsets.all(14.0),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: 434.0,
            maxHeight: 450.0,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: Image.asset(
                'assets/images/Good_Score_Card2.png',
              ).image,
            ),
            borderRadius: BorderRadius.circular(28.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(28.0, 20.0, 28.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      FFIcons.klogoMini2,
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      size: 40.0,
                    ),
                    Text(
                      'Good Power',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).titleMediumFamily,
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            fontSize: 18.0,
                            letterSpacing: -0.63,
                            lineHeight: 1.5,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleMediumIsCustom,
                          ),
                    ),
                    FlutterFlowIconButton(
                      borderRadius: 8.0,
                      buttonSize: 40.0,
                      icon: Icon(
                        FFIcons.kinfoCircle,
                        color: FlutterFlowTheme.of(context).info,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          useSafeArea: true,
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: MediaQuery.viewInsetsOf(context),
                              child: HomeInfoDialogWidget(),
                            );
                          },
                        ).then((value) => safeSetState(() {}));
                      },
                    ),
                  ].divide(SizedBox(width: 8.0)),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, -1.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                  child: FlutterFlowDropDown<String>(
                    controller: _model.dropDownValueController ??=
                        FormFieldController<String>(
                      _model.dropDownValue ??= () {
                        if (_model.periodState == Period.woche.name) {
                          return 'Diese Woche';
                        } else if (_model.periodState == Period.gesamt.name) {
                          return 'Gesamt';
                        } else {
                          return 'Diesen Monat';
                        }
                      }(),
                    ),
                    options: ['Diesen Monat', 'Diese Woche', 'Gesamt'],
                    onChanged: (val) async {
                      safeSetState(() => _model.dropDownValue = val);
                      if (_model.dropDownValue == 'Diese Woche') {
                        _model.periodState = Period.woche.name;
                        safeSetState(() {});
                      } else if (_model.dropDownValue == 'Gesamt') {
                        _model.periodState = Period.gesamt.name;
                        safeSetState(() {});
                      } else {
                        _model.periodState = Period.monat.name;
                        safeSetState(() {});
                      }
                    },
                    width: 122.0,
                    height: 32.0,
                    textStyle: FlutterFlowTheme.of(context)
                        .titleMedium
                        .override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleMediumFamily,
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          fontSize: 12.0,
                          letterSpacing: valueOrDefault<double>(
                            -0.275,
                            -0.275,
                          ),
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.5,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleMediumIsCustom,
                        ),
                    hintText: 'Diesen Monat',
                    icon: Icon(
                      FFIcons.karrowSeparateVertical,
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      size: 20.0,
                    ),
                    fillColor: Colors.black,
                    elevation: 2.0,
                    borderColor: FlutterFlowTheme.of(context).primaryBackground,
                    borderWidth: 1.0,
                    borderRadius: 360.0,
                    margin:
                        EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                    hidesUnderline: true,
                    isOverButton: false,
                    isSearchable: false,
                    isMultiSelect: false,
                  ),
                ),
              ),
              FutureBuilder<List<UsersRow>>(
                future: UsersTable().queryRows(
                  queryFn: (q) => q,
                ),
                builder: (context, snapshot) {
                  // Customize what your widget looks like when it's loading.
                  if (!snapshot.hasData) {
                    return Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  }
                  List<UsersRow> containerUsersRowList = snapshot.data!;

                  return Container(
                    constraints: BoxConstraints(
                      minHeight: 270.0,
                      maxHeight: 270.0,
                    ),
                    decoration: BoxDecoration(),
                    child: Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        child: Stack(
                          alignment: AlignmentDirectional(0.0, 1.0),
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 0.0, 24.0, 0.0),
                              child: Container(
                                width: 320.0,
                                height: MediaQuery.sizeOf(context).height * 3.2,
                                child: custom_widgets.DoubleArcGaugeWidget(
                                  width: 320.0,
                                  height:
                                      MediaQuery.sizeOf(context).height * 3.2,
                                  lowerMax: valueOrDefault<double>(
                                    functions.totalSumMAX(
                                        widget!.games
                                            ?.where(
                                                (e) => e.status == 'completed')
                                            .toList()
                                            ?.toList(),
                                        _model.periodState,
                                        null,
                                        widget!.invites?.toList(),
                                        containerUsersRowList.length),
                                    0.0,
                                  ),
                                  lowerValue: valueOrDefault<double>(
                                    functions.totalSumMAX(
                                        widget!.games
                                            ?.where(
                                                (e) => e.status == 'completed')
                                            .toList()
                                            ?.toList(),
                                        _model.periodState,
                                        valueOrDefault<String>(
                                          currentUserUid,
                                          'guest',
                                        ),
                                        widget!.invites?.toList(),
                                        containerUsersRowList.length),
                                    0.0,
                                  ),
                                  lowerActiveColor:
                                      FlutterFlowTheme.of(context).focus,
                                  lowerInactiveColor:
                                      FlutterFlowTheme.of(context).white30,
                                  lowerStrokeWidth: 18.0,
                                  upperMax: valueOrDefault<double>(
                                    functions.totalSumAVG(
                                        widget!.games
                                            ?.where(
                                                (e) => e.status == 'completed')
                                            .toList()
                                            ?.toList(),
                                        _model.periodState,
                                        null,
                                        widget!.invites?.toList(),
                                        containerUsersRowList.length),
                                    0.0,
                                  ),
                                  upperValue: valueOrDefault<double>(
                                    functions.totalSumAVG(
                                        widget!.games
                                            ?.where(
                                                (e) => e.status == 'completed')
                                            .toList()
                                            ?.toList(),
                                        _model.periodState,
                                        valueOrDefault<String>(
                                          currentUserUid,
                                          'guest',
                                        ),
                                        widget!.invites?.toList(),
                                        containerUsersRowList.length),
                                    0.0,
                                  ),
                                  upperActiveColor:
                                      FlutterFlowTheme.of(context).green,
                                  upperInactiveColor: Colors.transparent,
                                  arcGap: 4.0,
                                  labelTextSize: 12.0,
                                  labelTextColor: Colors.transparent,
                                  upperStrokeWidth: 5.0,
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, 1.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 30.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 150.0,
                                      decoration: BoxDecoration(),
                                      child: AutoSizeText(
                                        FFAppState().hasGuestGetLichtwatt &&
                                                !loggedIn
                                            ? '100'
                                            : valueOrDefault<String>(
                                                functions
                                                    .formatCompactWithComma(
                                                        valueOrDefault<double>(
                                                  functions.totalSumPeriodLichtwatt(
                                                      widget!.games
                                                          ?.where((e) =>
                                                              e.creatorUserId ==
                                                              currentUserUid)
                                                          .toList()
                                                          ?.toList(),
                                                      _model.periodState,
                                                      widget!.invites
                                                          ?.toList()),
                                                  0.0,
                                                )),
                                                '0',
                                              ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Dela Gothic One',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              fontSize: 36.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 8.0),
                                      child: Text(
                                        'Lichtwatt',
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              color: Color(0xBFFAFAF9),
                                              fontSize: 14.0,
                                              letterSpacing:
                                                  valueOrDefault<double>(
                                                -0.24,
                                                -0.24,
                                              ),
                                              fontWeight: FontWeight.w500,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      height: 32.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(99.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 0.0, 16.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              FFIcons.kaward,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              size: 17.0,
                                            ),
                                            Text(
                                              valueOrDefault<String>(
                                                '#${valueOrDefault<String>(
                                                  functions
                                                      .ratingUserLichtwatt(
                                                          widget!.games
                                                              ?.toList(),
                                                          currentUserUid,
                                                          _model.periodState,
                                                          RatingGamesFilter
                                                              .valuable.name,
                                                          widget!.invites
                                                              ?.toList(),
                                                          containerUsersRowList
                                                              .length)
                                                      .toString(),
                                                  '0',
                                                )}',
                                                '#1',
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.bold,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 8.0)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 20.0, 0.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '0',
                                            style: FlutterFlowTheme.of(context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary75,
                                                  fontSize: 10.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  lineHeight: 1.5,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallIsCustom,
                                                ),
                                          ),
                                          Text(
                                            valueOrDefault<String>(
                                              functions.formatCompactWithComma(
                                                  valueOrDefault<double>(
                                                functions.totalSumMAX(
                                                    widget!.games?.toList(),
                                                    _model.periodState,
                                                    null,
                                                    widget!.invites?.toList(),
                                                    containerUsersRowList
                                                        .length),
                                                0.0,
                                              )),
                                              '0',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary75,
                                                  fontSize: 10.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  lineHeight: 1.5,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 50.0)),
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
                  );
                },
              ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              valueOrDefault<String>(
                                widget!.invites?.length?.toString(),
                                '0',
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleMediumFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    fontSize: 22.0,
                                    letterSpacing: valueOrDefault<double>(
                                      -0.63,
                                      -0.63,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    lineHeight: 1.5,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .titleMediumIsCustom,
                                  ),
                            ),
                            AutoSizeText(
                              'Good Circle',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    color:
                                        FlutterFlowTheme.of(context).primary50,
                                    fontSize: 13.0,
                                    letterSpacing: valueOrDefault<double>(
                                      -0.22,
                                      -0.22,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1.5,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 44.0,
                        child: VerticalDivider(
                          thickness: 1.0,
                          color: FlutterFlowTheme.of(context).primaryBackground,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              valueOrDefault<String>(
                                widget!.games
                                    ?.where((e) =>
                                        e.creatorUserId == currentUserUid)
                                    .toList()
                                    ?.length
                                    ?.toString(),
                                '0',
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleMediumFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    fontSize: 22.0,
                                    letterSpacing: valueOrDefault<double>(
                                      -0.63,
                                      -0.63,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    lineHeight: 1.5,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .titleMediumIsCustom,
                                  ),
                            ),
                            AutoSizeText(
                              'Good Games',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    color:
                                        FlutterFlowTheme.of(context).primary50,
                                    fontSize: 13.0,
                                    letterSpacing: valueOrDefault<double>(
                                      -0.22,
                                      -0.22,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1.5,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ],
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
    );
  }
}
