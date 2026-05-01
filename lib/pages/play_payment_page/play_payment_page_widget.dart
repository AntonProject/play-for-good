import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/dialogs/auth_dialog/auth_dialog_widget.dart';
import '/components/dialogs/cancel_game_dialog/cancel_game_dialog_widget.dart';
import '/components/dialogs/donat_add/donat_add_widget.dart';
import '/components/dialogs/game_title_edit/game_title_edit_widget.dart';
import '/components/dialogs/organisation_list_play/organisation_list_play_widget.dart';
import '/components/dialogs/receipt_dialog/receipt_dialog_widget.dart';
import '/components/dialogs/snack_bar/snack_bar_widget.dart';
import '/components/image/image_widget.dart';
import '/components/organisation_comp/organisation_comp_widget.dart';
import '/components/organizations_home_empty/organizations_home_empty_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'play_payment_page_model.dart';
export 'play_payment_page_model.dart';

class PlayPaymentPageWidget extends StatefulWidget {
  const PlayPaymentPageWidget({
    super.key,
    this.game,
    this.user,
    this.guestChosenOrgId,
  });

  final GameStruct? game;
  final UsersRow? user;
  final String? guestChosenOrgId;

  static String routeName = 'PlayPaymentPage';
  static String routePath = '/playPaymentPage';

  @override
  State<PlayPaymentPageWidget> createState() => _PlayPaymentPageWidgetState();
}

class _PlayPaymentPageWidgetState extends State<PlayPaymentPageWidget> {
  late PlayPaymentPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PlayPaymentPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.setStatusBarColor(
        false,
      );
      _model.paymentType = widget!.user?.paymentMethod;
      _model.gamePage = widget!.game;
      safeSetState(() {});
      if (widget!.user?.chosenOrg != null && widget!.user?.chosenOrg != '') {
        _model.updateGamePageStruct(
          (e) => e..chosenOrgId = widget!.user?.chosenOrg,
        );
        safeSetState(() {});
      }
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

    _model.nameFocusNode1 ??= FocusNode();
    _model.nameFocusNode1!.addListener(() => safeSetState(() {}));

    _model.surnameFocusNode1 ??= FocusNode();
    _model.surnameFocusNode1!.addListener(() => safeSetState(() {}));

