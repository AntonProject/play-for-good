import '/auth/supabase_auth/auth_util.dart';
import '/components/dialogs/snack_bar/snack_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'Login';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      setDarkModeSetting(context, ThemeMode.light);
      await actions.setStatusBarColor(
        true,
      );
      GoRouter.of(context).prepareAuthEvent();
      await authManager.signOut();
      GoRouter.of(context).clearRedirectLocation();

      if (isWeb) {
        if (kDebugMode) {
        } else {
          context.goNamedAuth(
            LoginAdminWidget.routeName,
            context.mounted,
            extra: <String, dynamic>{
              '__transition_info__': TransitionInfo(
                hasTransition: true,
                transitionType: PageTransitionType.fade,
                duration: Duration(milliseconds: 0),
              ),
            },
          );

          return;
        }
      }
      if (FFAppState().firstOpen) {
        _model.tab = 2;
        safeSetState(() {});
      } else {
        _model.tab = 1;
        safeSetState(() {});
      }
    });

    _model.nameTextController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();
    _model.nameFocusNode!.addListener(() => safeSetState(() {}));
    _model.displayNameTextController ??= TextEditingController();
    _model.displayNameFocusNode ??= FocusNode();
    _model.displayNameFocusNode!.addListener(() => safeSetState(() {}));
    _model.emailSigninTextController ??= TextEditingController();
    _model.emailSigninFocusNode ??= FocusNode();
    _model.emailSigninFocusNode!.addListener(() => safeSetState(() {}));
    _model.passSigninTextController ??= TextEditingController();
    _model.passSigninFocusNode ??= FocusNode();
    _model.passSigninFocusNode!.addListener(() => safeSetState(() {}));
    _model.emailLoginTextController ??=
        TextEditingController(text: FFAppState().email);
    _model.emailLoginFocusNode ??= FocusNode();
    _model.emailLoginFocusNode!.addListener(() => safeSetState(() {}));
    _model.passLoginTextController ??= TextEditingController();
    _model.passLoginFocusNode ??= FocusNode();
    _model.passLoginFocusNode!.addListener(() => safeSetState(() {}));
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
        title: 'Login',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              top: true,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 24.0, 12.0, 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional(0.0, -1.0),
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxWidth: 600.0,
                          ),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 12.0),
                                  child: Container(
                                    height: 48.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(32.0),
                                      border: Border.all(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: FFButtonWidget(
                                              onPressed: () async {
                                                _model.tab = 1;
                                                safeSetState(() {});
                                              },
                                              text: 'Anmelden',
                                              options: FFButtonOptions(
                                                height: 40.0,
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        16.0, 0.0, 16.0, 0.0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                color: valueOrDefault<Color>(
                                                  _model.tab == 1
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .secondary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primaryBackground,
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                                ),
                                                textStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .titleSmall
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmallFamily,
                                                      color:
                                                          valueOrDefault<Color>(
                                                        _model.tab == 1
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground
                                                            : FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryBackground,
                                                      ),
                                                      fontSize: 14.0,
                                                      letterSpacing:
                                                          valueOrDefault<
                                                              double>(
                                                        -0.35,
                                                        -0.35,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                _model.tab = 2;
                                                safeSetState(() {});
                                              },
                                              text: 'Registrieren',
                                              options: FFButtonOptions(
                                                height: 40.0,
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        16.0, 0.0, 16.0, 0.0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                color: valueOrDefault<Color>(
                                                  _model.tab == 1
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primaryBackground
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                                ),
                                                textStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .titleSmall
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmallFamily,
                                                      color:
                                                          valueOrDefault<Color>(
                                                        _model.tab == 1
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText
                                                            : FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                      ),
                                                      fontSize: 14.0,
                                                      letterSpacing:
                                                          valueOrDefault<
                                                              double>(
                                                        -0.35,
                                                        -0.35,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                        ].divide(SizedBox(width: 4.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Builder(
                                    builder: (context) {
                                      if (_model.tab == 2) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 24.0, 0.0, 0.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: AutoSizeText(
                                                      'Registrierung',
                                                      maxLines: 1,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Dela Gothic One',
                                                                fontSize: 32.0,
                                                                letterSpacing:
                                                                    valueOrDefault<
                                                                        double>(
                                                                  -1.44,
                                                                  -1.44,
                                                                ),
                                                                lineHeight: 1.2,
                                                              ),
                                                    ),
                                                  ),
                                                  Icon(
                                                    FFIcons.klogoMini2,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    size: 40.0,
                                                  ),
                                                ].divide(SizedBox(width: 12.0)),
                                              ),
                                            ),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                controller:
                                                    _model.columnController1,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  24.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Container(
                                                        constraints:
                                                            BoxConstraints(
                                                          minHeight: 56.0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      16.0),
                                                          border: Border.all(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (!valueOrDefault<
                                                                        bool>(
                                                                      functions.validateName(_model
                                                                          .nameTextController
                                                                          .text),
                                                                      false,
                                                                    ) &&
                                                                    valueOrDefault<
                                                                        bool>(
                                                                      _model.nameTextController.text !=
                                                                              null &&
                                                                          _model.nameTextController.text !=
                                                                              '',
                                                                      false,
                                                                    )) {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if ((_model
                                                                        .nameFocusNode
                                                                        ?.hasFocus ??
                                                                    false)) {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .focus;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
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
                                                          width:
                                                              double.infinity,
                                                          child: TextFormField(
                                                            controller: _model
                                                                .nameTextController,
                                                            focusNode: _model
                                                                .nameFocusNode,
                                                            onChanged: (_) =>
                                                                EasyDebounce
                                                                    .debounce(
                                                              '_model.nameTextController',
                                                              Duration(
                                                                  milliseconds:
                                                                      50),
                                                              () =>
                                                                  safeSetState(
                                                                      () {}),
                                                            ),
                                                            onFieldSubmitted:
                                                                (_) async {
                                                              if (functions
                                                                  .validateName(_model
                                                                      .nameTextController
                                                                      .text)) {
                                                                _model.error =
                                                                    'error';
                                                                safeSetState(
                                                                    () {});
                                                              } else {
                                                                _model.error =
                                                                    'name_error';
                                                                safeSetState(
                                                                    () {});
                                                              }
                                                            },
                                                            autofocus: false,
                                                            textCapitalization:
                                                                TextCapitalization
                                                                    .words,
                                                            obscureText: false,
                                                            decoration:
                                                                InputDecoration(
                                                              isDense: true,
                                                              labelText:
                                                                  'Dein Vorname',
                                                              labelStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleSmallFamily,
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          _model.nameTextController.text != null && _model.nameTextController.text != ''
                                                                              ? FlutterFlowTheme.of(context).secondaryText
                                                                              : FlutterFlowTheme.of(context).secondaryText50,
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondaryText50,
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
                                                              hintStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).labelMediumFamily,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText50,
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
                                                                  EdgeInsets
                                                                      .all(
                                                                          16.0),
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      valueOrDefault<
                                                                          double>(
                                                                    -0.4,
                                                                    -0.4,
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
                                                                .nameTextControllerValidator
                                                                .asValidator(
                                                                    context),
                                                            inputFormatters: [
                                                              if (!isAndroid &&
                                                                  !isiOS)
                                                                TextInputFormatter
                                                                    .withFunction(
                                                                        (oldValue,
                                                                            newValue) {
                                                                  return TextEditingValue(
                                                                    selection:
                                                                        newValue
                                                                            .selection,
                                                                    text: newValue
                                                                        .text
                                                                        .toCapitalization(
                                                                            TextCapitalization.words),
                                                                  );
                                                                }),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if (!functions.validateName(
                                                            _model
                                                                .nameTextController
                                                                .text) &&
                                                        (_model.nameTextController
                                                                    .text !=
                                                                null &&
                                                            _model.nameTextController
                                                                    .text !=
                                                                ''))
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      4.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: AutoSizeText(
                                                            'Gültigen Vornamen eingeben',
                                                            maxLines: 1,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  fontSize:
                                                                      14.0,
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
                                                                          .titleSmallIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (_model.nameTextController
                                                                .text ==
                                                            null ||
                                                        _model.nameTextController
                                                                .text ==
                                                            '')
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      4.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Text(
                                                            'Nicht öffentlich sichtbar',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  fontSize:
                                                                      14.0,
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
                                                                  24.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Container(
                                                        constraints:
                                                            BoxConstraints(
                                                          minHeight: 56.0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      16.0),
                                                          border: Border.all(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (!valueOrDefault<
                                                                        bool>(
                                                                      functions.validateHandle(_model
                                                                          .displayNameTextController
                                                                          .text),
                                                                      false,
                                                                    ) &&
                                                                    valueOrDefault<
                                                                        bool>(
                                                                      _model.displayNameTextController.text !=
                                                                              null &&
                                                                          _model.displayNameTextController.text !=
                                                                              '',
                                                                      false,
                                                                    )) {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if ((_model
                                                                        .displayNameFocusNode
                                                                        ?.hasFocus ??
                                                                    false)) {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .focus;
                                                                } else if (_model
                                                                        .error ==
                                                                    'name_exists') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else {
                                                                  return Colors
                                                                      .transparent;
                                                                }
                                                              }(),
                                                              Colors
                                                                  .transparent,
                                                            ),
                                                            width: 2.0,
                                                          ),
                                                        ),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          child: TextFormField(
                                                            controller: _model
                                                                .displayNameTextController,
                                                            focusNode: _model
                                                                .displayNameFocusNode,
                                                            onChanged: (_) =>
                                                                EasyDebounce
                                                                    .debounce(
                                                              '_model.displayNameTextController',
                                                              Duration(
                                                                  milliseconds:
                                                                      50),
                                                              () async {
                                                                _model.error =
                                                                    'error';
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                            ),
                                                            onFieldSubmitted:
                                                                (_) async {
                                                              if (functions
                                                                  .validateHandle(_model
                                                                      .displayNameTextController
                                                                      .text)) {
                                                                _model.error =
                                                                    'error';
                                                                safeSetState(
                                                                    () {});
                                                              } else {
                                                                _model.error =
                                                                    'handle_error';
                                                                safeSetState(
                                                                    () {});
                                                              }
                                                            },
                                                            autofocus: false,
                                                            textCapitalization:
                                                                TextCapitalization
                                                                    .none,
                                                            obscureText: false,
                                                            decoration:
                                                                InputDecoration(
                                                              isDense: true,
                                                              labelText:
                                                                  'Dein @Benutzername',
                                                              labelStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleSmallFamily,
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          _model.displayNameTextController.text != null && _model.displayNameTextController.text != ''
                                                                              ? FlutterFlowTheme.of(context).secondaryText
                                                                              : FlutterFlowTheme.of(context).secondaryText50,
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondaryText50,
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
                                                              hintStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).labelMediumFamily,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText50,
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
                                                                  EdgeInsets
                                                                      .all(
                                                                          16.0),
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      valueOrDefault<
                                                                          double>(
                                                                    -0.4,
                                                                    -0.4,
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
                                                            maxLength: 50,
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
                                                                .displayNameTextControllerValidator
                                                                .asValidator(
                                                                    context),
                                                            inputFormatters: [
                                                              if (!isAndroid &&
                                                                  !isiOS)
                                                                TextInputFormatter
                                                                    .withFunction(
                                                                        (oldValue,
                                                                            newValue) {
                                                                  return TextEditingValue(
                                                                    selection:
                                                                        newValue
                                                                            .selection,
                                                                    text: newValue
                                                                        .text
                                                                        .toCapitalization(
                                                                            TextCapitalization.none),
                                                                  );
                                                                }),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if ((_model.error ==
                                                            'name_exists') &&
                                                        (_model.displayNameTextController
                                                                    .text !=
                                                                null &&
                                                            _model.displayNameTextController
                                                                    .text !=
                                                                ''))
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      4.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: AutoSizeText(
                                                            'Existiert bereits.',
                                                            maxLines: 1,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  fontSize:
                                                                      14.0,
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
                                                                          .titleSmallIsCustom,
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
                                                                    16.0,
                                                                    4.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: AutoSizeText(
                                                          'Maximal 20 Zeichen. Erlaubte Zeichen: Buchstaben (a–z), Ziffern (0–9), Punkte (.) und Unterstriche (_)',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: !valueOrDefault<
                                                                            bool>(
                                                                          functions.validateHandle(_model
                                                                              .displayNameTextController
                                                                              .text),
                                                                          false,
                                                                        ) &&
                                                                        valueOrDefault<
                                                                            bool>(
                                                                          _model.displayNameTextController.text != null &&
                                                                              _model.displayNameTextController.text != '',
                                                                          false,
                                                                        )
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .error
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                fontSize: 14.0,
                                                                letterSpacing:
                                                                    valueOrDefault<
                                                                        double>(
                                                                  -0.35,
                                                                  -0.35,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                lineHeight: 1.5,
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
                                                                  24.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Container(
                                                        constraints:
                                                            BoxConstraints(
                                                          minHeight: 56.0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      16.0),
                                                          border: Border.all(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (!valueOrDefault<
                                                                        bool>(
                                                                      functions.validateEmail(_model
                                                                          .emailSigninTextController
                                                                          .text),
                                                                      false,
                                                                    ) &&
                                                                    valueOrDefault<
                                                                        bool>(
                                                                      _model.emailSigninTextController.text !=
                                                                              null &&
                                                                          _model.emailSigninTextController.text !=
                                                                              '',
                                                                      false,
                                                                    )) {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .error ==
                                                                    'email_exists') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if ((_model
                                                                        .emailSigninFocusNode
                                                                        ?.hasFocus ??
                                                                    false)) {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .focus;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
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
                                                        child: Stack(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.9, 0.0),
                                                          children: [
                                                            Icon(
                                                              FFIcons.kmail,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 24.0,
                                                            ),
                                                            Container(
                                                              width: double
                                                                  .infinity,
                                                              child:
                                                                  TextFormField(
                                                                controller: _model
                                                                    .emailSigninTextController,
                                                                focusNode: _model
                                                                    .emailSigninFocusNode,
                                                                onChanged: (_) =>
                                                                    EasyDebounce
                                                                        .debounce(
                                                                  '_model.emailSigninTextController',
                                                                  Duration(
                                                                      milliseconds:
                                                                          50),
                                                                  () async {
                                                                    _model.error =
                                                                        'error';
                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                ),
                                                                onFieldSubmitted:
                                                                    (_) async {
                                                                  if (functions
                                                                      .validateEmail(_model
                                                                          .emailLoginTextController
                                                                          .text)) {
                                                                    _model.error =
                                                                        'error';
                                                                    safeSetState(
                                                                        () {});
                                                                  } else {
                                                                    _model.error =
                                                                        'email_error';
                                                                    safeSetState(
                                                                        () {});
                                                                  }
                                                                },
                                                                autofocus:
                                                                    false,
                                                                textCapitalization:
                                                                    TextCapitalization
                                                                        .none,
                                                                obscureText:
                                                                    false,
                                                                decoration:
                                                                    InputDecoration(
                                                                  isDense: true,
                                                                  labelText:
                                                                      'Deine E-Mail-Adresse',
                                                                  labelStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleSmallFamily,
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          _model.emailSigninTextController.text != null && _model.emailSigninTextController.text != ''
                                                                              ? FlutterFlowTheme.of(context).secondaryText
                                                                              : FlutterFlowTheme.of(context).secondaryText50,
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondaryText50,
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText50,
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
                                                                      EdgeInsetsDirectional.fromSTEB(
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
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      fontSize:
                                                                          16.0,
                                                                      letterSpacing:
                                                                          valueOrDefault<
                                                                              double>(
                                                                        -0.4,
                                                                        -0.4,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      lineHeight:
                                                                          1.5,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
                                                                    ),
                                                                maxLength: 50,
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
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                enableInteractiveSelection:
                                                                    true,
                                                                validator: _model
                                                                    .emailSigninTextControllerValidator
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
                                                                            .toCapitalization(TextCapitalization.none),
                                                                      );
                                                                    }),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if ((_model.error ==
                                                            'email_exists') &&
                                                        (_model.emailSigninTextController
                                                                    .text !=
                                                                null &&
                                                            _model.emailSigninTextController
                                                                    .text !=
                                                                ''))
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      4.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: AutoSizeText(
                                                            'Existiert bereits.',
                                                            maxLines: 1,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  fontSize:
                                                                      14.0,
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
                                                                          .titleSmallIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (!functions.validateEmail(
                                                            _model
                                                                .emailSigninTextController
                                                                .text) &&
                                                        (_model.emailSigninTextController
                                                                    .text !=
                                                                null &&
                                                            _model.emailSigninTextController
                                                                    .text !=
                                                                ''))
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      4.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: AutoSizeText(
                                                            'Gültige E-Mail-Adresse eingeben',
                                                            maxLines: 1,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  fontSize:
                                                                      14.0,
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
                                                                  24.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Container(
                                                        constraints:
                                                            BoxConstraints(
                                                          minHeight: 56.0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      16.0),
                                                          border: Border.all(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (!valueOrDefault<
                                                                        bool>(
                                                                      functions.validatePassword(_model
                                                                          .passSigninTextController
                                                                          .text),
                                                                      false,
                                                                    ) &&
                                                                    valueOrDefault<
                                                                        bool>(
                                                                      _model.passSigninTextController.text !=
                                                                              null &&
                                                                          _model.passSigninTextController.text !=
                                                                              '',
                                                                      false,
                                                                    )) {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if ((_model
                                                                        .passSigninFocusNode
                                                                        ?.hasFocus ??
                                                                    false)) {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .focus;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
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
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      4.0,
                                                                      0.0),
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            child:
                                                                TextFormField(
                                                              controller: _model
                                                                  .passSigninTextController,
                                                              focusNode: _model
                                                                  .passSigninFocusNode,
                                                              onChanged: (_) =>
                                                                  EasyDebounce
                                                                      .debounce(
                                                                '_model.passSigninTextController',
                                                                Duration(
                                                                    milliseconds:
                                                                        50),
                                                                () =>
                                                                    safeSetState(
                                                                        () {}),
                                                              ),
                                                              autofocus: false,
                                                              textCapitalization:
                                                                  TextCapitalization
                                                                      .none,
                                                              obscureText: !_model
                                                                  .passSigninVisibility,
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                labelText:
                                                                    'Passwort',
                                                                labelStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: valueOrDefault<
                                                                          Color>(
                                                                        _model.passSigninTextController.text != null &&
                                                                                _model.passSigninTextController.text != ''
                                                                            ? FlutterFlowTheme.of(context).secondaryText
                                                                            : FlutterFlowTheme.of(context).secondaryText50,
                                                                        FlutterFlowTheme.of(context)
                                                                            .secondaryText50,
                                                                      ),
                                                                      fontSize:
                                                                          16.0,
                                                                      letterSpacing:
                                                                          valueOrDefault<
                                                                              double>(
                                                                        -0.4,
                                                                        -0.4,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      lineHeight:
                                                                          1.5,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                                hintStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .labelMediumFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText50,
                                                                      fontSize:
                                                                          16.0,
                                                                      letterSpacing:
                                                                          valueOrDefault<
                                                                              double>(
                                                                        -0.4,
                                                                        -0.4,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      lineHeight:
                                                                          1.5,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .labelMediumIsCustom,
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
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            16.0,
                                                                            16.0,
                                                                            16.0),
                                                                suffixIcon:
                                                                    InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    safeSetState(() => _model
                                                                            .passSigninVisibility =
                                                                        !_model
                                                                            .passSigninVisibility);
                                                                  },
                                                                  focusNode: FocusNode(
                                                                      skipTraversal:
                                                                          true),
                                                                  child: Icon(
                                                                    _model.passSigninVisibility
                                                                        ? Icons
                                                                            .visibility_outlined
                                                                        : Icons
                                                                            .visibility_off_outlined,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    fontSize:
                                                                        16.0,
                                                                    letterSpacing:
                                                                        valueOrDefault<
                                                                            double>(
                                                                      -0.4,
                                                                      -0.4,
                                                                    ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    lineHeight:
                                                                        1.5,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                              maxLength: 50,
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
                                                                      .visiblePassword,
                                                              cursorColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              enableInteractiveSelection:
                                                                  true,
                                                              validator: _model
                                                                  .passSigninTextControllerValidator
                                                                  .asValidator(
                                                                      context),
                                                              inputFormatters: [
                                                                if (!isAndroid &&
                                                                    !isiOS)
                                                                  TextInputFormatter
                                                                      .withFunction(
                                                                          (oldValue,
                                                                              newValue) {
                                                                    return TextEditingValue(
                                                                      selection:
                                                                          newValue
                                                                              .selection,
                                                                      text: newValue
                                                                          .text
                                                                          .toCapitalization(
                                                                              TextCapitalization.none),
                                                                    );
                                                                  }),
                                                              ],
                                                            ),
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
                                                                    16.0,
                                                                    4.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Text(
                                                          'Mindestens 10 Zeichen, eine Zahl, ein Großbuchstabe, ein Sonderzeichen',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color:
                                                                    valueOrDefault<
                                                                        Color>(
                                                                  !valueOrDefault<
                                                                              bool>(
                                                                            functions.validatePassword(_model.passSigninTextController.text),
                                                                            false,
                                                                          ) &&
                                                                          valueOrDefault<
                                                                              bool>(
                                                                            _model.passSigninTextController.text != null &&
                                                                                _model.passSigninTextController.text != '',
                                                                            false,
                                                                          )
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .error
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                ),
                                                                fontSize: 14.0,
                                                                letterSpacing:
                                                                    valueOrDefault<
                                                                        double>(
                                                                  -0.35,
                                                                  -0.35,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                lineHeight: 1.5,
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
                                                                  24.0,
                                                                  0.0,
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
                                                          _model.terms =
                                                              !_model.terms;
                                                          safeSetState(() {});
                                                        },
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Container(
                                                              width: 18.0,
                                                              height: 18.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    valueOrDefault<
                                                                        Color>(
                                                                  _model.terms
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondary
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4.0),
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: Visibility(
                                                                visible: _model
                                                                    .terms,
                                                                child: Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    FFIcons
                                                                        .kcheck2,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                    size: 12.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: RichText(
                                                                textScaler: MediaQuery.of(
                                                                        context)
                                                                    .textScaler,
                                                                text: TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          'Ich akzeptiere ',
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
                                                                    TextSpan(
                                                                      text:
                                                                          'AGB',
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
                                                                                FontWeight.bold,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                          ),
                                                                      mouseCursor:
                                                                          SystemMouseCursors
                                                                              .click,
                                                                      recognizer:
                                                                          TapGestureRecognizer()
                                                                            ..onTap =
                                                                                () async {
                                                                              unawaited(
                                                                                () async {
                                                                                  await launchURL(FFAppConstants.terms);
                                                                                }(),
                                                                              );
                                                                            },
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          ' and ',
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
                                                                    TextSpan(
                                                                      text:
                                                                          'Datenschutzbestimmungen.',
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
                                                                                FontWeight.bold,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                          ),
                                                                      mouseCursor:
                                                                          SystemMouseCursors
                                                                              .click,
                                                                      recognizer:
                                                                          TapGestureRecognizer()
                                                                            ..onTap =
                                                                                () async {
                                                                              unawaited(
                                                                                () async {
                                                                                  await launchURL(FFAppConstants.policy);
                                                                                }(),
                                                                              );
                                                                            },
                                                                    )
                                                                  ],
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        lineHeight:
                                                                            1.5,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 8.0)),
                                                        ),
                                                      ),
                                                    ),
                                                  ].addToEnd(
                                                      SizedBox(height: 100.0)),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 1.0),
                                              child: Builder(
                                                builder: (context) =>
                                                    FFButtonWidget(
                                                  onPressed: ((_model.nameTextController.text == null ||
                                                              _model.nameTextController.text ==
                                                                  '') ||
                                                          (_model.emailSigninTextController.text == null ||
                                                              _model.emailSigninTextController.text ==
                                                                  '') ||
                                                          (_model.passSigninTextController.text == null ||
                                                              _model.passSigninTextController.text ==
                                                                  '') ||
                                                          (_model.displayNameTextController.text == null ||
                                                              _model.displayNameTextController
                                                                      .text ==
                                                                  '') ||
                                                          !_model.terms ||
                                                          (!functions.validateName(_model.nameTextController.text) &&
                                                              (_model.nameTextController.text !=
                                                                      null &&
                                                                  _model.nameTextController.text !=
                                                                      '')) ||
                                                          (!functions.validateEmail(
                                                                  _model
                                                                      .emailSigninTextController
                                                                      .text) &&
                                                              (_model.emailSigninTextController.text !=
                                                                      null &&
                                                                  _model.emailSigninTextController.text !=
                                                                      '')) ||
                                                          (!valueOrDefault<bool>(
                                                                functions.validateHandle(
                                                                    _model
                                                                        .displayNameTextController
                                                                        .text),
                                                                false,
                                                              ) &&
                                                              valueOrDefault<bool>(
                                                                _model.displayNameTextController
                                                                            .text !=
                                                                        null &&
                                                                    _model.displayNameTextController
                                                                            .text !=
                                                                        '',
                                                                false,
                                                              )) ||
                                                          (!valueOrDefault<bool>(
                                                                functions.validatePassword(
                                                                    _model
                                                                        .passSigninTextController
                                                                        .text),
                                                                false,
                                                              ) &&
                                                              valueOrDefault<bool>(
                                                                _model.passSigninTextController
                                                                            .text !=
                                                                        null &&
                                                                    _model.passSigninTextController
                                                                            .text !=
                                                                        '',
                                                                false,
                                                              )))
                                                      ? null
                                                      : () async {
                                                          var _shouldSetState =
                                                              false;
                                                          _model.error =
                                                              'error';
                                                          safeSetState(() {});
                                                          await Future.wait([
                                                            Future(() async {
                                                              if (!functions
                                                                  .validateEmail(_model
                                                                      .emailSigninTextController
                                                                      .text)) {
                                                                if (_shouldSetState)
                                                                  safeSetState(
                                                                      () {});
                                                                return;
                                                              }
                                                            }),
                                                            Future(() async {
                                                              if (!functions
                                                                  .validateHandle(_model
                                                                      .displayNameTextController
                                                                      .text)) {
                                                                if (_shouldSetState)
                                                                  safeSetState(
                                                                      () {});
                                                                return;
                                                              }
                                                            }),
                                                            Future(() async {
                                                              if (!functions
                                                                  .validatePassword(_model
                                                                      .passSigninTextController
                                                                      .text)) {
                                                                if (_shouldSetState)
                                                                  safeSetState(
                                                                      () {});
                                                                return;
                                                              }
                                                            }),
                                                            Future(() async {
                                                              if (!functions
                                                                  .validateName(_model
                                                                      .nameTextController
                                                                      .text)) {
                                                                if (_shouldSetState)
                                                                  safeSetState(
                                                                      () {});
                                                                return;
                                                              }
                                                            }),
                                                          ]);
                                                          _model.singUp =
                                                              await actions
                                                                  .signUpWithOtp(
                                                            _model
                                                                .emailSigninTextController
                                                                .text,
                                                            _model
                                                                .passSigninTextController
                                                                .text,
                                                            _model
                                                                .nameTextController
                                                                .text,
                                                            (String username) {
                                                              return username
                                                                      ?.toLowerCase()
                                                                      .replaceAll(
                                                                          ' ',
                                                                          '') ??
                                                                  '';
                                                            }(_model
                                                                .displayNameTextController
                                                                .text),
                                                          );
                                                          _shouldSetState =
                                                              true;
                                                          await Future.delayed(
                                                            Duration(
                                                              milliseconds:
                                                                  1000,
                                                            ),
                                                          );
                                                          if (_model.singUp ==
                                                              'success') {
                                                            context.pushNamed(
                                                              ConfirmWidget
                                                                  .routeName,
                                                              queryParameters: {
                                                                'email':
                                                                    serializeParam(
                                                                  _model
                                                                      .emailSigninTextController
                                                                      .text,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'password':
                                                                    serializeParam(
                                                                  _model
                                                                      .passSigninTextController
                                                                      .text,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'username':
                                                                    serializeParam(
                                                                  _model
                                                                      .displayNameTextController
                                                                      .text,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'firstName':
                                                                    serializeParam(
                                                                  _model
                                                                      .nameTextController
                                                                      .text,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'actionType':
                                                                    serializeParam(
                                                                  'signup',
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                              }.withoutNulls,
                                                            );
                                                          } else {
                                                            _model.error =
                                                                _model.singUp;
                                                            safeSetState(() {});
                                                            showDialog(
                                                              barrierColor: Colors
                                                                  .transparent,
                                                              context: context,
                                                              builder:
                                                                  (dialogContext) {
                                                                return Dialog(
                                                                  elevation: 0,
                                                                  insetPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  alignment: AlignmentDirectional(
                                                                          0.0,
                                                                          1.0)
                                                                      .resolve(
                                                                          Directionality.of(
                                                                              context)),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      FocusScope.of(
                                                                              dialogContext)
                                                                          .unfocus();
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                    },
                                                                    child:
                                                                        SnackBarWidget(
                                                                      text: () {
                                                                        if (_model.error ==
                                                                            'email_exists') {
                                                                          return 'Existiert bereits.';
                                                                        } else if (_model.error ==
                                                                            'name_exists') {
                                                                          return 'Existiert bereits.';
                                                                        } else {
                                                                          return 'Error';
                                                                        }
                                                                      }(),
                                                                      error:
                                                                          true,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );

                                                            if (_shouldSetState)
                                                              safeSetState(
                                                                  () {});
                                                            return;
                                                          }

                                                          if (_shouldSetState)
                                                            safeSetState(() {});
                                                        },
                                                  text: 'Account erstellen',
                                                  icon: Icon(
                                                    FFIcons.krightArrow,
                                                    size: 16.0,
                                                  ),
                                                  options: FFButtonOptions(
                                                    width: double.infinity,
                                                    height: 56.0,
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                                16.0, 0.0),
                                                    iconAlignment:
                                                        IconAlignment.end,
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    iconColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryBackground,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    textStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmall
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryBackground,
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
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  -1.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 24.0, 0.0, 24.0),
                                                child: Text(
                                                  'Willkommen zurück!',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                            fontSize: 14.0,
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
                                                                    .titleSmallIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Expanded(
                                                  child: AutoSizeText(
                                                    'Anmelden',
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Dela Gothic One',
                                                          fontSize: 32.0,
                                                          letterSpacing:
                                                              valueOrDefault<
                                                                  double>(
                                                            -1.44,
                                                            -1.44,
                                                          ),
                                                          lineHeight: 1.2,
                                                        ),
                                                  ),
                                                ),
                                                Icon(
                                                  FFIcons.klogoMini2,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 40.0,
                                                ),
                                              ].divide(SizedBox(width: 8.0)),
                                            ),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                controller:
                                                    _model.columnController2,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  24.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Stack(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 0.0),
                                                        children: [
                                                          Container(
                                                            constraints:
                                                                BoxConstraints(
                                                              minHeight: 56.0,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
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
                                                                    if (!valueOrDefault<
                                                                            bool>(
                                                                          functions.validateEmail(_model
                                                                              .emailLoginTextController
                                                                              .text),
                                                                          false,
                                                                        ) &&
                                                                        valueOrDefault<
                                                                            bool>(
                                                                          _model.emailLoginTextController.text != null &&
                                                                              _model.emailLoginTextController.text != '',
                                                                          false,
                                                                        )) {
                                                                      return FlutterFlowTheme.of(
                                                                              context)
                                                                          .error;
                                                                    } else if ((_model
                                                                            .emailLoginFocusNode
                                                                            ?.hasFocus ??
                                                                        false)) {
                                                                      return FlutterFlowTheme.of(
                                                                              context)
                                                                          .focus;
                                                                    } else if ((_model
                                                                                .error ==
                                                                            'empty_fields') ||
                                                                        (_model.error ==
                                                                            'invalid_credentials') ||
                                                                        (_model.error ==
                                                                            'user_not_found')) {
                                                                      return FlutterFlowTheme.of(
                                                                              context)
                                                                          .error;
                                                                    } else {
                                                                      return FlutterFlowTheme.of(
                                                                              context)
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
                                                                    .emailLoginTextController,
                                                                focusNode: _model
                                                                    .emailLoginFocusNode,
                                                                onChanged: (_) =>
                                                                    EasyDebounce
                                                                        .debounce(
                                                                  '_model.emailLoginTextController',
                                                                  Duration(
                                                                      milliseconds:
                                                                          50),
                                                                  () async {
                                                                    _model.error =
                                                                        'error';
                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                ),
                                                                onFieldSubmitted:
                                                                    (_) async {
                                                                  if (functions
                                                                      .validateEmail(_model
                                                                          .emailLoginTextController
                                                                          .text)) {
                                                                    _model.error =
                                                                        'error';
                                                                    safeSetState(
                                                                        () {});
                                                                  } else {
                                                                    _model.error =
                                                                        'email_error';
                                                                    safeSetState(
                                                                        () {});
                                                                  }
                                                                },
                                                                autofocus:
                                                                    false,
                                                                textCapitalization:
                                                                    TextCapitalization
                                                                        .none,
                                                                obscureText:
                                                                    false,
                                                                decoration:
                                                                    InputDecoration(
                                                                  isDense: true,
                                                                  labelText:
                                                                      'Deine E-Mail-Adresse',
                                                                  labelStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleSmallFamily,
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          _model.emailLoginTextController.text != null && _model.emailLoginTextController.text != ''
                                                                              ? FlutterFlowTheme.of(context).secondaryText
                                                                              : FlutterFlowTheme.of(context).secondaryText50,
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondaryText50,
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText50,
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
                                                                      EdgeInsetsDirectional.fromSTEB(
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
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      fontSize:
                                                                          16.0,
                                                                      letterSpacing:
                                                                          valueOrDefault<
                                                                              double>(
                                                                        -0.4,
                                                                        -0.4,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      lineHeight:
                                                                          1.5,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
                                                                    ),
                                                                maxLength: 50,
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
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                enableInteractiveSelection:
                                                                    true,
                                                                validator: _model
                                                                    .emailLoginTextControllerValidator
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
                                                                            .toCapitalization(TextCapitalization.none),
                                                                      );
                                                                    }),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    1.0, 0.0),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                              child: Icon(
                                                                FFIcons.kmail,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                size: 24.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (!functions.validateEmail(
                                                            _model
                                                                .emailLoginTextController
                                                                .text) &&
                                                        (_model.emailLoginTextController
                                                                    .text !=
                                                                null &&
                                                            _model.emailLoginTextController
                                                                    .text !=
                                                                ''))
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      4.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: AutoSizeText(
                                                            'Gültige E-Mail-Adresse eingeben',
                                                            maxLines: 1,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  fontSize:
                                                                      14.0,
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
                                                                  24.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Stack(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 0.0),
                                                        children: [
                                                          Container(
                                                            constraints:
                                                                BoxConstraints(
                                                              minHeight: 56.0,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
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
                                                                    if ((_model.error ==
                                                                            'empty_fields') ||
                                                                        (_model.error ==
                                                                            'invalid_credentials')) {
                                                                      return FlutterFlowTheme.of(
                                                                              context)
                                                                          .error;
                                                                    } else if ((_model
                                                                            .passLoginFocusNode
                                                                            ?.hasFocus ??
                                                                        false)) {
                                                                      return FlutterFlowTheme.of(
                                                                              context)
                                                                          .focus;
                                                                    } else {
                                                                      return FlutterFlowTheme.of(
                                                                              context)
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
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          4.0,
                                                                          0.0),
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                child:
                                                                    TextFormField(
                                                                  controller: _model
                                                                      .passLoginTextController,
                                                                  focusNode: _model
                                                                      .passLoginFocusNode,
                                                                  onChanged: (_) =>
                                                                      EasyDebounce
                                                                          .debounce(
                                                                    '_model.passLoginTextController',
                                                                    Duration(
                                                                        milliseconds:
                                                                            50),
                                                                    () async {
                                                                      _model.error =
                                                                          'error';
                                                                      safeSetState(
                                                                          () {});
                                                                    },
                                                                  ),
                                                                  autofocus:
                                                                      false,
                                                                  textCapitalization:
                                                                      TextCapitalization
                                                                          .none,
                                                                  obscureText:
                                                                      !_model
                                                                          .passLoginVisibility,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    isDense:
                                                                        true,
                                                                    labelText:
                                                                        'Dein Passwort',
                                                                    labelStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).titleSmallFamily,
                                                                          color:
                                                                              valueOrDefault<Color>(
                                                                            _model.passLoginTextController.text != null && _model.passLoginTextController.text != ''
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
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            16.0,
                                                                            16.0,
                                                                            16.0,
                                                                            16.0),
                                                                    suffixIcon:
                                                                        InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        safeSetState(() =>
                                                                            _model.passLoginVisibility =
                                                                                !_model.passLoginVisibility);
                                                                      },
                                                                      focusNode:
                                                                          FocusNode(
                                                                              skipTraversal: true),
                                                                      child:
                                                                          Icon(
                                                                        _model.passLoginVisibility
                                                                            ? Icons.visibility_outlined
                                                                            : Icons.visibility_off_outlined,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                        size:
                                                                            24.0,
                                                                      ),
                                                                    ),
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
                                                                  maxLength: 50,
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
                                                                          .visiblePassword,
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                  enableInteractiveSelection:
                                                                      true,
                                                                  validator: _model
                                                                      .passLoginTextControllerValidator
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
                                                                              .toCapitalization(TextCapitalization.none),
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
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  24.0,
                                                                  0.0,
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
                                                          _model.remember =
                                                              !_model.remember;
                                                          safeSetState(() {});
                                                        },
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Container(
                                                              width: 18.0,
                                                              height: 18.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    valueOrDefault<
                                                                        Color>(
                                                                  _model.remember
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondary
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4.0),
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: Visibility(
                                                                visible: _model
                                                                    .remember,
                                                                child: Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    FFIcons
                                                                        .kcheck2,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                    size: 12.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              'Login speichern',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    fontSize:
                                                                        16.0,
                                                                    letterSpacing:
                                                                        valueOrDefault<
                                                                            double>(
                                                                      -0.4,
                                                                      -0.4,
                                                                    ),
                                                                    lineHeight:
                                                                        1.5,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 8.0)),
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
                                                                    0.0,
                                                                    24.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: FFButtonWidget(
                                                          onPressed: () async {
                                                            context.pushNamed(
                                                              ForgotpasswordWidget
                                                                  .routeName,
                                                              queryParameters: {
                                                                'email':
                                                                    serializeParam(
                                                                  _model
                                                                      .emailLoginTextController
                                                                      .text,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                              }.withoutNulls,
                                                            );
                                                          },
                                                          text:
                                                              'Passwort vergessen?',
                                                          options:
                                                              FFButtonOptions(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            iconPadding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            color: Colors
                                                                .transparent,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          valueOrDefault<
                                                                              double>(
                                                                        -0.4,
                                                                        -0.4,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      lineHeight:
                                                                          1.5,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 0.0,
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ].addToEnd(
                                                      SizedBox(height: 100.0)),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 1.0),
                                              child: Builder(
                                                builder: (context) =>
                                                    FFButtonWidget(
                                                  onPressed: ((_model
                                                                      .emailLoginTextController
                                                                      .text ==
                                                                  null ||
                                                              _model.emailLoginTextController
                                                                      .text ==
                                                                  '') ||
                                                          (_model.passLoginTextController
                                                                      .text ==
                                                                  null ||
                                                              _model.passLoginTextController
                                                                      .text ==
                                                                  '') ||
                                                          (!functions.validateEmail(
                                                                  _model
                                                                      .emailLoginTextController
                                                                      .text) &&
                                                              (_model.emailLoginTextController
                                                                          .text !=
                                                                      null &&
                                                                  _model.emailLoginTextController
                                                                          .text !=
                                                                      '')))
                                                      ? null
                                                      : () async {
                                                          var _shouldSetState =
                                                              false;
                                                          if (_model.remember) {
                                                            FFAppState().email =
                                                                _model
                                                                    .emailLoginTextController
                                                                    .text;
                                                            safeSetState(() {});
                                                          }
                                                          if (_model
                                                                  .emailLoginTextController
                                                                  .text ==
                                                              'test@gmail.com') {
                                                            context.pushNamed(
                                                              ConfirmWidget
                                                                  .routeName,
                                                              queryParameters: {
                                                                'email':
                                                                    serializeParam(
                                                                  _model
                                                                      .emailLoginTextController
                                                                      .text,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'password':
                                                                    serializeParam(
                                                                  _model
                                                                      .passLoginTextController
                                                                      .text,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'actionType':
                                                                    serializeParam(
                                                                  'signin',
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                              }.withoutNulls,
                                                            );
                                                          } else {
                                                            _model.login =
                                                                await actions
                                                                    .sendSignInOtp(
                                                              _model
                                                                  .emailLoginTextController
                                                                  .text,
                                                              _model
                                                                  .passLoginTextController
                                                                  .text,
                                                              'signin',
                                                            );
                                                            _shouldSetState =
                                                                true;
                                                            await Future
                                                                .delayed(
                                                              Duration(
                                                                milliseconds:
                                                                    1000,
                                                              ),
                                                            );
                                                            if (_model.login ==
                                                                'success') {
                                                              context.pushNamed(
                                                                ConfirmWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'email':
                                                                      serializeParam(
                                                                    _model
                                                                        .emailLoginTextController
                                                                        .text,
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                  'password':
                                                                      serializeParam(
                                                                    _model
                                                                        .passLoginTextController
                                                                        .text,
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                  'actionType':
                                                                      serializeParam(
                                                                    'signin',
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                            } else {
                                                              _model.error =
                                                                  _model.login;
                                                              safeSetState(
                                                                  () {});
                                                              showDialog(
                                                                barrierColor: Colors
                                                                    .transparent,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (dialogContext) {
                                                                  return Dialog(
                                                                    elevation:
                                                                        0,
                                                                    insetPadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            1.0)
                                                                        .resolve(
                                                                            Directionality.of(context)),
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        FocusScope.of(dialogContext)
                                                                            .unfocus();
                                                                        FocusManager
                                                                            .instance
                                                                            .primaryFocus
                                                                            ?.unfocus();
                                                                      },
                                                                      child:
                                                                          SnackBarWidget(
                                                                        text:
                                                                            () {
                                                                          if (_model.error ==
                                                                              'empty_fields') {
                                                                            return 'Email or password is empty';
                                                                          } else if (_model.error ==
                                                                              'invalid_credentials') {
                                                                            return 'Die eingegebenen Login-Daten sind nicht korrekt';
                                                                          } else if (_model.error ==
                                                                              'user_not_found') {
                                                                            return 'User not found';
                                                                          } else if (_model.error ==
                                                                              'otp_failed') {
                                                                            return 'Failed to send OTP';
                                                                          } else {
                                                                            return 'Error';
                                                                          }
                                                                        }(),
                                                                        error:
                                                                            true,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );

                                                              if (_shouldSetState)
                                                                safeSetState(
                                                                    () {});
                                                              return;
                                                            }
                                                          }

                                                          if (_shouldSetState)
                                                            safeSetState(() {});
                                                        },
                                                  text: 'Let\'s Roll!',
                                                  icon: Icon(
                                                    FFIcons.krightArrow,
                                                    size: 16.0,
                                                  ),
                                                  options: FFButtonOptions(
                                                    width: double.infinity,
                                                    height: 56.0,
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                                16.0, 0.0),
                                                    iconAlignment:
                                                        IconAlignment.end,
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    iconColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryBackground,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    textStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmall
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryBackground,
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
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
