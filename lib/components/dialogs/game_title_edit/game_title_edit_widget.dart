import '/backend/schema/structs/index.dart';
import '/components/close_keyboard_widget.dart';
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
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'game_title_edit_model.dart';
export 'game_title_edit_model.dart';

class GameTitleEditWidget extends StatefulWidget {
  const GameTitleEditWidget({
    super.key,
    required this.game,
    required this.updateTitle,
  });

  final GameStruct? game;
  final Future Function(String title)? updateTitle;

  @override
  State<GameTitleEditWidget> createState() => _GameTitleEditWidgetState();
}

class _GameTitleEditWidgetState extends State<GameTitleEditWidget> {
  late GameTitleEditModel _model;

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
    _model = createModel(context, () => GameTitleEditModel());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.textController ??= TextEditingController(text: widget!.game?.title);
    _model.textFieldFocusNode ??= FocusNode();

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
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        Navigator.pop(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Align(
            alignment: AlignmentDirectional(0.0, 1.0),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 600.0,
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
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      12.0,
                      12.0,
                      12.0,
                      valueOrDefault<double>(
                        (isWeb
                                ? MediaQuery.viewInsetsOf(context).bottom > 0
                                : _isKeyboardVisible)
                            ? 0.0
                            : 34.0,
                        34.0,
                      )),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 12.0),
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
                                fillColor:
                                    FlutterFlowTheme.of(context).alternate,
                                icon: Icon(
                                  FFIcons.kxmark,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 24.0,
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Game-Namen ändern',
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
                                disabledColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                disabledIconColor:
                                    FlutterFlowTheme.of(context).secondaryText,
                                icon: Icon(
                                  FFIcons.kcheck2,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 14.0,
                                ),
                                showLoadingIndicator: true,
                                onPressed:
                                    ((_model.textController.text!.length ?? 0) >
                                            50)
                                        ? null
                                        : () async {
                                            if ((_model.textController.text!
                                                        .length ??
                                                    0) <=
                                                50) {
                                              Navigator.pop(context);
                                              if (_model.textController.text !=
                                                      null &&
                                                  _model.textController.text !=
                                                      '') {
                                                await widget.updateTitle?.call(
                                                  _model.textController.text,
                                                );
                                              }
                                            }
                                          },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
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
                                () => safeSetState(() {}),
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
                                hintText: 'Game #1',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
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
                                      (_model.textController.text.length) > 50
                                          ? FlutterFlowTheme.of(context).error
                                          : FlutterFlowTheme.of(context)
                                              .primaryText,
                                      FlutterFlowTheme.of(context).primaryText,
                                    ),
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                filled: true,
                                fillColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(
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
                              maxLengthEnforcement: MaxLengthEnforcement.none,
                              buildCounter: (context,
                                      {required currentLength,
                                      required isFocused,
                                      maxLength}) =>
                                  null,
                              cursorColor:
                                  FlutterFlowTheme.of(context).primaryText,
                              validator: _model.textControllerValidator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                      ),
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
                                    (_model.textController.text.length) > 50
                                        ? FlutterFlowTheme.of(context).error
                                        : FlutterFlowTheme.of(context)
                                            .secondaryText,
                                    FlutterFlowTheme.of(context).secondaryText,
                                  ),
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
          ),
        ],
      ),
    );
  }
}