    _model.emailLoginFocusNode1 ??= FocusNode();
    _model.emailLoginFocusNode1!.addListener(() => safeSetState(() {}));
    _model.nameTextController2 ??= TextEditingController();
    _model.nameFocusNode2 ??= FocusNode();
    _model.nameFocusNode2!.addListener(() => safeSetState(() {}));
    _model.surnameTextController2 ??= TextEditingController();
    _model.surnameFocusNode2 ??= FocusNode();
    _model.surnameFocusNode2!.addListener(() => safeSetState(() {}));
    _model.emailLoginTextController2 ??= TextEditingController();
    _model.emailLoginFocusNode2 ??= FocusNode();
    _model.emailLoginFocusNode2!.addListener(() => safeSetState(() {}));
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
        title: 'PlayPaymentPage',
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
                if (_model.isPaymentProcessing == false) {
                  return Builder(
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
                                        alignment:
                                            AlignmentDirectional(0.0, -1.0),
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
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Container(
                                                      width: 96.0,
                                                      height: 96.0,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          width: 4.0,
                                                        ),
                                                      ),
                                                      child: wrapWithModel(
                                                        model:
                                                            _model.imageModel1,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child: ImageWidget(
                                                          size: 96.0,
                                                          image: valueOrDefault<
                                                              String>(
                                                            stackUsersRow
                                                                ?.photoUrl,
                                                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/42sgzx6uejhj/Vector.png',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  16.0,
                                                                  16.0,
                                                                  0.0),
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
                                                                      GameTitleEditWidget(
                                                                    game:
                                                                        GameStruct(
                                                                      title: valueOrDefault<
                                                                          String>(
                                                                        _model.gamePage?.title != null &&
                                                                                _model.gamePage?.title != ''
                                                                            ? _model.gamePage?.title
                                                                            : 'Game #${((stackUsersRow!.gamesCount!) + 1).toString()}',
                                                                        'Game #1',
                                                                      ),
                                                                    ),
                                                                    updateTitle:
                                                                        (title) async {
                                                                      _model
                                                                          .updateGamePageStruct(
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
                                                              safeSetState(
                                                                  () {}));
                                                        },
                                                        child: Text(
                                                          valueOrDefault<
                                                              String>(
                                                            widget!.game?.title,
                                                            'Game #1',
                                                          ),
                                                          maxLines: 3,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .labelLarge
                                                              .override(
                                                                fontFamily:
                                                                    'Dela Gothic One',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
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
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  24.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Text(
                                                        'Deine Game €nergy',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMediumFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  letterSpacing:
                                                                      valueOrDefault<
                                                                          double>(
                                                                    -0.35,
                                                                    -0.35,
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  lineHeight:
                                                                      1.5,
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
                                                            text:
                                                                valueOrDefault<
                                                                    String>(
                                                              functions.numFormat(
                                                                  valueOrDefault<
                                                                      String>(
                                                                (_model.gamePage!.userMoney +
                                                                        _model
                                                                            .gamePage!
                                                                            .teamMoney +
                                                                        _model
                                                                            .gamePage!
                                                                            .siegMoney)
                                                                    .toString(),
                                                                '0',
                                                              )),
                                                              '0',
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Dela Gothic One',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  fontSize:
                                                                      48.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                          TextSpan(
                                                            text: ' €',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Dela Gothic One',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  fontSize:
                                                                      24.0,
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
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                      ),
                                                    ),
                                                  ]
                                                      .addToStart(SizedBox(
                                                          height: 120.0))
                                                      .addToEnd(SizedBox(
                                                          height: 32.0)),
                                                ),
                                              ),
                                              Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: 600.0,
                                                ),
                                                decoration: BoxDecoration(),
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
                                                                    24.0,
                                                                    24.0,
                                                                    24.0,
                                                                    0.0),
                                                        child: Text(
                                                          'Deine €nergy geht an',
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
                                                    Builder(
                                                      builder: (context) {
                                                        if (stackUsersRow
                                                                    ?.chosenOrg !=
                                                                null &&
                                                            stackUsersRow
                                                                    ?.chosenOrg !=
                                                                '') {
                                                          return Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        0.0),
                                                            child: FutureBuilder<
                                                                List<
                                                                    OrganizationRow>>(
                                                              future: OrganizationTable()
                                                                  .querySingleRow(
                                                                queryFn: (q) =>
                                                                    q.eqOrNull(
                                                                  'id',
                                                                  stackUsersRow
                                                                      ?.chosenOrg,
                                                                ),
                                                              ),
                                                              builder: (context,
                                                                  snapshot) {
                                                                // Customize what your widget looks like when it's loading.
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          20.0,
                                                                      height:
                                                                          20.0,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                List<OrganizationRow>
                                                                    containerOrganizationRowList =
                                                                    snapshot
                                                                        .data!;

                                                                // Return an empty Container when the item does not exist.
                                                                if (snapshot
                                                                    .data!
                                                                    .isEmpty) {
                                                                  return Container();
                                                                }
                                                                final containerOrganizationRow =
                                                                    containerOrganizationRowList
                                                                            .isNotEmpty
                                                                        ? containerOrganizationRowList
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
                                                                        BorderRadius.circular(
                                                                            16.0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            20.0,
                                                                            16.0,
                                                                            20.0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              8.0,
                                                                              0.0),
                                                                          child:
                                                                              wrapWithModel(
                                                                            model:
                                                                                _model.organisationCompModel1,
                                                                            updateCallback: () =>
                                                                                safeSetState(() {}),
                                                                            updateOnChange:
                                                                                true,
                                                                            child:
                                                                                OrganisationCompWidget(
                                                                              orgRow: containerOrganizationRow!,
                                                                              buttonText: 'Im nächsten Game unterstützen',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        } else {
                                                          return wrapWithModel(
                                                            model: _model
                                                                .organizationsHomeEmptyModel1,
                                                            updateCallback: () =>
                                                                safeSetState(
                                                                    () {}),
                                                            updateOnChange:
                                                                true,
                                                            child:
                                                                OrganizationsHomeEmptyWidget(
                                                              userId:
                                                                  stackUsersRow!
                                                                      .id,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  12.0,
                                                                  36.0,
                                                                  12.0,
                                                                  0.0),
                                                      child: Container(
                                                        width: double.infinity,
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
                                                              EdgeInsets.all(
                                                                  32.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        -1.0,
                                                                        0.0),
                                                                child: Text(
                                                                  'Dein freiwilliger Beitrag an Players For Good, damit wir ...',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleSmallFamily,
                                                                        fontSize:
                                                                            18.0,
                                                                        letterSpacing:
                                                                            valueOrDefault<double>(
                                                                          -0.63,
                                                                          -0.63,
                                                                        ),
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        lineHeight:
                                                                            1.4,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                      ),
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        -1.0,
                                                                        0.0),
                                                                child: Text(
                                                                  '... diese App weiterentwickeln und noch mehr Menschen dafür begeistern können, beim Sport und Spielen Gutes zu tun.',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        letterSpacing:
                                                                            valueOrDefault<double>(
                                                                          -0.35,
                                                                          -0.35,
                                                                        ),
                                                                        lineHeight:
                                                                            1.5,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                height: 72.0,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16.0),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              16.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        '${valueOrDefault<String>(
                                                                          functions.numFormat(_model
                                                                              .gamePage!
                                                                              .donatMoney
                                                                              .toString()),
                                                                          '0',
                                                                        )} €',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.4,
                                                                                -0.4,
                                                                              ),
                                                                              fontWeight: FontWeight.w600,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                            ),
                                                                      ),
                                                                      FFButtonWidget(
                                                                        onPressed:
                                                                            () async {
                                                                          await showModalBottomSheet(
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
                                                                                onTap: () {
                                                                                  FocusScope.of(context).unfocus();
                                                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                                                },
                                                                                child: Padding(
                                                                                  padding: MediaQuery.viewInsetsOf(context),
                                                                                  child: DonatAddWidget(
                                                                                    game: _model.gamePage,
                                                                                    update: (donatMoney) async {
                                                                                      _model.updateGamePageStruct(
                                                                                        (e) => e
                                                                                          ..donatMoney = valueOrDefault<double>(
                                                                                            donatMoney,
                                                                                            0.0,
                                                                                          ),
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
                                                                        text:
                                                                            'Beitrag anpassen',
                                                                        icon:
                                                                            Icon(
                                                                          FFIcons
                                                                              .krightArrow,
                                                                          size:
                                                                              20.0,
                                                                        ),
                                                                        options:
                                                                            FFButtonOptions(
                                                                          width:
                                                                              180.0,
                                                                          height:
                                                                              40.0,
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              16.0,
                                                                              0.0,
                                                                              16.0,
                                                                              0.0),
                                                                          iconAlignment:
                                                                              IconAlignment.end,
                                                                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).success,
                                                                          textStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                color: Colors.white,
                                                                                fontSize: 14.0,
                                                                                letterSpacing: valueOrDefault<double>(
                                                                                  -0.35,
                                                                                  -0.35,
                                                                                ),
                                                                                fontWeight: FontWeight.w600,
                                                                                lineHeight: 1.5,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                              ),
                                                                          elevation:
                                                                              0.0,
                                                                          borderRadius:
                                                                              BorderRadius.circular(99.0),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Icon(
                                                                    FFIcons
                                                                        .kthumbsUp,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          0.0,
                                                                          16.0,
                                                                          0.0,
                                                                          16.0),
                                                                      child:
                                                                          Text(
                                                                        'Vielen Dank! Jede Unterstützung zählt!',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.4,
                                                                                -0.4,
                                                                              ),
                                                                              fontWeight: FontWeight.w600,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        20.0)),
                                                              ),
                                                            ].divide(SizedBox(
                                                                height: 24.0)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
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
                                                          'Zahlungsmethode',
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
                                                                      32.0,
                                                                      24.0,
                                                                      32.0,
                                                                      24.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        12.0,
                                                                        0.0,
                                                                        12.0),
                                                                child: InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    _model.paymentType =
                                                                        PaymentMethods
                                                                            .paypal
                                                                            .name;
                                                                    safeSetState(
                                                                        () {});
                                                                  },
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
                                                                              .kpaypal,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          size:
                                                                              16.0,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          'PayPal',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                letterSpacing: valueOrDefault<double>(
                                                                                  -0.4,
                                                                                  -0.4,
                                                                                ),
                                                                                fontWeight: FontWeight.w600,
                                                                                lineHeight: 1.5,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                      Builder(
                                                                        builder:
                                                                            (context) {
                                                                          if (_model.paymentType ==
                                                                              PaymentMethods.paypal.name) {
                                                                            return Container(
                                                                              width: 24.0,
                                                                              height: 24.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                shape: BoxShape.circle,
                                                                                border: Border.all(
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  width: 7.0,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          } else {
                                                                            return Container(
                                                                              width: 24.0,
                                                                              height: 24.0,
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                border: Border.all(
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }
                                                                        },
                                                                      ),
                                                                    ]
                                                                        .divide(SizedBox(
                                                                            width:
                                                                                16.0))
                                                                        .addToEnd(SizedBox(
                                                                            width:
                                                                                8.0)),
                                                                  ),
                                                                ),
                                                              ),
                                                              Divider(
                                                                height: 1.0,
                                                                thickness: 1.0,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        12.0,
                                                                        0.0,
                                                                        12.0),
                                                                child: InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    _model.paymentType =
                                                                        PaymentMethods
                                                                            .card
                                                                            .name;
                                                                    safeSetState(
                                                                        () {});
                                                                  },
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
                                                                              .kcard,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          size:
                                                                              16.0,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          'Card${() {
                                                                            if (isAndroid) {
                                                                              return ' / Google Pay';
                                                                            } else if (isiOS) {
                                                                              return ' / Apple Pay';
                                                                            } else {
                                                                              return ' ';
                                                                            }
                                                                          }()}',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                letterSpacing: valueOrDefault<double>(
                                                                                  -0.4,
                                                                                  -0.4,
                                                                                ),
                                                                                fontWeight: FontWeight.w600,
                                                                                lineHeight: 1.5,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                      Builder(
                                                                        builder:
                                                                            (context) {
                                                                          if (_model.paymentType ==
                                                                              PaymentMethods.card.name) {
                                                                            return Container(
                                                                              width: 24.0,
                                                                              height: 24.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                shape: BoxShape.circle,
                                                                                border: Border.all(
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  width: 7.0,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          } else {
                                                                            return Container(
                                                                              width: 24.0,
                                                                              height: 24.0,
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                border: Border.all(
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }
                                                                        },
                                                                      ),
                                                                    ]
                                                                        .divide(SizedBox(
                                                                            width:
                                                                                16.0))
                                                                        .addToEnd(SizedBox(
                                                                            width:
                                                                                8.0)),
                                                                  ),
                                                                ),
                                                              ),
                                                              Divider(
                                                                height: 1.0,
                                                                thickness: 1.0,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        16.0,
                                                                        0.0,
                                                                        16.0),
                                                                child: InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    _model.saveMethod =
                                                                        !_model
                                                                            .saveMethod;
                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Builder(
                                                                        builder:
                                                                            (context) {
                                                                          if (_model
                                                                              .saveMethod) {
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
                                                                        child:
                                                                            Text(
                                                                          'Als Standardmethode speichern',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if (false)
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
                                                            'Daten zur Spende',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  fontSize:
                                                                      18.0,
                                                                  letterSpacing:
                                                                      valueOrDefault<
                                                                          double>(
                                                                    -0.63,
                                                                    -0.63,
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  lineHeight:
                                                                      1.4,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (false)
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    8.0,
                                                                    12.0,
                                                                    0.0),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
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
                                                                EdgeInsets.all(
                                                                    32.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16.0),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: valueOrDefault<
                                                                          Color>(
                                                                        () {
                                                                          if (((_model.nameTextController1.text != null && _model.nameTextController1.text != '') && !functions.validateName(_model.nameTextController1.text)) ||
                                                                              (_model.nameTextController1.text == null || _model.nameTextController1.text == '')) {
                                                                            return FlutterFlowTheme.of(context).error;
                                                                          } else if ((_model.nameFocusNode1?.hasFocus ?? false)) {
                                                                            return FlutterFlowTheme.of(context).focus;
                                                                          } else {
                                                                            return FlutterFlowTheme.of(context).primaryBackground;
                                                                          }
                                                                        }(),
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryBackground,
                                                                      ),
                                                                      width:
                                                                          2.0,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    width: double
                                                                        .infinity,
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _model.nameTextController1 ??=
                                                                              TextEditingController(
                                                                        text: stackUsersRow
                                                                            ?.firstName,
                                                                      ),
                                                                      focusNode:
                                                                          _model
                                                                              .nameFocusNode1,
                                                                      onChanged:
                                                                          (_) =>
                                                                              EasyDebounce.debounce(
                                                                        '_model.nameTextController1',
                                                                        Duration(
                                                                            milliseconds:
                                                                                50),
                                                                        () => safeSetState(
                                                                            () {}),
                                                                      ),
                                                                      autofocus:
                                                                          false,
                                                                      textCapitalization:
                                                                          TextCapitalization
                                                                              .words,
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        isDense:
                                                                            true,
                                                                        labelText:
                                                                            'Vorname*',
                                                                        labelStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.nameTextController1.text != null && _model.nameTextController1.text != '' ? FlutterFlowTheme.of(context).secondaryText : FlutterFlowTheme.of(context).secondaryText50,
                                                                                FlutterFlowTheme.of(context).secondaryText50,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.4,
                                                                                -0.4,
                                                                              ),
                                                                              fontWeight: FontWeight.w500,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                            ),
                                                                        hintStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                                                                              color: FlutterFlowTheme.of(context).secondaryText50,
                                                                              fontSize: 16.0,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.4,
                                                                                -0.4,
                                                                              ),
                                                                              fontWeight: FontWeight.w500,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).labelMediumIsCustom,
                                                                            ),
                                                                        enabledBorder:
                                                                            InputBorder.none,
                                                                        focusedBorder:
                                                                            InputBorder.none,
                                                                        errorBorder:
                                                                            InputBorder.none,
                                                                        focusedErrorBorder:
                                                                            InputBorder.none,
                                                                        contentPadding:
                                                                            EdgeInsets.all(16.0),
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.4,
                                                                              -0.4,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                          ),
                                                                      maxLength:
                                                                          30,
                                                                      maxLengthEnforcement:
                                                                          MaxLengthEnforcement
                                                                              .none,
                                                                      buildCounter: (context,
                                                                              {required currentLength,
                                                                              required isFocused,
                                                                              maxLength}) =>
                                                                          null,
                                                                      cursorColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .primaryText,
                                                                      enableInteractiveSelection:
                                                                          true,
                                                                      validator: _model
                                                                          .nameTextController1Validator
                                                                          .asValidator(
                                                                              context),
                                                                      inputFormatters: [
                                                                        if (!isAndroid &&
                                                                            !isiOS)
                                                                          TextInputFormatter.withFunction((oldValue,
                                                                              newValue) {
                                                                            return TextEditingValue(
                                                                              selection: newValue.selection,
                                                                              text: newValue.text.toCapitalization(TextCapitalization.words),
                                                                            );
                                                                          }),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (!functions.validateName(_model
                                                                        .nameTextController1
                                                                        .text) &&
                                                                    (_model.nameTextController1.text !=
                                                                            null &&
                                                                        _model.nameTextController1.text !=
                                                                            ''))
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            -1.0,
                                                                            0.0),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          4.0,
                                                                          0.0,
                                                                          0.0),
                                                                      child:
                                                                          AutoSizeText(
                                                                        'Gültigen Vornamen eingeben',
                                                                        maxLines:
                                                                            1,
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              fontSize: 14.0,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.35,
                                                                                -0.35,
                                                                              ),
                                                                              fontWeight: FontWeight.w500,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          24.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16.0),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          () {
                                                                            if (((_model.surnameTextController1.text != null && _model.surnameTextController1.text != '') && !functions.validateName(_model.surnameTextController1.text)) ||
                                                                                (_model.surnameTextController1.text == null || _model.surnameTextController1.text == '')) {
                                                                              return FlutterFlowTheme.of(context).error;
                                                                            } else if ((_model.surnameFocusNode1?.hasFocus ?? false)) {
                                                                              return FlutterFlowTheme.of(context).focus;
                                                                            } else {
                                                                              return FlutterFlowTheme.of(context).primaryBackground;
                                                                            }
                                                                          }(),
                                                                          FlutterFlowTheme.of(context)
                                                                              .primaryBackground,
                                                                        ),
                                                                        width:
                                                                            2.0,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            _model.surnameTextController1 ??=
                                                                                TextEditingController(
                                                                          text:
                                                                              stackUsersRow?.surname,
                                                                        ),
                                                                        focusNode:
                                                                            _model.surnameFocusNode1,
                                                                        onChanged:
                                                                            (_) =>
                                                                                EasyDebounce.debounce(
                                                                          '_model.surnameTextController1',
                                                                          Duration(
                                                                              milliseconds: 50),
                                                                          () =>
                                                                              safeSetState(() {}),
                                                                        ),
                                                                        autofocus:
                                                                            false,
                                                                        textCapitalization:
                                                                            TextCapitalization.words,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          labelText:
                                                                              'Nachname*',
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                color: valueOrDefault<Color>(
                                                                                  _model.surnameTextController1.text != null && _model.surnameTextController1.text != '' ? FlutterFlowTheme.of(context).secondaryText : FlutterFlowTheme.of(context).secondaryText50,
                                                                                  FlutterFlowTheme.of(context).secondaryText50,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: valueOrDefault<double>(
                                                                                  -0.4,
                                                                                  -0.4,
                                                                                ),
                                                                                fontWeight: FontWeight.w500,
                                                                                lineHeight: 1.5,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                              ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                                                                                color: FlutterFlowTheme.of(context).secondaryText50,
                                                                                fontSize: 16.0,
                                                                                letterSpacing: valueOrDefault<double>(
                                                                                  -0.4,
                                                                                  -0.4,
                                                                                ),
                                                                                fontWeight: FontWeight.w500,
                                                                                lineHeight: 1.5,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).labelMediumIsCustom,
                                                                              ),
                                                                          enabledBorder:
                                                                              InputBorder.none,
                                                                          focusedBorder:
                                                                              InputBorder.none,
                                                                          errorBorder:
                                                                              InputBorder.none,
                                                                          focusedErrorBorder:
                                                                              InputBorder.none,
                                                                          contentPadding:
                                                                              EdgeInsets.all(16.0),
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                              fontSize: 16.0,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.4,
                                                                                -0.4,
                                                                              ),
                                                                              fontWeight: FontWeight.w500,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                            ),
                                                                        maxLength:
                                                                            30,
                                                                        maxLengthEnforcement:
                                                                            MaxLengthEnforcement.none,
                                                                        buildCounter: (context,
                                                                                {required currentLength,
                                                                                required isFocused,
                                                                                maxLength}) =>
                                                                            null,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        enableInteractiveSelection:
                                                                            true,
                                                                        validator: _model
                                                                            .surnameTextController1Validator
                                                                            .asValidator(context),
                                                                        inputFormatters: [
                                                                          if (!isAndroid &&
                                                                              !isiOS)
                                                                            TextInputFormatter.withFunction((oldValue,
                                                                                newValue) {
                                                                              return TextEditingValue(
                                                                                selection: newValue.selection,
                                                                                text: newValue.text.toCapitalization(TextCapitalization.words),
                                                                              );
                                                                            }),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (!functions.validateName(_model
                                                                        .surnameTextController1
                                                                        .text) &&
                                                                    (_model.surnameTextController1.text !=
                                                                            null &&
                                                                        _model.surnameTextController1.text !=
                                                                            ''))
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            -1.0,
                                                                            0.0),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          4.0,
                                                                          0.0,
                                                                          0.0),
                                                                      child:
                                                                          AutoSizeText(
                                                                        'Gültigen Nachname eingeben',
                                                                        maxLines:
                                                                            1,
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              fontSize: 14.0,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.35,
                                                                                -0.35,
                                                                              ),
                                                                              fontWeight: FontWeight.w500,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          24.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16.0),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .alternate,
                                                                        width:
                                                                            2.0,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            _model.emailLoginTextController1 ??=
                                                                                TextEditingController(
                                                                          text:
                                                                              stackUsersRow?.email,
                                                                        ),
                                                                        focusNode:
                                                                            _model.emailLoginFocusNode1,
                                                                        onChanged:
                                                                            (_) =>
                                                                                EasyDebounce.debounce(
                                                                          '_model.emailLoginTextController1',
                                                                          Duration(
                                                                              milliseconds: 50),
                                                                          () =>
                                                                              safeSetState(() {}),
                                                                        ),
                                                                        autofocus:
                                                                            false,
                                                                        textCapitalization:
                                                                            TextCapitalization.none,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          labelText:
                                                                              'Deine E-Mail-Adresse*',
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                                fontSize: 16.0,
                                                                                letterSpacing: valueOrDefault<double>(
                                                                                  -0.4,
                                                                                  -0.4,
                                                                                ),
                                                                                fontWeight: FontWeight.w500,
                                                                                lineHeight: 1.5,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                              ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                                                                                color: FlutterFlowTheme.of(context).secondaryText50,
                                                                                fontSize: 16.0,
                                                                                letterSpacing: valueOrDefault<double>(
                                                                                  -0.4,
                                                                                  -0.4,
                                                                                ),
                                                                                fontWeight: FontWeight.w500,
                                                                                lineHeight: 1.5,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).labelMediumIsCustom,
                                                                              ),
                                                                          enabledBorder:
                                                                              InputBorder.none,
                                                                          focusedBorder:
                                                                              InputBorder.none,
                                                                          errorBorder:
                                                                              InputBorder.none,
                                                                          focusedErrorBorder:
                                                                              InputBorder.none,
                                                                          contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              16.0,
                                                                              16.0,
                                                                              48.0,
                                                                              16.0),
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                              color: FlutterFlowTheme.of(context).primaryText50,
                                                                              fontSize: 16.0,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.4,
                                                                                -0.4,
                                                                              ),
                                                                              fontWeight: FontWeight.w500,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                            ),
                                                                        maxLength:
                                                                            50,
                                                                        maxLengthEnforcement:
                                                                            MaxLengthEnforcement.none,
                                                                        buildCounter: (context,
                                                                                {required currentLength,
                                                                                required isFocused,
                                                                                maxLength}) =>
                                                                            null,
                                                                        keyboardType:
                                                                            TextInputType.emailAddress,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        enableInteractiveSelection:
                                                                            true,
                                                                        validator: _model
                                                                            .emailLoginTextController1Validator
                                                                            .asValidator(context),
                                                                        inputFormatters: [
                                                                          if (!isAndroid &&
                                                                              !isiOS)
                                                                            TextInputFormatter.withFunction((oldValue,
                                                                                newValue) {
                                                                              return TextEditingValue(
                                                                                selection: newValue.selection,
                                                                                text: newValue.text.toCapitalization(TextCapitalization.none),
                                                                              );
                                                                            }),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (false)
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      24.0,
                                                                      8.0,
                                                                      24.0,
                                                                      0.0),
                                                          child: Text(
                                                            '*Mit einem Sternchen (*) gekennzeichnete Felder sind Pflichtfelder',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      valueOrDefault<
                                                                          double>(
                                                                    -0.24,
                                                                    -0.24,
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  lineHeight:
                                                                      1.5,
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
                                                                  32.0,
                                                                  12.0,
                                                                  0.0),
                                                      child: Container(
                                                        width: double.infinity,
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
                                                                      32.0,
                                                                      24.0,
                                                                      32.0,
                                                                      24.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        12.0,
                                                                        0.0,
                                                                        12.0),
                                                                child: InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    if (stackUsersRow!
                                                                        .receipt!) {
                                                                      await UsersTable()
                                                                          .update(
                                                                        data: {
                                                                          'receipt':
                                                                              false,
                                                                        },
                                                                        matchingRows:
                                                                            (rows) =>
                                                                                rows.eqOrNull(
                                                                          'id',
                                                                          currentUserUid,
                                                                        ),
                                                                      );
                                                                    } else {
                                                                      if ((stackUsersRow?.gender != null && stackUsersRow?.gender != '') &&
                                                                          (stackUsersRow?.firstName != null &&
                                                                              stackUsersRow?.firstName !=
                                                                                  '') &&
                                                                          (stackUsersRow?.surname != null &&
                                                                              stackUsersRow?.surname !=
                                                                                  '') &&
                                                                          (stackUsersRow?.land != null &&
                                                                              stackUsersRow?.land !=
                                                                                  '') &&
                                                                          (stackUsersRow?.plz != null &&
                                                                              stackUsersRow?.plz !=
                                                                                  '') &&
                                                                          (stackUsersRow?.stadt != null &&
                                                                              stackUsersRow?.stadt !=
                                                                                  '') &&
                                                                          (stackUsersRow?.strae != null &&
                                                                              stackUsersRow?.strae !=
                                                                                  '') &&
                                                                          (stackUsersRow?.hausNr != null &&
                                                                              stackUsersRow?.hausNr != '')) {
                                                                        await UsersTable()
                                                                            .update(
                                                                          data: {
                                                                            'receipt':
                                                                                true,
                                                                          },
                                                                          matchingRows: (rows) =>
                                                                              rows.eqOrNull(
                                                                            'id',
                                                                            currentUserUid,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        await UsersTable()
                                                                            .update(
                                                                          data: {
                                                                            'receipt':
                                                                                false,
                                                                          },
                                                                          matchingRows: (rows) =>
                                                                              rows.eqOrNull(
                                                                            'id',
                                                                            currentUserUid,
                                                                          ),
                                                                        );
                                                                      }

                                                                      await showModalBottomSheet(
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
                                                                              child: ReceiptDialogWidget(
                                                                                userId: stackUsersRow!.id,
                                                                                name: _model.nameTextController1.text,
                                                                                surname: _model.surnameTextController1.text,
                                                                                gender: stackUsersRow?.gender,
                                                                                update: (receipt) async {
                                                                                  await UsersTable().update(
                                                                                    data: {
                                                                                      'receipt': receipt,
                                                                                    },
                                                                                    matchingRows: (rows) => rows.eqOrNull(
                                                                                      'id',
                                                                                      currentUserUid,
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ).then((value) =>
                                                                          safeSetState(
                                                                              () {}));
                                                                    }

                                                                    FFAppState()
                                                                            .refreshDate =
                                                                        getCurrentTimestamp;
                                                                    FFAppState()
                                                                        .update(
                                                                            () {});
                                                                    FFAppState()
                                                                        .clearUserCache();

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Builder(
                                                                        builder:
                                                                            (context) {
                                                                          if (valueOrDefault<
                                                                              bool>(
                                                                            stackUsersRow?.receipt,
                                                                            false,
                                                                          )) {
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
                                                                        child:
                                                                            RichText(
                                                                          textScaler:
                                                                              MediaQuery.of(context).textScaler,
                                                                          text:
                                                                              TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: 'Ja, ich möchte immer eine ',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: valueOrDefault<double>(
                                                                                        -0.24,
                                                                                        -0.24,
                                                                                      ),
                                                                                      fontWeight: FontWeight.w500,
                                                                                      lineHeight: 1.5,
                                                                                      useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                    ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: 'Spendenbetscheinigung erhalten',
                                                                                style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: valueOrDefault<double>(
                                                                                        -0.24,
                                                                                        -0.24,
                                                                                      ),
                                                                                      fontWeight: FontWeight.w500,
                                                                                      lineHeight: 1.5,
                                                                                      useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                    ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: ', um meine €nergy-Spenden von der Steuer abzusetzen.',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: valueOrDefault<double>(
                                                                                        -0.24,
                                                                                        -0.24,
                                                                                      ),
                                                                                      fontWeight: FontWeight.w500,
                                                                                      lineHeight: 1.5,
                                                                                      useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                    ),
                                                                              )
                                                                            ],
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  lineHeight: 1.5,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            20.0)),
                                                                  ),
                                                                ),
                                                              ),
                                                              if (false)
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          12.0,
                                                                          0.0,
                                                                          12.0),
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
                                                                      if (stackUsersRow!
                                                                          .emails!) {
                                                                        await UsersTable()
                                                                            .update(
                                                                          data: {
                                                                            'emails':
                                                                                false,
                                                                          },
                                                                          matchingRows: (rows) =>
                                                                              rows.eqOrNull(
                                                                            'id',
                                                                            currentUserUid,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        await UsersTable()
                                                                            .update(
                                                                          data: {
                                                                            'emails':
                                                                                true,
                                                                          },
                                                                          matchingRows: (rows) =>
                                                                              rows.eqOrNull(
                                                                            'id',
                                                                            currentUserUid,
                                                                          ),
                                                                        );
                                                                      }

                                                                      FFAppState()
                                                                          .clearUserCache();
                                                                      FFAppState()
                                                                              .refreshDate =
                                                                          getCurrentTimestamp;
                                                                      safeSetState(
                                                                          () {});

                                                                      safeSetState(
                                                                          () {});
                                                                    },
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
                                                                        Builder(
                                                                          builder:
                                                                              (context) {
                                                                            if (stackUsersRow?.emails ??
                                                                                false) {
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
                                                                          child:
                                                                              RichText(
                                                                            textScaler:
                                                                                MediaQuery.of(context).textScaler,
                                                                            text:
                                                                                TextSpan(
                                                                              children: [
                                                                                TextSpan(
                                                                                  text: 'Ich will per E-Mail von der Wirkung meiner Spenden und spannenden Aktionen erfahren. Hierfür stimme ich der ',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: valueOrDefault<double>(
                                                                                          -0.24,
                                                                                          -0.24,
                                                                                        ),
                                                                                        fontWeight: FontWeight.w500,
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                      ),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: 'Datenverarbeitung',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: valueOrDefault<double>(
                                                                                          -0.24,
                                                                                          -0.24,
                                                                                        ),
                                                                                        fontWeight: FontWeight.bold,
                                                                                        decoration: TextDecoration.underline,
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                      ),
                                                                                  mouseCursor: SystemMouseCursors.click,
                                                                                  recognizer: TapGestureRecognizer()
                                                                                    ..onTap = () async {
                                                                                      unawaited(
                                                                                        () async {
                                                                                          await launchURL(FFAppConstants.policy2);
                                                                                        }(),
                                                                                      );
                                                                                    },
                                                                                ),
                                                                                TextSpan(
                                                                                  text: ' zu. Abmeldung jederzeit möglich',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: valueOrDefault<double>(
                                                                                          -0.24,
                                                                                          -0.24,
                                                                                        ),
                                                                                        fontWeight: FontWeight.w500,
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                      ),
                                                                                )
                                                                              ],
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    fontSize: 16.0,
                                                                                    letterSpacing: 0.0,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 20.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              if (false)
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          12.0,
                                                                          0.0,
                                                                          12.0),
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
                                                                      FFAppState()
                                                                          .terms = !(FFAppState()
                                                                              .terms ??
                                                                          true);
                                                                      safeSetState(
                                                                          () {});
                                                                    },
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
                                                                        Builder(
                                                                          builder:
                                                                              (context) {
                                                                            if (FFAppState().terms) {
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
                                                                          child:
                                                                              RichText(
                                                                            textScaler:
                                                                                MediaQuery.of(context).textScaler,
                                                                            text:
                                                                                TextSpan(
                                                                              children: [
                                                                                TextSpan(
                                                                                  text: 'Es gelten die allgemeinen ',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: valueOrDefault<double>(
                                                                                          -0.24,
                                                                                          -0.24,
                                                                                        ),
                                                                                        fontWeight: FontWeight.w500,
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                      ),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: 'Nutzungsbedingungen',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: valueOrDefault<double>(
                                                                                          -0.24,
                                                                                          -0.24,
                                                                                        ),
                                                                                        fontWeight: FontWeight.bold,
                                                                                        decoration: TextDecoration.underline,
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                      ),
                                                                                  mouseCursor: SystemMouseCursors.click,
                                                                                  recognizer: TapGestureRecognizer()
                                                                                    ..onTap = () async {
                                                                                      unawaited(
                                                                                        () async {
                                                                                          await launchURL(FFAppConstants.terms);
                                                                                        }(),
                                                                                      );
                                                                                    },
                                                                                ),
                                                                                TextSpan(
                                                                                  text: ' und ',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: valueOrDefault<double>(
                                                                                          -0.24,
                                                                                          -0.24,
                                                                                        ),
                                                                                        fontWeight: FontWeight.w500,
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                      ),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: 'Datenschutzbestimmungen des Spendenempfängers Players For Good gGmbH.',
                                                                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: valueOrDefault<double>(
                                                                                          -0.24,
                                                                                          -0.24,
                                                                                        ),
                                                                                        fontWeight: FontWeight.bold,
                                                                                        decoration: TextDecoration.underline,
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                                      ),
                                                                                  mouseCursor: SystemMouseCursors.click,
                                                                                  recognizer: TapGestureRecognizer()
                                                                                    ..onTap = () async {
                                                                                      unawaited(
                                                                                        () async {
                                                                                          await launchURL(FFAppConstants.policy);
                                                                                        }(),
                                                                                      );
                                                                                    },
                                                                                )
                                                                              ],
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    fontSize: 16.0,
                                                                                    letterSpacing: 0.0,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 20.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
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
                                            child: custom_widgets
                                                .Visibilitydetector(
                                              width: 50.0,
                                              height: 50.0,
                                              visibilityThreshold: 0.5,
                                              action:
                                                  (visible, visibility) async {
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
                                    ? MediaQuery.viewInsetsOf(context).bottom >
                                        0
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
                                                  decoration: BoxDecoration(),
                                                  child: Icon(
                                                    FFIcons.kball,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 20.0,
                                                  ),
                                                ),
                                                Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.2,
                                                  height: 1.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                  ),
                                                ),
                                                Container(
                                                  width: 44.0,
                                                  height: 32.0,
                                                  decoration: BoxDecoration(),
                                                  child: Icon(
                                                    FFIcons.kdonate,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 24.0,
                                                  ),
                                                ),
                                                Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.2,
                                                  height: 1.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                  ),
                                                ),
                                                Container(
                                                  width: 44.0,
                                                  height: 32.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .tertiary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            99.0),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      FFIcons.kflash,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      size: 22.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      12.0, 0.0, 4.0, 0.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
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
                                                              valueOrDefault<
                                                                  double>(
                                                            -0.24,
                                                            -0.24,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          lineHeight: 1.5,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
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
                                                              valueOrDefault<
                                                                  double>(
                                                            -0.24,
                                                            -0.24,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          lineHeight: 1.5,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
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
                                                              valueOrDefault<
                                                                  double>(
                                                            -0.24,
                                                            -0.24,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          lineHeight: 1.5,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 12.0, 0.0, 34.0),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          99.0),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    32.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Text(
                                                          '${valueOrDefault<String>(
                                                            functions.numFormat(
                                                                valueOrDefault<
                                                                    String>(
                                                              (_model.gamePage!
                                                                          .userMoney +
                                                                      _model
                                                                          .gamePage!
                                                                          .teamMoney +
                                                                      _model
                                                                          .gamePage!
                                                                          .siegMoney +
                                                                      _model
                                                                          .gamePage!
                                                                          .donatMoney)
                                                                  .toString(),
                                                              '0',
                                                            )),
                                                            '0',
                                                          )} €',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .headlineLarge
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineLargeFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                letterSpacing:
                                                                    valueOrDefault<
                                                                        double>(
                                                                  -1.44,
                                                                  -1.44,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                lineHeight: 1.2,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLargeIsCustom,
                                                              ),
                                                        ),
                                                      ),
                                                      Builder(
                                                        builder: (context) =>
                                                            FFButtonWidget(
                                                          onPressed:
                                                              (_model.paymentType ==
                                                                          null ||
                                                                      _model.paymentType ==
                                                                          '')
                                                                  ? null
                                                                  : () async {
                                                                      if (stackUsersRow!
                                                                          .emails!) {
                                                                        await UsersTable()
                                                                            .update(
                                                                          data: {
                                                                            'emails':
                                                                                false,
                                                                          },
                                                                          matchingRows: (rows) =>
                                                                              rows.eqOrNull(
                                                                            'id',
                                                                            currentUserUid,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        await UsersTable()
                                                                            .update(
                                                                          data: {
                                                                            'emails':
                                                                                true,
                                                                          },
                                                                          matchingRows: (rows) =>
                                                                              rows.eqOrNull(
                                                                            'id',
                                                                            currentUserUid,
                                                                          ),
                                                                        );
                                                                      }

                                                                      FFAppState()
                                                                          .clearUserCache();
                                                                      FFAppState()
                                                                              .refreshDate =
                                                                          getCurrentTimestamp;
                                                                      safeSetState(
                                                                          () {});
                                                                      _model.newGame =
                                                                          await GamesTable()
                                                                              .insert({
                                                                        'created_at':
                                                                            supaSerialize<DateTime>(getCurrentTimestamp),
                                                                        'game_date':
                                                                            supaSerialize<DateTime>(getCurrentTimestamp),
                                                                        'creator_user_id':
                                                                            currentUserUid,
                                                                        'organization_id':
                                                                            stackUsersRow?.chosenOrg,
                                                                        'user_money':
                                                                            valueOrDefault<double>(
                                                                          _model
                                                                              .gamePage
                                                                              ?.userMoney,
                                                                          0.0,
                                                                        ),
                                                                        'user_points':
                                                                            valueOrDefault<double>(
                                                                          _model
                                                                              .gamePage
                                                                              ?.userPoints,
                                                                          0.0,
                                                                        ),
                                                                        'team_money':
                                                                            valueOrDefault<double>(
                                                                          _model
                                                                              .gamePage
                                                                              ?.teamMoney,
                                                                          0.0,
                                                                        ),
                                                                        'team_points':
                                                                            valueOrDefault<double>(
                                                                          _model
                                                                              .gamePage
                                                                              ?.teamPoints,
                                                                          0.0,
                                                                        ),
                                                                        'sieg_money':
                                                                            valueOrDefault<double>(
                                                                          _model
                                                                              .gamePage
                                                                              ?.siegPoints,
                                                                          0.0,
                                                                        ),
                                                                        'sieg_points':
                                                                            valueOrDefault<double>(
                                                                          _model
                                                                              .gamePage
                                                                              ?.siegMoney,
                                                                          0.0,
                                                                        ),
                                                                        'sponsor_money':
                                                                            valueOrDefault<double>(
                                                                          _model
                                                                              .gamePage
                                                                              ?.sponsorMoney,
                                                                          0.0,
                                                                        ),
                                                                        'additional_donation_money':
                                                                            valueOrDefault<double>(
                                                                          _model
                                                                              .gamePage
                                                                              ?.donatMoney,
                                                                          0.0,
                                                                        ),
                                                                        'user_points_to_euro_rate':
                                                                            valueOrDefault<double>(
                                                                          _model
                                                                              .gamePage
                                                                              ?.userMoneyRate,
                                                                          0.0,
                                                                        ),
                                                                        'status':
                                                                            'pending_payment',
                                                                        'team_points_to_euro_rate':
                                                                            valueOrDefault<double>(
                                                                          widget!
                                                                              .game
                                                                              ?.teamMoneyRate,
                                                                          0.0,
                                                                        ),
                                                                        'sieg_points_to_euro_rate':
                                                                            valueOrDefault<double>(
                                                                          widget!
                                                                              .game
                                                                              ?.siegMoneyRate,
                                                                          0.0,
                                                                        ),
                                                                        'sponsor_points_to_euro_rate':
                                                                            0.1,
                                                                        'sponsor_points':
                                                                            valueOrDefault<double>(
                                                                          widget!
                                                                              .game
                                                                              ?.sponsorPoints,
                                                                          0.0,
                                                                        ),
                                                                        'title':
                                                                            valueOrDefault<String>(
                                                                          widget!
                                                                              .game
                                                                              ?.title,
                                                                          'Game #1',
                                                                        ),
                                                                        'lichtwatt':
                                                                            valueOrDefault<double>(
                                                                          (widget!.game!.userMoney + widget!.game!.teamMoney + widget!.game!.siegMoney + widget!.game!.sponsorMoney + _model.gamePage!.donatMoney) *
                                                                              10,
                                                                          0.0,
                                                                        ),
                                                                      });
                                                                      _model.paymentStripe1 = await SupabaseEdgeGroup
                                                                          .createPaymentCheckoutCall
                                                                          .call(
                                                                        userId:
                                                                            currentUserUid,
                                                                        gameId: _model
                                                                            .newGame
                                                                            ?.id,
                                                                        paymentMethod:
                                                                            _model.paymentType,
                                                                        jwt:
                                                                            currentJwtToken,
                                                                        receipt:
                                                                            stackUsersRow?.receipt,
                                                                        test: FFDevEnvironmentValues()
                                                                            .test,
                                                                        firstName: _model
                                                                            .nameTextController1
                                                                            .text,
                                                                        surname: _model
                                                                            .surnameTextController1
                                                                            .text,
                                                                      );

                                                                      if ((_model
                                                                              .paymentStripe1
                                                                              ?.succeeded ??
                                                                          true)) {
                                                                        unawaited(
                                                                          () async {}(),
                                                                        );
                                                                        _model.isPaymentProcessing =
                                                                            true;
                                                                        safeSetState(
                                                                            () {});
                                                                        _model.gameIdFromStripe =
                                                                            await actions.openStripeCheckout(
                                                                          SupabaseEdgeGroup
                                                                              .createPaymentCheckoutCall
                                                                              .url(
                                                                            (_model.paymentStripe1?.jsonBody ??
                                                                                ''),
                                                                          )!,
                                                                        );
                                                                        if (_model.gameIdFromStripe !=
                                                                                null &&
                                                                            _model.gameIdFromStripe !=
                                                                                '') {
                                                                        } else {
                                                                          _model.isPaymentProcessing =
                                                                              false;
                                                                          safeSetState(
                                                                              () {});
                                                                        }
                                                                      } else {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (dialogContext) {
                                                                            return Dialog(
                                                                              elevation: 0,
                                                                              insetPadding: EdgeInsets.zero,
                                                                              backgroundColor: Colors.transparent,
                                                                              alignment: AlignmentDirectional(0.0, 1.0).resolve(Directionality.of(context)),
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  FocusScope.of(dialogContext).unfocus();
                                                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                                                },
                                                                                child: SnackBarWidget(
                                                                                  text: (_model.paymentStripe1?.jsonBody ?? '').toString(),
                                                                                  error: true,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      }

                                                                      await UsersTable()
                                                                          .update(
                                                                        data: {
                                                                          'first_name': _model
                                                                              .nameTextController1
                                                                              .text,
                                                                          'surname': _model
                                                                              .surnameTextController1
                                                                              .text,
                                                                        },
                                                                        matchingRows:
                                                                            (rows) =>
                                                                                rows.eqOrNull(
                                                                          'id',
                                                                          currentUserUid,
                                                                        ),
                                                                      );
                                                                      if (_model
                                                                          .saveMethod) {
                                                                        unawaited(
                                                                          () async {
                                                                            await UsersTable().update(
                                                                              data: {
                                                                                'payment_method': _model.paymentType,
                                                                              },
                                                                              matchingRows: (rows) => rows.eqOrNull(
                                                                                'id',
                                                                                currentUserUid,
                                                                              ),
                                                                            );
                                                                          }(),
                                                                        );
                                                                      }
                                                                      FFAppState()
                                                                              .refreshDate =
                                                                          getCurrentTimestamp;
                                                                      FFAppState()
                                                                              .terms =
                                                                          false;
                                                                      safeSetState(
                                                                          () {});
                                                                      FFAppState()
                                                                          .clearGamesCache();
                                                                      FFAppState()
                                                                          .clearUserCache();
                                                                      FFAppState()
                                                                          .clearOrgPostsCache();
                                                                      FFAppState()
                                                                          .clearUserPostsCacheKey(
                                                                              '${currentUserUid}${FFAppState().refreshDate?.toString()}');

                                                                      safeSetState(
                                                                          () {});
                                                                    },
                                                          text:
                                                              '€nergy senden ',
                                                          options:
                                                              FFButtonOptions(
                                                            height: 40.0,
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
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: Colors
                                                                          .white,
                                                                      letterSpacing:
                                                                          valueOrDefault<
                                                                              double>(
                                                                        -0.4,
                                                                        -0.4,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      lineHeight:
                                                                          1.5,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 0.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
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
                                              : FlutterFlowTheme.of(context)
                                                  .accent3,
                                          FlutterFlowTheme.of(context).accent3,
                                        ),
                                        valueOrDefault<Color>(
                                          _model.visible
                                              ? Colors.transparent
                                              : FlutterFlowTheme.of(context)
                                                  .accent2,
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
                                            borderRadius:
                                                BorderRadius.circular(99.0),
                                          ),
                                          child: FlutterFlowIconButton(
                                            borderColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryBackground,
                                            borderRadius: 99.0,
                                            borderWidth: 1.0,
                                            buttonSize: 40.0,
                                            icon: Icon(
                                              FFIcons.karrowLeftLong,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              size: 24.0,
                                            ),
                                            onPressed: () async {
                                              unawaited(
                                                () async {
                                                  await actions.closeKeyboard(
                                                    context,
                                                  );
                                                }(),
                                              );
                                              await showModalBottomSheet(
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                isDismissible: false,
                                                enableDrag: false,
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
                                                      padding: MediaQuery
                                                          .viewInsetsOf(
                                                              context),
                                                      child:
                                                          OrganisationListPlayWidget(
                                                        userId: stackUsersRow,
                                                        gameDT:
                                                            _model.gamePage!,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ).then((value) =>
                                                  safeSetState(() {}));
                                            },
                                          ),
                                        ),
                                        Container(
                                          width: 56.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(99.0),
                                          ),
                                          child: FlutterFlowIconButton(
                                            borderColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryBackground,
                                            borderRadius: 99.0,
                                            borderWidth: 1.0,
                                            buttonSize: 40.0,
                                            icon: Icon(
                                              FFIcons.kxmark,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              size: 24.0,
                                            ),
                                            onPressed: () async {
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
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                    },
                                                    child: Padding(
                                                      padding: MediaQuery
                                                          .viewInsetsOf(
                                                              context),
                                                      child:
                                                          CancelGameDialogWidget(),
                                                    ),
                                                  );
                                                },
                                              ).then((value) =>
                                                  safeSetState(() {}));
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      width: 4.0,
                                                    ),
                                                  ),
                                                  child: wrapWithModel(
                                                    model: _model.imageModel2,
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
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(16.0, 16.0,
                                                          16.0, 0.0),
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
                                                        isScrollControlled:
                                                            true,
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
                                                                game:
                                                                    GameStruct(
                                                                  title:
                                                                      valueOrDefault<
                                                                          String>(
                                                                    _model.gamePage?.title !=
                                                                                null &&
                                                                            _model.gamePage?.title !=
                                                                                ''
                                                                        ? _model
                                                                            .gamePage
                                                                            ?.title
                                                                        : 'Game #${(1 + 1).toString()}',
                                                                    'Game #1',
                                                                  ),
                                                                ),
                                                                updateTitle:
                                                                    (title) async {
                                                                  _model
                                                                      .updateGamePageStruct(
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
                                                        widget!.game?.title,
                                                        'Game #1',
                                                      ),
                                                      maxLines: 3,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelLarge
                                                              .override(
                                                                fontFamily:
                                                                    'Dela Gothic One',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
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
                                                    style: FlutterFlowTheme.of(
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
                                                              !FlutterFlowTheme
                                                                      .of(context)
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
                                                            (_model.gamePage!
                                                                        .userMoney +
                                                                    _model
                                                                        .gamePage!
                                                                        .teamMoney +
                                                                    _model
                                                                        .gamePage!
                                                                        .siegMoney)
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
                                                                  fontSize:
                                                                      48.0,
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
                                                                  fontSize:
                                                                      24.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                      )
                                                    ],
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                24.0,
                                                                24.0,
                                                                24.0,
                                                                0.0),
                                                    child: Text(
                                                      'Deine €nergy geht an',
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
                                                Builder(
                                                  builder: (context) {
                                                    if (widget!.guestChosenOrgId !=
                                                            null &&
                                                        widget!.guestChosenOrgId !=
                                                            '') {
                                                      return Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    8.0,
                                                                    12.0,
                                                                    0.0),
                                                        child: FutureBuilder<
                                                            List<
                                                                OrganizationRow>>(
                                                          future:
                                                              OrganizationTable()
                                                                  .querySingleRow(
                                                            queryFn: (q) =>
                                                                q.eqOrNull(
                                                              'id',
                                                              widget!
                                                                  .guestChosenOrgId,
                                                            ),
                                                          ),
                                                          builder: (context,
                                                              snapshot) {
                                                            // Customize what your widget looks like when it's loading.
                                                            if (!snapshot
                                                                .hasData) {
                                                              return Center(
                                                                child: SizedBox(
                                                                  width: 20.0,
                                                                  height: 20.0,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    valueColor:
                                                                        AlwaysStoppedAnimation<
                                                                            Color>(
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            List<OrganizationRow>
                                                                containerOrganizationRowList =
                                                                snapshot.data!;

                                                            // Return an empty Container when the item does not exist.
                                                            if (snapshot.data!
                                                                .isEmpty) {
                                                              return Container();
                                                            }
                                                            final containerOrganizationRow =
                                                                containerOrganizationRowList
                                                                        .isNotEmpty
                                                                    ? containerOrganizationRowList
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
                                                                        16.0,
                                                                        20.0,
                                                                        16.0,
                                                                        20.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          8.0,
                                                                          0.0),
                                                                      child:
                                                                          wrapWithModel(
                                                                        model: _model
                                                                            .organisationCompModel2,
                                                                        updateCallback:
                                                                            () =>
                                                                                safeSetState(() {}),
                                                                        updateOnChange:
                                                                            true,
                                                                        child:
                                                                            OrganisationCompWidget(
                                                                          orgRow:
                                                                              containerOrganizationRow!,
                                                                          buttonText:
                                                                              'Im nächsten Game unterstützen',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    } else {
                                                      return wrapWithModel(
                                                        model: _model
                                                            .organizationsHomeEmptyModel2,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        updateOnChange: true,
                                                        child:
                                                            OrganizationsHomeEmptyWidget(
                                                          userId: 'guest',
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(12.0, 36.0,
                                                          12.0, 0.0),
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
                                                          EdgeInsets.all(32.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Text(
                                                              'Dein freiwilliger Beitrag an Players For Good, damit wir ...',
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
                                                                        valueOrDefault<
                                                                            double>(
                                                                      -0.63,
                                                                      -0.63,
                                                                    ),
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
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Text(
                                                              '... diese App weiterentwickeln und noch mehr Menschen dafür begeistern können, beim Sport und Spielen Gutes zu tun.',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    letterSpacing:
                                                                        valueOrDefault<
                                                                            double>(
                                                                      -0.35,
                                                                      -0.35,
                                                                    ),
                                                                    lineHeight:
                                                                        1.5,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            height: 72.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryBackground,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          16.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    '${valueOrDefault<String>(
                                                                      functions.numFormat(_model
                                                                          .gamePage!
                                                                          .donatMoney
                                                                          .toString()),
                                                                      '0',
                                                                    )} €',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).titleSmallFamily,
                                                                          letterSpacing:
                                                                              valueOrDefault<double>(
                                                                            -0.4,
                                                                            -0.4,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          lineHeight:
                                                                              1.5,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                        ),
                                                                  ),
                                                                  FFButtonWidget(
                                                                    onPressed:
                                                                        () async {
                                                                      await showModalBottomSheet(
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
                                                                              child: DonatAddWidget(
                                                                                game: _model.gamePage,
                                                                                update: (donatMoney) async {
                                                                                  _model.updateGamePageStruct(
                                                                                    (e) => e
                                                                                      ..donatMoney = valueOrDefault<double>(
                                                                                        donatMoney,
                                                                                        0.0,
                                                                                      ),
                                                                                  );
                                                                                  safeSetState(() {});
                                                                                },
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ).then((value) =>
                                                                          safeSetState(
                                                                              () {}));
                                                                    },
                                                                    text:
                                                                        'Beitrag anpassen',
                                                                    icon: Icon(
                                                                      FFIcons
                                                                          .krightArrow,
                                                                      size:
                                                                          20.0,
                                                                    ),
                                                                    options:
                                                                        FFButtonOptions(
                                                                      width:
                                                                          180.0,
                                                                      height:
                                                                          40.0,
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                                      iconAlignment:
                                                                          IconAlignment
                                                                              .end,
                                                                      iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .success,
                                                                      textStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).titleSmallFamily,
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                14.0,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.35,
                                                                              -0.35,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                          ),
                                                                      elevation:
                                                                          0.0,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              99.0),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Icon(
                                                                FFIcons
                                                                    .kthumbsUp,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                size: 24.0,
                                                              ),
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          16.0,
                                                                          0.0,
                                                                          16.0),
                                                                  child: Text(
                                                                    'Vielen Dank! Jede Unterstützung zählt!',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).titleSmallFamily,
                                                                          letterSpacing:
                                                                              valueOrDefault<double>(
                                                                            -0.4,
                                                                            -0.4,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          lineHeight:
                                                                              1.5,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ].divide(SizedBox(
                                                                width: 20.0)),
                                                          ),
                                                        ].divide(SizedBox(
                                                            height: 24.0)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
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
                                                      'Zahlungsmethode',
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
                                                                  32.0,
                                                                  24.0,
                                                                  32.0,
                                                                  24.0),
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
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              focusColor: Colors
                                                                  .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                _model.paymentType =
                                                                    PaymentMethods
                                                                        .paypal
                                                                        .name;
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Container(
                                                                    width: 40.0,
                                                                    height:
                                                                        40.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child: Icon(
                                                                      FFIcons
                                                                          .kpaypal,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      size:
                                                                          16.0,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      'PayPal',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).titleSmallFamily,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.4,
                                                                              -0.4,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  Builder(
                                                                    builder:
                                                                        (context) {
                                                                      if (_model
                                                                              .paymentType ==
                                                                          PaymentMethods
                                                                              .paypal
                                                                              .name) {
                                                                        return Container(
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryBackground,
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              width: 7.0,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return Container(
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                                ]
                                                                    .divide(SizedBox(
                                                                        width:
                                                                            16.0))
                                                                    .addToEnd(SizedBox(
                                                                        width:
                                                                            8.0)),
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 1.0,
                                                            thickness: 1.0,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        12.0,
                                                                        0.0,
                                                                        12.0),
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              focusColor: Colors
                                                                  .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                _model.paymentType =
                                                                    PaymentMethods
                                                                        .card
                                                                        .name;
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Container(
                                                                    width: 40.0,
                                                                    height:
                                                                        40.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child: Icon(
                                                                      FFIcons
                                                                          .kcard,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      size:
                                                                          16.0,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      'Card${() {
                                                                        if (isAndroid) {
                                                                          return ' / Google Pay';
                                                                        } else if (isiOS) {
                                                                          return ' / Apple Pay';
                                                                        } else {
                                                                          return ' ';
                                                                        }
                                                                      }()}',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).titleSmallFamily,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.4,
                                                                              -0.4,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  Builder(
                                                                    builder:
                                                                        (context) {
                                                                      if (_model
                                                                              .paymentType ==
                                                                          PaymentMethods
                                                                              .card
                                                                              .name) {
                                                                        return Container(
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryBackground,
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              width: 7.0,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return Container(
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                                ]
                                                                    .divide(SizedBox(
                                                                        width:
                                                                            16.0))
                                                                    .addToEnd(SizedBox(
                                                                        width:
                                                                            8.0)),
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 1.0,
                                                            thickness: 1.0,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        16.0,
                                                                        0.0,
                                                                        16.0),
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              focusColor: Colors
                                                                  .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                _model.saveMethod =
                                                                    !_model
                                                                        .saveMethod;
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Builder(
                                                                    builder:
                                                                        (context) {
                                                                      if (_model
                                                                          .saveMethod) {
                                                                        return Container(
                                                                          width:
                                                                              18.0,
                                                                          height:
                                                                              18.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0),
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              width: 1.0,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              FFIcons.kcheck2,
                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                              size: 12.0,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return Container(
                                                                          width:
                                                                              18.0,
                                                                          height:
                                                                              18.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0),
                                                                            border:
                                                                                Border.all(
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
                                                                      'Als Standardmethode speichern',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.4,
                                                                              -0.4,
                                                                            ),
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        8.0)),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (false)
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
                                                        'Daten zur Spende',
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
                                                if (false)
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(12.0, 8.0,
                                                                12.0, 0.0),
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            32.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16.0),
                                                                border:
                                                                    Border.all(
                                                                  color:
                                                                      valueOrDefault<
                                                                          Color>(
                                                                    () {
                                                                      if (((_model.nameTextController2.text != null && _model.nameTextController2.text != '') &&
                                                                              !functions.validateName(_model
                                                                                  .nameTextController2.text)) ||
                                                                          (_model.nameTextController2.text == null ||
                                                                              _model.nameTextController2.text ==
                                                                                  '')) {
                                                                        return FlutterFlowTheme.of(context)
                                                                            .error;
                                                                      } else if ((_model
                                                                              .nameFocusNode2
                                                                              ?.hasFocus ??
                                                                          false)) {
                                                                        return FlutterFlowTheme.of(context)
                                                                            .focus;
                                                                      } else {
                                                                        return FlutterFlowTheme.of(context)
                                                                            .primaryBackground;
                                                                      }
                                                                    }(),
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                  ),
                                                                  width: 2.0,
                                                                ),
                                                              ),
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                child:
                                                                    TextFormField(
                                                                  controller: _model
                                                                      .nameTextController2,
                                                                  focusNode: _model
                                                                      .nameFocusNode2,
                                                                  onChanged: (_) =>
                                                                      EasyDebounce
                                                                          .debounce(
                                                                    '_model.nameTextController2',
                                                                    Duration(
                                                                        milliseconds:
                                                                            50),
                                                                    () => safeSetState(
                                                                        () {}),
                                                                  ),
                                                                  autofocus:
                                                                      false,
                                                                  textCapitalization:
                                                                      TextCapitalization
                                                                          .words,
                                                                  obscureText:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    isDense:
                                                                        true,
                                                                    labelText:
                                                                        'Vorname*',
                                                                    labelStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).titleSmallFamily,
                                                                          color:
                                                                              valueOrDefault<Color>(
                                                                            _model.nameTextController2.text != null && _model.nameTextController2.text != ''
                                                                                ? FlutterFlowTheme.of(context).secondaryText
                                                                                : FlutterFlowTheme.of(context).secondaryText50,
                                                                            FlutterFlowTheme.of(context).secondaryText50,
                                                                          ),
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              valueOrDefault<double>(
                                                                            -0.4,
                                                                            -0.4,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          lineHeight:
                                                                              1.5,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                        ),
                                                                    hintStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).labelMediumFamily,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText50,
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              valueOrDefault<double>(
                                                                            -0.4,
                                                                            -0.4,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          lineHeight:
                                                                              1.5,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).labelMediumIsCustom,
                                                                        ),
                                                                    enabledBorder:
                                                                        InputBorder
                                                                            .none,
                                                                    focusedBorder:
                                                                        InputBorder
                                                                            .none,
                                                                    errorBorder:
                                                                        InputBorder
                                                                            .none,
                                                                    focusedErrorBorder:
                                                                        InputBorder
                                                                            .none,
                                                                    contentPadding:
                                                                        EdgeInsets.all(
                                                                            16.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            valueOrDefault<double>(
                                                                          -0.4,
                                                                          -0.4,
                                                                        ),
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        lineHeight:
                                                                            1.5,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                  maxLength: 30,
                                                                  maxLengthEnforcement:
                                                                      MaxLengthEnforcement
                                                                          .none,
                                                                  buildCounter: (context,
                                                                          {required currentLength,
                                                                          required isFocused,
                                                                          maxLength}) =>
                                                                      null,
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                  enableInteractiveSelection:
                                                                      true,
                                                                  validator: _model
                                                                      .nameTextController2Validator
                                                                      .asValidator(
                                                                          context),
                                                                  inputFormatters: [
                                                                    if (!isAndroid &&
                                                                        !isiOS)
                                                                      TextInputFormatter.withFunction(
                                                                          (oldValue,
                                                                              newValue) {
                                                                        return TextEditingValue(
                                                                          selection:
                                                                              newValue.selection,
                                                                          text: newValue
                                                                              .text
                                                                              .toCapitalization(TextCapitalization.words),
                                                                        );
                                                                      }),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            if (!functions.validateName(
                                                                    _model
                                                                        .nameTextController2
                                                                        .text) &&
                                                                (_model.nameTextController2
                                                                            .text !=
                                                                        null &&
                                                                    _model.nameTextController2
                                                                            .text !=
                                                                        ''))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        -1.0,
                                                                        0.0),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          4.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      AutoSizeText(
                                                                    'Gültigen Vornamen eingeben',
                                                                    maxLines: 1,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).titleSmallFamily,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).error,
                                                                          fontSize:
                                                                              14.0,
                                                                          letterSpacing:
                                                                              valueOrDefault<double>(
                                                                            -0.35,
                                                                            -0.35,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          lineHeight:
                                                                              1.5,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          24.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16.0),
                                                                  border: Border
                                                                      .all(
                                                                    color: valueOrDefault<
                                                                        Color>(
                                                                      () {
                                                                        if (((_model.surnameTextController2.text != null && _model.surnameTextController2.text != '') && !functions.validateName(_model.surnameTextController2.text)) ||
                                                                            (_model.surnameTextController2.text == null ||
                                                                                _model.surnameTextController2.text ==
                                                                                    '')) {
                                                                          return FlutterFlowTheme.of(context)
                                                                              .error;
                                                                        } else if ((_model.surnameFocusNode2?.hasFocus ??
                                                                            false)) {
                                                                          return FlutterFlowTheme.of(context)
                                                                              .focus;
                                                                        } else {
                                                                          return FlutterFlowTheme.of(context)
                                                                              .primaryBackground;
                                                                        }
                                                                      }(),
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                    ),
                                                                    width: 2.0,
                                                                  ),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _model
                                                                            .surnameTextController2,
                                                                    focusNode:
                                                                        _model
                                                                            .surnameFocusNode2,
                                                                    onChanged: (_) =>
                                                                        EasyDebounce
                                                                            .debounce(
                                                                      '_model.surnameTextController2',
                                                                      Duration(
                                                                          milliseconds:
                                                                              50),
                                                                      () => safeSetState(
                                                                          () {}),
                                                                    ),
                                                                    autofocus:
                                                                        false,
                                                                    textCapitalization:
                                                                        TextCapitalization
                                                                            .words,
                                                                    obscureText:
                                                                        false,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      isDense:
                                                                          true,
                                                                      labelText:
                                                                          'Nachname*',
                                                                      labelStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).titleSmallFamily,
                                                                            color:
                                                                                valueOrDefault<Color>(
                                                                              _model.surnameTextController2.text != null && _model.surnameTextController2.text != '' ? FlutterFlowTheme.of(context).secondaryText : FlutterFlowTheme.of(context).secondaryText50,
                                                                              FlutterFlowTheme.of(context).secondaryText50,
                                                                            ),
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.4,
                                                                              -0.4,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                          ),
                                                                      hintStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).labelMediumFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText50,
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.4,
                                                                              -0.4,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).labelMediumIsCustom,
                                                                          ),
                                                                      enabledBorder:
                                                                          InputBorder
                                                                              .none,
                                                                      focusedBorder:
                                                                          InputBorder
                                                                              .none,
                                                                      errorBorder:
                                                                          InputBorder
                                                                              .none,
                                                                      focusedErrorBorder:
                                                                          InputBorder
                                                                              .none,
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              16.0),
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              valueOrDefault<double>(
                                                                            -0.4,
                                                                            -0.4,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          lineHeight:
                                                                              1.5,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                    maxLength:
                                                                        30,
                                                                    maxLengthEnforcement:
                                                                        MaxLengthEnforcement
                                                                            .none,
                                                                    buildCounter: (context,
                                                                            {required currentLength,
                                                                            required isFocused,
                                                                            maxLength}) =>
                                                                        null,
                                                                    cursorColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    enableInteractiveSelection:
                                                                        true,
                                                                    validator: _model
                                                                        .surnameTextController2Validator
                                                                        .asValidator(
                                                                            context),
                                                                    inputFormatters: [
                                                                      if (!isAndroid &&
                                                                          !isiOS)
                                                                        TextInputFormatter.withFunction((oldValue,
                                                                            newValue) {
                                                                          return TextEditingValue(
                                                                            selection:
                                                                                newValue.selection,
                                                                            text:
                                                                                newValue.text.toCapitalization(TextCapitalization.words),
                                                                          );
                                                                        }),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            if (!functions.validateName(
                                                                    _model
                                                                        .surnameTextController2
                                                                        .text) &&
                                                                (_model.surnameTextController2
                                                                            .text !=
                                                                        null &&
                                                                    _model.surnameTextController2
                                                                            .text !=
                                                                        ''))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        -1.0,
                                                                        0.0),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          4.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      AutoSizeText(
                                                                    'Gültigen Nachname eingeben',
                                                                    maxLines: 1,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).titleSmallFamily,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).error,
                                                                          fontSize:
                                                                              14.0,
                                                                          letterSpacing:
                                                                              valueOrDefault<double>(
                                                                            -0.35,
                                                                            -0.35,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          lineHeight:
                                                                              1.5,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          24.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16.0),
                                                                  border: Border
                                                                      .all(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .alternate,
                                                                    width: 2.0,
                                                                  ),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _model
                                                                            .emailLoginTextController2,
                                                                    focusNode:
                                                                        _model
                                                                            .emailLoginFocusNode2,
                                                                    onChanged: (_) =>
                                                                        EasyDebounce
                                                                            .debounce(
                                                                      '_model.emailLoginTextController2',
                                                                      Duration(
                                                                          milliseconds:
                                                                              50),
                                                                      () => safeSetState(
                                                                          () {}),
                                                                    ),
                                                                    autofocus:
                                                                        false,
                                                                    textCapitalization:
                                                                        TextCapitalization
                                                                            .none,
                                                                    readOnly:
                                                                        true,
                                                                    obscureText:
                                                                        false,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      isDense:
                                                                          true,
                                                                      labelText:
                                                                          'Deine E-Mail-Adresse*',
                                                                      labelStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).titleSmallFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText,
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.4,
                                                                              -0.4,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                          ),
                                                                      hintStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).labelMediumFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText50,
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.4,
                                                                              -0.4,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).labelMediumIsCustom,
                                                                          ),
                                                                      enabledBorder:
                                                                          InputBorder
                                                                              .none,
                                                                      focusedBorder:
                                                                          InputBorder
                                                                              .none,
                                                                      errorBorder:
                                                                          InputBorder
                                                                              .none,
                                                                      focusedErrorBorder:
                                                                          InputBorder
                                                                              .none,
                                                                      contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          16.0,
                                                                          48.0,
                                                                          16.0),
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText50,
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              valueOrDefault<double>(
                                                                            -0.4,
                                                                            -0.4,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          lineHeight:
                                                                              1.5,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                    maxLength:
                                                                        50,
                                                                    maxLengthEnforcement:
                                                                        MaxLengthEnforcement
                                                                            .none,
                                                                    buildCounter: (context,
                                                                            {required currentLength,
                                                                            required isFocused,
                                                                            maxLength}) =>
                                                                        null,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .emailAddress,
                                                                    cursorColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    enableInteractiveSelection:
                                                                        true,
                                                                    validator: _model
                                                                        .emailLoginTextController2Validator
                                                                        .asValidator(
                                                                            context),
                                                                    inputFormatters: [
                                                                      if (!isAndroid &&
                                                                          !isiOS)
                                                                        TextInputFormatter.withFunction((oldValue,
                                                                            newValue) {
                                                                          return TextEditingValue(
                                                                            selection:
                                                                                newValue.selection,
                                                                            text:
                                                                                newValue.text.toCapitalization(TextCapitalization.none),
                                                                          );
                                                                        }),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (false)
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            -1.0, 0.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  24.0,
                                                                  8.0,
                                                                  24.0,
                                                                  0.0),
                                                      child: Text(
                                                        '*Mit einem Sternchen (*) gekennzeichnete Felder sind Pflichtfelder',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              fontSize: 12.0,
                                                              letterSpacing:
                                                                  valueOrDefault<
                                                                      double>(
                                                                -0.24,
                                                                -0.24,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              lineHeight: 1.5,
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
                                                      .fromSTEB(12.0, 32.0,
                                                          12.0, 0.0),
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
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  32.0,
                                                                  24.0,
                                                                  32.0,
                                                                  24.0),
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
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              focusColor: Colors
                                                                  .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                _model.guestReceiptCheckbox =
                                                                    !_model
                                                                        .guestReceiptCheckbox;
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  if (false)
                                                                    Builder(
                                                                      builder:
                                                                          (context) {
                                                                        if (_model
                                                                            .guestReceiptCheckbox) {
                                                                          return Container(
                                                                            width:
                                                                                18.0,
                                                                            height:
                                                                                18.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              borderRadius: BorderRadius.circular(4.0),
                                                                              border: Border.all(
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                width: 1.0,
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Align(
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
                                                                            width:
                                                                                18.0,
                                                                            height:
                                                                                18.0,
                                                                            decoration:
                                                                                BoxDecoration(
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
                                                                    child:
                                                                        RichText(
                                                                      textScaler:
                                                                          MediaQuery.of(context)
                                                                              .textScaler,
                                                                      text:
                                                                          TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                'Ja, ich möchte immer eine ',
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: valueOrDefault<double>(
                                                                                    -0.24,
                                                                                    -0.24,
                                                                                  ),
                                                                                  fontWeight: FontWeight.w500,
                                                                                  lineHeight: 1.5,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                'Spendenbetscheinigung erhalten',
                                                                            style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: valueOrDefault<double>(
                                                                                    -0.24,
                                                                                    -0.24,
                                                                                  ),
                                                                                  fontWeight: FontWeight.w500,
                                                                                  lineHeight: 1.5,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                ', um meine €nergy-Spenden von der Steuer abzusetzen.',
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: valueOrDefault<double>(
                                                                                    -0.24,
                                                                                    -0.24,
                                                                                  ),
                                                                                  fontWeight: FontWeight.w500,
                                                                                  lineHeight: 1.5,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                ),
                                                                          )
                                                                        ],
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        0.0)),
                                                              ),
                                                            ),
                                                          ),
                                                          if (false)
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          12.0,
                                                                          0.0,
                                                                          12.0),
                                                              child: InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                focusColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap:
                                                                    () async {
                                                                  FFAppState()
                                                                      .clearUserCache();
                                                                  FFAppState()
                                                                          .refreshDate =
                                                                      getCurrentTimestamp;
                                                                  safeSetState(
                                                                      () {});
                                                                },
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Builder(
                                                                      builder:
                                                                          (context) {
                                                                        if (false) {
                                                                          return Container(
                                                                            width:
                                                                                18.0,
                                                                            height:
                                                                                18.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              borderRadius: BorderRadius.circular(4.0),
                                                                              border: Border.all(
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                width: 1.0,
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Align(
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
                                                                            width:
                                                                                18.0,
                                                                            height:
                                                                                18.0,
                                                                            decoration:
                                                                                BoxDecoration(
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
                                                                      child:
                                                                          RichText(
                                                                        textScaler:
                                                                            MediaQuery.of(context).textScaler,
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: 'Ich will per E-Mail von der Wirkung meiner Spenden und spannenden Aktionen erfahren. Hierfür stimme ich der ',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                      -0.24,
                                                                                      -0.24,
                                                                                    ),
                                                                                    fontWeight: FontWeight.w500,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: 'Datenverarbeitung',
                                                                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                      -0.24,
                                                                                      -0.24,
                                                                                    ),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    decoration: TextDecoration.underline,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                  ),
                                                                              mouseCursor: SystemMouseCursors.click,
                                                                              recognizer: TapGestureRecognizer()
                                                                                ..onTap = () async {
                                                                                  unawaited(
                                                                                    () async {
                                                                                      await launchURL(FFAppConstants.policy2);
                                                                                    }(),
                                                                                  );
                                                                                },
                                                                            ),
                                                                            TextSpan(
                                                                              text: ' zu. Abmeldung jederzeit möglich',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                      -0.24,
                                                                                      -0.24,
                                                                                    ),
                                                                                    fontWeight: FontWeight.w500,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            )
                                                                          ],
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                lineHeight: 1.5,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          20.0)),
                                                                ),
                                                              ),
                                                            ),
                                                          if (false)
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          12.0,
                                                                          0.0,
                                                                          12.0),
                                                              child: InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                focusColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap:
                                                                    () async {
                                                                  FFAppState()
                                                                          .terms =
                                                                      !(FFAppState()
                                                                              .terms ??
                                                                          true);
                                                                  safeSetState(
                                                                      () {});
                                                                },
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Builder(
                                                                      builder:
                                                                          (context) {
                                                                        if (FFAppState()
                                                                            .terms) {
                                                                          return Container(
                                                                            width:
                                                                                18.0,
                                                                            height:
                                                                                18.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              borderRadius: BorderRadius.circular(4.0),
                                                                              border: Border.all(
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                width: 1.0,
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Align(
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
                                                                            width:
                                                                                18.0,
                                                                            height:
                                                                                18.0,
                                                                            decoration:
                                                                                BoxDecoration(
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
                                                                      child:
                                                                          RichText(
                                                                        textScaler:
                                                                            MediaQuery.of(context).textScaler,
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: 'Es gelten die allgemeinen ',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                      -0.24,
                                                                                      -0.24,
                                                                                    ),
                                                                                    fontWeight: FontWeight.w500,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: 'Nutzungsbedingungen',
                                                                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                      -0.24,
                                                                                      -0.24,
                                                                                    ),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    decoration: TextDecoration.underline,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                  ),
                                                                              mouseCursor: SystemMouseCursors.click,
                                                                              recognizer: TapGestureRecognizer()
                                                                                ..onTap = () async {
                                                                                  unawaited(
                                                                                    () async {
                                                                                      await launchURL(FFAppConstants.terms);
                                                                                    }(),
                                                                                  );
                                                                                },
                                                                            ),
                                                                            TextSpan(
                                                                              text: ' und ',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                      -0.24,
                                                                                      -0.24,
                                                                                    ),
                                                                                    fontWeight: FontWeight.w500,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: 'Datenschutzbestimmungen des Spendenempfängers Players For Good gGmbH.',
                                                                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                      -0.24,
                                                                                      -0.24,
                                                                                    ),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    decoration: TextDecoration.underline,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                                  ),
                                                                              mouseCursor: SystemMouseCursors.click,
                                                                              recognizer: TapGestureRecognizer()
                                                                                ..onTap = () async {
                                                                                  unawaited(
                                                                                    () async {
                                                                                      await launchURL(FFAppConstants.policy);
                                                                                    }(),
                                                                                  );
                                                                                },
                                                                            )
                                                                          ],
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                lineHeight: 1.5,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          20.0)),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
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
                                        child:
                                            custom_widgets.Visibilitydetector(
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
                                              decoration: BoxDecoration(),
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
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .tertiary,
                                                borderRadius:
                                                    BorderRadius.circular(99.0),
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  FFIcons.kflash,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 22.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 0.0, 4.0, 0.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                'Game',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
                                                          fontSize: 12.0,
                                                          letterSpacing:
                                                              valueOrDefault<
                                                                  double>(
                                                            -0.24,
                                                            -0.24,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          lineHeight: 1.5,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                              ),
                                              Text(
                                                'Organisation',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
                                                          fontSize: 12.0,
                                                          letterSpacing:
                                                              valueOrDefault<
                                                                  double>(
                                                            -0.24,
                                                            -0.24,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          lineHeight: 1.5,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                              ),
                                              Text(
                                                'Zahlung',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
                                                          fontSize: 12.0,
                                                          letterSpacing:
                                                              valueOrDefault<
                                                                  double>(
                                                            -0.24,
                                                            -0.24,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          lineHeight: 1.5,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 12.0, 0.0, 34.0),
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(32.0, 0.0,
                                                                0.0, 0.0),
                                                    child: Text(
                                                      '${valueOrDefault<String>(
                                                        functions.numFormat(
                                                            valueOrDefault<
                                                                String>(
                                                          (_model.gamePage!
                                                                      .userMoney +
                                                                  _model
                                                                      .gamePage!
                                                                      .teamMoney +
                                                                  _model
                                                                      .gamePage!
                                                                      .siegMoney +
                                                                  _model
                                                                      .gamePage!
                                                                      .donatMoney)
                                                              .toString(),
                                                          '0',
                                                        )),
                                                        '0',
                                                      )} €',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .headlineLarge
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineLargeFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                letterSpacing:
                                                                    valueOrDefault<
                                                                        double>(
                                                                  -1.44,
                                                                  -1.44,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                lineHeight: 1.2,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLargeIsCustom,
                                                              ),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: (_model
                                                                    .paymentType ==
                                                                null ||
                                                            _model.paymentType ==
                                                                '')
                                                        ? null
                                                        : () async {
                                                            await showModalBottomSheet(
                                                              isScrollControlled:
                                                                  true,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              barrierColor: Color(
                                                                  0x66000000),
                                                              context: context,
                                                              builder:
                                                                  (context) {
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
                                                                  child:
                                                                      Padding(
                                                                    padding: MediaQuery
                                                                        .viewInsetsOf(
                                                                            context),
                                                                    child:
                                                                        AuthDialogWidget(),
                                                                  ),
                                                                );
                                                              },
                                                            ).then((value) =>
                                                                safeSetState(() =>
                                                                    _model.success =
                                                                        value));

                                                            if (_model
                                                                .success!) {
                                                              _model.userRows =
                                                                  await UsersTable()
                                                                      .queryRows(
                                                                queryFn: (q) =>
                                                                    q.eqOrNull(
                                                                  'id',
                                                                  currentUserUid,
                                                                ),
                                                              );
                                                              if (_model
                                                                      .userRows
                                                                      ?.firstOrNull
                                                                      ?.chosenOrg ==
                                                                  widget!
                                                                      .guestChosenOrgId) {
                                                                await UsersTable()
                                                                    .update(
                                                                  data: {
                                                                    'chosen_org':
                                                                        '',
                                                                  },
                                                                  matchingRows:
                                                                      (rows) =>
                                                                          rows.eqOrNull(
                                                                    'id',
                                                                    currentUserUid,
                                                                  ),
                                                                );
                                                                FFAppState()
                                                                        .refreshDate =
                                                                    getCurrentTimestamp;
                                                                FFAppState()
                                                                    .update(
                                                                        () {});
                                                                FFAppState()
                                                                    .clearUserCache();
                                                              } else {
                                                                await UsersTable()
                                                                    .update(
                                                                  data: {
                                                                    'chosen_org':
                                                                        widget!
                                                                            .guestChosenOrgId,
                                                                  },
                                                                  matchingRows:
                                                                      (rows) =>
                                                                          rows.eqOrNull(
                                                                    'id',
                                                                    currentUserUid,
                                                                  ),
                                                                );
                                                                FFAppState()
                                                                        .refreshDate =
                                                                    getCurrentTimestamp;
                                                                FFAppState()
                                                                    .update(
                                                                        () {});
                                                                FFAppState()
                                                                    .clearUserCache();
                                                              }

                                                              unawaited(
                                                                () async {
                                                                  await actions
                                                                      .closeKeyboard(
                                                                    context,
                                                                  );
                                                                }(),
                                                              );
                                                            }

                                                            safeSetState(() {});
                                                          },
                                                    text: 'Weiter',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
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
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    valueOrDefault<
                                                                        double>(
                                                                  -0.4,
                                                                  -0.4,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                lineHeight: 1.5,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
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
                                          : FlutterFlowTheme.of(context)
                                              .accent3,
                                      FlutterFlowTheme.of(context).accent3,
                                    ),
                                    valueOrDefault<Color>(
                                      _model.visible
                                          ? Colors.transparent
                                          : FlutterFlowTheme.of(context)
                                              .accent2,
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
                                        borderRadius:
                                            BorderRadius.circular(99.0),
                                      ),
                                      child: FlutterFlowIconButton(
                                        borderColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                        borderRadius: 99.0,
                                        borderWidth: 1.0,
                                        buttonSize: 40.0,
                                        icon: Icon(
                                          FFIcons.karrowLeftLong,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          size: 24.0,
                                        ),
                                        onPressed: () async {
                                          unawaited(
                                            () async {
                                              await actions.closeKeyboard(
                                                context,
                                              );
                                            }(),
                                          );
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            isDismissible: false,
                                            enableDrag: false,
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
                                                      OrganisationListPlayWidget(
                                                    userId: widget!.user,
                                                    gameDT: _model.gamePage!,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: 56.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(99.0),
                                      ),
                                      child: FlutterFlowIconButton(
                                        borderColor:
                                            FlutterFlowTheme.of(context)
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
                  );
                } else {
                  return Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Container(
                      width: 120.0,
                      height: 120.0,
                      child: custom_widgets.CustomCircularProgressIndicator(
                        width: 120.0,
                        height: 120.0,
                        color: FlutterFlowTheme.of(context).primary,
                        strokeWidth: 12.0,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ));
  }
}
