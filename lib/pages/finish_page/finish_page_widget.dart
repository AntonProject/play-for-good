import '/backend/supabase/supabase.dart';
import '/components/dialogs/berechnung_dialog/berechnung_dialog_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'finish_page_model.dart';
export 'finish_page_model.dart';

class FinishPageWidget extends StatefulWidget {
  const FinishPageWidget({
    super.key,
    required this.gameId,
  });

  /// Handle deeplink
  final String? gameId;

  static String routeName = 'FinishPage';
  static String routePath = '/finishPage';

  @override
  State<FinishPageWidget> createState() => _FinishPageWidgetState();
}

class _FinishPageWidgetState extends State<FinishPageWidget> {
  late FinishPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FinishPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      setDarkModeSetting(context, ThemeMode.light);
      await actions.setStatusBarColor(
        true,
      );
      unawaited(
        () async {
          await action_blocks.refresh(context);
          safeSetState(() {});
        }(),
      );
      _model.queryGame = await GamesTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id',
          widget!.gameId,
        ),
      );
      _model.game = _model.queryGame?.firstOrNull;
      safeSetState(() {});
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
    return StreamBuilder<List<TransactionsRow>>(
      stream: _model.finishPageSupabaseStream ??= SupaFlow.client
          .from("transactions")
          .stream(primaryKey: ['id'])
          .eqOrNull(
            'game_id',
            widget!.gameId,
          )
          .map((list) => list.map((item) => TransactionsRow(item)).toList()),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 40.0,
                height: 40.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.transparent,
                  ),
                ),
              ),
            ),
          );
        }
        List<TransactionsRow> finishPageTransactionsRowList = snapshot.data!;

        final finishPageTransactionsRow =
            finishPageTransactionsRowList.isNotEmpty
                ? finishPageTransactionsRowList.first
                : null;

        return Title(
            title: 'FinishPage',
            color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Scaffold(
                key: scaffoldKey,
                backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
                body: Builder(
                  builder: (context) {
                    if (finishPageTransactionsRow?.status == 'completed') {
                      return Stack(
                        children: [
                          SingleChildScrollView(
                            controller: _model.columnController,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Stack(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Container(
                                            constraints: BoxConstraints(
                                              minHeight: 400.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: Image.asset(
                                                  Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? 'assets/images/Good_Games_-_My_games.png'
                                                      : 'assets/images/Good_Games_-_My_games.png',
                                                ).image,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text(
                                                  'BIG GAME!',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        fontFamily:
                                                            'Dela Gothic One',
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        fontSize: 40.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: 600.0,
                                                  ),
                                                  decoration: BoxDecoration(),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                16.0,
                                                                24.0,
                                                                16.0,
                                                                30.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                valueOrDefault<
                                                                    String>(
                                                                  functions.numFormat(
                                                                      valueOrDefault<
                                                                          String>(
                                                                    ((_model.game!.userMoney!) +
                                                                            (_model.game!.teamMoney!) +
                                                                            (_model.game!.siegMoney!))
                                                                        .toString(),
                                                                    '0',
                                                                  )),
                                                                  '0',
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'DM Sans',
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      fontSize:
                                                                          32.0,
                                                                      letterSpacing:
                                                                          -1.12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      lineHeight:
                                                                          1.5,
                                                                    ),
                                                              ),
                                                              AutoSizeText(
                                                                'Deine €',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 1,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      fontSize:
                                                                          11.0,
                                                                      letterSpacing:
                                                                          -0.22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      lineHeight:
                                                                          1.5,
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
                                                          child:
                                                              VerticalDivider(
                                                            thickness: 1.0,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                valueOrDefault<
                                                                    String>(
                                                                  functions.numFormat(
                                                                      valueOrDefault<
                                                                          String>(
                                                                    _model.game
                                                                        ?.additionalDonationMoney
                                                                        ?.toString(),
                                                                    '0',
                                                                  )),
                                                                  '0',
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'DM Sans',
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      fontSize:
                                                                          32.0,
                                                                      letterSpacing:
                                                                          -1.12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      lineHeight:
                                                                          1.5,
                                                                    ),
                                                              ),
                                                              AutoSizeText(
                                                                'P4G €',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 1,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      fontSize:
                                                                          11.0,
                                                                      letterSpacing:
                                                                          -0.22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      lineHeight:
                                                                          1.5,
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
                                                          child:
                                                              VerticalDivider(
                                                            thickness: 1.0,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                valueOrDefault<
                                                                    String>(
                                                                  functions.numFormat(
                                                                      valueOrDefault<
                                                                          String>(
                                                                    _model.game
                                                                        ?.sponsorMoney
                                                                        ?.toString(),
                                                                    '0',
                                                                  )),
                                                                  '0',
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'DM Sans',
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      fontSize:
                                                                          32.0,
                                                                      letterSpacing:
                                                                          -1.12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      lineHeight:
                                                                          1.5,
                                                                    ),
                                                              ),
                                                              AutoSizeText(
                                                                'Sponsoren €',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 1,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      fontSize:
                                                                          11.0,
                                                                      letterSpacing:
                                                                          -0.22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      lineHeight:
                                                                          1.5,
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
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.asset(
                                                    'assets/images/tgiwy_.png',
                                                    width: 150.0,
                                                    height: 120.0,
                                                    fit: BoxFit.fitHeight,
                                                  ),
                                                ),
                                              ].addToStart(
                                                  SizedBox(height: 120.0)),
                                            ),
                                          ),
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          elevation: 0.0,
                                          child: Container(
                                            width: double.infinity,
                                            constraints: BoxConstraints(
                                              maxWidth: 600.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text(
                                                  'Dein Game erzeugte',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmallFamily,
                                                        fontSize: 24.0,
                                                        letterSpacing: -0.96,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        lineHeight: 1.4,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .titleSmallIsCustom,
                                                      ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 12.0, 0.0, 0.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 40.0,
                                                        height: 40.0,
                                                        decoration:
                                                            BoxDecoration(),
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Text(
                                                            valueOrDefault<
                                                                String>(
                                                              functions.formatCompactWithComma(
                                                                  valueOrDefault<
                                                                      double>(
                                                                _model.game
                                                                    ?.lichtwatt,
                                                                0.0,
                                                              )),
                                                              '0',
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Dela Gothic One',
                                                                  fontSize:
                                                                      40.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                          Text(
                                                            'Lichtwatt',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText75,
                                                                  fontSize:
                                                                      14.0,
                                                                  letterSpacing:
                                                                      -0.35,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  lineHeight:
                                                                      1.5,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmallIsCustom,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      FlutterFlowIconButton(
                                                        borderColor:
                                                            Colors.transparent,
                                                        borderRadius: 99.0,
                                                        buttonSize: 40.0,
                                                        fillColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryBackground,
                                                        icon: Icon(
                                                          FFIcons.kinfoCircle,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          size: 26.0,
                                                        ),
                                                        onPressed: () async {
                                                          showModalBottomSheet(
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            useSafeArea: true,
                                                            context: context,
                                                            builder: (context) {
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  FocusScope.of(
                                                                          context)
                                                                      .unfocus();
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();
                                                                },
                                                                child: Padding(
                                                                  padding: MediaQuery
                                                                      .viewInsetsOf(
                                                                          context),
                                                                  child:
                                                                      BerechnungDialogWidget(
                                                                    game: _model
                                                                        .game!,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ).then((value) =>
                                                              safeSetState(
                                                                  () {}));
                                                        },
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 16.0)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(14.0, 14.0,
                                                          14.0, 0.0),
                                                  child: Text(
                                                    'an Good Power für andere Menschen! ❤️⚡🙌️',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
                                                          fontSize: 24.0,
                                                          letterSpacing: -0.96,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          lineHeight: 1.4,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 1.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                36.0,
                                                                44.0,
                                                                36.0,
                                                                16.0),
                                                    child: FFButtonWidget(
                                                      onPressed: () async {
                                                        unawaited(
                                                          () async {
                                                            await action_blocks
                                                                .refresh(
                                                                    context);
                                                            safeSetState(() {});
                                                          }(),
                                                        );
                                                        FFAppState().terms =
                                                            false;
                                                        FFAppState()
                                                                .refreshDate =
                                                            getCurrentTimestamp;
                                                        safeSetState(() {});

                                                        context.goNamed(
                                                          HomePageWidget
                                                              .routeName,
                                                          extra: <String,
                                                              dynamic>{
                                                            '__transition_info__':
                                                                TransitionInfo(
                                                              hasTransition:
                                                                  true,
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
                                                      text: 'Zu Home',
                                                      options: FFButtonOptions(
                                                        width: double.infinity,
                                                        height: 56.0,
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    16.0,
                                                                    0.0,
                                                                    16.0,
                                                                    0.0),
                                                        iconPadding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      -0.4,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  lineHeight:
                                                                      1.5,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmallIsCustom,
                                                                ),
                                                        elevation: 0.0,
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(64.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 1.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(36.0, 0.0,
                                                                36.0, 34.0),
                                                    child: FFButtonWidget(
                                                      onPressed: () async {
                                                        context.goNamed(
                                                          GoodNewsPageWidget
                                                              .routeName,
                                                          extra: <String,
                                                              dynamic>{
                                                            '__transition_info__':
                                                                TransitionInfo(
                                                              hasTransition:
                                                                  true,
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
                                                      text:
                                                          'Post im Good Feed ansehen',
                                                      options: FFButtonOptions(
                                                        width: double.infinity,
                                                        height: 56.0,
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    16.0,
                                                                    0.0,
                                                                    16.0,
                                                                    0.0),
                                                        iconPadding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      -0.4,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  lineHeight:
                                                                      1.5,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmallIsCustom,
                                                                ),
                                                        elevation: 0.0,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(64.0),
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
                              ].addToEnd(SizedBox(height: 24.0)),
                            ),
                          ),
                          Container(
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
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 60.0, 16.0, 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 56.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(99.0),
                                    ),
                                  ),
                                  Container(
                                    width: 56.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(99.0),
                                    ),
                                    child: FlutterFlowIconButton(
                                      borderColor: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: 99.0,
                                      borderWidth: 1.0,
                                      buttonSize: 40.0,
                                      icon: Icon(
                                        FFIcons.kxmark,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        size: 24.0,
                                      ),
                                      onPressed: () async {
                                        unawaited(
                                          () async {
                                            await action_blocks
                                                .refresh(context);
                                            safeSetState(() {});
                                          }(),
                                        );
                                        FFAppState().terms = false;
                                        FFAppState().refreshDate =
                                            getCurrentTimestamp;
                                        safeSetState(() {});

                                        context.goNamed(
                                          HomePageWidget.routeName,
                                          extra: <String, dynamic>{
                                            '__transition_info__':
                                                TransitionInfo(
                                              hasTransition: true,
                                              transitionType:
                                                  PageTransitionType.fade,
                                              duration:
                                                  Duration(milliseconds: 0),
                                            ),
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).info,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 48.0, 24.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(-1.0, -1.0),
                                child: Container(
                                  width: 56.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(99.0),
                                  ),
                                  child: FlutterFlowIconButton(
                                    borderColor: Colors.black,
                                    borderRadius: 99.0,
                                    borderWidth: 1.0,
                                    buttonSize: 40.0,
                                    icon: Icon(
                                      FFIcons.karrowLeftLong,
                                      color: Colors.black,
                                      size: 24.0,
                                    ),
                                    onPressed: () async {
                                      if (finishPageTransactionsRow?.status ==
                                          'completed') {
                                        context.goNamed(
                                          HomePageWidget.routeName,
                                          extra: <String, dynamic>{
                                            '__transition_info__':
                                                TransitionInfo(
                                              hasTransition: true,
                                              transitionType:
                                                  PageTransitionType.fade,
                                              duration:
                                                  Duration(milliseconds: 0),
                                            ),
                                          },
                                        );
                                      } else {
                                        context.safePop();
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: 600.0,
                                  ),
                                  decoration: BoxDecoration(),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 3.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          'LÄDT...',
                                          style: FlutterFlowTheme.of(context)
                                              .headlineSmall
                                              .override(
                                                fontFamily: 'Dela Gothic One',
                                                color: Colors.black,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                lineHeight: 1.5,
                                              ),
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(0.0),
                                          child: Image.asset(
                                            'assets/images/e0c90a4acaf78fe0397672e427d12fc71d220f2e.gif',
                                            width: 300.0,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ].addToEnd(SizedBox(height: 100.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(height: 48.0)),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ));
      },
    );
  }
}
