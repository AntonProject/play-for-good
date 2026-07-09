import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/components/dialogs/snack_bar_light_error/snack_bar_light_error_widget.dart';
import '/components/dialogs/snack_bar_white_success/snack_bar_white_success_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'auth_dialog_model.dart';
export 'auth_dialog_model.dart';

/// This component have numeric enum for the auth step - currentAuthStep:
/// 1 - Login/Register
/// 2 - Enter the code
/// 3 - Forgot password
/// 4 - Forgot password - new password
class AuthDialogWidget extends StatefulWidget {
  const AuthDialogWidget({super.key});

  @override
  State<AuthDialogWidget> createState() => _AuthDialogWidgetState();
}

class _AuthDialogWidgetState extends State<AuthDialogWidget> {
  late AuthDialogModel _model;

  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthDialogModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().firstOpen) {
        _model.tab = 2;
        safeSetState(() {});
      } else {
        _model.tab = 1;
        safeSetState(() {});
      }
    });

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

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
    _model.pinCodeFocusNode ??= FocusNode();

    _model.emailLoginPasswordResetTextController ??=
        TextEditingController(text: _model.email);
    _model.emailLoginPasswordResetFocusNode ??= FocusNode();
    _model.emailLoginPasswordResetFocusNode!
        .addListener(() => safeSetState(() {}));
    _model.newPassTextController ??= TextEditingController();
    _model.newPassFocusNode ??= FocusNode();
    _model.newPassFocusNode!.addListener(() => safeSetState(() {}));
    _model.confirmPassTextController ??= TextEditingController();
    _model.confirmPassFocusNode ??= FocusNode();
    _model.confirmPassFocusNode!.addListener(() => safeSetState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
            0.0,
            WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
                WidgetsBinding
                    .instance.platformDispatcher.views.first.devicePixelRatio,
            0.0,
            0.0),
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 8.0,
                color: Color(0x1A000000),
                offset: Offset(
                  0.0,
                  valueOrDefault<double>(
                    -2,
                    -2.0,
                  ),
                ),
                spreadRadius: valueOrDefault<double>(
                  -2,
                  -2.0,
                ),
              )
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2.0,
                  color: Color(0xF0000000),
                  offset: Offset(0.0, 0.0),
                  spreadRadius: valueOrDefault<double>(
                    -2,
                    -2.0,
                  ),
                )
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Builder(
              builder: (context) {
                if (_model.currentAuthStep == 1) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 12.0, 16.0, 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    40.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  'Hey, bist du neu hier?',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 20.0,
                                        letterSpacing: -0.8,
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1.4,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                              ),
                            ),
                            Container(
                              width: 56.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(99.0),
                              ),
                              child: FlutterFlowIconButton(
                                borderColor: Colors.transparent,
                                borderRadius: 99.0,
                                buttonSize: 40.0,
                                fillColor:
                                    FlutterFlowTheme.of(context).alternate,
                                icon: Icon(
                                  FFIcons.kcheck2,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 14.0,
                                ),
                                showLoadingIndicator: true,
                                onPressed: () async {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Builder(
                          builder: (context) {
                            if (_model.tab == 2) {
                              return SingleChildScrollView(
                                primary: false,
                                controller: _model.columnController1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 16.0, 24.0, 24.0),
                                      child: RichText(
                                        textScaler:
                                            MediaQuery.of(context).textScaler,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  'Melde dich an oder registriere dich ',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyLarge
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLargeFamily,
                                                    letterSpacing:
                                                        valueOrDefault<double>(
                                                      -0.4,
                                                      -0.4,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                    lineHeight: 1.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLargeIsCustom,
                                                  ),
                                            ),
                                            TextSpan(
                                              text: 'unter einer Minute',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyLarge
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLargeFamily,
                                                    letterSpacing:
                                                        valueOrDefault<double>(
                                                      -0.4,
                                                      -0.4,
                                                    ),
                                                    fontWeight: FontWeight.bold,
                                                    lineHeight: 1.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLargeIsCustom,
                                                  ),
                                            ),
                                            TextSpan(
                                              text:
                                                  ', um Good €nergy ausstrahlen, deine positive Wirkung nachverfolgen und Spendenbestätigungen erhalten zu können.',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyLarge
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLargeFamily,
                                                    letterSpacing:
                                                        valueOrDefault<double>(
                                                      -0.4,
                                                      -0.4,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                    lineHeight: 1.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLargeIsCustom,
                                                  ),
                                            )
                                          ],
                                          style: FlutterFlowTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyLargeFamily,
                                                letterSpacing: -0.4,
                                                fontWeight: FontWeight.w500,
                                                lineHeight: 1.5,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLargeIsCustom,
                                              ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  24.0, 0.0, 24.0, 0.0),
                                          child: Container(
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(32.0),
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
                                                        color: valueOrDefault<
                                                            Color>(
                                                          _model.tab == 1
                                                              ? FlutterFlowTheme
                                                                      .of(
                                                                          context)
                                                                  .secondary
                                                              : FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryBackground,
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary,
                                                        ),
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  color:
                                                                      valueOrDefault<
                                                                          Color>(
                                                                    _model.tab ==
                                                                            1
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .primaryBackground
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                  ),
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
                                                                .circular(99.0),
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
                                                        color: valueOrDefault<
                                                            Color>(
                                                          _model.tab == 1
                                                              ? FlutterFlowTheme
                                                                      .of(
                                                                          context)
                                                                  .primaryBackground
                                                              : FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondary,
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                        ),
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  color:
                                                                      valueOrDefault<
                                                                          Color>(
                                                                    _model.tab ==
                                                                            1
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .primaryText
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primaryBackground,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                  ),
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
                                                                .circular(99.0),
                                                      ),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(width: 16.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  44.0, 24.0, 44.0, 74.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                constraints: BoxConstraints(
                                                  minHeight: 56.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  border: Border.all(
                                                    color:
                                                        valueOrDefault<Color>(
                                                      () {
                                                        if (!valueOrDefault<
                                                                bool>(
                                                              functions.validateName(
                                                                  _model
                                                                      .nameTextController
                                                                      .text),
                                                              false,
                                                            ) &&
                                                            valueOrDefault<
                                                                bool>(
                                                              _model.nameTextController
                                                                          .text !=
                                                                      null &&
                                                                  _model.nameTextController
                                                                          .text !=
                                                                      '',
                                                              false,
                                                            )) {
                                                          return FlutterFlowTheme
                                                                  .of(context)
                                                              .error;
                                                        } else if ((_model
                                                                .nameFocusNode
                                                                ?.hasFocus ??
                                                            false)) {
                                                          return FlutterFlowTheme
                                                                  .of(context)
                                                              .focus;
                                                        } else {
                                                          return FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground;
                                                        }
                                                      }(),
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                    ),
                                                    width: 2.0,
                                                  ),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    child: TextFormField(
                                                      controller: _model
                                                          .nameTextController,
                                                      focusNode:
                                                          _model.nameFocusNode,
                                                      onChanged: (_) =>
                                                          EasyDebounce.debounce(
                                                        '_model.nameTextController',
                                                        Duration(
                                                            milliseconds: 50),
                                                        () =>
                                                            safeSetState(() {}),
                                                      ),
                                                      onFieldSubmitted:
                                                          (_) async {
                                                        if (functions
                                                            .validateName(_model
                                                                .nameTextController
                                                                .text)) {
                                                          _model.error =
                                                              'error';
                                                          safeSetState(() {});
                                                        } else {
                                                          _model.error =
                                                              'name_error';
                                                          safeSetState(() {});
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
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  fontSize:
                                                                      16.0,
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
                                                                          .labelSmallIsCustom,
                                                                ),
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
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
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMediumIsCustom,
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
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    16.0,
                                                                    6.0,
                                                                    16.0,
                                                                    6.0),
                                                      ),
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
                                                          .asValidator(context),
                                                      inputFormatters: [
                                                        if (!isAndroid &&
                                                            !isiOS)
                                                          TextInputFormatter
                                                              .withFunction(
                                                                  (oldValue,
                                                                      newValue) {
                                                            return TextEditingValue(
                                                              selection: newValue
                                                                  .selection,
                                                              text: newValue
                                                                  .text
                                                                  .toCapitalization(
                                                                      TextCapitalization
                                                                          .words),
                                                            );
                                                          }),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (!functions.validateName(_model
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
                                                            .fromSTEB(16.0, 4.0,
                                                                0.0, 0.0),
                                                    child: AutoSizeText(
                                                      'Gültigen Vornamen eingeben',
                                                      maxLines: 1,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                letterSpacing:
                                                                    -0.24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                lineHeight: 1.5,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmallIsCustom,
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
                                                Opacity(
                                                  opacity: 0.75,
                                                  child: Align(
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
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      -0.24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  lineHeight:
                                                                      1.5,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 24.0, 0.0, 0.0),
                                                child: Container(
                                                  constraints: BoxConstraints(
                                                    minHeight: 56.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0),
                                                    border: Border.all(
                                                      color:
                                                          valueOrDefault<Color>(
                                                        () {
                                                          if (!valueOrDefault<
                                                                  bool>(
                                                                functions.validateHandle(
                                                                    _model
                                                                        .displayNameTextController
                                                                        .text),
                                                                false,
                                                              ) &&
                                                              valueOrDefault<
                                                                  bool>(
                                                                _model.displayNameTextController
                                                                            .text !=
                                                                        null &&
                                                                    _model.displayNameTextController
                                                                            .text !=
                                                                        '',
                                                                false,
                                                              )) {
                                                            return FlutterFlowTheme
                                                                    .of(context)
                                                                .error;
                                                          } else if ((_model
                                                                  .displayNameFocusNode
                                                                  ?.hasFocus ??
                                                              false)) {
                                                            return FlutterFlowTheme
                                                                    .of(context)
                                                                .focus;
                                                          } else if (_model
                                                                  .error ==
                                                              'name_exists') {
                                                            return FlutterFlowTheme
                                                                    .of(context)
                                                                .error;
                                                          } else {
                                                            return FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground;
                                                          }
                                                        }(),
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryBackground,
                                                      ),
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Container(
                                                      width: double.infinity,
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
                                                              milliseconds: 50),
                                                          () async {
                                                            _model.error =
                                                                'error';
                                                            safeSetState(() {});
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
                                                            safeSetState(() {});
                                                          } else {
                                                            _model.error =
                                                                'handle_error';
                                                            safeSetState(() {});
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
                                                                  .labelSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .labelSmallFamily,
                                                                    fontSize:
                                                                        16.0,
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
                                                                        !FlutterFlowTheme.of(context)
                                                                            .labelSmallIsCustom,
                                                                  ),
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
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
                                                              InputBorder.none,
                                                          focusedBorder:
                                                              InputBorder.none,
                                                          errorBorder:
                                                              InputBorder.none,
                                                          focusedErrorBorder:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      6.0,
                                                                      16.0,
                                                                      6.0),
                                                        ),
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
                                                                  FontWeight
                                                                      .w500,
                                                              lineHeight: 1.5,
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
                                                                selection: newValue
                                                                    .selection,
                                                                text: newValue
                                                                    .text
                                                                    .toCapitalization(
                                                                        TextCapitalization
                                                                            .none),
                                                              );
                                                            }),
                                                        ],
                                                      ),
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
                                                            .fromSTEB(16.0, 4.0,
                                                                0.0, 0.0),
                                                    child: AutoSizeText(
                                                      'Existiert bereits.',
                                                      maxLines: 1,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                letterSpacing:
                                                                    -0.24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                lineHeight: 1.5,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmallIsCustom,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                              Opacity(
                                                opacity: 0.75,
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 4.0,
                                                                0.0, 0.0),
                                                    child: AutoSizeText(
                                                      'Maximal 20 Zeichen. Erlaubte Zeichen: Buchstaben (a–z), Ziffern (0–9), Punkte (.) und Unterstriche (_)',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                letterSpacing:
                                                                    -0.24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                lineHeight: 1.5,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmallIsCustom,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 24.0, 0.0, 0.0),
                                                child: Container(
                                                  constraints: BoxConstraints(
                                                    minHeight: 56.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0),
                                                    border: Border.all(
                                                      color:
                                                          valueOrDefault<Color>(
                                                        () {
                                                          if (!valueOrDefault<
                                                                  bool>(
                                                                functions.validateEmail(
                                                                    _model
                                                                        .emailSigninTextController
                                                                        .text),
                                                                false,
                                                              ) &&
                                                              valueOrDefault<
                                                                  bool>(
                                                                _model.emailSigninTextController
                                                                            .text !=
                                                                        null &&
                                                                    _model.emailSigninTextController
                                                                            .text !=
                                                                        '',
                                                                false,
                                                              )) {
                                                            return FlutterFlowTheme
                                                                    .of(context)
                                                                .error;
                                                          } else if (_model
                                                                  .error ==
                                                              'email_exists') {
                                                            return FlutterFlowTheme
                                                                    .of(context)
                                                                .error;
                                                          } else if ((_model
                                                                  .emailSigninFocusNode
                                                                  ?.hasFocus ??
                                                              false)) {
                                                            return FlutterFlowTheme
                                                                    .of(context)
                                                                .focus;
                                                          } else {
                                                            return FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground;
                                                          }
                                                        }(),
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryBackground,
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 24.0,
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          child: TextFormField(
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
                                                                      .emailSigninTextController
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
                                                            autofocus: false,
                                                            textCapitalization:
                                                                TextCapitalization
                                                                    .none,
                                                            obscureText: false,
                                                            decoration:
                                                                InputDecoration(
                                                              isDense: true,
                                                              labelText:
                                                                  'Deine E-Mail-Adresse',
                                                              labelStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).labelSmallFamily,
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            valueOrDefault<double>(
                                                                          -0.24,
                                                                          -0.24,
                                                                        ),
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        lineHeight:
                                                                            1.5,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).labelSmallIsCustom,
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
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          6.0,
                                                                          48.0,
                                                                          6.0),
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
                                                            .fromSTEB(16.0, 4.0,
                                                                0.0, 0.0),
                                                    child: AutoSizeText(
                                                      'Existiert bereits.',
                                                      maxLines: 1,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                letterSpacing:
                                                                    -0.24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                lineHeight: 1.5,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmallIsCustom,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                              if (!functions.validateEmail(_model
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
                                                            .fromSTEB(16.0, 4.0,
                                                                0.0, 0.0),
                                                    child: AutoSizeText(
                                                      'Gültige E-Mail-Adresse eingeben',
                                                      maxLines: 1,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                letterSpacing:
                                                                    -0.24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                lineHeight: 1.5,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmallIsCustom,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 24.0, 0.0, 0.0),
                                                child: Container(
                                                  constraints: BoxConstraints(
                                                    minHeight: 56.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0),
                                                    border: Border.all(
                                                      color:
                                                          valueOrDefault<Color>(
                                                        () {
                                                          if (!valueOrDefault<
                                                                  bool>(
                                                                functions.validatePassword(
                                                                    _model
                                                                        .passSigninTextController
                                                                        .text),
                                                                false,
                                                              ) &&
                                                              valueOrDefault<
                                                                  bool>(
                                                                _model.passSigninTextController
                                                                            .text !=
                                                                        null &&
                                                                    _model.passSigninTextController
                                                                            .text !=
                                                                        '',
                                                                false,
                                                              )) {
                                                            return FlutterFlowTheme
                                                                    .of(context)
                                                                .error;
                                                          } else if ((_model
                                                                  .passSigninFocusNode
                                                                  ?.hasFocus ??
                                                              false)) {
                                                            return FlutterFlowTheme
                                                                    .of(context)
                                                                .focus;
                                                          } else {
                                                            return FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground;
                                                          }
                                                        }(),
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryBackground,
                                                      ),
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  4.0,
                                                                  0.0),
                                                      child: Container(
                                                        width: double.infinity,
                                                        child: TextFormField(
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
                                                            () => safeSetState(
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
                                                            labelStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .labelSmallFamily,
                                                                      fontSize:
                                                                          16.0,
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
                                                                          !FlutterFlowTheme.of(context)
                                                                              .labelSmallIsCustom,
                                                                    ),
                                                            hintStyle:
                                                                FlutterFlowTheme.of(
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
                                                                        6.0,
                                                                        16.0,
                                                                        6.0),
                                                            suffixIcon: InkWell(
                                                              onTap: () async {
                                                                safeSetState(() =>
                                                                    _model.passSigninVisibility =
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
                                                                fontFamily: FlutterFlowTheme.of(
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
                                                                    FontWeight
                                                                        .w500,
                                                                lineHeight: 1.5,
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
                                                                          TextCapitalization
                                                                              .none),
                                                                );
                                                              }),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Opacity(
                                                opacity: 0.75,
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 4.0,
                                                                0.0, 0.0),
                                                    child: Text(
                                                      'Mindestens 10 Zeichen, eine Zahl, ein Großbuchstabe, ein Sonderzeichen',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
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
                                                                letterSpacing:
                                                                    -0.24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                lineHeight: 1.5,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmallIsCustom,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 24.0, 0.0, 0.0),
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
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 18.0,
                                                        height: 18.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: valueOrDefault<
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
                                                          border: Border.all(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        child: Visibility(
                                                          visible: _model.terms,
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Icon(
                                                              FFIcons.kcheck2,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryBackground,
                                                              size: 12.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: RichText(
                                                          textScaler:
                                                              MediaQuery.of(
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
                                                              TextSpan(
                                                                text: 'AGB',
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
                                                                              .bold,
                                                                      lineHeight:
                                                                          1.5,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
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
                                                                text: ' and ',
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
                                                                      lineHeight:
                                                                          1.5,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
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
                                                                              .bold,
                                                                      lineHeight:
                                                                          1.5,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
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
                                                                      0.0,
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
                                                    ].divide(
                                                        SizedBox(width: 16.0)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Builder(
                                      builder: (context) => Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            44.0,
                                            0.0,
                                            44.0,
                                            valueOrDefault<double>(
                                              MediaQuery.paddingOf(context)
                                                      .bottom +
                                                  24,
                                              24.0,
                                            )),
                                        child: FFButtonWidget(
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
                                                      _model.displayNameTextController.text ==
                                                          '') ||
                                                  !_model.terms ||
                                                  (!functions.validateName(_model
                                                          .nameTextController
                                                          .text) &&
                                                      (_model.nameTextController.text != null &&
                                                          _model.nameTextController.text !=
                                                              '')) ||
                                                  (!functions.validateEmail(_model
                                                          .emailSigninTextController
                                                          .text) &&
                                                      (_model.emailSigninTextController.text != null &&
                                                          _model.emailSigninTextController.text != '')) ||
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
                                                  var _shouldSetState = false;
                                                  _model.email = _model
                                                      .emailSigninTextController
                                                      .text;
                                                  _model.password = _model
                                                      .passSigninTextController
                                                      .text;
                                                  _model.firstName = _model
                                                      .nameTextController.text;
                                                  _model.username = _model
                                                      .displayNameTextController
                                                      .text;
                                                  _model.actionType =
                                                      _model.tab == 1
                                                          ? 'signin'
                                                          : 'signup';
                                                  if (_model.tab == 1) {
                                                  } else {
                                                    _model.error = 'error';
                                                    safeSetState(() {});
                                                    await Future.wait([
                                                      Future(() async {
                                                        if (!functions
                                                            .validateEmail(_model
                                                                .emailSigninTextController
                                                                .text)) {
                                                          if (_shouldSetState)
                                                            safeSetState(() {});
                                                          return;
                                                        }
                                                      }),
                                                      Future(() async {
                                                        if (!functions
                                                            .validateHandle(_model
                                                                .displayNameTextController
                                                                .text)) {
                                                          if (_shouldSetState)
                                                            safeSetState(() {});
                                                          return;
                                                        }
                                                      }),
                                                      Future(() async {
                                                        if (!functions
                                                            .validatePassword(_model
                                                                .passSigninTextController
                                                                .text)) {
                                                          if (_shouldSetState)
                                                            safeSetState(() {});
                                                          return;
                                                        }
                                                      }),
                                                      Future(() async {
                                                        if (!functions
                                                            .validateName(_model
                                                                .nameTextController
                                                                .text)) {
                                                          if (_shouldSetState)
                                                            safeSetState(() {});
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
                                                      _model.nameTextController
                                                          .text,
                                                      (String username) {
                                                        return username
                                                                ?.toLowerCase()
                                                                .replaceAll(
                                                                    ' ', '') ??
                                                            '';
                                                      }(_model
                                                          .displayNameTextController
                                                          .text),
                                                    );
                                                    _shouldSetState = true;
                                                    await Future.delayed(
                                                      Duration(
                                                        milliseconds: 1000,
                                                      ),
                                                    );
                                                    if (_model.singUp ==
                                                        'success') {
                                                      _model.currentAuthStep =
                                                          2;
                                                      _model.timerStart = true;
                                                      safeSetState(() {});
                                                      _model.timerController
                                                          .onResetTimer();

                                                      await Future.delayed(
                                                        Duration(
                                                          milliseconds: 500,
                                                        ),
                                                      );
                                                      _model.timerController
                                                          .onStartTimer();
                                                    } else {
                                                      _model.error =
                                                          _model.singUp;
                                                      safeSetState(() {});
                                                      unawaited(
                                                        () async {}(),
                                                      );
                                                      showDialog(
                                                        barrierColor:
                                                            Colors.transparent,
                                                        context: context,
                                                        builder:
                                                            (dialogContext) {
                                                          return Dialog(
                                                            elevation: 0,
                                                            insetPadding:
                                                                EdgeInsets.zero,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            alignment: AlignmentDirectional(
                                                                    0.0, -1.0)
                                                                .resolve(
                                                                    Directionality.of(
                                                                        context)),
                                                            child:
                                                                SnackBarLightErrorWidget(
                                                              text: () {
                                                                if (_model
                                                                        .error ==
                                                                    'email_exists') {
                                                                  return 'Existiert bereits.';
                                                                } else if (_model
                                                                        .error ==
                                                                    'name_exists') {
                                                                  return 'Existiert bereits.';
                                                                } else {
                                                                  return 'Error';
                                                                }
                                                              }(),
                                                              error: true,
                                                            ),
                                                          );
                                                        },
                                                      );

                                                      if (_shouldSetState)
                                                        safeSetState(() {});
                                                      return;
                                                    }
                                                  }

                                                  if (_shouldSetState)
                                                    safeSetState(() {});
                                                },
                                          text: 'Weiter',
                                          options: FFButtonOptions(
                                            width: double.infinity,
                                            height: 56.0,
                                            padding: EdgeInsets.all(16.0),
                                            iconPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            textStyle: FlutterFlowTheme.of(
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
                                                  letterSpacing:
                                                      valueOrDefault<double>(
                                                    -0.4,
                                                    -0.4,
                                                  ),
                                                  fontWeight: FontWeight.w600,
                                                  lineHeight: 1.5,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallIsCustom,
                                                ),
                                            elevation: 0.0,
                                            borderRadius:
                                                BorderRadius.circular(360.0),
                                            disabledColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary30,
                                            disabledTextColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      primary: false,
                                      controller: _model.columnController2,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    24.0, 16.0, 24.0, 24.0),
                                            child: RichText(
                                              textScaler: MediaQuery.of(context)
                                                  .textScaler,
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        'Melde dich an oder registriere dich ',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLargeFamily,
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
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyLargeIsCustom,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text: 'unter einer Minute',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLargeFamily,
                                                          letterSpacing:
                                                              valueOrDefault<
                                                                  double>(
                                                            -0.4,
                                                            -0.4,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          lineHeight: 1.5,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyLargeIsCustom,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        ', um Good €nergy ausstrahlen, deine positive Wirkung nachverfolgen und Spendenbestätigungen erhalten zu können.',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLargeFamily,
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
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyLargeIsCustom,
                                                        ),
                                                  )
                                                ],
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLargeFamily,
                                                          letterSpacing: -0.4,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          lineHeight: 1.5,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyLargeIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        24.0, 0.0, 24.0, 0.0),
                                                child: Container(
                                                  height: 48.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32.0),
                                                    border: Border.all(
                                                      color: Colors.transparent,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                          child: FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              _model.tab = 1;
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            text: 'Anmelden',
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
                                                              color:
                                                                  valueOrDefault<
                                                                      Color>(
                                                                _model.tab == 1
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                              ),
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleSmallFamily,
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          _model.tab == 1
                                                                              ? FlutterFlowTheme.of(context).primaryBackground
                                                                              : FlutterFlowTheme.of(context).primaryText,
                                                                          FlutterFlowTheme.of(context)
                                                                              .primaryBackground,
                                                                        ),
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
                                                              elevation: 0.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          99.0),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              _model.tab = 2;
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            text:
                                                                'Registrieren',
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
                                                              color:
                                                                  valueOrDefault<
                                                                      Color>(
                                                                _model.tab == 1
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                              ),
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleSmallFamily,
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          _model.tab == 1
                                                                              ? FlutterFlowTheme.of(context).primaryText
                                                                              : FlutterFlowTheme.of(context).primaryBackground,
                                                                          FlutterFlowTheme.of(context)
                                                                              .primaryText,
                                                                        ),
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
                                                              elevation: 0.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          99.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ].divide(SizedBox(
                                                          width: 16.0)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        32.0, 28.0, 24.0, 0.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Stack(
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
                                                            border: Border.all(
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
                                                                        _model.emailLoginTextController.text !=
                                                                                null &&
                                                                            _model.emailLoginTextController.text !=
                                                                                '',
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
                                                                        .secondaryBackground;
                                                                  }
                                                                }(),
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                              ),
                                                              width: 2.0,
                                                            ),
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
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
                                                                      .labelSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).labelSmallFamily,
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            valueOrDefault<double>(
                                                                          -0.24,
                                                                          -0.24,
                                                                        ),
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        lineHeight:
                                                                            1.5,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).labelSmallIsCustom,
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
                                                                          6.0,
                                                                          48.0,
                                                                          6.0),
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 24.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  letterSpacing:
                                                                      -0.24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  lineHeight:
                                                                      1.5,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
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
                                                                          .secondaryBackground;
                                                                    }
                                                                  }(),
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                ),
                                                                width: 2.0,
                                                              ),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            4.0,
                                                                            0.0),
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _model
                                                                            .passLoginTextController,
                                                                    focusNode:
                                                                        _model
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
                                                                          .labelSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).labelSmallFamily,
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.24,
                                                                              -0.24,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).labelSmallIsCustom,
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
                                                                          6.0,
                                                                          16.0,
                                                                          6.0),
                                                                      suffixIcon:
                                                                          InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          safeSetState(() =>
                                                                              _model.passLoginVisibility = !_model.passLoginVisibility);
                                                                        },
                                                                        focusNode:
                                                                            FocusNode(skipTraversal: true),
                                                                        child:
                                                                            Icon(
                                                                          _model.passLoginVisibility
                                                                              ? Icons.visibility_outlined
                                                                              : Icons.visibility_off_outlined,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
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
                                                                            .visiblePassword,
                                                                    cursorColor:
                                                                        FlutterFlowTheme.of(context)
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
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
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
                                                                        -0.4,
                                                                    lineHeight:
                                                                        1.5,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                            ),
                                                            Expanded(
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        1.0,
                                                                        0.0),
                                                                child:
                                                                    FFButtonWidget(
                                                                  onPressed:
                                                                      () async {
                                                                    _model.error =
                                                                        'error';
                                                                    _model.email =
                                                                        _model
                                                                            .emailLoginTextController
                                                                            .text;
                                                                    _model.currentAuthStep =
                                                                        3;
                                                                    _model.actionType =
                                                                        'password_reset';
                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text:
                                                                      'Passwort vergessen?',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).titleSmallFamily,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          letterSpacing:
                                                                              -0.4,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          lineHeight:
                                                                              1.5,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: Colors
                                                                          .transparent,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 8.0)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Builder(
                                    builder: (context) => Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          44.0,
                                          8.0,
                                          44.0,
                                          valueOrDefault<double>(
                                            (isWeb
                                                    ? MediaQuery.viewInsetsOf(
                                                                context)
                                                            .bottom >
                                                        0
                                                    : _isKeyboardVisible)
                                                ? 12.0
                                                : valueOrDefault<double>(
                                                    MediaQuery.paddingOf(
                                                                context)
                                                            .bottom +
                                                        24,
                                                    24.0,
                                                  ),
                                            24.0,
                                          )),
                                      child: FFButtonWidget(
                                        onPressed: ((_model.emailLoginTextController
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
                                                (!functions.validateEmail(_model
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
                                                var _shouldSetState = false;
                                                _model.email = _model
                                                    .emailLoginTextController
                                                    .text;
                                                _model.password = _model
                                                    .passLoginTextController
                                                    .text;
                                                _model.actionType =
                                                    _model.tab == 1
                                                        ? 'signin'
                                                        : 'signup';
                                                if (_model.tab == 1) {
                                                  if (_model.remember) {
                                                    FFAppState().email = _model
                                                        .emailLoginTextController
                                                        .text;
                                                    safeSetState(() {});
                                                  }
                                                  if (_model
                                                          .emailLoginTextController
                                                          .text ==
                                                      'test@gmail.com') {
                                                    _model.currentAuthStep = 2;
                                                    _model.timerStart = true;
                                                    safeSetState(() {});
                                                    _model.timerController
                                                        .onResetTimer();

                                                    await Future.delayed(
                                                      Duration(
                                                        milliseconds: 500,
                                                      ),
                                                    );
                                                    _model.timerController
                                                        .onStartTimer();
                                                  } else {
                                                    _model.login = await actions
                                                        .sendSignInOtp(
                                                      _model
                                                          .emailLoginTextController
                                                          .text,
                                                      _model
                                                          .passLoginTextController
                                                          .text,
                                                      'signin',
                                                    );
                                                    _shouldSetState = true;
                                                    await Future.delayed(
                                                      Duration(
                                                        milliseconds: 1000,
                                                      ),
                                                    );
                                                    if (_model.login ==
                                                        'success') {
                                                      _model.currentAuthStep =
                                                          2;
                                                      _model.timerStart = true;
                                                      safeSetState(() {});
                                                      _model.timerController
                                                          .onResetTimer();

                                                      await Future.delayed(
                                                        Duration(
                                                          milliseconds: 500,
                                                        ),
                                                      );
                                                      _model.timerController
                                                          .onStartTimer();
                                                    } else {
                                                      _model.error =
                                                          _model.login;
                                                      safeSetState(() {});
                                                      unawaited(
                                                        () async {}(),
                                                      );
                                                      showDialog(
                                                        barrierColor:
                                                            Colors.transparent,
                                                        context: context,
                                                        builder:
                                                            (dialogContext) {
                                                          return Dialog(
                                                            elevation: 0,
                                                            insetPadding:
                                                                EdgeInsets.zero,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            alignment: AlignmentDirectional(
                                                                    0.0, -1.0)
                                                                .resolve(
                                                                    Directionality.of(
                                                                        context)),
                                                            child:
                                                                SnackBarLightErrorWidget(
                                                              text: () {
                                                                if (_model
                                                                        .error ==
                                                                    'empty_fields') {
                                                                  return 'Email or password is empty';
                                                                } else if (_model
                                                                        .error ==
                                                                    'invalid_credentials') {
                                                                  return 'Die eingegebenen Login-Daten sind nicht korrekt';
                                                                } else if (_model
                                                                        .error ==
                                                                    'user_not_found') {
                                                                  return 'User not found';
                                                                } else if (_model
                                                                        .error ==
                                                                    'otp_failed') {
                                                                  return 'Failed to send OTP';
                                                                } else {
                                                                  return 'Error';
                                                                }
                                                              }(),
                                                              error: true,
                                                            ),
                                                          );
                                                        },
                                                      );

                                                      if (_shouldSetState)
                                                        safeSetState(() {});
                                                      return;
                                                    }
                                                  }
                                                }
                                                if (_shouldSetState)
                                                  safeSetState(() {});
                                              },
                                        text: 'Weiter',
                                        options: FFButtonOptions(
                                          width: double.infinity,
                                          height: 56.0,
                                          padding: EdgeInsets.all(16.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                letterSpacing:
                                                    valueOrDefault<double>(
                                                  -0.4,
                                                  -0.4,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                lineHeight: 1.5,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmallIsCustom,
                                              ),
                                          elevation: 0.0,
                                          borderRadius:
                                              BorderRadius.circular(360.0),
                                          disabledColor:
                                              FlutterFlowTheme.of(context)
                                                  .primary30,
                                          disabledTextColor:
                                              FlutterFlowTheme.of(context)
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
                  );
                } else if (_model.currentAuthStep == 2) {
                  return Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        12.0,
                        12.0,
                        12.0,
                        valueOrDefault<double>(
                          MediaQuery.paddingOf(context).bottom + 24,
                          24.0,
                        )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 56.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(99.0),
                              ),
                              child: FlutterFlowIconButton(
                                borderColor: Colors.transparent,
                                borderRadius: 99.0,
                                buttonSize: 40.0,
                                fillColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                icon: Icon(
                                  FFIcons.karrowLeftLong,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 24.0,
                                ),
                                onPressed: () async {
                                  _model.currentAuthStep =
                                      _model.actionType == 'password_reset'
                                          ? 3
                                          : 1;
                                  safeSetState(() {});
                                },
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 40.0, 0.0),
                                child: Text(
                                  'Bestätige Registrierung',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        fontSize: 20.0,
                                        letterSpacing: -0.8,
                                        lineHeight: 1.4,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!(isWeb
                                    ? MediaQuery.viewInsetsOf(context).bottom >
                                        0
                                    : _isKeyboardVisible))
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'Bist du das wirklich?',
                                      style: FlutterFlowTheme.of(context)
                                          .headlineSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .headlineSmallFamily,
                                            letterSpacing:
                                                valueOrDefault<double>(
                                              -0.96,
                                              -0.96,
                                            ),
                                            fontWeight: FontWeight.w500,
                                            lineHeight: 1.4,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .headlineSmallIsCustom,
                                          ),
                                    ),
                                  ),
                                RichText(
                                  textScaler: MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            'Gib den Code ein, den wir an deine E-Mail-Adresse ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              fontSize: 14.0,
                                              letterSpacing: -0.35,
                                              fontWeight: FontWeight.w500,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                      TextSpan(
                                        text: _model.email!,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              fontSize: 14.0,
                                              letterSpacing: -0.35,
                                              fontWeight: FontWeight.bold,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                      TextSpan(
                                        text: ' gesendet haben.',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              fontSize: 14.0,
                                              letterSpacing: -0.35,
                                              fontWeight: FontWeight.w500,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      )
                                    ],
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                ),
                                PinCodeTextField(
                                  autoDisposeControllers: false,
                                  appContext: context,
                                  length: 4,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        fontFamily: 'Dela Gothic One',
                                        letterSpacing: valueOrDefault<double>(
                                          -1.08,
                                          -1.08,
                                        ),
                                        fontWeight: FontWeight.normal,
                                        lineHeight: 1.2,
                                      ),
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  enableActiveFill: true,
                                  autoFocus: true,
                                  focusNode: _model.pinCodeFocusNode,
                                  enablePinAutofill: false,
                                  errorTextSpace: 16.0,
                                  showCursor: false,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primary,
                                  obscureText: false,
                                  hintCharacter: '-',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  pinTheme: PinTheme(
                                    fieldHeight: 88.0,
                                    fieldWidth: 68.0,
                                    borderWidth: 0.0,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(16.0),
                                      bottomRight: Radius.circular(16.0),
                                      topLeft: Radius.circular(16.0),
                                      topRight: Radius.circular(16.0),
                                    ),
                                    shape: PinCodeFieldShape.box,
                                    activeColor: valueOrDefault<Color>(
                                      _model.codeError
                                          ? FlutterFlowTheme.of(context).error
                                          : FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                    inactiveColor: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    selectedColor:
                                        FlutterFlowTheme.of(context).focus,
                                    activeFillColor:
                                        FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                    inactiveFillColor:
                                        FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                    selectedFillColor:
                                        FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                  ),
                                  controller: _model.pinCodeController,
                                  onChanged: (_) async {
                                    _model.error = 'error';
                                    _model.codeError = false;
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: _model.pinCodeControllerValidator
                                      .asValidator(context),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AutoSizeText(
                                      'Code nicht erhalten?',
                                      maxLines: 1,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            fontSize: 16.0,
                                            letterSpacing: -0.4,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ),
                                    Builder(
                                      builder: (context) {
                                        if (_model.timerStart) {
                                          return Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 2.0, 0.0, 2.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Erneut senden in',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                            letterSpacing: -0.4,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            lineHeight: 1.5,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallIsCustom,
                                                          ),
                                                ),
                                                FlutterFlowTimer(
                                                  initialTime:
                                                      _model.timerInitialTimeMs,
                                                  getDisplayTime: (value) =>
                                                      StopWatchTimer
                                                          .getDisplayTime(
                                                    value,
                                                    hours: false,
                                                    milliSecond: false,
                                                  ),
                                                  controller:
                                                      _model.timerController,
                                                  updateStateInterval: Duration(
                                                      milliseconds: 1000),
                                                  onChanged: (value,
                                                      displayTime,
                                                      shouldUpdate) {
                                                    _model.timerMilliseconds =
                                                        value;
                                                    _model.timerValue =
                                                        displayTime;
                                                    if (shouldUpdate)
                                                      safeSetState(() {});
                                                  },
                                                  onEnded: () async {
                                                    _model.timerStart = false;
                                                    safeSetState(() {});
                                                  },
                                                  textAlign: TextAlign.start,
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .headlineSmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineSmallFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            lineHeight: 1.5,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineSmallIsCustom,
                                                          ),
                                                ),
                                                Text(
                                                  'Sekunden.',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            lineHeight: 1.5,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallIsCustom,
                                                          ),
                                                ),
                                              ].divide(SizedBox(width: 4.0)),
                                            ),
                                          );
                                        } else {
                                          return InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              _model.timerStart = true;
                                              safeSetState(() {});
                                              _model.timerController
                                                  .onResetTimer();

                                              await Future.delayed(
                                                Duration(
                                                  milliseconds: 500,
                                                ),
                                              );
                                              _model.timerController
                                                  .onStartTimer();
                                              _model.resend =
                                                  await actions.resendOtp(
                                                _model.email!,
                                                _model.actionType!,
                                              );
                                              FFAppState().refreshDate =
                                                  getCurrentTimestamp;
                                              FFAppState().update(() {});

                                              safeSetState(() {});
                                            },
                                            child: Text(
                                              'Code erneut senden',
                                              textAlign: TextAlign.center,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    letterSpacing:
                                                        valueOrDefault<double>(
                                                      -0.4,
                                                      -0.4,
                                                    ),
                                                    fontWeight: FontWeight.bold,
                                                    lineHeight: 1.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ].divide(SizedBox(height: 24.0)),
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0.0, 1.0),
                          child: Builder(
                            builder: (context) => Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  32.0, 8.0, 32.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: ((_model.pinCodeController!.text ==
                                                null ||
                                            _model.pinCodeController!.text ==
                                                '') ||
                                        ((_model.pinCodeController!.text
                                                .length) <
                                            4))
                                    ? null
                                    : () async {
                                        var _shouldSetState = false;
                                        FFAppState().firstOpen = false;
                                        safeSetState(() {});
                                        _model.codeError = false;
                                        safeSetState(() {});
                                        if (_model.email == 'test@gmail.com') {
                                          GoRouter.of(context)
                                              .prepareAuthEvent();

                                          final user =
                                              await authManager.signInWithEmail(
                                            context,
                                            _model.email!,
                                            _model.password!,
                                          );
                                          if (user == null) {
                                            return;
                                          }

                                          await showDialog(
                                            barrierColor: Colors.transparent,
                                            context: context,
                                            builder: (dialogContext) {
                                              return Dialog(
                                                elevation: 0,
                                                insetPadding: EdgeInsets.zero,
                                                backgroundColor:
                                                    Colors.transparent,
                                                alignment: AlignmentDirectional(
                                                        0.0, -1.0)
                                                    .resolve(Directionality.of(
                                                        context)),
                                                child:
                                                    SnackBarWhiteSuccessWidget(
                                                  text:
                                                      'Erfolgreich angemeldet!',
                                                  error: false,
                                                ),
                                              );
                                            },
                                          );

                                          FFAppState().hasGuestGetLichtwatt =
                                              false;
                                          FFAppState().update(() {});
                                          Navigator.pop(context, true);
                                          if (_shouldSetState)
                                            safeSetState(() {});
                                          return;
                                        } else {
                                          _model.verify =
                                              await actions.verifyOtp(
                                            _model.email!,
                                            _model.pinCodeController!.text,
                                          );
                                          _shouldSetState = true;
                                          if (_model.verify == 'success') {
                                            if (_model.actionType !=
                                                'password_reset') {
                                              _model.auth = await actions
                                                  .signInAfterOtpVerification(
                                                _model.email!,
                                                _model.password!,
                                                _model.actionType!,
                                                _model.firstName,
                                                _model.username,
                                              );
                                              _shouldSetState = true;
                                              if (_model.auth!) {
                                                if (isWeb) {
                                                  if (!kDebugMode) {
                                                    _model.adminLogin =
                                                        await actions.isAdmin(
                                                      currentUserUid,
                                                    );
                                                    _shouldSetState = true;
                                                    if (_model.adminLogin!) {
                                                      context.goNamedAuth(
                                                        StatisticsAdminWidget
                                                            .routeName,
                                                        context.mounted,
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

                                                      FFAppState().adminPage =
                                                          AdminPages
                                                              .statistics.name;
                                                      FFAppState()
                                                          .update(() {});
                                                    } else {
                                                      GoRouter.of(context)
                                                          .prepareAuthEvent();
                                                      await authManager
                                                          .signOut();
                                                      GoRouter.of(context)
                                                          .clearRedirectLocation();
                                                    }

                                                    if (_shouldSetState)
                                                      safeSetState(() {});
                                                    return;
                                                  }
                                                }
                                                await showDialog(
                                                  barrierColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (dialogContext) {
                                                    return Dialog(
                                                      elevation: 0,
                                                      insetPadding:
                                                          EdgeInsets.zero,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      alignment:
                                                          AlignmentDirectional(
                                                                  0.0, -1.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                      child:
                                                          SnackBarWhiteSuccessWidget(
                                                        text:
                                                            'Erfolgreich angemeldet!',
                                                        error: false,
                                                      ),
                                                    );
                                                  },
                                                );

                                                FFAppState()
                                                        .hasGuestGetLichtwatt =
                                                    false;
                                                FFAppState().update(() {});
                                                Navigator.pop(context, true);
                                              } else {
                                                _model.codeError = true;
                                                safeSetState(() {});
                                                if (_shouldSetState)
                                                  safeSetState(() {});
                                                return;
                                              }
                                            } else {
                                              _model.currentAuthStep = 4;
                                              safeSetState(() {});
                                              if (_shouldSetState)
                                                safeSetState(() {});
                                              return;
                                            }
                                          } else {
                                            _model.codeError = true;
                                            safeSetState(() {});
                                            unawaited(
                                              () async {}(),
                                            );
                                            showDialog(
                                              barrierColor: Colors.transparent,
                                              context: context,
                                              builder: (dialogContext) {
                                                return Dialog(
                                                  elevation: 0,
                                                  insetPadding: EdgeInsets.zero,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  alignment:
                                                      AlignmentDirectional(
                                                              0.0, -0.5)
                                                          .resolve(
                                                              Directionality.of(
                                                                  context)),
                                                  child:
                                                      SnackBarLightErrorWidget(
                                                    text: () {
                                                      if (_model.verify ==
                                                          'used') {
                                                        return 'Future<String> verifyOtp(String email, String code) async {  try {    final supabase = Supabase.instance.client;        print(\'Verifying OTP for: \$email with code: \$code\');    final response = await supabase.functions.invoke(      \'verify-otp\',      body: {        \'email\': email,        \'code\': code,      },    );    print(\'Verify response status: \${response.status}\');    print(\'Verify response data: \${response.data}\');    if (response.status == 200 && response.data?[\'success\'] == true) {      print(\'Success: OTP verified successfully\');      return \'success\';    } else {      String errorMessage = response.data?[\'error\'] ?? \'Unknown error\';            if (errorMessage.toLowerCase().contains(\'already used\')) {        print(\'Error: This code has already been used';
                                                      } else if (_model
                                                              .verify ==
                                                          'invalid') {
                                                        return 'Invalid code provided';
                                                      } else if (_model
                                                              .verify ==
                                                          'expired') {
                                                        return 'This code has expired';
                                                      } else {
                                                        return 'Error';
                                                      }
                                                    }(),
                                                    error: true,
                                                  ),
                                                );
                                              },
                                            );

                                            if (_shouldSetState)
                                              safeSetState(() {});
                                            return;
                                          }
                                        }

                                        if (_shouldSetState)
                                          safeSetState(() {});
                                      },
                                text: 'Weiter',
                                icon: Icon(
                                  FFIcons.krightArrow,
                                  size: 16.0,
                                ),
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 56.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconAlignment: IconAlignment.end,
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  iconColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        letterSpacing: -0.4,
                                        fontWeight: FontWeight.w600,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(99.0),
                                  disabledColor:
                                      FlutterFlowTheme.of(context).primary30,
                                  disabledTextColor:
                                      FlutterFlowTheme.of(context).primary50,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 24.0)),
                    ),
                  );
                } else if (_model.currentAuthStep == 3) {
                  return Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        12.0,
                        12.0,
                        12.0,
                        valueOrDefault<double>(
                          MediaQuery.paddingOf(context).bottom + 24,
                          24.0,
                        )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              4.0, 0.0, 4.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 56.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(99.0),
                                ),
                                child: FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 99.0,
                                  buttonSize: 40.0,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  icon: Icon(
                                    FFIcons.karrowLeftLong,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    _model.currentAuthStep = 1;
                                    safeSetState(() {});
                                  },
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 40.0, 0.0),
                                  child: Text(
                                    'Passwort vergessen',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmallFamily,
                                          fontSize: 20.0,
                                          letterSpacing: valueOrDefault<double>(
                                            -0.8,
                                            -0.8,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 1.4,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleSmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'Passwort zurücksetzen',
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmallFamily,
                                          fontSize: 24.0,
                                          letterSpacing: -0.96,
                                          lineHeight: 1.4,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleSmallIsCustom,
                                        ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'Trage deine E-Mail-Adresse ein, an die wir den Code zum Zurücksetzen des Passworts senden.',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          letterSpacing: -0.35,
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                ),
                                Stack(
                                  alignment: AlignmentDirectional(1.0, 0.0),
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        minHeight: 56.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            (_model.emailLoginPasswordResetFocusNode
                                                        ?.hasFocus ??
                                                    false)
                                                ? FlutterFlowTheme.of(context)
                                                    .focus
                                                : FlutterFlowTheme.of(context)
                                                    .primaryBackground,
                                            FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                          ),
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Container(
                                          width: double.infinity,
                                          child: TextFormField(
                                            controller: _model
                                                .emailLoginPasswordResetTextController,
                                            focusNode: _model
                                                .emailLoginPasswordResetFocusNode,
                                            autofocus: false,
                                            textCapitalization:
                                                TextCapitalization.none,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              labelText: 'Deine E-Mail-Adresse',
                                              labelStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color:
                                                        valueOrDefault<Color>(
                                                      _model.emailLoginPasswordResetTextController
                                                                      .text !=
                                                                  null &&
                                                              _model.emailLoginPasswordResetTextController
                                                                      .text !=
                                                                  ''
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText50,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryText50,
                                                    ),
                                                    fontSize: 16.0,
                                                    letterSpacing:
                                                        valueOrDefault<double>(
                                                      -0.24,
                                                      -0.24,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                    lineHeight: 1.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              hintStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText50,
                                                    fontSize: 16.0,
                                                    letterSpacing:
                                                        valueOrDefault<double>(
                                                      -0.4,
                                                      -0.4,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                    lineHeight: 1.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumIsCustom,
                                                  ),
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              focusedErrorBorder:
                                                  InputBorder.none,
                                              contentPadding:
                                                  EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          16.0, 6.0, 48.0, 6.0),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  fontSize: 16.0,
                                                  letterSpacing: -0.4,
                                                  fontWeight: FontWeight.w500,
                                                  lineHeight: 1.5,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                            maxLength: 50,
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
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .emailLoginPasswordResetTextControllerValidator
                                                .asValidator(context),
                                            inputFormatters: [
                                              if (!isAndroid && !isiOS)
                                                TextInputFormatter.withFunction(
                                                    (oldValue, newValue) {
                                                  return TextEditingValue(
                                                    selection:
                                                        newValue.selection,
                                                    text: newValue.text
                                                        .toCapitalization(
                                                            TextCapitalization
                                                                .none),
                                                  );
                                                }),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(1.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 16.0, 0.0),
                                        child: Icon(
                                          FFIcons.kmail,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ].divide(SizedBox(height: 24.0)),
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0.0, 1.0),
                          child: Builder(
                            builder: (context) => Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  44.0, 8.0, 44.0, 0.0),
                              child: FFButtonWidget(
                                onPressed:
                                    (_model.emailLoginPasswordResetTextController
                                                    .text ==
                                                null ||
                                            _model.emailLoginPasswordResetTextController
                                                    .text ==
                                                '')
                                        ? null
                                        : () async {
                                            _model.reset = await actions
                                                .sendPasswordResetOtp(
                                              _model
                                                  .emailLoginPasswordResetTextController
                                                  .text,
                                            );
                                            if (_model.reset == 'success') {
                                              _model.currentAuthStep = 2;
                                              _model.timerStart = true;
                                              _model.email = _model
                                                  .emailLoginPasswordResetTextController
                                                  .text;
                                              safeSetState(() {});
                                              _model.timerController
                                                  .onResetTimer();

                                              await Future.delayed(
                                                Duration(
                                                  milliseconds: 500,
                                                ),
                                              );
                                              _model.timerController
                                                  .onStartTimer();
                                            } else {
                                              unawaited(
                                                () async {}(),
                                              );
                                              showDialog(
                                                barrierColor:
                                                    Colors.transparent,
                                                context: context,
                                                builder: (dialogContext) {
                                                  return Dialog(
                                                    elevation: 0,
                                                    insetPadding:
                                                        EdgeInsets.zero,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    alignment:
                                                        AlignmentDirectional(
                                                                0.0, -0.6)
                                                            .resolve(
                                                                Directionality.of(
                                                                    context)),
                                                    child:
                                                        SnackBarLightErrorWidget(
                                                      text:
                                                          'Error: Failed to send OTP',
                                                      error: true,
                                                    ),
                                                  );
                                                },
                                              );
                                            }

                                            safeSetState(() {});
                                          },
                                text: 'E-Mail senden',
                                icon: Icon(
                                  FFIcons.krightArrow,
                                  size: 16.0,
                                ),
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 56.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconAlignment: IconAlignment.end,
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  iconColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(99.0),
                                  disabledColor:
                                      FlutterFlowTheme.of(context).primary30,
                                  disabledTextColor:
                                      FlutterFlowTheme.of(context).primary50,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 24.0)),
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        12.0,
                        24.0,
                        12.0,
                        valueOrDefault<double>(
                          MediaQuery.paddingOf(context).bottom + 24,
                          24.0,
                        )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 56.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(99.0),
                              ),
                              child: FlutterFlowIconButton(
                                borderColor: Colors.transparent,
                                borderRadius: 99.0,
                                buttonSize: 40.0,
                                fillColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                icon: Icon(
                                  FFIcons.karrowLeftLong,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 24.0,
                                ),
                                onPressed: () async {
                                  _model.currentAuthStep = 3;
                                  safeSetState(() {});
                                },
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 40.0, 0.0),
                                child: Text(
                                  'Neues Passwort',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        fontSize: 20.0,
                                        letterSpacing: valueOrDefault<double>(
                                          -0.8,
                                          -0.8,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1.4,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: AutoSizeText(
                                    'Wähle ein neues Passwort',
                                    maxLines: 1,
                                    style: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .headlineSmallFamily,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 1.2,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .headlineSmallIsCustom,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 32.0, 0.0, 0.0),
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minHeight: 56.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: valueOrDefault<Color>(
                                          () {
                                            if ((_model.newPassFocusNode
                                                    ?.hasFocus ??
                                                false)) {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .focus;
                                            } else if (!valueOrDefault<bool>(
                                                  functions.validatePassword(
                                                      _model
                                                          .newPassTextController
                                                          .text),
                                                  false,
                                                ) &&
                                                valueOrDefault<bool>(
                                                  _model.newPassTextController
                                                              .text !=
                                                          null &&
                                                      _model.newPassTextController
                                                              .text !=
                                                          '',
                                                  false,
                                                )) {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .error;
                                            } else {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primaryBackground;
                                            }
                                          }(),
                                          FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                        ),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.newPassTextController,
                                          focusNode: _model.newPassFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.newPassTextController',
                                            Duration(milliseconds: 50),
                                            () => safeSetState(() {}),
                                          ),
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.none,
                                          obscureText:
                                              !_model.newPassVisibility,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'Neues Passwort',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.newPassTextController
                                                                    .text !=
                                                                null &&
                                                            _model.newPassTextController
                                                                    .text !=
                                                                ''
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText50,
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText50,
                                                  ),
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  lineHeight: 1.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallIsCustom,
                                                ),
                                            hintStyle: FlutterFlowTheme.of(
                                                    context)
                                                .labelMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMediumFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText50,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  lineHeight: 1.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .labelMediumIsCustom,
                                                ),
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            focusedErrorBorder:
                                                InputBorder.none,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 6.0, 48.0, 6.0),
                                            suffixIcon: InkWell(
                                              onTap: () async {
                                                safeSetState(() => _model
                                                        .newPassVisibility =
                                                    !_model.newPassVisibility);
                                              },
                                              focusNode: FocusNode(
                                                  skipTraversal: true),
                                              child: Icon(
                                                _model.newPassVisibility
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                size: 24.0,
                                              ),
                                            ),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                lineHeight: 1.0,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMediumIsCustom,
                                              ),
                                          maxLength: 50,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.none,
                                          buildCounter: (context,
                                                  {required currentLength,
                                                  required isFocused,
                                                  maxLength}) =>
                                              null,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          validator: _model
                                              .newPassTextControllerValidator
                                              .asValidator(context),
                                          inputFormatters: [
                                            if (!isAndroid && !isiOS)
                                              TextInputFormatter.withFunction(
                                                  (oldValue, newValue) {
                                                return TextEditingValue(
                                                  selection: newValue.selection,
                                                  text: newValue.text
                                                      .toCapitalization(
                                                          TextCapitalization
                                                              .none),
                                                );
                                              }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: 0.75,
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 4.0, 0.0, 0.0),
                                      child: Text(
                                        'Mindestens 10 Zeichen, eine Zahl, ein Großbuchstabe, ein Sonderzeichen',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmallFamily,
                                              color: valueOrDefault<Color>(
                                                !valueOrDefault<bool>(
                                                          functions
                                                              .validatePassword(
                                                                  _model
                                                                      .newPassTextController
                                                                      .text),
                                                          false,
                                                        ) &&
                                                        valueOrDefault<bool>(
                                                          _model.newPassTextController
                                                                      .text !=
                                                                  null &&
                                                              _model.newPassTextController
                                                                      .text !=
                                                                  '',
                                                          false,
                                                        )
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                              ),
                                              letterSpacing: -0.24,
                                              fontWeight: FontWeight.w500,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .labelSmallIsCustom,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 24.0, 0.0, 0.0),
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minHeight: 56.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: valueOrDefault<Color>(
                                          (_model.confirmPassFocusNode
                                                      ?.hasFocus ??
                                                  false)
                                              ? FlutterFlowTheme.of(context)
                                                  .focus
                                              : FlutterFlowTheme.of(context)
                                                  .primaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                        ),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.confirmPassTextController,
                                          focusNode:
                                              _model.confirmPassFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.confirmPassTextController',
                                            Duration(milliseconds: 50),
                                            () => safeSetState(() {}),
                                          ),
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.none,
                                          obscureText:
                                              !_model.confirmPassVisibility,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'Passwort bestätigen',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.confirmPassTextController
                                                                    .text !=
                                                                null &&
                                                            _model.confirmPassTextController
                                                                    .text !=
                                                                ''
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText50,
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText50,
                                                  ),
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  lineHeight: 1.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallIsCustom,
                                                ),
                                            hintStyle: FlutterFlowTheme.of(
                                                    context)
                                                .labelMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMediumFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText50,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  lineHeight: 1.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .labelMediumIsCustom,
                                                ),
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            focusedErrorBorder:
                                                InputBorder.none,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 6.0, 48.0, 6.0),
                                            suffixIcon: InkWell(
                                              onTap: () async {
                                                safeSetState(() => _model
                                                        .confirmPassVisibility =
                                                    !_model
                                                        .confirmPassVisibility);
                                              },
                                              focusNode: FocusNode(
                                                  skipTraversal: true),
                                              child: Icon(
                                                _model.confirmPassVisibility
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                size: 24.0,
                                              ),
                                            ),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                lineHeight: 1.0,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMediumIsCustom,
                                              ),
                                          maxLength: 50,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.none,
                                          buildCounter: (context,
                                                  {required currentLength,
                                                  required isFocused,
                                                  maxLength}) =>
                                              null,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          validator: _model
                                              .confirmPassTextControllerValidator
                                              .asValidator(context),
                                          inputFormatters: [
                                            if (!isAndroid && !isiOS)
                                              TextInputFormatter.withFunction(
                                                  (oldValue, newValue) {
                                                return TextEditingValue(
                                                  selection: newValue.selection,
                                                  text: newValue.text
                                                      .toCapitalization(
                                                          TextCapitalization
                                                              .none),
                                                );
                                              }),
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
                        Align(
                          alignment: AlignmentDirectional(0.0, 1.0),
                          child: Builder(
                            builder: (context) => Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  44.0, 8.0, 44.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: ((_model.newPassTextController
                                                    .text ==
                                                null ||
                                            _model.newPassTextController.text ==
                                                '') ||
                                        (_model.confirmPassTextController
                                                    .text ==
                                                null ||
                                            _model.confirmPassTextController
                                                    .text ==
                                                '') ||
                                        (_model.newPassTextController.text !=
                                            _model.confirmPassTextController
                                                .text) ||
                                        (!valueOrDefault<bool>(
                                              functions.validatePassword(_model
                                                  .newPassTextController.text),
                                              false,
                                            ) &&
                                            valueOrDefault<bool>(
                                              _model.newPassTextController
                                                          .text !=
                                                      null &&
                                                  _model.newPassTextController
                                                          .text !=
                                                      '',
                                              false,
                                            )))
                                    ? null
                                    : () async {
                                        var _shouldSetState = false;
                                        if (!functions.validatePassword(_model
                                            .confirmPassTextController.text)) {
                                          if (_shouldSetState)
                                            safeSetState(() {});
                                          return;
                                        }
                                        _model.update =
                                            await actions.updatePassword(
                                          _model.newPassTextController.text,
                                          _model.email!,
                                        );
                                        _shouldSetState = true;
                                        if (_model.update == 'success') {
                                          _model.instantTimer =
                                              InstantTimer.periodic(
                                            duration:
                                                Duration(milliseconds: 1000),
                                            callback: (timer) async {
                                              if (loggedIn) {
                                                FFAppState().refreshDate =
                                                    getCurrentTimestamp;
                                                FFAppState().update(() {});
                                                await showDialog(
                                                  barrierColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (dialogContext) {
                                                    return Dialog(
                                                      elevation: 0,
                                                      insetPadding:
                                                          EdgeInsets.zero,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      alignment:
                                                          AlignmentDirectional(
                                                                  0.0, -1.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                      child:
                                                          SnackBarWhiteSuccessWidget(
                                                        text:
                                                            'Erfolgreich angemeldet!',
                                                        error: false,
                                                      ),
                                                    );
                                                  },
                                                );

                                                FFAppState()
                                                        .hasGuestGetLichtwatt =
                                                    false;
                                                FFAppState().update(() {});
                                                Navigator.pop(context, true);
                                                _model.instantTimer?.cancel();
                                              }
                                            },
                                            startImmediately: true,
                                          );
                                        } else {
                                          unawaited(
                                            () async {}(),
                                          );
                                          showDialog(
                                            barrierColor: Colors.transparent,
                                            context: context,
                                            builder: (dialogContext) {
                                              return Dialog(
                                                elevation: 0,
                                                insetPadding: EdgeInsets.zero,
                                                backgroundColor:
                                                    Colors.transparent,
                                                alignment: AlignmentDirectional(
                                                        0.0, -0.6)
                                                    .resolve(Directionality.of(
                                                        context)),
                                                child: SnackBarLightErrorWidget(
                                                  text:
                                                      'Error in updatePassword: ${_model.update}',
                                                  error: true,
                                                ),
                                              );
                                            },
                                          );
                                        }

                                        if (_shouldSetState)
                                          safeSetState(() {});
                                      },
                                text: 'Anmelden',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 56.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconAlignment: IconAlignment.end,
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        letterSpacing: -0.4,
                                        fontWeight: FontWeight.w600,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(99.0),
                                  disabledColor:
                                      FlutterFlowTheme.of(context).primary30,
                                  disabledTextColor:
                                      FlutterFlowTheme.of(context).primary50,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 24.0)),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
