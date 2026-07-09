import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/dialogs/cancel_game_dialog/cancel_game_dialog_widget.dart';
import '/components/dialogs/game_title_edit/game_title_edit_widget.dart';
import '/components/dialogs/organisation_list_play/organisation_list_play_widget.dart';
import '/components/dialogs/types_points/types_points_widget.dart';
import '/components/dialogs/types_points_single/types_points_single_widget.dart';
import '/components/image/image_widget.dart';
import '/components/pfg_org_sum/pfg_org_sum_widget.dart';
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
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'play_page_model.dart';
export 'play_page_model.dart';

class PlayPageWidget extends StatefulWidget {
  const PlayPageWidget({
    super.key,
    this.gameDT,
  });

  final GameStruct? gameDT;

  static String routeName = 'PlayPage';
  static String routePath = '/playPage';

  @override
  State<PlayPageWidget> createState() => _PlayPageWidgetState();
}

class _PlayPageWidgetState extends State<PlayPageWidget> {
  late PlayPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PlayPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        Future(() async {
          await actions.setStatusBarColor(
            false,
          );
        }),
        Future(() async {
          if (widget!.gameDT != null) {
            _model.game = widget!.gameDT;
            safeSetState(() {});
            safeSetState(() {
              _model.userPointsTextController1?.text =
                  functions.numFormat(widget!.gameDT!.userPoints.toString())!;
            });
            if (widget!.gameDT!.teamPoints > 0.0) {
              safeSetState(() {
                _model.teamPointsTextController1?.text =
                    functions.numFormat(widget!.gameDT!.teamPoints.toString())!;
              });
              _model.addToChosenPoints(PointsType.team.name);
              safeSetState(() {});
            }
            if (widget!.gameDT!.siegPoints > 0.0) {
              _model.addToChosenPoints(PointsType.sieg.name);
              safeSetState(() {});
            }
          } else {
            _model.game = GameStruct(
              userPoints: 0.0,
              teamPoints: 0.0,
              siegPoints: 0.0,
              userMoney: 0.0,
              teamMoney: 0.0,
              siegMoney: 0.0,
              userMoneyRate: 1.0,
              teamMoneyRate: 1.0,
              siegMoneyRate: 1.0,
              sponsorMoney: 0.0,
              donatMoney: 0.0,
              sponsorPoints: 0.0,
              sponsorRate: 0.1,
            );
            safeSetState(() {});
          }
        }),
        Future(() async {
          if (loggedIn) {
            _model.gamesUserCount = await actions.gamesCount(
              currentUserUid,
            );
            _model.gamesCount = _model.gamesUserCount;
            safeSetState(() {});
            safeSetState(() {});
          }
        }),
      ]);
      unawaited(
        () async {
          await actions.closeKeyboard(
            context,
          );
        }(),
      );
    });

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.userPointsTextController1 ??= TextEditingController(
        text: valueOrDefault<String>(
      functions.numFormat(valueOrDefault<String>(
        _model.game?.userPoints?.toString(),
        '0',
      )),
      '0',
    ));
    _model.userPointsFocusNode1 ??= FocusNode();

    _model.teamPointsTextController1 ??= TextEditingController(
        text: valueOrDefault<String>(
      functions.numFormat(valueOrDefault<String>(
        _model.game?.teamPoints?.toString(),
        '0',
      )),
      '0',
    ));
    _model.teamPointsFocusNode1 ??= FocusNode();

    _model.userPointsTextController2 ??= TextEditingController(
        text: valueOrDefault<String>(
      functions.numFormat(valueOrDefault<String>(
        _model.game?.userPoints?.toString(),
        '0',
      )),
      '0',
    ));
    _model.userPointsFocusNode2 ??= FocusNode();

    _model.teamPointsTextController2 ??= TextEditingController(
        text: valueOrDefault<String>(
      functions.numFormat(valueOrDefault<String>(
        _model.game?.teamPoints?.toString(),
        '0',
      )),
      '0',
    ));
    _model.teamPointsFocusNode2 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
        title: 'PlayPage',
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
                if (loggedIn) {
                  return StreamBuilder<List<UsersRow>>(
                    stream: _model.stackSupabaseStream ??= SupaFlow.client
                        .from("users")
                        .stream(primaryKey: ['id'])
                        .eqOrNull(
                          'id',
                          currentUserUid,
                        )
                        .map((list) =>
                            list.map((item) => UsersRow(item)).toList()),
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
                      final stackUsersRow = stackUsersRowList.isNotEmpty
                          ? stackUsersRowList.first
                          : null;

                      return Stack(
                        children: [
                          SingleChildScrollView(
                            controller: _model.columnController1,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Stack(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          constraints: BoxConstraints(
                                            minHeight: 420.0,
                                          ),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: Image.asset(
                                                'assets/images/Wallet.png',
                                              ).image,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 96.0,
                                                height: 96.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    width: 4.0,
                                                  ),
                                                ),
                                                child: wrapWithModel(
                                                  model: _model.imageModel1,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: ImageWidget(
                                                    size: 96.0,
                                                    image:
                                                        valueOrDefault<String>(
                                                      stackUsersRow?.photoUrl,
                                                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/42sgzx6uejhj/Vector.png',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        16.0, 16.0, 16.0, 0.0),
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
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
                                                                GameTitleEditWidget(
                                                              game: GameStruct(
                                                                title:
                                                                    valueOrDefault<
                                                                        String>(
                                                                  _model.game?.title !=
                                                                              null &&
                                                                          _model.game?.title !=
                                                                              ''
                                                                      ? _model
                                                                          .game
                                                                          ?.title
                                                                      : 'Game #${((stackUsersRow!.gamesCount!) + 1).toString()}',
                                                                  'Game #1',
                                                                ),
                                                              ),
                                                              updateTitle:
                                                                  (title) async {
                                                                _model
                                                                    .updateGameStruct(
                                                                  (e) => e
                                                                    ..title =
                                                                        title,
                                                                );
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Text(
                                                    valueOrDefault<String>(
                                                      _model.game?.title !=
                                                                  null &&
                                                              _model.game
                                                                      ?.title !=
                                                                  ''
                                                          ? _model.game?.title
                                                          : 'Game #${((stackUsersRow!.gamesCount!) + 1).toString()}',
                                                      'Game #1',
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 3,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .labelLarge
                                                        .override(
                                                          fontFamily:
                                                              'Dela Gothic One',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          fontSize: 20.0,
                                                          letterSpacing:
                                                              valueOrDefault<
                                                                  double>(
                                                            -0.7,
                                                            -0.7,
                                                          ),
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          lineHeight: 1.5,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 24.0, 0.0, 0.0),
                                                child: Text(
                                                  'Deine Game €nergy',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            letterSpacing:
                                                                valueOrDefault<
                                                                    double>(
                                                              -0.35,
                                                              -0.35,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            lineHeight: 1.5,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                              RichText(
                                                textScaler:
                                                    MediaQuery.of(context)
                                                        .textScaler,
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: valueOrDefault<
                                                          String>(
                                                        functions.numFormat(
                                                            valueOrDefault<
                                                                String>(
                                                          ((_model.game!
                                                                          .userPoints *
                                                                      _model
                                                                          .game!
                                                                          .userMoneyRate) +
                                                                  (_model.game!
                                                                          .teamPoints *
                                                                      _model
                                                                          .game!
                                                                          .teamMoneyRate) +
                                                                  (_model.game!
                                                                          .siegPoints *
                                                                      _model
                                                                          .game!
                                                                          .siegMoneyRate))
                                                              .toString(),
                                                          '0',
                                                        )),
                                                        '0',
                                                      ),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Dela Gothic One',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                fontSize: 48.0,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                    ),
                                                    TextSpan(
                                                      text: ' €',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Dela Gothic One',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                fontSize: 24.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                    )
                                                  ],
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ]
                                                .addToStart(
                                                    SizedBox(height: 120.0))
                                                .addToEnd(
                                                    SizedBox(height: 32.0)),
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
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, 0.0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(24.0, 24.0,
                                                          24.0, 0.0),
                                                  child: Text(
                                                    'Trage deine Game Stats ein',
                                                    style: FlutterFlowTheme.of(
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
                                                              !FlutterFlowTheme
                                                                      .of(context)
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
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    12.0,
                                                                    0.0,
                                                                    12.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            if (valueOrDefault<
                                                                bool>(
                                                              _model
                                                                  .chosenPoints
                                                                  .contains(
                                                                      PointsType
                                                                          .user
                                                                          .name),
                                                              false,
                                                            ))
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        0.0,
                                                                        12.0,
                                                                        0.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          16.0,
                                                                          16.0,
                                                                          16.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children:
                                                                            [
                                                                          Container(
                                                                            width:
                                                                                40.0,
                                                                            height:
                                                                                40.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                              shape: BoxShape.circle,
                                                                              border: Border.all(
                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                wrapWithModel(
                                                                              model: _model.imageModel2,
                                                                              updateCallback: () => safeSetState(() {}),
                                                                              child: ImageWidget(
                                                                                size: 40.0,
                                                                                image: valueOrDefault<String>(
                                                                                  stackUsersRow?.photoUrl,
                                                                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  'Eigene Punkte',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                                InkWell(
                                                                                  splashColor: Colors.transparent,
                                                                                  focusColor: Colors.transparent,
                                                                                  hoverColor: Colors.transparent,
                                                                                  highlightColor: Colors.transparent,
                                                                                  onTap: () async {
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
                                                                                            child: TypesPointsSingleWidget(
                                                                                              game: _model.game,
                                                                                              chosenType: PointsType.user.name,
                                                                                              userPhoto: valueOrDefault<String>(
                                                                                                stackUsersRow?.photoUrl,
                                                                                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                              ),
                                                                                              update: (gameDT) async {
                                                                                                _model.game = gameDT;
                                                                                                safeSetState(() {});
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ).then((value) => safeSetState(() {}));
                                                                                  },
                                                                                  child: Text(
                                                                                    '${valueOrDefault<String>(
                                                                                      functions.numFormat(valueOrDefault<String>(
                                                                                        _model.game?.userMoneyRate?.toString(),
                                                                                        '0',
                                                                                      )),
                                                                                      '0',
                                                                                    )} € je Punkt',
                                                                                    style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                          fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                          color: FlutterFlowTheme.of(context).primary,
                                                                                          fontSize: 14.0,
                                                                                          letterSpacing: valueOrDefault<double>(
                                                                                            -0.35,
                                                                                            -0.35,
                                                                                          ),
                                                                                          fontWeight: FontWeight.w500,
                                                                                          decoration: TextDecoration.underline,
                                                                                          lineHeight: 1.5,
                                                                                          useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                        ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          FlutterFlowIconButton(
                                                                            borderRadius:
                                                                                99.0,
                                                                            buttonSize:
                                                                                40.0,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).alternate,
                                                                            icon:
                                                                                Icon(
                                                                              FFIcons.ktrash,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              size: 18.0,
                                                                            ),
                                                                            onPressed:
                                                                                () async {
                                                                              _model.removeFromChosenPoints(PointsType.user.name);
                                                                              _model.updateGameStruct(
                                                                                (e) => e
                                                                                  ..userPoints = null
                                                                                  ..userMoney = null
                                                                                  ..userMoneyRate = null
                                                                                  ..sponsorMoney = null
                                                                                  ..sponsorPoints = null,
                                                                              );
                                                                              safeSetState(() {});
                                                                            },
                                                                          ),
                                                                        ].divide(SizedBox(width: 16.0)),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          8.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children:
                                                                            [
                                                                          Align(
                                                                            alignment:
                                                                                AlignmentDirectional(-1.0, 0.0),
                                                                            child:
                                                                                Container(
                                                                              width: 170.0,
                                                                              height: 42.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                borderRadius: BorderRadius.circular(99.0),
                                                                              ),
                                                                              child: Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Align(
                                                                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                    child: FlutterFlowIconButton(
                                                                                      borderRadius: 99.0,
                                                                                      buttonSize: 50.0,
                                                                                      disabledIconColor: FlutterFlowTheme.of(context).secondaryText50,
                                                                                      icon: Icon(
                                                                                        FFIcons.kminus,
                                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                                        size: 25.0,
                                                                                      ),
                                                                                      onPressed: (valueOrDefault<double>(
                                                                                                _model.game?.userPoints,
                                                                                                0.0,
                                                                                              ) <=
                                                                                              0.0)
                                                                                          ? null
                                                                                          : () async {
                                                                                              if (valueOrDefault<double>(
                                                                                                    _model.game?.userPoints,
                                                                                                    0.0,
                                                                                                  ) >
                                                                                                  0.0) {
                                                                                                _model.updateGameStruct(
                                                                                                  (e) => e..incrementUserPoints(-1.0),
                                                                                                );
                                                                                                safeSetState(() {});
                                                                                              } else {
                                                                                                _model.updateGameStruct(
                                                                                                  (e) => e..userPoints = 0.0,
                                                                                                );
                                                                                                safeSetState(() {});
                                                                                              }

                                                                                              safeSetState(() {
                                                                                                _model.userPointsTextController1?.text = functions.numFormat(_model.game!.userPoints.toString())!;
                                                                                              });
                                                                                            },
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: Container(
                                                                                      width: 200.0,
                                                                                      child: TextFormField(
                                                                                        controller: _model.userPointsTextController1,
                                                                                        focusNode: _model.userPointsFocusNode1,
                                                                                        onChanged: (_) => EasyDebounce.debounce(
                                                                                          '_model.userPointsTextController1',
                                                                                          Duration(milliseconds: 50),
                                                                                          () async {
                                                                                            _model.updateGameStruct(
                                                                                              (e) => e..userPoints = functions.numParse(_model.userPointsTextController1.text),
                                                                                            );
                                                                                            safeSetState(() {});
                                                                                          },
                                                                                        ),
                                                                                        onFieldSubmitted: (_) async {
                                                                                          unawaited(
                                                                                            () async {
                                                                                              await actions.closeKeyboard(
                                                                                                context,
                                                                                              );
                                                                                            }(),
                                                                                          );
                                                                                        },
                                                                                        autofocus: false,
                                                                                        textInputAction: TextInputAction.done,
                                                                                        obscureText: false,
                                                                                        decoration: InputDecoration(
                                                                                          isDense: true,
                                                                                          hintText: '0',
                                                                                          hintStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                                fontFamily: FlutterFlowTheme.of(context).labelLargeFamily,
                                                                                                letterSpacing: 0.0,
                                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).labelLargeIsCustom,
                                                                                              ),
                                                                                          enabledBorder: InputBorder.none,
                                                                                          focusedBorder: InputBorder.none,
                                                                                          errorBorder: InputBorder.none,
                                                                                          focusedErrorBorder: InputBorder.none,
                                                                                        ),
                                                                                        style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                              fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                              fontSize: 14.0,
                                                                                              letterSpacing: valueOrDefault<double>(
                                                                                                -0.35,
                                                                                                -0.35,
                                                                                              ),
                                                                                              fontWeight: FontWeight.w600,
                                                                                              lineHeight: 1.5,
                                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                            ),
                                                                                        textAlign: TextAlign.center,
                                                                                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                                                                        cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                                        enableInteractiveSelection: true,
                                                                                        validator: _model.userPointsTextController1Validator.asValidator(context),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  FlutterFlowIconButton(
                                                                                    borderRadius: 99.0,
                                                                                    buttonSize: 50.0,
                                                                                    icon: Icon(
                                                                                      FFIcons.kplus,
                                                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                                                      size: 25.0,
                                                                                    ),
                                                                                    onPressed: () async {
                                                                                      _model.updateGameStruct(
                                                                                        (e) => e..incrementUserPoints(1.0),
                                                                                      );
                                                                                      safeSetState(() {});
                                                                                      safeSetState(() {
                                                                                        _model.userPointsTextController1?.text = functions.numFormat(_model.game!.userPoints.toString())!;
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            '${valueOrDefault<String>(
                                                                              functions.numFormat(valueOrDefault<String>(
                                                                                (_model.game!.userPoints * _model.game!.userMoneyRate).toString(),
                                                                                '0',
                                                                              )),
                                                                              '0',
                                                                            )} €',
                                                                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                                  letterSpacing: valueOrDefault<double>(
                                                                                    -0.63,
                                                                                    -0.63,
                                                                                  ),
                                                                                  fontWeight: FontWeight.bold,
                                                                                  lineHeight: 1.5,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                                ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      height:
                                                                          32.0,
                                                                      thickness:
                                                                          1.0,
                                                                      indent:
                                                                          16.0,
                                                                      endIndent:
                                                                          16.0,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            if (valueOrDefault<
                                                                bool>(
                                                              _model
                                                                  .chosenPoints
                                                                  .contains(
                                                                      PointsType
                                                                          .team
                                                                          .name),
                                                              false,
                                                            ))
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        0.0,
                                                                        12.0,
                                                                        0.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          16.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children:
                                                                            [
                                                                          Container(
                                                                            width:
                                                                                40.0,
                                                                            height:
                                                                                40.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                              shape: BoxShape.circle,
                                                                            ),
                                                                            child:
                                                                                Icon(
                                                                              FFIcons.kgroup,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              size: 18.0,
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  'Team-Punkte',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                                InkWell(
                                                                                  splashColor: Colors.transparent,
                                                                                  focusColor: Colors.transparent,
                                                                                  hoverColor: Colors.transparent,
                                                                                  highlightColor: Colors.transparent,
                                                                                  onTap: () async {
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
                                                                                            child: TypesPointsSingleWidget(
                                                                                              game: _model.game,
                                                                                              chosenType: PointsType.team.name,
                                                                                              userPhoto: stackUsersRow?.photoUrl,
                                                                                              update: (gameDT) async {
                                                                                                _model.game = gameDT;
                                                                                                safeSetState(() {});
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ).then((value) => safeSetState(() {}));
                                                                                  },
                                                                                  child: Text(
                                                                                    '${valueOrDefault<String>(
                                                                                      functions.numFormat(valueOrDefault<String>(
                                                                                        _model.game?.teamMoneyRate?.toString(),
                                                                                        '0',
                                                                                      )),
                                                                                      '0',
                                                                                    )} € je Punkt',
                                                                                    style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                          fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                          color: FlutterFlowTheme.of(context).primary,
                                                                                          fontSize: 14.0,
                                                                                          letterSpacing: valueOrDefault<double>(
                                                                                            -0.35,
                                                                                            -0.35,
                                                                                          ),
                                                                                          fontWeight: FontWeight.w500,
                                                                                          decoration: TextDecoration.underline,
                                                                                          lineHeight: 1.5,
                                                                                          useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                        ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          FlutterFlowIconButton(
                                                                            borderRadius:
                                                                                99.0,
                                                                            buttonSize:
                                                                                40.0,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).alternate,
                                                                            icon:
                                                                                Icon(
                                                                              FFIcons.ktrash,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              size: 18.0,
                                                                            ),
                                                                            onPressed:
                                                                                () async {
                                                                              _model.removeFromChosenPoints(PointsType.team.name);
                                                                              _model.updateGameStruct(
                                                                                (e) => e
                                                                                  ..teamPoints = null
                                                                                  ..teamMoney = null
                                                                                  ..teamMoneyRate = null,
                                                                              );
                                                                              safeSetState(() {});
                                                                            },
                                                                          ),
                                                                        ].divide(SizedBox(width: 16.0)),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          8.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children:
                                                                            [
                                                                          Align(
                                                                            alignment:
                                                                                AlignmentDirectional(-1.0, 0.0),
                                                                            child:
                                                                                Container(
                                                                              width: 170.0,
                                                                              height: 42.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                borderRadius: BorderRadius.circular(99.0),
                                                                              ),
                                                                              child: Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Align(
                                                                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                    child: FlutterFlowIconButton(
                                                                                      borderRadius: 99.0,
                                                                                      buttonSize: 50.0,
                                                                                      disabledIconColor: FlutterFlowTheme.of(context).secondaryText50,
                                                                                      icon: Icon(
                                                                                        FFIcons.kminus,
                                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                                        size: 25.0,
                                                                                      ),
                                                                                      onPressed: (valueOrDefault<double>(
                                                                                                _model.game?.teamPoints,
                                                                                                0.0,
                                                                                              ) <=
                                                                                              0.0)
                                                                                          ? null
                                                                                          : () async {
                                                                                              if (valueOrDefault<double>(
                                                                                                    _model.game?.teamPoints,
                                                                                                    0.0,
                                                                                                  ) >
                                                                                                  0.0) {
                                                                                                _model.updateGameStruct(
                                                                                                  (e) => e..incrementTeamPoints(-1.0),
                                                                                                );
                                                                                                safeSetState(() {});
                                                                                              } else {
                                                                                                _model.updateGameStruct(
                                                                                                  (e) => e..teamPoints = 0.0,
                                                                                                );
                                                                                                safeSetState(() {});
                                                                                              }

                                                                                              safeSetState(() {
                                                                                                _model.teamPointsTextController1?.text = functions.numFormat(_model.game!.teamPoints.toString())!;
                                                                                              });
                                                                                            },
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: Container(
                                                                                      width: 200.0,
                                                                                      child: TextFormField(
                                                                                        controller: _model.teamPointsTextController1,
                                                                                        focusNode: _model.teamPointsFocusNode1,
                                                                                        onChanged: (_) => EasyDebounce.debounce(
                                                                                          '_model.teamPointsTextController1',
                                                                                          Duration(milliseconds: 50),
                                                                                          () async {
                                                                                            _model.updateGameStruct(
                                                                                              (e) => e..teamPoints = functions.numParse(_model.teamPointsTextController1.text),
                                                                                            );
                                                                                            safeSetState(() {});
                                                                                          },
                                                                                        ),
                                                                                        onFieldSubmitted: (_) async {
                                                                                          unawaited(
                                                                                            () async {
                                                                                              await actions.closeKeyboard(
                                                                                                context,
                                                                                              );
                                                                                            }(),
                                                                                          );
                                                                                        },
                                                                                        autofocus: false,
                                                                                        textInputAction: TextInputAction.done,
                                                                                        obscureText: false,
                                                                                        decoration: InputDecoration(
                                                                                          isDense: true,
                                                                                          hintText: '0',
                                                                                          hintStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                                fontFamily: FlutterFlowTheme.of(context).labelLargeFamily,
                                                                                                letterSpacing: 0.0,
                                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).labelLargeIsCustom,
                                                                                              ),
                                                                                          enabledBorder: InputBorder.none,
                                                                                          focusedBorder: InputBorder.none,
                                                                                          errorBorder: InputBorder.none,
                                                                                          focusedErrorBorder: InputBorder.none,
                                                                                        ),
                                                                                        style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                              fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                              fontSize: 14.0,
                                                                                              letterSpacing: valueOrDefault<double>(
                                                                                                -0.35,
                                                                                                -0.35,
                                                                                              ),
                                                                                              fontWeight: FontWeight.w600,
                                                                                              lineHeight: 1.5,
                                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                            ),
                                                                                        textAlign: TextAlign.center,
                                                                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                                                        cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                                        enableInteractiveSelection: true,
                                                                                        validator: _model.teamPointsTextController1Validator.asValidator(context),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  FlutterFlowIconButton(
                                                                                    borderRadius: 99.0,
                                                                                    buttonSize: 50.0,
                                                                                    icon: Icon(
                                                                                      FFIcons.kplus,
                                                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                                                      size: 25.0,
                                                                                    ),
                                                                                    onPressed: () async {
                                                                                      _model.updateGameStruct(
                                                                                        (e) => e..incrementTeamPoints(1.0),
                                                                                      );
                                                                                      safeSetState(() {});
                                                                                      safeSetState(() {
                                                                                        _model.teamPointsTextController1?.text = functions.numFormat(_model.game!.teamPoints.toString())!;
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            '${valueOrDefault<String>(
                                                                              functions.numFormat(valueOrDefault<String>(
                                                                                (_model.game!.teamPoints * _model.game!.teamMoneyRate).toString(),
                                                                                '0',
                                                                              )),
                                                                              '0',
                                                                            )} €',
                                                                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                                  letterSpacing: valueOrDefault<double>(
                                                                                    -0.63,
                                                                                    -0.63,
                                                                                  ),
                                                                                  fontWeight: FontWeight.bold,
                                                                                  lineHeight: 1.5,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                                ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      height:
                                                                          32.0,
                                                                      thickness:
                                                                          1.0,
                                                                      indent:
                                                                          16.0,
                                                                      endIndent:
                                                                          16.0,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            if (valueOrDefault<
                                                                bool>(
                                                              _model
                                                                  .chosenPoints
                                                                  .contains(
                                                                      PointsType
                                                                          .sieg
                                                                          .name),
                                                              false,
                                                            ))
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        0.0,
                                                                        12.0,
                                                                        0.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          16.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children:
                                                                            [
                                                                          Container(
                                                                            width:
                                                                                40.0,
                                                                            height:
                                                                                40.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                              shape: BoxShape.circle,
                                                                            ),
                                                                            child:
                                                                                Icon(
                                                                              FFIcons.ktrophy,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              size: 18.0,
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  'Sieg',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                                InkWell(
                                                                                  splashColor: Colors.transparent,
                                                                                  focusColor: Colors.transparent,
                                                                                  hoverColor: Colors.transparent,
                                                                                  highlightColor: Colors.transparent,
                                                                                  onTap: () async {
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
                                                                                            child: TypesPointsSingleWidget(
                                                                                              game: _model.game,
                                                                                              chosenType: PointsType.sieg.name,
                                                                                              userPhoto: stackUsersRow?.photoUrl,
                                                                                              update: (gameDT) async {
                                                                                                _model.game = gameDT;
                                                                                                safeSetState(() {});
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ).then((value) => safeSetState(() {}));
                                                                                  },
                                                                                  child: Text(
                                                                                    '${valueOrDefault<String>(
                                                                                      functions.numFormat(_model.game!.siegPoints.toString()),
                                                                                      '0',
                                                                                    )} € für Sieg',
                                                                                    style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                          fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                          color: FlutterFlowTheme.of(context).primary,
                                                                                          fontSize: 14.0,
                                                                                          letterSpacing: valueOrDefault<double>(
                                                                                            -0.35,
                                                                                            -0.35,
                                                                                          ),
                                                                                          fontWeight: FontWeight.w500,
                                                                                          decoration: TextDecoration.underline,
                                                                                          lineHeight: 1.5,
                                                                                          useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                        ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          FlutterFlowIconButton(
                                                                            borderRadius:
                                                                                99.0,
                                                                            buttonSize:
                                                                                40.0,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).alternate,
                                                                            icon:
                                                                                Icon(
                                                                              FFIcons.ktrash,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              size: 18.0,
                                                                            ),
                                                                            onPressed:
                                                                                () async {
                                                                              _model.removeFromChosenPoints(PointsType.sieg.name);
                                                                              _model.updateGameStruct(
                                                                                (e) => e
                                                                                  ..siegPoints = null
                                                                                  ..siegMoney = null
                                                                                  ..siegMoneyRate = null,
                                                                              );
                                                                              safeSetState(() {});
                                                                            },
                                                                          ),
                                                                        ].divide(SizedBox(width: 16.0)),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          8.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children:
                                                                            [
                                                                          Expanded(
                                                                            child:
                                                                                InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                if (_model.game!.siegMoneyRate > 0.0) {
                                                                                  _model.updateGameStruct(
                                                                                    (e) => e..siegMoneyRate = 0.0,
                                                                                  );
                                                                                  safeSetState(() {});
                                                                                } else {
                                                                                  _model.updateGameStruct(
                                                                                    (e) => e..siegMoneyRate = 1.0,
                                                                                  );
                                                                                  safeSetState(() {});
                                                                                }
                                                                              },
                                                                              child: Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: [
                                                                                  Builder(
                                                                                    builder: (context) {
                                                                                      if (_model.game!.siegMoneyRate > 0.0) {
                                                                                        return Container(
                                                                                          width: 18.0,
                                                                                          height: 18.0,
                                                                                          decoration: BoxDecoration(
                                                                                            color: FlutterFlowTheme.of(context).primaryText,
                                                                                            borderRadius: BorderRadius.circular(4.0),
                                                                                            border: Border.all(
                                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                                              width: 1.0,
                                                                                            ),
                                                                                          ),
                                                                                          child: Align(
                                                                                            alignment: AlignmentDirectional(0.0, 0.0),
                                                                                            child: Icon(
                                                                                              FFIcons.kcheck2,
                                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                              size: 12.0,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      } else {
                                                                                        return Container(
                                                                                          width: 18.0,
                                                                                          height: 18.0,
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.circular(4.0),
                                                                                            border: Border.all(
                                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                                              width: 1.0,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      'Gewonnen',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                            fontSize: 16.0,
                                                                                            letterSpacing: valueOrDefault<double>(
                                                                                              -0.4,
                                                                                              -0.4,
                                                                                            ),
                                                                                            lineHeight: 1.5,
                                                                                            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                          ),
                                                                                    ),
                                                                                  ),
                                                                                ].divide(SizedBox(width: 8.0)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            '${valueOrDefault<String>(
                                                                              functions.numFormat(valueOrDefault<String>(
                                                                                (_model.game!.siegPoints * _model.game!.siegMoneyRate).toString(),
                                                                                '0',
                                                                              )),
                                                                              '0',
                                                                            )} €',
                                                                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                                  letterSpacing: valueOrDefault<double>(
                                                                                    -0.63,
                                                                                    -0.63,
                                                                                  ),
                                                                                  fontWeight: FontWeight.bold,
                                                                                  lineHeight: 1.5,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                                ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      height:
                                                                          32.0,
                                                                      thickness:
                                                                          1.0,
                                                                      indent:
                                                                          16.0,
                                                                      endIndent:
                                                                          16.0,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            if (_model
                                                                    .chosenPoints
                                                                    .length <
                                                                3)
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        0.0,
                                                                        12.0,
                                                                        16.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          8.0,
                                                                          0.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children:
                                                                            [
                                                                          Icon(
                                                                            FFIcons.kevPlugCharging,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                            size:
                                                                                24.0,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              'Einsatz hinzufügen',
                                                                              style: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                          ),
                                                                          Container(
                                                                            width:
                                                                                56.0,
                                                                            height:
                                                                                40.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).secondary,
                                                                              borderRadius: BorderRadius.circular(99.0),
                                                                            ),
                                                                            child:
                                                                                FlutterFlowIconButton(
                                                                              borderColor: Colors.transparent,
                                                                              borderRadius: 99.0,
                                                                              buttonSize: 40.0,
                                                                              fillColor: FlutterFlowTheme.of(context).secondary,
                                                                              icon: Icon(
                                                                                FFIcons.kplus,
                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                size: 24.0,
                                                                              ),
                                                                              onPressed: () async {
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
                                                                                        child: TypesPointsWidget(
                                                                                          chosenTypes: _model.chosenPoints,
                                                                                          game: _model.game,
                                                                                          userPhoto: valueOrDefault<String>(
                                                                                            stackUsersRow?.photoUrl,
                                                                                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                          ),
                                                                                          update: (gameDT) async {
                                                                                            _model.updateGameStruct(
                                                                                              (e) => e
                                                                                                ..userMoneyRate = gameDT.userMoneyRate
                                                                                                ..teamMoneyRate = gameDT.teamMoneyRate
                                                                                                ..siegPoints = gameDT.siegPoints,
                                                                                            );
                                                                                            safeSetState(() {});
                                                                                          },
                                                                                          updateTypes: (type) async {
                                                                                            if (!_model.chosenPoints.contains(type)) {
                                                                                              _model.addToChosenPoints(type!);
                                                                                              safeSetState(() {});
                                                                                            }
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ).then((value) => safeSetState(() {}));
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 16.0)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (_model.gamesCount! < 5)
                                                Column(
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
                                                                    24.0,
                                                                    36.0,
                                                                    24.0,
                                                                    0.0),
                                                        child: Text(
                                                          'Deine Sponsoren',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
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
                                                                    FontWeight
                                                                        .w500,
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
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  12.0,
                                                                  8.0,
                                                                  12.0,
                                                                  0.0),
                                                      child: Container(
                                                        width: double.infinity,
                                                        constraints:
                                                            BoxConstraints(
                                                          minHeight: 106.0,
                                                        ),
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
                                                                      12.0,
                                                                      4.0,
                                                                      12.0,
                                                                      4.0),
                                                          child: wrapWithModel(
                                                            model: _model
                                                                .pfgOrgSumModel1,
                                                            updateCallback: () =>
                                                                safeSetState(
                                                                    () {}),
                                                            updateOnChange:
                                                                true,
                                                            child:
                                                                PfgOrgSumWidget(
                                                              text:
                                                                  '0,10 € je eigener Punkt\n5 Games, max. 2 €/Game ',
                                                              sum:
                                                                  valueOrDefault<
                                                                      double>(
                                                                (_model.game!.userPoints *
                                                                            0.1) >
                                                                        2.0
                                                                    ? 2.0
                                                                    : (_model
                                                                            .game!
                                                                            .userPoints *
                                                                        0.1),
                                                                0.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ].addToEnd(SizedBox(
                                          height: valueOrDefault<double>(
                                        (isWeb
                                                ? MediaQuery.viewInsetsOf(
                                                            context)
                                                        .bottom >
                                                    0
                                                : _isKeyboardVisible)
                                            ? 24.0
                                            : 250.0,
                                        250.0,
                                      ))),
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
                              ],
                            ),
                          ),
                          if (!(isWeb
                              ? MediaQuery.viewInsetsOf(context).bottom > 0
                              : _isKeyboardVisible))
                            Align(
                              alignment: AlignmentDirectional(0.0, 1.0),
                              child: Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  maxWidth: 800.0,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    topRight: Radius.circular(16.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12.0, 32.0, 12.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 44.0,
                                            height: 32.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              borderRadius:
                                                  BorderRadius.circular(99.0),
                                            ),
                                            child: Icon(
                                              FFIcons.kball,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 20.0,
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.2,
                                            height: 1.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                            ),
                                          ),
                                          Container(
                                            width: 44.0,
                                            height: 32.0,
                                            decoration: BoxDecoration(),
                                            child: Icon(
                                              FFIcons.kdonate,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 24.0,
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.2,
                                            height: 1.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                            ),
                                          ),
                                          Container(
                                            width: 44.0,
                                            height: 32.0,
                                            decoration: BoxDecoration(),
                                            child: Icon(
                                              FFIcons.kflash,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 22.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 0.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              'Game',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    fontSize: 12.0,
                                                    letterSpacing:
                                                        valueOrDefault<double>(
                                                      -0.24,
                                                      -0.24,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                    lineHeight: 1.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                            ),
                                            Text(
                                              'Organisation',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    fontSize: 12.0,
                                                    letterSpacing:
                                                        valueOrDefault<double>(
                                                      -0.24,
                                                      -0.24,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                    lineHeight: 1.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                            ),
                                            Text(
                                              'Zahlung',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    fontSize: 12.0,
                                                    letterSpacing:
                                                        valueOrDefault<double>(
                                                      -0.24,
                                                      -0.24,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                    lineHeight: 1.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 12.0, 0.0, 34.0),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            borderRadius:
                                                BorderRadius.circular(99.0),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          32.0, 0.0, 0.0, 0.0),
                                                  child: Text(
                                                    '${valueOrDefault<String>(
                                                      functions.numFormat(
                                                          valueOrDefault<
                                                              String>(
                                                        ((_model.game!
                                                                        .userPoints *
                                                                    _model.game!
                                                                        .userMoneyRate) +
                                                                (_model.game!
                                                                        .teamPoints *
                                                                    _model.game!
                                                                        .teamMoneyRate) +
                                                                (_model.game!
                                                                        .siegPoints *
                                                                    _model.game!
                                                                        .siegMoneyRate))
                                                            .toString(),
                                                        '0',
                                                      )),
                                                      '0',
                                                    )} €',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .headlineLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineLargeFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          letterSpacing:
                                                              valueOrDefault<
                                                                  double>(
                                                            -1.44,
                                                            -1.44,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          lineHeight: 1.2,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .headlineLargeIsCustom,
                                                        ),
                                                  ),
                                                ),
                                                FFButtonWidget(
                                                  onPressed: (((_model.game!
                                                                      .userPoints *
                                                                  _model.game!
                                                                      .userMoneyRate) +
                                                              (_model.game!
                                                                      .teamPoints *
                                                                  _model.game!
                                                                      .teamMoneyRate) +
                                                              (_model.game!
                                                                      .siegPoints *
                                                                  _model.game!
                                                                      .siegMoneyRate)) ==
                                                          0.0)
                                                      ? null
                                                      : () async {
                                                          _model
                                                              .updateGameStruct(
                                                            (e) => e
                                                              ..userMoney = _model
                                                                      .game!
                                                                      .userPoints *
                                                                  _model.game!
                                                                      .userMoneyRate
                                                              ..teamMoney = _model
                                                                      .game!
                                                                      .teamPoints *
                                                                  _model.game!
                                                                      .teamMoneyRate
                                                              ..siegMoney = _model
                                                                      .game!
                                                                      .siegPoints *
                                                                  _model.game!
                                                                      .siegMoneyRate
                                                              ..title =
                                                                  valueOrDefault<
                                                                      String>(
                                                                _model.game?.title !=
                                                                            null &&
                                                                        _model.game?.title !=
                                                                            ''
                                                                    ? _model
                                                                        .game
                                                                        ?.title
                                                                    : 'Game #${((stackUsersRow!.gamesCount!) + 1).toString()}',
                                                                'Game #1',
                                                              ),
                                                          );
                                                          safeSetState(() {});
                                                          _model
                                                              .updateGameStruct(
                                                            (e) => e
                                                              ..donatMoney =
                                                                  valueOrDefault<
                                                                      double>(
                                                                functions
                                                                    .donationCalculate(
                                                                        valueOrDefault<
                                                                            double>(
                                                                      valueOrDefault<
                                                                              double>(
                                                                            _model.game?.userMoney,
                                                                            0.0,
                                                                          ) +
                                                                          valueOrDefault<
                                                                              double>(
                                                                            _model.game?.teamMoney,
                                                                            0.0,
                                                                          ) +
                                                                          valueOrDefault<
                                                                              double>(
                                                                            _model.game?.siegMoney,
                                                                            0.0,
                                                                          ),
                                                                      0.0,
                                                                    ))
                                                                    .suggestDonat,
                                                                0.0,
                                                              )
                                                              ..sponsorMoney =
                                                                  valueOrDefault<
                                                                      double>(
                                                                () {
                                                                  if (_model
                                                                          .gamesCount! >=
                                                                      5) {
                                                                    return 0.0;
                                                                  } else if ((_model
                                                                              .game!
                                                                              .userPoints *
                                                                          0.1) >
                                                                      2.0) {
                                                                    return 2.0;
                                                                  } else {
                                                                    return (_model
                                                                            .game!
                                                                            .userPoints *
                                                                        0.1);
                                                                  }
                                                                }(),
                                                                0.0,
                                                              )
                                                              ..sponsorPoints = _model
                                                                          .gamesCount! <
                                                                      5
                                                                  ? (valueOrDefault<
                                                                          double>(
                                                                        (_model.game!.userPoints * 0.1) >
                                                                                2.0
                                                                            ? 2.0
                                                                            : (_model.game!.userPoints *
                                                                                0.1),
                                                                        0.0,
                                                                      ) /
                                                                      _model
                                                                          .game!
                                                                          .sponsorRate)
                                                                  : 0.0,
                                                          );
                                                          safeSetState(() {});
                                                          unawaited(
                                                            () async {
                                                              await actions
                                                                  .closeKeyboard(
                                                                context,
                                                              );
                                                            }(),
                                                          );
                                                          await showModalBottomSheet(
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            isDismissible:
                                                                false,
                                                            enableDrag: false,
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
                                                                      OrganisationListPlayWidget(
                                                                    userId:
                                                                        stackUsersRow,
                                                                    gameDT: _model
                                                                        .game!,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ).then((value) =>
                                                              safeSetState(
                                                                  () {}));
                                                        },
                                                  text: 'Weiter',
                                                  options: FFButtonOptions(
                                                    width: 98.0,
                                                    height: 40.0,
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                                16.0, 0.0),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
                                                          color: Colors.white,
                                                          letterSpacing:
                                                              valueOrDefault<
                                                                  double>(
                                                            -0.4,
                                                            -0.4,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          lineHeight: 1.5,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                                    elevation: 0.0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            99.0),
                                                    disabledColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary30,
                                                    disabledTextColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary50,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                                ),
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
                                  16.0, 60.0, 16.0, 12.0),
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
                                        if (valueOrDefault<double>(
                                              (_model.game!.userPoints *
                                                      _model.game!
                                                          .userMoneyRate) +
                                                  (_model.game!.teamPoints *
                                                      _model.game!
                                                          .teamMoneyRate) +
                                                  (_model.game!.siegPoints *
                                                      _model
                                                          .game!.siegMoneyRate),
                                              0.0,
                                            ) >
                                            0.0) {
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            useSafeArea: true,
                                            context: context,
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child:
                                                      CancelGameDialogWidget(),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        } else {
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
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(1.0, 1.0),
                            child: wrapWithModel(
                              model: _model.closeKeyboardModel1,
                              updateCallback: () => safeSetState(() {}),
                              updateOnChange: true,
                              child: CloseKeyboardWidget(),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        controller: _model.columnController2,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Stack(
                              alignment: AlignmentDirectional(0.0, -1.0),
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      constraints: BoxConstraints(
                                        minHeight: 420.0,
                                      ),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: Image.asset(
                                            'assets/images/Wallet.png',
                                          ).image,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 96.0,
                                            height: 96.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                width: 4.0,
                                              ),
                                            ),
                                            child: wrapWithModel(
                                              model: _model.imageModel3,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: ImageWidget(
                                                size: 96.0,
                                                image:
                                                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/42sgzx6uejhj/Vector.png',
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 16.0, 16.0, 0.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  useSafeArea: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child:
                                                            GameTitleEditWidget(
                                                          game: GameStruct(
                                                            title:
                                                                valueOrDefault<
                                                                    String>(
                                                              _model.game?.title !=
                                                                          null &&
                                                                      _model.game
                                                                              ?.title !=
                                                                          ''
                                                                  ? _model.game
                                                                      ?.title
                                                                  : 'Game #1',
                                                              'Game #1',
                                                            ),
                                                          ),
                                                          updateTitle:
                                                              (title) async {
                                                            _model
                                                                .updateGameStruct(
                                                              (e) => e
                                                                ..title = title,
                                                            );
                                                            safeSetState(() {});
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Text(
                                                valueOrDefault<String>(
                                                  _model.game?.title != null &&
                                                          _model.game?.title !=
                                                              ''
                                                      ? _model.game?.title
                                                      : 'Game #1',
                                                  'Game #1',
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 3,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .override(
                                                          fontFamily:
                                                              'Dela Gothic One',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          fontSize: 20.0,
                                                          letterSpacing:
                                                              valueOrDefault<
                                                                  double>(
                                                            -0.7,
                                                            -0.7,
                                                          ),
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          lineHeight: 1.5,
                                                        ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 24.0, 0.0, 0.0),
                                            child: Text(
                                              'Deine Game €nergy',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing:
                                                        valueOrDefault<double>(
                                                      -0.35,
                                                      -0.35,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                    lineHeight: 1.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumIsCustom,
                                                  ),
                                            ),
                                          ),
                                          RichText(
                                            textScaler: MediaQuery.of(context)
                                                .textScaler,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: valueOrDefault<String>(
                                                    functions.numFormat(
                                                        valueOrDefault<String>(
                                                      ((_model.game!
                                                                      .userPoints *
                                                                  _model.game!
                                                                      .userMoneyRate) +
                                                              (_model.game!
                                                                      .teamPoints *
                                                                  _model.game!
                                                                      .teamMoneyRate) +
                                                              (_model.game!
                                                                      .siegPoints *
                                                                  _model.game!
                                                                      .siegMoneyRate))
                                                          .toString(),
                                                      '0',
                                                    )),
                                                    '0',
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Dela Gothic One',
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        fontSize: 48.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                                TextSpan(
                                                  text: ' €',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Dela Gothic One',
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        fontSize: 24.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                )
                                              ],
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMediumIsCustom,
                                                      ),
                                            ),
                                          ),
                                        ]
                                            .addToStart(SizedBox(height: 120.0))
                                            .addToEnd(SizedBox(height: 32.0)),
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
                                          Align(
                                            alignment:
                                                AlignmentDirectional(-1.0, 0.0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      24.0, 24.0, 24.0, 0.0),
                                              child: Text(
                                                'Trage deine Game Stats ein',
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
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    12.0, 8.0, 12.0, 0.0),
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 12.0,
                                                                0.0, 12.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        if (valueOrDefault<
                                                            bool>(
                                                          _model.chosenPoints
                                                              .contains(
                                                                  PointsType
                                                                      .user
                                                                      .name),
                                                          false,
                                                        ))
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        0.0,
                                                                        12.0,
                                                                        0.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          16.0,
                                                                          16.0,
                                                                          16.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            40.0,
                                                                        height:
                                                                            40.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryBackground,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryBackground,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            wrapWithModel(
                                                                          model:
                                                                              _model.imageModel4,
                                                                          updateCallback: () =>
                                                                              safeSetState(() {}),
                                                                          child:
                                                                              ImageWidget(
                                                                            size:
                                                                                40.0,
                                                                            image:
                                                                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'Eigene Punkte',
                                                                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                    fontSize: 18.0,
                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                      -0.4,
                                                                                      -0.4,
                                                                                    ),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                  ),
                                                                            ),
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
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
                                                                                        child: TypesPointsSingleWidget(
                                                                                          game: _model.game,
                                                                                          chosenType: PointsType.user.name,
                                                                                          userPhoto: 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                          update: (gameDT) async {
                                                                                            _model.game = gameDT;
                                                                                            safeSetState(() {});
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ).then((value) => safeSetState(() {}));
                                                                              },
                                                                              child: Text(
                                                                                '${valueOrDefault<String>(
                                                                                  functions.numFormat(valueOrDefault<String>(
                                                                                    _model.game?.userMoneyRate?.toString(),
                                                                                    '0',
                                                                                  )),
                                                                                  '0',
                                                                                )} € je Punkt',
                                                                                style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                      color: FlutterFlowTheme.of(context).primary,
                                                                                      fontSize: 14.0,
                                                                                      letterSpacing: valueOrDefault<double>(
                                                                                        -0.35,
                                                                                        -0.35,
                                                                                      ),
                                                                                      fontWeight: FontWeight.w500,
                                                                                      decoration: TextDecoration.underline,
                                                                                      lineHeight: 1.5,
                                                                                      useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      FlutterFlowIconButton(
                                                                        borderRadius:
                                                                            99.0,
                                                                        buttonSize:
                                                                            40.0,
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).alternate,
                                                                        icon:
                                                                            Icon(
                                                                          FFIcons
                                                                              .ktrash,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          size:
                                                                              18.0,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          _model.removeFromChosenPoints(PointsType
                                                                              .user
                                                                              .name);
                                                                          _model
                                                                              .updateGameStruct(
                                                                            (e) => e
                                                                              ..userPoints = null
                                                                              ..userMoney = null
                                                                              ..userMoneyRate = null
                                                                              ..sponsorMoney = null
                                                                              ..sponsorPoints = null,
                                                                          );
                                                                          safeSetState(
                                                                              () {});
                                                                        },
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            16.0)),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          8.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Align(
                                                                        alignment: AlignmentDirectional(
                                                                            -1.0,
                                                                            0.0),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              170.0,
                                                                          height:
                                                                              42.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryBackground,
                                                                            borderRadius:
                                                                                BorderRadius.circular(99.0),
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Align(
                                                                                alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                child: FlutterFlowIconButton(
                                                                                  borderRadius: 99.0,
                                                                                  buttonSize: 50.0,
                                                                                  disabledIconColor: FlutterFlowTheme.of(context).secondaryText50,
                                                                                  icon: Icon(
                                                                                    FFIcons.kminus,
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    size: 25.0,
                                                                                  ),
                                                                                  onPressed: (valueOrDefault<double>(
                                                                                            _model.game?.userPoints,
                                                                                            0.0,
                                                                                          ) <=
                                                                                          0.0)
                                                                                      ? null
                                                                                      : () async {
                                                                                          if (valueOrDefault<double>(
                                                                                                _model.game?.userPoints,
                                                                                                0.0,
                                                                                              ) >
                                                                                              0.0) {
                                                                                            _model.updateGameStruct(
                                                                                              (e) => e..incrementUserPoints(-1.0),
                                                                                            );
                                                                                            safeSetState(() {});
                                                                                          } else {
                                                                                            _model.updateGameStruct(
                                                                                              (e) => e..userPoints = 0.0,
                                                                                            );
                                                                                            safeSetState(() {});
                                                                                          }

                                                                                          safeSetState(() {
                                                                                            _model.userPointsTextController2?.text = functions.numFormat(_model.game!.userPoints.toString())!;
                                                                                          });
                                                                                        },
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Container(
                                                                                  width: 200.0,
                                                                                  child: TextFormField(
                                                                                    controller: _model.userPointsTextController2,
                                                                                    focusNode: _model.userPointsFocusNode2,
                                                                                    onChanged: (_) => EasyDebounce.debounce(
                                                                                      '_model.userPointsTextController2',
                                                                                      Duration(milliseconds: 50),
                                                                                      () async {
                                                                                        _model.updateGameStruct(
                                                                                          (e) => e..userPoints = functions.numParse(_model.userPointsTextController2.text),
                                                                                        );
                                                                                        safeSetState(() {});
                                                                                      },
                                                                                    ),
                                                                                    onFieldSubmitted: (_) async {
                                                                                      unawaited(
                                                                                        () async {
                                                                                          await actions.closeKeyboard(
                                                                                            context,
                                                                                          );
                                                                                        }(),
                                                                                      );
                                                                                    },
                                                                                    autofocus: false,
                                                                                    textInputAction: TextInputAction.done,
                                                                                    obscureText: false,
                                                                                    decoration: InputDecoration(
                                                                                      isDense: true,
                                                                                      hintText: '0',
                                                                                      hintStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                            fontFamily: FlutterFlowTheme.of(context).labelLargeFamily,
                                                                                            letterSpacing: 0.0,
                                                                                            useGoogleFonts: !FlutterFlowTheme.of(context).labelLargeIsCustom,
                                                                                          ),
                                                                                      enabledBorder: InputBorder.none,
                                                                                      focusedBorder: InputBorder.none,
                                                                                      errorBorder: InputBorder.none,
                                                                                      focusedErrorBorder: InputBorder.none,
                                                                                    ),
                                                                                    style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                          fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                          fontSize: 14.0,
                                                                                          letterSpacing: valueOrDefault<double>(
                                                                                            -0.35,
                                                                                            -0.35,
                                                                                          ),
                                                                                          fontWeight: FontWeight.w600,
                                                                                          lineHeight: 1.5,
                                                                                          useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                        ),
                                                                                    textAlign: TextAlign.center,
                                                                                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                                                                    cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                                    enableInteractiveSelection: true,
                                                                                    validator: _model.userPointsTextController2Validator.asValidator(context),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              FlutterFlowIconButton(
                                                                                borderRadius: 99.0,
                                                                                buttonSize: 50.0,
                                                                                icon: Icon(
                                                                                  FFIcons.kplus,
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  size: 25.0,
                                                                                ),
                                                                                onPressed: () async {
                                                                                  _model.updateGameStruct(
                                                                                    (e) => e..incrementUserPoints(1.0),
                                                                                  );
                                                                                  safeSetState(() {});
                                                                                  safeSetState(() {
                                                                                    _model.userPointsTextController2?.text = functions.numFormat(_model.game!.userPoints.toString())!;
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        '${valueOrDefault<String>(
                                                                          functions
                                                                              .numFormat(valueOrDefault<String>(
                                                                            (_model.game!.userPoints * _model.game!.userMoneyRate).toString(),
                                                                            '0',
                                                                          )),
                                                                          '0',
                                                                        )} €',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.63,
                                                                                -0.63,
                                                                              ),
                                                                              fontWeight: FontWeight.bold,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                                Divider(
                                                                  height: 32.0,
                                                                  thickness:
                                                                      1.0,
                                                                  indent: 16.0,
                                                                  endIndent:
                                                                      16.0,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        if (valueOrDefault<
                                                            bool>(
                                                          _model.chosenPoints
                                                              .contains(
                                                                  PointsType
                                                                      .team
                                                                      .name),
                                                          false,
                                                        ))
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        0.0,
                                                                        12.0,
                                                                        0.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          16.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            40.0,
                                                                        height:
                                                                            40.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryBackground,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child:
                                                                            Icon(
                                                                          FFIcons
                                                                              .kgroup,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          size:
                                                                              18.0,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'Team-Punkte',
                                                                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                    fontSize: 18.0,
                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                      -0.4,
                                                                                      -0.4,
                                                                                    ),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                  ),
                                                                            ),
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
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
                                                                                        child: TypesPointsSingleWidget(
                                                                                          game: _model.game,
                                                                                          chosenType: PointsType.team.name,
                                                                                          userPhoto: 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                          update: (gameDT) async {
                                                                                            _model.game = gameDT;
                                                                                            safeSetState(() {});
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ).then((value) => safeSetState(() {}));
                                                                              },
                                                                              child: Text(
                                                                                '${valueOrDefault<String>(
                                                                                  functions.numFormat(valueOrDefault<String>(
                                                                                    _model.game?.teamMoneyRate?.toString(),
                                                                                    '0',
                                                                                  )),
                                                                                  '0',
                                                                                )} € je Punkt',
                                                                                style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                      color: FlutterFlowTheme.of(context).primary,
                                                                                      fontSize: 14.0,
                                                                                      letterSpacing: valueOrDefault<double>(
                                                                                        -0.35,
                                                                                        -0.35,
                                                                                      ),
                                                                                      fontWeight: FontWeight.w500,
                                                                                      decoration: TextDecoration.underline,
                                                                                      lineHeight: 1.5,
                                                                                      useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      FlutterFlowIconButton(
                                                                        borderRadius:
                                                                            99.0,
                                                                        buttonSize:
                                                                            40.0,
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).alternate,
                                                                        icon:
                                                                            Icon(
                                                                          FFIcons
                                                                              .ktrash,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          size:
                                                                              18.0,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          _model.removeFromChosenPoints(PointsType
                                                                              .team
                                                                              .name);
                                                                          _model
                                                                              .updateGameStruct(
                                                                            (e) => e
                                                                              ..teamPoints = null
                                                                              ..teamMoney = null
                                                                              ..teamMoneyRate = null,
                                                                          );
                                                                          safeSetState(
                                                                              () {});
                                                                        },
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            16.0)),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          8.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Align(
                                                                        alignment: AlignmentDirectional(
                                                                            -1.0,
                                                                            0.0),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              170.0,
                                                                          height:
                                                                              42.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryBackground,
                                                                            borderRadius:
                                                                                BorderRadius.circular(99.0),
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Align(
                                                                                alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                child: FlutterFlowIconButton(
                                                                                  borderRadius: 99.0,
                                                                                  buttonSize: 50.0,
                                                                                  disabledIconColor: FlutterFlowTheme.of(context).secondaryText50,
                                                                                  icon: Icon(
                                                                                    FFIcons.kminus,
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    size: 25.0,
                                                                                  ),
                                                                                  onPressed: (valueOrDefault<double>(
                                                                                            _model.game?.teamPoints,
                                                                                            0.0,
                                                                                          ) <=
                                                                                          0.0)
                                                                                      ? null
                                                                                      : () async {
                                                                                          if (valueOrDefault<double>(
                                                                                                _model.game?.teamPoints,
                                                                                                0.0,
                                                                                              ) >
                                                                                              0.0) {
                                                                                            _model.updateGameStruct(
                                                                                              (e) => e..incrementTeamPoints(-1.0),
                                                                                            );
                                                                                            safeSetState(() {});
                                                                                          } else {
                                                                                            _model.updateGameStruct(
                                                                                              (e) => e..teamPoints = 0.0,
                                                                                            );
                                                                                            safeSetState(() {});
                                                                                          }

                                                                                          safeSetState(() {
                                                                                            _model.teamPointsTextController2?.text = functions.numFormat(_model.game!.teamPoints.toString())!;
                                                                                          });
                                                                                        },
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Container(
                                                                                  width: 200.0,
                                                                                  child: TextFormField(
                                                                                    controller: _model.teamPointsTextController2,
                                                                                    focusNode: _model.teamPointsFocusNode2,
                                                                                    onChanged: (_) => EasyDebounce.debounce(
                                                                                      '_model.teamPointsTextController2',
                                                                                      Duration(milliseconds: 50),
                                                                                      () async {
                                                                                        _model.updateGameStruct(
                                                                                          (e) => e..teamPoints = functions.numParse(_model.teamPointsTextController2.text),
                                                                                        );
                                                                                        safeSetState(() {});
                                                                                      },
                                                                                    ),
                                                                                    onFieldSubmitted: (_) async {
                                                                                      unawaited(
                                                                                        () async {
                                                                                          await actions.closeKeyboard(
                                                                                            context,
                                                                                          );
                                                                                        }(),
                                                                                      );
                                                                                    },
                                                                                    autofocus: false,
                                                                                    textInputAction: TextInputAction.done,
                                                                                    obscureText: false,
                                                                                    decoration: InputDecoration(
                                                                                      isDense: true,
                                                                                      hintText: '0',
                                                                                      hintStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                            fontFamily: FlutterFlowTheme.of(context).labelLargeFamily,
                                                                                            letterSpacing: 0.0,
                                                                                            useGoogleFonts: !FlutterFlowTheme.of(context).labelLargeIsCustom,
                                                                                          ),
                                                                                      enabledBorder: InputBorder.none,
                                                                                      focusedBorder: InputBorder.none,
                                                                                      errorBorder: InputBorder.none,
                                                                                      focusedErrorBorder: InputBorder.none,
                                                                                    ),
                                                                                    style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                          fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                          fontSize: 14.0,
                                                                                          letterSpacing: valueOrDefault<double>(
                                                                                            -0.35,
                                                                                            -0.35,
                                                                                          ),
                                                                                          fontWeight: FontWeight.w600,
                                                                                          lineHeight: 1.5,
                                                                                          useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                        ),
                                                                                    textAlign: TextAlign.center,
                                                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                                                    cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                                    enableInteractiveSelection: true,
                                                                                    validator: _model.teamPointsTextController2Validator.asValidator(context),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              FlutterFlowIconButton(
                                                                                borderRadius: 99.0,
                                                                                buttonSize: 50.0,
                                                                                icon: Icon(
                                                                                  FFIcons.kplus,
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  size: 25.0,
                                                                                ),
                                                                                onPressed: () async {
                                                                                  _model.updateGameStruct(
                                                                                    (e) => e..incrementTeamPoints(1.0),
                                                                                  );
                                                                                  safeSetState(() {});
                                                                                  safeSetState(() {
                                                                                    _model.teamPointsTextController2?.text = functions.numFormat(_model.game!.teamPoints.toString())!;
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        '${valueOrDefault<String>(
                                                                          functions
                                                                              .numFormat(valueOrDefault<String>(
                                                                            (_model.game!.teamPoints * _model.game!.teamMoneyRate).toString(),
                                                                            '0',
                                                                          )),
                                                                          '0',
                                                                        )} €',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.63,
                                                                                -0.63,
                                                                              ),
                                                                              fontWeight: FontWeight.bold,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                                Divider(
                                                                  height: 32.0,
                                                                  thickness:
                                                                      1.0,
                                                                  indent: 16.0,
                                                                  endIndent:
                                                                      16.0,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        if (valueOrDefault<
                                                            bool>(
                                                          _model.chosenPoints
                                                              .contains(
                                                                  PointsType
                                                                      .sieg
                                                                      .name),
                                                          false,
                                                        ))
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        0.0,
                                                                        12.0,
                                                                        0.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          16.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            40.0,
                                                                        height:
                                                                            40.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryBackground,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child:
                                                                            Icon(
                                                                          FFIcons
                                                                              .ktrophy,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          size:
                                                                              18.0,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'Sieg',
                                                                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                    fontSize: 18.0,
                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                      -0.4,
                                                                                      -0.4,
                                                                                    ),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                  ),
                                                                            ),
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
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
                                                                                        child: TypesPointsSingleWidget(
                                                                                          game: _model.game,
                                                                                          chosenType: PointsType.sieg.name,
                                                                                          userPhoto: 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                          update: (gameDT) async {
                                                                                            _model.game = gameDT;
                                                                                            safeSetState(() {});
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ).then((value) => safeSetState(() {}));
                                                                              },
                                                                              child: Text(
                                                                                '${valueOrDefault<String>(
                                                                                  functions.numFormat(_model.game!.siegPoints.toString()),
                                                                                  '0',
                                                                                )} € für Sieg',
                                                                                style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                      color: FlutterFlowTheme.of(context).primary,
                                                                                      fontSize: 14.0,
                                                                                      letterSpacing: valueOrDefault<double>(
                                                                                        -0.35,
                                                                                        -0.35,
                                                                                      ),
                                                                                      fontWeight: FontWeight.w500,
                                                                                      decoration: TextDecoration.underline,
                                                                                      lineHeight: 1.5,
                                                                                      useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      FlutterFlowIconButton(
                                                                        borderRadius:
                                                                            99.0,
                                                                        buttonSize:
                                                                            40.0,
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).alternate,
                                                                        icon:
                                                                            Icon(
                                                                          FFIcons
                                                                              .ktrash,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          size:
                                                                              18.0,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          _model.removeFromChosenPoints(PointsType
                                                                              .sieg
                                                                              .name);
                                                                          _model
                                                                              .updateGameStruct(
                                                                            (e) => e
                                                                              ..siegPoints = null
                                                                              ..siegMoney = null
                                                                              ..siegMoneyRate = null,
                                                                          );
                                                                          safeSetState(
                                                                              () {});
                                                                        },
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            16.0)),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          8.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            InkWell(
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          focusColor:
                                                                              Colors.transparent,
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () async {
                                                                            if (_model.game!.siegMoneyRate >
                                                                                0.0) {
                                                                              _model.updateGameStruct(
                                                                                (e) => e..siegMoneyRate = 0.0,
                                                                              );
                                                                              safeSetState(() {});
                                                                            } else {
                                                                              _model.updateGameStruct(
                                                                                (e) => e..siegMoneyRate = 1.0,
                                                                              );
                                                                              safeSetState(() {});
                                                                            }
                                                                          },
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children:
                                                                                [
                                                                              Builder(
                                                                                builder: (context) {
                                                                                  if (_model.game!.siegMoneyRate > 0.0) {
                                                                                    return Container(
                                                                                      width: 18.0,
                                                                                      height: 18.0,
                                                                                      decoration: BoxDecoration(
                                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                                        borderRadius: BorderRadius.circular(4.0),
                                                                                        border: Border.all(
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                          width: 1.0,
                                                                                        ),
                                                                                      ),
                                                                                      child: Align(
                                                                                        alignment: AlignmentDirectional(0.0, 0.0),
                                                                                        child: Icon(
                                                                                          FFIcons.kcheck2,
                                                                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                          size: 12.0,
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  } else {
                                                                                    return Container(
                                                                                      width: 18.0,
                                                                                      height: 18.0,
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(4.0),
                                                                                        border: Border.all(
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                          width: 1.0,
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                },
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'Gewonnen',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                        fontSize: 16.0,
                                                                                        letterSpacing: valueOrDefault<double>(
                                                                                          -0.4,
                                                                                          -0.4,
                                                                                        ),
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            ].divide(SizedBox(width: 8.0)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        '${valueOrDefault<String>(
                                                                          functions
                                                                              .numFormat(valueOrDefault<String>(
                                                                            (_model.game!.siegPoints * _model.game!.siegMoneyRate).toString(),
                                                                            '0',
                                                                          )),
                                                                          '0',
                                                                        )} €',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.63,
                                                                                -0.63,
                                                                              ),
                                                                              fontWeight: FontWeight.bold,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                                Divider(
                                                                  height: 32.0,
                                                                  thickness:
                                                                      1.0,
                                                                  indent: 16.0,
                                                                  endIndent:
                                                                      16.0,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        if (_model.chosenPoints
                                                                .length <
                                                            3)
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        0.0,
                                                                        12.0,
                                                                        16.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          8.0,
                                                                          0.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Icon(
                                                                        FFIcons
                                                                            .kevPlugCharging,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                        size:
                                                                            24.0,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          'Einsatz hinzufügen',
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
                                                                            FFIcons.kplus,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryBackground,
                                                                            size:
                                                                                24.0,
                                                                          ),
                                                                          onPressed:
                                                                              () async {
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
                                                                                    child: TypesPointsWidget(
                                                                                      chosenTypes: _model.chosenPoints,
                                                                                      game: _model.game,
                                                                                      userPhoto: 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                                      update: (gameDT) async {
                                                                                        _model.updateGameStruct(
                                                                                          (e) => e
                                                                                            ..userMoneyRate = gameDT.userMoneyRate
                                                                                            ..teamMoneyRate = gameDT.teamMoneyRate
                                                                                            ..siegPoints = gameDT.siegPoints,
                                                                                        );
                                                                                        safeSetState(() {});
                                                                                      },
                                                                                      updateTypes: (type) async {
                                                                                        if (!_model.chosenPoints.contains(type)) {
                                                                                          _model.addToChosenPoints(type!);
                                                                                          safeSetState(() {});
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ).then((value) =>
                                                                                safeSetState(() {}));
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            16.0)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (_model.gamesCount! < 5)
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
                                                      'Deine Sponsoren',
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
                                                      minHeight: 106.0,
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
                                                                  12.0,
                                                                  4.0,
                                                                  12.0,
                                                                  4.0),
                                                      child: wrapWithModel(
                                                        model: _model
                                                            .pfgOrgSumModel2,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        updateOnChange: true,
                                                        child: PfgOrgSumWidget(
                                                          text:
                                                              '0,10 € je eigener Punkt\n5 Games, max. 2 €/Game ',
                                                          sum: valueOrDefault<
                                                              double>(
                                                            (_model.game!.userPoints *
                                                                        0.1) >
                                                                    2.0
                                                                ? 2.0
                                                                : (_model.game!
                                                                        .userPoints *
                                                                    0.1),
                                                            0.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ].addToEnd(SizedBox(
                                      height: valueOrDefault<double>(
                                    (isWeb
                                            ? MediaQuery.viewInsetsOf(context)
                                                    .bottom >
                                                0
                                            : _isKeyboardVisible)
                                        ? 24.0
                                        : 250.0,
                                    250.0,
                                  ))),
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
                          ],
                        ),
                      ),
                      if (!(isWeb
                          ? MediaQuery.viewInsetsOf(context).bottom > 0
                          : _isKeyboardVisible))
                        Align(
                          alignment: AlignmentDirectional(0.0, 1.0),
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: 800.0,
                            ),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 32.0, 12.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 44.0,
                                        height: 32.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .tertiary,
                                          borderRadius:
                                              BorderRadius.circular(99.0),
                                        ),
                                        child: Icon(
                                          FFIcons.kball,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 20.0,
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.2,
                                        height: 1.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      Container(
                                        width: 44.0,
                                        height: 32.0,
                                        decoration: BoxDecoration(),
                                        child: Icon(
                                          FFIcons.kdonate,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.2,
                                        height: 1.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      Container(
                                        width: 44.0,
                                        height: 32.0,
                                        decoration: BoxDecoration(),
                                        child: Icon(
                                          FFIcons.kflash,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 22.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        12.0, 0.0, 0.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          'Game',
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                fontSize: 12.0,
                                                letterSpacing:
                                                    valueOrDefault<double>(
                                                  -0.24,
                                                  -0.24,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                lineHeight: 1.5,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmallIsCustom,
                                              ),
                                        ),
                                        Text(
                                          'Organisation',
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                fontSize: 12.0,
                                                letterSpacing:
                                                    valueOrDefault<double>(
                                                  -0.24,
                                                  -0.24,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                lineHeight: 1.5,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmallIsCustom,
                                              ),
                                        ),
                                        Text(
                                          'Zahlung',
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                fontSize: 12.0,
                                                letterSpacing:
                                                    valueOrDefault<double>(
                                                  -0.24,
                                                  -0.24,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                lineHeight: 1.5,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmallIsCustom,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 34.0),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        borderRadius:
                                            BorderRadius.circular(99.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      32.0, 0.0, 0.0, 0.0),
                                              child: Text(
                                                '${valueOrDefault<String>(
                                                  functions.numFormat(
                                                      valueOrDefault<String>(
                                                    ((_model.game!.userPoints *
                                                                _model.game!
                                                                    .userMoneyRate) +
                                                            (_model.game!
                                                                    .teamPoints *
                                                                _model.game!
                                                                    .teamMoneyRate) +
                                                            (_model.game!
                                                                    .siegPoints *
                                                                _model.game!
                                                                    .siegMoneyRate))
                                                        .toString(),
                                                    '0',
                                                  )),
                                                  '0',
                                                )} €',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineLargeFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          letterSpacing:
                                                              valueOrDefault<
                                                                  double>(
                                                            -1.44,
                                                            -1.44,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          lineHeight: 1.2,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .headlineLargeIsCustom,
                                                        ),
                                              ),
                                            ),
                                            FFButtonWidget(
                                              onPressed: (((_model.game!
                                                                  .userPoints *
                                                              _model.game!
                                                                  .userMoneyRate) +
                                                          (_model.game!
                                                                  .teamPoints *
                                                              _model.game!
                                                                  .teamMoneyRate) +
                                                          (_model.game!
                                                                  .siegPoints *
                                                              _model.game!
                                                                  .siegMoneyRate)) ==
                                                      0.0)
                                                  ? null
                                                  : () async {
                                                      _model.updateGameStruct(
                                                        (e) => e
                                                          ..userMoney = _model
                                                                  .game!
                                                                  .userPoints *
                                                              _model.game!
                                                                  .userMoneyRate
                                                          ..teamMoney = _model
                                                                  .game!
                                                                  .teamPoints *
                                                              _model.game!
                                                                  .teamMoneyRate
                                                          ..siegMoney = _model
                                                                  .game!
                                                                  .siegPoints *
                                                              _model.game!
                                                                  .siegMoneyRate
                                                          ..title =
                                                              valueOrDefault<
                                                                  String>(
                                                            _model.game?.title !=
                                                                        null &&
                                                                    _model.game
                                                                            ?.title !=
                                                                        ''
                                                                ? _model
                                                                    .game?.title
                                                                : 'Game #1',
                                                            'Game #1',
                                                          ),
                                                      );
                                                      safeSetState(() {});
                                                      _model.updateGameStruct(
                                                        (e) => e
                                                          ..donatMoney =
                                                              valueOrDefault<
                                                                  double>(
                                                            functions
                                                                .donationCalculate(
                                                                    valueOrDefault<
                                                                        double>(
                                                                  valueOrDefault<
                                                                          double>(
                                                                        _model
                                                                            .game
                                                                            ?.userMoney,
                                                                        0.0,
                                                                      ) +
                                                                      valueOrDefault<
                                                                          double>(
                                                                        _model
                                                                            .game
                                                                            ?.teamMoney,
                                                                        0.0,
                                                                      ) +
                                                                      valueOrDefault<
                                                                          double>(
                                                                        _model
                                                                            .game
                                                                            ?.siegMoney,
                                                                        0.0,
                                                                      ),
                                                                  0.0,
                                                                ))
                                                                .suggestDonat,
                                                            0.0,
                                                          )
                                                          ..sponsorMoney =
                                                              valueOrDefault<
                                                                  double>(
                                                            () {
                                                              if (_model
                                                                      .gamesCount! >=
                                                                  5) {
                                                                return 0.0;
                                                              } else if ((_model
                                                                          .game!
                                                                          .userPoints *
                                                                      0.1) >
                                                                  2.0) {
                                                                return 2.0;
                                                              } else {
                                                                return (_model
                                                                        .game!
                                                                        .userPoints *
                                                                    0.1);
                                                              }
                                                            }(),
                                                            0.0,
                                                          )
                                                          ..sponsorPoints = _model
                                                                      .gamesCount! <
                                                                  5
                                                              ? (valueOrDefault<
                                                                      double>(
                                                                    (_model.game!.userPoints *
                                                                                0.1) >
                                                                            2.0
                                                                        ? 2.0
                                                                        : (_model.game!.userPoints *
                                                                            0.1),
                                                                    0.0,
                                                                  ) /
                                                                  _model.game!
                                                                      .sponsorRate)
                                                              : 0.0,
                                                      );
                                                      safeSetState(() {});
                                                      unawaited(
                                                        () async {
                                                          await actions
                                                              .closeKeyboard(
                                                            context,
                                                          );
                                                        }(),
                                                      );
                                                      await showModalBottomSheet(
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        isDismissible: false,
                                                        enableDrag: false,
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
                                                                  OrganisationListPlayWidget(
                                                                gameDT: _model
                                                                    .game!,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ).then((value) =>
                                                          safeSetState(() {}));
                                                    },
                                              text: 'Weiter',
                                              options: FFButtonOptions(
                                                width: 98.0,
                                                height: 40.0,
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        16.0, 0.0, 16.0, 0.0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
                                                          color: Colors.white,
                                                          letterSpacing:
                                                              valueOrDefault<
                                                                  double>(
                                                            -0.4,
                                                            -0.4,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          lineHeight: 1.5,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                                elevation: 0.0,
                                                borderRadius:
                                                    BorderRadius.circular(99.0),
                                                disabledColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary30,
                                                disabledTextColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary50,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                            ),
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
                              16.0, 60.0, 16.0, 12.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    if (valueOrDefault<double>(
                                          (_model.game!.userPoints *
                                                  _model.game!.userMoneyRate) +
                                              (_model.game!.teamPoints *
                                                  _model.game!.teamMoneyRate) +
                                              (_model.game!.siegPoints *
                                                  _model.game!.siegMoneyRate),
                                          0.0,
                                        ) >
                                        0.0) {
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        useSafeArea: true,
                                        context: context,
                                        builder: (context) {
                                          return GestureDetector(
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: CancelGameDialogWidget(),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    } else {
                                      context.goNamed(
                                        HomePageWidget.routeName,
                                        extra: <String, dynamic>{
                                          '__transition_info__': TransitionInfo(
                                            hasTransition: true,
                                            transitionType:
                                                PageTransitionType.fade,
                                            duration: Duration(milliseconds: 0),
                                          ),
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(1.0, 1.0),
                        child: wrapWithModel(
                          model: _model.closeKeyboardModel2,
                          updateCallback: () => safeSetState(() {}),
                          updateOnChange: true,
                          child: CloseKeyboardWidget(),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ));
  }
}
