import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'receipt_dialog_model.dart';
export 'receipt_dialog_model.dart';

class ReceiptDialogWidget extends StatefulWidget {
  const ReceiptDialogWidget({
    super.key,
    required this.userId,
    required this.update,
    required this.name,
    required this.surname,
    this.gender,
  });

  final String? userId;
  final Future Function(bool receipt)? update;
  final String? name;
  final String? surname;
  final String? gender;

  @override
  State<ReceiptDialogWidget> createState() => _ReceiptDialogWidgetState();
}

class _ReceiptDialogWidgetState extends State<ReceiptDialogWidget> {
  late ReceiptDialogModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReceiptDialogModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget!.gender != null && widget!.gender != '') {
        safeSetState(() {
          _model.dropDownValueController?.value = widget!.gender!;
          _model.dropDownValue = widget!.gender!;
        });
      }
    });

    _model.nameTextController ??= TextEditingController(text: widget!.name);
    _model.nameFocusNode ??= FocusNode();
    _model.nameFocusNode!.addListener(() => safeSetState(() {}));
    _model.surnameTextController ??=
        TextEditingController(text: widget!.surname);
    _model.surnameFocusNode ??= FocusNode();
    _model.surnameFocusNode!.addListener(() => safeSetState(() {}));

    _model.landFocusNode ??= FocusNode();
    _model.landFocusNode!.addListener(() => safeSetState(() {}));

    _model.plzFocusNode ??= FocusNode();
    _model.plzFocusNode!.addListener(() => safeSetState(() {}));

    _model.stadtFocusNode ??= FocusNode();
    _model.stadtFocusNode!.addListener(() => safeSetState(() {}));

    _model.straeFocusNode ??= FocusNode();
    _model.straeFocusNode!.addListener(() => safeSetState(() {}));

    _model.hausNrFocusNode ??= FocusNode();
    _model.hausNrFocusNode!.addListener(() => safeSetState(() {}));
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
      child: StreamBuilder<List<UsersRow>>(
        stream: _model.containerSupabaseStream ??= SupaFlow.client
            .from("users")
            .stream(primaryKey: ['id'])
            .eqOrNull(
              'id',
              widget!.userId,
            )
            .map((list) => list.map((item) => UsersRow(item)).toList()),
        builder: (context, snapshot) {
          // Customize what your widget looks like when it's loading.
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            );
          }
          List<UsersRow> containerUsersRowList = snapshot.data!;

          final containerUsersRow = containerUsersRowList.isNotEmpty
              ? containerUsersRowList.first
              : null;

          return Container(
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
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
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
                          child: AutoSizeText(
                            'Spendenbescheinigung',
                            textAlign: TextAlign.center,
                            maxLines: 1,
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
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
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
                            fillColor: FlutterFlowTheme.of(context).alternate,
                            icon: Icon(
                              FFIcons.kcheck2,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 14.0,
                            ),
                            showLoadingIndicator: true,
                            onPressed: () async {
                              if ((_model.dropDownValue != null &&
                                      _model.dropDownValue != '') &&
                                  (_model.nameTextController.text != null &&
                                      _model.nameTextController.text != '') &&
                                  (_model.surnameTextController.text != null &&
                                      _model.surnameTextController.text !=
                                          '') &&
                                  (_model.landTextController.text != null &&
                                      _model.landTextController.text != '') &&
                                  (_model.plzTextController.text != null &&
                                      _model.plzTextController.text != '') &&
                                  (_model.stadtTextController.text != null &&
                                      _model.stadtTextController.text != '') &&
                                  (_model.straeTextController.text != null &&
                                      _model.straeTextController.text != '') &&
                                  (_model.hausNrTextController.text != null &&
                                      _model.hausNrTextController.text != '')) {
                                _model.error = false;
                                safeSetState(() {});
                                await widget.update?.call(
                                  true,
                                );
                                await UsersTable().update(
                                  data: {
                                    'first_name':
                                        _model.nameTextController.text,
                                    'surname':
                                        _model.surnameTextController.text,
                                    'land': _model.landTextController.text,
                                    'plz': _model.plzTextController.text,
                                    'stadt': _model.stadtTextController.text,
                                    'strae': _model.straeTextController.text,
                                    'haus_nr': _model.hausNrTextController.text,
                                    'gender': _model.dropDownValue,
                                  },
                                  matchingRows: (rows) => rows.eqOrNull(
                                    'id',
                                    currentUserUid,
                                  ),
                                );
                              } else {
                                await widget.update?.call(
                                  false,
                                );
                                _model.error = true;
                                safeSetState(() {});
                                return;
                              }

                              Navigator.pop(context);
                              unawaited(
                                () async {
                                  await actions.closeKeyboard(
                                    context,
                                  );
                                }(),
                              );
                              FFAppState().refreshDate = getCurrentTimestamp;
                              FFAppState().update(() {});
                              FFAppState().clearUserCache();
                            },
                          ),
                        ),
                      ].divide(SizedBox(width: 8.0)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                      child: SingleChildScrollView(
                        controller: _model.columnController,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FlutterFlowDropDown<String>(
                                      controller:
                                          _model.dropDownValueController ??=
                                              FormFieldController<String>(
                                        _model.dropDownValue ??=
                                            containerUsersRow?.gender,
                                      ),
                                      options: ['Frau', 'Herr'],
                                      onChanged: (val) => safeSetState(
                                          () => _model.dropDownValue = val),
                                      width: double.infinity,
                                      height: 56.0,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            color: valueOrDefault<Color>(
                                              _model.dropDownValue != null &&
                                                      _model.dropDownValue != ''
                                                  ? FlutterFlowTheme.of(context)
                                                      .primaryText
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryText50,
                                              FlutterFlowTheme.of(context)
                                                  .secondaryText50,
                                            ),
                                            fontSize: 16.0,
                                            letterSpacing:
                                                valueOrDefault<double>(
                                              -0.4,
                                              -0.4,
                                            ),
                                            fontWeight: FontWeight.w500,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                      hintText: 'Anrede*',
                                      icon: Icon(
                                        FFIcons.karrowSeparateVertical,
                                        color: valueOrDefault<Color>(
                                          _model.dropDownValue != null &&
                                                  _model.dropDownValue != ''
                                              ? FlutterFlowTheme.of(context)
                                                  .primaryText
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryText50,
                                          FlutterFlowTheme.of(context)
                                              .secondaryText50,
                                        ),
                                        size: 26.0,
                                      ),
                                      fillColor: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      elevation: 2.0,
                                      borderColor: valueOrDefault<Color>(
                                        (_model.dropDownValue == null ||
                                                    _model.dropDownValue ==
                                                        '') &&
                                                _model.error
                                            ? FlutterFlowTheme.of(context).error
                                            : Colors.transparent,
                                        Colors.transparent,
                                      ),
                                      borderWidth: 1.0,
                                      borderRadius: 16.0,
                                      margin: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 0.0),
                                      hidesUnderline: true,
                                      isOverButton: false,
                                      isSearchable: false,
                                      isMultiSelect: false,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            () {
                                              if ((_model.nameFocusNode
                                                      ?.hasFocus ??
                                                  false)) {
                                                return FlutterFlowTheme.of(
                                                        context)
                                                    .focus;
                                              } else if ((_model
                                                              .nameTextController
                                                              .text ==
                                                          null ||
                                                      _model.nameTextController
                                                              .text ==
                                                          '') &&
                                                  _model.error) {
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
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller: _model.nameTextController,
                                          focusNode: _model.nameFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.nameTextController',
                                            Duration(milliseconds: 50),
                                            () => safeSetState(() {}),
                                          ),
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'Vorname*',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.nameTextController
                                                                    .text !=
                                                                null &&
                                                            _model.nameTextController
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
                                                EdgeInsets.all(16.0),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
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
                                                        .bodyMediumIsCustom,
                                              ),
                                          maxLength: 30,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.none,
                                          buildCounter: (context,
                                                  {required currentLength,
                                                  required isFocused,
                                                  maxLength}) =>
                                              null,
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          validator: _model
                                              .nameTextControllerValidator
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
                                                              .words),
                                                );
                                              }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            () {
                                              if ((_model.surnameFocusNode
                                                      ?.hasFocus ??
                                                  false)) {
                                                return FlutterFlowTheme.of(
                                                        context)
                                                    .focus;
                                              } else if ((_model
                                                              .surnameTextController
                                                              .text ==
                                                          null ||
                                                      _model.surnameTextController
                                                              .text ==
                                                          '') &&
                                                  _model.error) {
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
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.surnameTextController,
                                          focusNode: _model.surnameFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.surnameTextController',
                                            Duration(milliseconds: 50),
                                            () => safeSetState(() {}),
                                          ),
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'Nachname*',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.surnameTextController
                                                                    .text !=
                                                                null &&
                                                            _model.surnameTextController
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
                                                EdgeInsets.all(16.0),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
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
                                                        .bodyMediumIsCustom,
                                              ),
                                          maxLength: 30,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.none,
                                          buildCounter: (context,
                                                  {required currentLength,
                                                  required isFocused,
                                                  maxLength}) =>
                                              null,
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          validator: _model
                                              .surnameTextControllerValidator
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
                                                              .words),
                                                );
                                              }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            () {
                                              if ((_model.landFocusNode
                                                      ?.hasFocus ??
                                                  false)) {
                                                return FlutterFlowTheme.of(
                                                        context)
                                                    .focus;
                                              } else if ((_model
                                                              .landTextController
                                                              .text ==
                                                          null ||
                                                      _model.landTextController
                                                              .text ==
                                                          '') &&
                                                  _model.error) {
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
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.landTextController ??=
                                                  TextEditingController(
                                            text: containerUsersRow?.land,
                                          ),
                                          focusNode: _model.landFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.landTextController',
                                            Duration(milliseconds: 50),
                                            () => safeSetState(() {}),
                                          ),
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'Land*',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.landTextController
                                                                    .text !=
                                                                null &&
                                                            _model.landTextController
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
                                                EdgeInsets.all(16.0),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
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
                                                        .bodyMediumIsCustom,
                                              ),
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          validator: _model
                                              .landTextControllerValidator
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
                                                              .words),
                                                );
                                              }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            () {
                                              if ((_model
                                                      .plzFocusNode?.hasFocus ??
                                                  false)) {
                                                return FlutterFlowTheme.of(
                                                        context)
                                                    .focus;
                                              } else if ((_model
                                                              .plzTextController
                                                              .text ==
                                                          null ||
                                                      _model.plzTextController
                                                              .text ==
                                                          '') &&
                                                  _model.error) {
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
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.plzTextController ??=
                                                  TextEditingController(
                                            text: containerUsersRow?.plz,
                                          ),
                                          focusNode: _model.plzFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.plzTextController',
                                            Duration(milliseconds: 50),
                                            () => safeSetState(() {}),
                                          ),
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'PLZ*',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.plzTextController
                                                                    .text !=
                                                                null &&
                                                            _model
                                                                    .plzTextController
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
                                                EdgeInsets.all(16.0),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
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
                                                        .bodyMediumIsCustom,
                                              ),
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          validator: _model
                                              .plzTextControllerValidator
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
                                                              .words),
                                                );
                                              }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            () {
                                              if ((_model.stadtFocusNode
                                                      ?.hasFocus ??
                                                  false)) {
                                                return FlutterFlowTheme.of(
                                                        context)
                                                    .focus;
                                              } else if ((_model
                                                              .stadtTextController
                                                              .text ==
                                                          null ||
                                                      _model.stadtTextController
                                                              .text ==
                                                          '') &&
                                                  _model.error) {
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
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.stadtTextController ??=
                                                  TextEditingController(
                                            text: containerUsersRow?.stadt,
                                          ),
                                          focusNode: _model.stadtFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.stadtTextController',
                                            Duration(milliseconds: 50),
                                            () => safeSetState(() {}),
                                          ),
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'Stadt*',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.stadtTextController
                                                                    .text !=
                                                                null &&
                                                            _model.stadtTextController
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
                                                EdgeInsets.all(16.0),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
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
                                                        .bodyMediumIsCustom,
                                              ),
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          validator: _model
                                              .stadtTextControllerValidator
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
                                                              .words),
                                                );
                                              }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            () {
                                              if ((_model.straeFocusNode
                                                      ?.hasFocus ??
                                                  false)) {
                                                return FlutterFlowTheme.of(
                                                        context)
                                                    .focus;
                                              } else if ((_model
                                                              .straeTextController
                                                              .text ==
                                                          null ||
                                                      _model.straeTextController
                                                              .text ==
                                                          '') &&
                                                  _model.error) {
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
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.straeTextController ??=
                                                  TextEditingController(
                                            text: containerUsersRow?.strae,
                                          ),
                                          focusNode: _model.straeFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.straeTextController',
                                            Duration(milliseconds: 50),
                                            () => safeSetState(() {}),
                                          ),
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'Straße*',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.straeTextController
                                                                    .text !=
                                                                null &&
                                                            _model.straeTextController
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
                                                EdgeInsets.all(16.0),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
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
                                                        .bodyMediumIsCustom,
                                              ),
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          validator: _model
                                              .straeTextControllerValidator
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
                                                              .words),
                                                );
                                              }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            () {
                                              if ((_model.hausNrFocusNode
                                                      ?.hasFocus ??
                                                  false)) {
                                                return FlutterFlowTheme.of(
                                                        context)
                                                    .focus;
                                              } else if ((_model
                                                              .hausNrTextController
                                                              .text ==
                                                          null ||
                                                      _model.hausNrTextController
                                                              .text ==
                                                          '') &&
                                                  _model.error) {
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
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.hausNrTextController ??=
                                                  TextEditingController(
                                            text: containerUsersRow?.hausNr,
                                          ),
                                          focusNode: _model.hausNrFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.hausNrTextController',
                                            Duration(milliseconds: 50),
                                            () => safeSetState(() {}),
                                          ),
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.done,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'Haus-Nr*',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.hausNrTextController
                                                                    .text !=
                                                                null &&
                                                            _model.hausNrTextController
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
                                                EdgeInsets.all(16.0),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
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
                                                        .bodyMediumIsCustom,
                                              ),
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          validator: _model
                                              .hausNrTextControllerValidator
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
                                                              .words),
                                                );
                                              }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 24.0)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 24.0, 0.0, 0.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      32.0, 16.0, 32.0, 16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Spendenempfänger \n“Players For Good” ',
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              fontSize: 18.0,
                                              letterSpacing:
                                                  valueOrDefault<double>(
                                                -0.63,
                                                -0.63,
                                              ),
                                              fontWeight: FontWeight.w500,
                                              lineHeight: 1.4,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
                                            ),
                                      ),
                                      Text(
                                        'Alle Spenden auf dieser Plattform gehen an die gemeinnützige Förderkörperschaft Players For Good gGmbH, welche die App “Play For Good” betreibt. Die Players For Good gGmbH spendet die gesammelten Spenden in ihrer Rolle als Förderkörperschaft an die auf dieser Plattform registrierten gemeinnützigen Organisationen weiter und stellt die Spendenbescheinigungen aus.',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText75,
                                              letterSpacing:
                                                  valueOrDefault<double>(
                                                -0.35,
                                                -0.35,
                                              ),
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 24.0)),
                                  ),
                                ),
                              ),
                            ),
                          ]
                              .addToStart(SizedBox(height: 24.0))
                              .addToEnd(SizedBox(height: 34.0)),
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
          );
        },
      ),
    );
  }
}
