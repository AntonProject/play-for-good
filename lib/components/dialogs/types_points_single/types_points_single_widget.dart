import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/close_keyboard_widget.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'types_points_single_model.dart';
export 'types_points_single_model.dart';

class TypesPointsSingleWidget extends StatefulWidget {
  const TypesPointsSingleWidget({
    super.key,
    this.chosenType,
    this.game,
    this.update,
    String? userPhoto,
  }) : this.userPhoto = userPhoto ??
            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png';

  final String? chosenType;
  final GameStruct? game;
  final Future Function(GameStruct gameDT)? update;
  final String userPhoto;

  @override
  State<TypesPointsSingleWidget> createState() =>
      _TypesPointsSingleWidgetState();
}

class _TypesPointsSingleWidgetState extends State<TypesPointsSingleWidget> {
  late TypesPointsSingleModel _model;

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
    _model = createModel(context, () => TypesPointsSingleModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.gameDT = widget!.game;
      _model.chosenType = widget!.chosenType;
      safeSetState(() {});
      if (widget!.chosenType == PointsType.user.name) {
        safeSetState(() {
          _model.textController?.text = valueOrDefault<String>(
            functions.numFormat(widget!.game!.userMoneyRate.toString()),
            '0',
          );
        });
      } else if (widget!.chosenType == PointsType.team.name) {
        safeSetState(() {
          _model.textController?.text = valueOrDefault<String>(
            functions.numFormat(widget!.game!.teamMoneyRate.toString()),
            '0',
          );
        });
      } else if (widget!.chosenType == PointsType.sieg.name) {
        safeSetState(() {
          _model.textController?.text = valueOrDefault<String>(
            functions.numFormat(widget!.game!.siegPoints.toString()),
            '0',
          );
        });
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

    _model.textController ??= TextEditingController(
        text: valueOrDefault<String>(
      functions.numFormat(valueOrDefault<String>(
        () {
          if (_model.chosenType == PointsType.sieg.name) {
            return valueOrDefault<double>(
              _model.gameDT?.siegPoints,
              0.0,
            );
          } else if (_model.chosenType == PointsType.team.name) {
            return valueOrDefault<double>(
              _model.gameDT?.teamMoneyRate,
              0.0,
            );
          } else {
            return valueOrDefault<double>(
              _model.gameDT?.userMoneyRate,
              0.0,
            );
          }
        }()
            .toString(),
        '0',
      )),
      '0',
    ));
    _model.textFieldFocusNode ??= FocusNode();
    _model.textFieldFocusNode!.addListener(() => safeSetState(() {}));
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
    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600.0,
          maxHeight: MediaQuery.sizeOf(context).height * 0.95,
        ),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 8.0,
              color: Color(0x19000000),
              offset: Offset(
                0.0,
                -2.0,
              ),
              spreadRadius: 2.0,
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
                color: Color(0x10000000),
                offset: Offset(
                  0.0,
                  -2.0,
                ),
                spreadRadius: 2.0,
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
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 6.0, 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 56.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
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
                          unawaited(
                            () async {
                              await actions.closeKeyboard(
                                context,
                              );
                            }(),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Einsatz hinzufügen',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              fontSize: 20.0,
                              letterSpacing: valueOrDefault<double>(
                                -0.8,
                                -0.8,
                              ),
                              fontWeight: FontWeight.w500,
                              lineHeight: 1.4,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                      ),
                    ),
                    Container(
                      width: 56.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 99.0,
                        buttonSize: 40.0,
                        fillColor: FlutterFlowTheme.of(context).alternate,
                        disabledColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        icon: Icon(
                          FFIcons.kcheck2,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 14.0,
                        ),
                        showLoadingIndicator: true,
                        onPressed: ((functions
                                        .numParse(_model.textController.text)! <
                                    0.1) ||
                                (_model.chosenType == null ||
                                    _model.chosenType == ''))
                            ? null
                            : () async {
                                if (functions.numParse(
                                        _model.textController.text)! >=
                                    0.1) {
                                  if (_model.chosenType ==
                                      PointsType.sieg.name) {
                                    _model.updateGameDTStruct(
                                      (e) => e
                                        ..siegPoints = valueOrDefault<double>(
                                          functions.numParse(
                                              _model.textController.text),
                                          0.0,
                                        ),
                                    );
                                  } else if (_model.chosenType ==
                                      PointsType.team.name) {
                                    _model.updateGameDTStruct(
                                      (e) => e
                                        ..teamMoneyRate =
                                            valueOrDefault<double>(
                                          functions.numParse(
                                              _model.textController.text),
                                          0.0,
                                        ),
                                    );
                                  } else {
                                    _model.updateGameDTStruct(
                                      (e) => e
                                        ..userMoneyRate =
                                            valueOrDefault<double>(
                                          functions.numParse(
                                              _model.textController.text),
                                          0.0,
                                        ),
                                    );
                                  }

                                  await widget.update?.call(
                                    _model.gameDT!,
                                  );
                                  Navigator.pop(context);
                                  unawaited(
                                    () async {
                                      await actions.closeKeyboard(
                                        context,
                                      );
                                    }(),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      12.0,
                      0,
                      valueOrDefault<double>(
                        (isWeb
                                ? MediaQuery.viewInsetsOf(context).bottom > 0
                                : _isKeyboardVisible)
                            ? 0.0
                            : 34.0,
                        34.0,
                      ),
                    ),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 16.0, 0.0, 0.0),
                          child: Text(
                            'Wofür möchtest du spenden?',
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleSmallFamily,
                                  fontSize: 18.0,
                                  letterSpacing: valueOrDefault<double>(
                                    -0.63,
                                    -0.63,
                                  ),
                                  fontWeight: FontWeight.w500,
                                  lineHeight: 1.4,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .titleSmallIsCustom,
                                ),
                          ),
                        ),
                      ),
                      if (widget!.chosenType == PointsType.user.name)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.chosenType = PointsType.user.name;
                              safeSetState(() {});
                              safeSetState(() {
                                _model.textController?.text =
                                    functions.numFormat(valueOrDefault<String>(
                                  _model.gameDT?.userMoneyRate?.toString(),
                                  '0',
                                ))!;
                                _model.textFieldFocusNode?.requestFocus();
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _model.textController?.selection =
                                      TextSelection.collapsed(
                                    offset: _model.textController!.text.length,
                                  );
                                });
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    12.0, 8.0, 12.0, 8.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: valueOrDefault<Color>(
                                      _model.chosenType == PointsType.user.name
                                          ? FlutterFlowTheme.of(context)
                                              .alternate
                                          : FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                            ),
                                          ),
                                          child: wrapWithModel(
                                            model: _model.imageModel,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ImageWidget(
                                              size: 40.0,
                                              image: valueOrDefault<String>(
                                                widget!.userPhoto,
                                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Eigene Punkte',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
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
                                                                  .titleSmallIsCustom,
                                                        ),
                                              ),
                                              Text(
                                                'Gib deinem Spiel mehr Sinn',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
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
                                                              .bodyMediumIsCustom,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Builder(
                                              builder: (context) {
                                                if (_model.chosenType ==
                                                    PointsType.user.name) {
                                                  return Container(
                                                    width: 24.0,
                                                    height: 24.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ]
                                              .divide(SizedBox(width: 16.0))
                                              .addToEnd(SizedBox(width: 8.0)),
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (widget!.chosenType == PointsType.team.name)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 16.0, 0.0, 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.chosenType = PointsType.team.name;
                              safeSetState(() {});
                              safeSetState(() {
                                _model.textController?.text =
                                    functions.numFormat(valueOrDefault<String>(
                                  _model.gameDT?.teamMoneyRate?.toString(),
                                  '0',
                                ))!;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    12.0, 8.0, 12.0, 8.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: valueOrDefault<Color>(
                                      _model.chosenType == PointsType.team.name
                                          ? FlutterFlowTheme.of(context)
                                              .alternate
                                          : FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            FFIcons.kgroup,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 18.0,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Team-Punkt',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
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
                                                                  .titleSmallIsCustom,
                                                        ),
                                              ),
                                              Text(
                                                'Motiviere das Team als Ganzes',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
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
                                                              .bodyMediumIsCustom,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Builder(
                                              builder: (context) {
                                                if (_model.chosenType ==
                                                    PointsType.team.name) {
                                                  return Container(
                                                    width: 24.0,
                                                    height: 24.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ]
                                              .divide(SizedBox(width: 16.0))
                                              .addToEnd(SizedBox(width: 8.0)),
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (widget!.chosenType == PointsType.sieg.name)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 16.0, 0.0, 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.chosenType = PointsType.sieg.name;
                              _model.updateGameDTStruct(
                                (e) => e
                                  ..siegPoints = functions
                                      .numParse(_model.textController.text),
                              );
                              safeSetState(() {});
                              safeSetState(() {
                                _model.textController?.text =
                                    functions.numFormat(valueOrDefault<String>(
                                  _model.gameDT?.siegPoints?.toString(),
                                  '0',
                                ))!;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    12.0, 8.0, 12.0, 8.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: valueOrDefault<Color>(
                                      _model.chosenType == PointsType.sieg.name
                                          ? FlutterFlowTheme.of(context)
                                              .alternate
                                          : FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            FFIcons.ktrophy,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 18.0,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Sieg',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
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
                                                                  .titleSmallIsCustom,
                                                        ),
                                              ),
                                              Text(
                                                'Würdige Bestleistung',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
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
                                                              .bodyMediumIsCustom,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Builder(
                                              builder: (context) {
                                                if (_model.chosenType ==
                                                    PointsType.sieg.name) {
                                                  return Container(
                                                    width: 24.0,
                                                    height: 24.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ]
                                              .divide(SizedBox(width: 16.0))
                                              .addToEnd(SizedBox(width: 8.0)),
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Align(
                        alignment: AlignmentDirectional(-1.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 0.0),
                          child: RichText(
                            textScaler: MediaQuery.of(context).textScaler,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Wähle dein Einsatz für ',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        fontSize: 18.0,
                                        letterSpacing: valueOrDefault<double>(
                                          -0.63,
                                          -0.63,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                                TextSpan(
                                  text: () {
                                    if (_model.chosenType ==
                                        PointsType.sieg.name) {
                                      return 'Sieg';
                                    } else if (_model.chosenType ==
                                        PointsType.team.name) {
                                      return 'Team-Punkt';
                                    } else {
                                      return 'Eigene Punkte';
                                    }
                                  }(),
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        fontSize: 18.0,
                                        letterSpacing: valueOrDefault<double>(
                                          -0.63,
                                          -0.63,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                )
                              ],
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(1.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 0.0),
                          child: Stack(
                            alignment: AlignmentDirectional(1.0, 0.0),
                            children: [
                              Container(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _model.textController,
                                  focusNode: _model.textFieldFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.textController',
                                    Duration(milliseconds: 50),
                                    () async {
                                      if (functions.numParse(
                                              _model.textController.text)! >=
                                          0.1) {
                                        if (_model.chosenType ==
                                            PointsType.sieg.name) {
                                          _model.updateGameDTStruct(
                                            (e) => e
                                              ..siegPoints =
                                                  valueOrDefault<double>(
                                                functions.numParse(
                                                    _model.textController.text),
                                                0.0,
                                              ),
                                          );
                                        } else if (_model.chosenType ==
                                            PointsType.team.name) {
                                          _model.updateGameDTStruct(
                                            (e) => e
                                              ..teamMoneyRate =
                                                  valueOrDefault<double>(
                                                functions.numParse(
                                                    _model.textController.text),
                                                0.0,
                                              ),
                                          );
                                        } else {
                                          _model.updateGameDTStruct(
                                            (e) => e
                                              ..userMoneyRate =
                                                  valueOrDefault<double>(
                                                functions.numParse(
                                                    _model.textController.text),
                                                0.0,
                                              ),
                                          );
                                        }
                                      }
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
                                    hintText: '0,10',
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
                                          functions.numParse(_model
                                                      .textController.text)! <
                                                  0.1
                                              ? FlutterFlowTheme.of(context)
                                                  .error
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: valueOrDefault<Color>(
                                          functions.numParse(_model
                                                      .textController.text)! <
                                                  0.1
                                              ? FlutterFlowTheme.of(context)
                                                  .error
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
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
                                    filled: true,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
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
                                  maxLength: 5,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.none,
                                  buildCounter: (context,
                                          {required currentLength,
                                          required isFocused,
                                          maxLength}) =>
                                      null,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  validator: _model.textControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(1.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Icon(
                                    FFIcons.keuro,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(-1.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 4.0, 16.0, 0.0),
                          child: Text(
                            'Deine Spende für die gewählte Option. \nMindestbetrag 0,10 €.',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText75,
                                  letterSpacing: valueOrDefault<double>(
                                    -0.35,
                                    -0.35,
                                  ),
                                  fontWeight: FontWeight.w500,
                                  lineHeight: 1.5,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(1.0, 1.0),
                child: wrapWithModel(
                  model: _model.closeKeyboardModel,
                  updateCallback: () => safeSetState(() {}),
                  child: CloseKeyboardWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
