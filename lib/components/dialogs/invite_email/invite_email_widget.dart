import '/components/close_keyboard_widget.dart';
import '/components/dialogs/snack_bar/snack_bar_widget.dart';
import '/components/dialogs/snack_bar_light_error/snack_bar_light_error_widget.dart';
import '/components/dialogs/snack_bar_white_success/snack_bar_white_success_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'invite_email_model.dart';
export 'invite_email_model.dart';

class InviteEmailWidget extends StatefulWidget {
  const InviteEmailWidget({super.key});

  @override
  State<InviteEmailWidget> createState() => _InviteEmailWidgetState();
}

class _InviteEmailWidgetState extends State<InviteEmailWidget> {
  late InviteEmailModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InviteEmailModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          constraints: BoxConstraints(
            maxWidth: 600.0,
          ),
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
            width: double.infinity,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(4.0, 12.0, 4.0, 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 56.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 99.0,
                          buttonSize: 40.0,
                          fillColor: FlutterFlowTheme.of(context).alternate,
                          icon: Icon(
                            FFIcons.kxmark,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Freunde einladen',
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Dela Gothic One',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    lineHeight: 1.4,
                                  ),
                        ),
                      ),
                      Container(
                        width: 56.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                        child: Visibility(
                          visible: false,
                          child: Builder(
                            builder: (context) => FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 99.0,
                              buttonSize: 40.0,
                              fillColor: FlutterFlowTheme.of(context).alternate,
                              icon: Icon(
                                FFIcons.kcheck2,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 14.0,
                              ),
                              showLoadingIndicator: true,
                              onPressed: () async {
                                if (_model.textController.text != null &&
                                    _model.textController.text != '') {
                                  if ((_model.textController.text.length) <=
                                      50) {
                                    _model.invite = await actions.inviteUser(
                                      _model.textController.text,
                                    );
                                    if (_model.invite == 'success') {
                                      Navigator.pop(context);
                                      showDialog(
                                        barrierColor: Colors.transparent,
                                        context: context,
                                        builder: (dialogContext) {
                                          return Dialog(
                                            elevation: 0,
                                            insetPadding: EdgeInsets.zero,
                                            backgroundColor: Colors.transparent,
                                            alignment: AlignmentDirectional(
                                                    0.0, 1.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                            child: SnackBarWidget(
                                              text:
                                                  'Invitation sent successfully!',
                                              error: false,
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      _model.error = true;
                                      safeSetState(() {});
                                      showDialog(
                                        barrierColor: Colors.transparent,
                                        context: context,
                                        builder: (dialogContext) {
                                          return Dialog(
                                            elevation: 0,
                                            insetPadding: EdgeInsets.zero,
                                            backgroundColor: Colors.transparent,
                                            alignment: AlignmentDirectional(
                                                    0.0, 1.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                            child: SnackBarWidget(
                                              text: () {
                                                if (_model.invite ==
                                                    'already_invited') {
                                                  return 'This email is already invited';
                                                } else if (_model.invite ==
                                                    'already_registered') {
                                                  return 'This email is already registered';
                                                } else if (_model.invite ==
                                                    'cannot_invite_self') {
                                                  return 'You cannot invite yourself';
                                                } else if (_model.invite ==
                                                    'invalid_email') {
                                                  return 'Invalid email format';
                                                } else {
                                                  return 'Error: ${_model.invite}';
                                                }
                                              }(),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    _model.error = true;
                                    safeSetState(() {});
                                  }
                                }

                                safeSetState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                    child: SingleChildScrollView(
                      primary: false,
                      controller: _model.columnController,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                12.0, 16.0, 12.0, 0.0),
                            child: Text(
                              'Lade deine Freunde ein und erweitere deinen Good Circle - deinen besonderen Freundeskreis aus Menschen, die die Welt mit dir gemeinsam besser machen. ',
                              style: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .labelLargeFamily,
                                    color: Colors.black,
                                    letterSpacing: valueOrDefault<double>(
                                      -0.4,
                                      -0.4,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1.5,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .labelLargeIsCustom,
                                  ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 8.0, 0.0, 0.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(),
                                child: Image.asset(
                                  'assets/images/grafik.png',
                                  width: 280.0,
                                  height: 280.0,
                                  fit: BoxFit.cover,
                                  alignment: Alignment(0.0, 0.0),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 5.0, 0.0, 0.0),
                              child: Text(
                                'Good Power',
                                style: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .headlineSmallFamily,
                                      letterSpacing: valueOrDefault<double>(
                                        -0.96,
                                        -0.96,
                                      ),
                                      lineHeight: 1.4,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .headlineSmallIsCustom,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Text(
                              '+ 10',
                              style: FlutterFlowTheme.of(context)
                                  .displayMedium
                                  .override(
                                    fontFamily: 'Dela Gothic One',
                                    fontSize: 40.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Text(
                              'Lichtwatt mit jeder registrierten Person',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    letterSpacing: valueOrDefault<double>(
                                      -0.35,
                                      -0.35,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1.5,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 44.0, 0.0, 0.0),
                            child: Form(
                              key: _model.formKey,
                              autovalidateMode: AutovalidateMode.disabled,
                              child: Container(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _model.textController,
                                  focusNode: _model.textFieldFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.textController',
                                    Duration(milliseconds: 50),
                                    () async {
                                      _model.error = false;
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
                                    hintText: 'E-Mail-Adresse eingeben',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .labelMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText50,
                                          fontSize: 16.0,
                                          letterSpacing: valueOrDefault<double>(
                                            -0.4,
                                            -0.4,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .labelMediumIsCustom,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: valueOrDefault<Color>(
                                          _model.error
                                              ? FlutterFlowTheme.of(context)
                                                  .error
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF53D5FF),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    contentPadding:
                                        EdgeInsetsDirectional.fromSTEB(
                                            16.0, 16.0, 60.0, 16.0),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodyMediumFamily,
                                        fontSize: 16.0,
                                        letterSpacing: valueOrDefault<double>(
                                          -0.4,
                                          -0.4,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodyMediumIsCustom,
                                      ),
                                  maxLines: 2,
                                  minLines: 1,
                                  maxLength: 50,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.none,
                                  buildCounter: (context,
                                          {required currentLength,
                                          required isFocused,
                                          maxLength}) =>
                                      null,
                                  keyboardType: TextInputType.emailAddress,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  validator: _model.textControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          if (false)
                            Align(
                              alignment: AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 4.0, 16.0, 0.0),
                                child: Text(
                                  'Maximal 50 Zeichen',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodyMediumFamily,
                                        color: valueOrDefault<Color>(
                                          (_model.textController.text
                                                      .length) >
                                                  50
                                              ? FlutterFlowTheme.of(context)
                                                  .error
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                        letterSpacing: valueOrDefault<double>(
                                          -0.35,
                                          -0.35,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodyMediumIsCustom,
                                      ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Builder(
                              builder: (context) => Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    32.0,
                                    32.0,
                                    32.0,
                                    valueOrDefault<double>(
                                      MediaQuery.paddingOf(context).bottom + 24,
                                      24.0,
                                    )),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    if (_model.textController.text != null &&
                                        _model.textController.text != '') {
                                      if ((_model.textController.text.length) <=
                                          50) {
                                        _model.inviteCopy =
                                            await actions.inviteUser(
                                          _model.textController.text,
                                        );
                                        if (_model.inviteCopy == 'success') {
                                          Navigator.pop(context);
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
                                                        0.0, -1.0)
                                                    .resolve(Directionality.of(
                                                        context)),
                                                child:
                                                    SnackBarWhiteSuccessWidget(
                                                  text: 'Einladung verschickt!',
                                                  error: false,
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          _model.error = true;
                                          safeSetState(() {});
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
                                                        0.0, -0.5)
                                                    .resolve(Directionality.of(
                                                        context)),
                                                child: SnackBarLightErrorWidget(
                                                  text: () {
                                                    if (_model.inviteCopy ==
                                                        'already_invited') {
                                                      return 'This email is already invited';
                                                    } else if (_model
                                                            .inviteCopy ==
                                                        'already_registered') {
                                                      return 'This email is already registered';
                                                    } else if (_model
                                                            .inviteCopy ==
                                                        'cannot_invite_self') {
                                                      return 'You cannot invite yourself';
                                                    } else if (_model
                                                            .inviteCopy ==
                                                        'invalid_email') {
                                                      return 'Das sieht nicht nach einer gültigen E-Mail-Adresse aus.';
                                                    } else {
                                                      return 'Error: ${_model.inviteCopy}';
                                                    }
                                                  }(),
                                                  error: true,
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      } else {
                                        _model.error = true;
                                        safeSetState(() {});
                                      }
                                    }

                                    safeSetState(() {});
                                  },
                                  text: 'Einladen',
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 56.0,
                                    padding: EdgeInsets.all(16.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmallFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          letterSpacing: valueOrDefault<double>(
                                            -0.4,
                                            -0.4,
                                          ),
                                          fontWeight: FontWeight.w600,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleSmallIsCustom,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(360.0),
                                  ),
                                  showLoadingIndicator: false,
                                ),
                              ),
                            ),
                          ),
                          if (false)
                            Align(
                              alignment: AlignmentDirectional(1.0, 1.0),
                              child: wrapWithModel(
                                model: _model.closeKeyboardModel,
                                updateCallback: () => safeSetState(() {}),
                                updateOnChange: true,
                                child: CloseKeyboardWidget(),
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
        ),
      ),
    );
  }
}
