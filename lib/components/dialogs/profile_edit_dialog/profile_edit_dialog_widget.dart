import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/dialogs/delete_acc_dialog/delete_acc_dialog_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'profile_edit_dialog_model.dart';
export 'profile_edit_dialog_model.dart';

class ProfileEditDialogWidget extends StatefulWidget {
  const ProfileEditDialogWidget({
    super.key,
    required this.user,
  });

  final UsersRow? user;

  @override
  State<ProfileEditDialogWidget> createState() =>
      _ProfileEditDialogWidgetState();
}

class _ProfileEditDialogWidgetState extends State<ProfileEditDialogWidget> {
  late ProfileEditDialogModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileEditDialogModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget!.user?.photoUrl != null && widget!.user?.photoUrl != '') {
        _model.photo = widget!.user?.photoUrl;
        safeSetState(() {});
      }
      _model.showUsername = valueOrDefault<bool>(
        widget!.user?.showUsername,
        false,
      );
      safeSetState(() {});
    });

    _model.emailTextController ??=
        TextEditingController(text: widget!.user?.email);
    _model.emailFocusNode ??= FocusNode();

    _model.displaynameTextController ??=
        TextEditingController(text: widget!.user?.displayName);
    _model.displaynameFocusNode ??= FocusNode();
    _model.displaynameFocusNode!.addListener(() => safeSetState(() {}));
    _model.nameTextController ??=
        TextEditingController(text: widget!.user?.firstName);
    _model.nameFocusNode ??= FocusNode();
    _model.nameFocusNode!.addListener(() => safeSetState(() {}));
    _model.surnameTextController ??=
        TextEditingController(text: widget!.user?.surname);
    _model.surnameFocusNode ??= FocusNode();
    _model.surnameFocusNode!.addListener(() => safeSetState(() {}));
    _model.descTextController ??=
        TextEditingController(text: widget!.user?.info);
    _model.descFocusNode ??= FocusNode();

    _model.instTextController ??=
        TextEditingController(text: widget!.user?.instagramUrl);
    _model.instFocusNode ??= FocusNode();
    _model.instFocusNode!.addListener(() => safeSetState(() {}));
    _model.facebookTextController ??=
        TextEditingController(text: widget!.user?.facebookUrl);
    _model.facebookFocusNode ??= FocusNode();
    _model.facebookFocusNode!.addListener(() => safeSetState(() {}));
    _model.youtubeTextController ??=
        TextEditingController(text: widget!.user?.youtubeUrl);
    _model.youtubeFocusNode ??= FocusNode();
    _model.youtubeFocusNode!.addListener(() => safeSetState(() {}));
    _model.landTextController ??=
        TextEditingController(text: widget!.user?.land);
    _model.landFocusNode ??= FocusNode();
    _model.landFocusNode!.addListener(() => safeSetState(() {}));
    _model.plzTextController ??= TextEditingController(text: widget!.user?.plz);
    _model.plzFocusNode ??= FocusNode();
    _model.plzFocusNode!.addListener(() => safeSetState(() {}));
    _model.stadtTextController ??=
        TextEditingController(text: widget!.user?.stadt);
    _model.stadtFocusNode ??= FocusNode();
    _model.stadtFocusNode!.addListener(() => safeSetState(() {}));
    _model.straeTextController ??=
        TextEditingController(text: widget!.user?.strae);
    _model.straeFocusNode ??= FocusNode();
    _model.straeFocusNode!.addListener(() => safeSetState(() {}));
    _model.hausNrTextController ??=
        TextEditingController(text: widget!.user?.hausNr);
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
    context.watch<FFAppState>();

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
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
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
                        'Profil editieren',
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
                        disabledIconColor:
                            FlutterFlowTheme.of(context).primaryText50,
                        icon: Icon(
                          FFIcons.kcheck2,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 14.0,
                        ),
                        showLoadingIndicator: true,
                        onPressed: ((!functions.validateName(
                                        _model.nameTextController.text) &&
                                    (_model.nameTextController.text != null &&
                                        _model.nameTextController.text !=
                                            '')) ||
                                (!functions.validateName(
                                        _model.surnameTextController.text) &&
                                    (_model.surnameTextController.text !=
                                            null &&
                                        _model.surnameTextController.text !=
                                            '')) ||
                                (!valueOrDefault<bool>(
                                      functions.validateHandle(_model
                                          .displaynameTextController.text),
                                      false,
                                    ) &&
                                    valueOrDefault<bool>(
                                      _model.displaynameTextController.text !=
                                              null &&
                                          _model.displaynameTextController
                                                  .text !=
                                              '',
                                      false,
                                    )))
                            ? null
                            : () async {
                                if (!(_model.displaynameTextController.text ==
                                        null ||
                                    _model.displaynameTextController.text ==
                                        '')) {
                                  if (!functions.validateHandle(
                                      _model.displaynameTextController.text)) {
                                    return;
                                  }
                                }
                                if (!(_model.nameTextController.text == null ||
                                    _model.nameTextController.text == '')) {
                                  if (!functions.validateName(
                                      _model.nameTextController.text)) {
                                    return;
                                  }
                                }
                                if (!(_model.surnameTextController.text ==
                                        null ||
                                    _model.surnameTextController.text == '')) {
                                  if (!functions.validateName(
                                      _model.surnameTextController.text)) {
                                    return;
                                  }
                                }
                                await UsersTable().update(
                                  data: {
                                    'display_name':
                                        _model.displaynameTextController.text,
                                    'first_name':
                                        _model.nameTextController.text,
                                    'surname':
                                        _model.surnameTextController.text,
                                    'instagram_url':
                                        _model.instTextController.text,
                                    'facebook_url':
                                        _model.facebookTextController.text,
                                    'youtube_url':
                                        _model.youtubeTextController.text,
                                    'land': _model.landTextController.text,
                                    'plz': _model.plzTextController.text,
                                    'stadt': _model.stadtTextController.text,
                                    'strae': _model.straeTextController.text,
                                    'haus_nr': _model.hausNrTextController.text,
                                    'show_username': _model.showUsername,
                                    'photo_url': _model.photo,
                                    'info': _model.descTextController.text,
                                  },
                                  matchingRows: (rows) => rows.eqOrNull(
                                    'id',
                                    widget!.user?.id,
                                  ),
                                );
                                FFAppState().refreshDate = getCurrentTimestamp;
                                FFAppState().update(() {});
                                FFAppState().clearUserCacheKey(
                                    '${currentUserUid}${FFAppState().refreshDate?.toString()}');
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
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  child: SingleChildScrollView(
                    controller: _model.columnController,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 100.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
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
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                  ),
                                  child: Builder(
                                    builder: (context) {
                                      if (_model.photo != null &&
                                          _model.photo != '') {
                                        return Container(
                                          width: 96.0,
                                          height: 96.0,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: CachedNetworkImage(
                                            fadeInDuration:
                                                Duration(milliseconds: 500),
                                            fadeOutDuration:
                                                Duration(milliseconds: 500),
                                            imageUrl: valueOrDefault<String>(
                                              _model.photo,
                                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                            ),
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, error, stackTrace) =>
                                                    Image.asset(
                                              'assets/images/error_image.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          width: 96.0,
                                          height: 96.0,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                            'assets/images/Profilbild.png',
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Profilbild hochladen',
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              letterSpacing:
                                                  valueOrDefault<double>(
                                                -0.4,
                                                -0.4,
                                              ),
                                              fontWeight: FontWeight.bold,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
                                            ),
                                      ),
                                      Text(
                                        'PNG, JPG (160x160 px)',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing:
                                                  valueOrDefault<double>(
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
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 56.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    borderRadius: BorderRadius.circular(99.0),
                                  ),
                                  child: FlutterFlowIconButton(
                                    borderColor: Colors.transparent,
                                    borderRadius: 99.0,
                                    buttonSize: 40.0,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    icon: Icon(
                                      FFIcons.kupload,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      size: 24.0,
                                    ),
                                    showLoadingIndicator: true,
                                    onPressed: () async {
                                      final selectedMedia =
                                          await selectMediaWithSourceBottomSheet(
                                        context: context,
                                        storageFolderPath: 'users',
                                        maxWidth: 300.00,
                                        maxHeight: 300.00,
                                        imageQuality: 95,
                                        allowPhoto: true,
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                        textColor: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        pickerFontFamily: 'DM Sans',
                                      );
                                      if (selectedMedia != null &&
                                          selectedMedia.every((m) =>
                                              validateFileFormat(
                                                  m.storagePath, context))) {
                                        safeSetState(() => _model
                                                .isDataUploading_uploadDataKn0 =
                                            true);
                                        var selectedUploadedFiles =
                                            <FFUploadedFile>[];

                                        var downloadUrls = <String>[];
                                        try {
                                          selectedUploadedFiles = selectedMedia
                                              .map((m) => FFUploadedFile(
                                                    name: m.storagePath
                                                        .split('/')
                                                        .last,
                                                    bytes: m.bytes,
                                                    height:
                                                        m.dimensions?.height,
                                                    width: m.dimensions?.width,
                                                    blurHash: m.blurHash,
                                                    originalFilename:
                                                        m.originalFilename,
                                                  ))
                                              .toList();

                                          downloadUrls =
                                              await uploadSupabaseStorageFiles(
                                            bucketName: 'pfg',
                                            selectedFiles: selectedMedia,
                                          );
                                        } finally {
                                          _model.isDataUploading_uploadDataKn0 =
                                              false;
                                        }
                                        if (selectedUploadedFiles.length ==
                                                selectedMedia.length &&
                                            downloadUrls.length ==
                                                selectedMedia.length) {
                                          safeSetState(() {
                                            _model.uploadedLocalFile_uploadDataKn0 =
                                                selectedUploadedFiles.first;
                                            _model.uploadedFileUrl_uploadDataKn0 =
                                                downloadUrls.first;
                                          });
                                        } else {
                                          safeSetState(() {});
                                          return;
                                        }
                                      }

                                      if ((_model.uploadedFileUrl_uploadDataKn0 !=
                                                  null &&
                                              _model.uploadedFileUrl_uploadDataKn0 !=
                                                  '') &&
                                          !_model
                                              .isDataUploading_uploadDataKn0) {
                                        _model.photo = _model
                                            .uploadedFileUrl_uploadDataKn0;
                                        safeSetState(() {});
                                      }

                                      FFAppState().update(() {});
                                    },
                                  ),
                                ),
                              ]
                                  .divide(SizedBox(width: 16.0))
                                  .addToStart(SizedBox(width: 16.0))
                                  .addToEnd(SizedBox(width: 16.0)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(
                                ForgotpasswordWidget.routeName,
                                queryParameters: {
                                  'email': serializeParam(
                                    widget!.user?.email,
                                    ParamType.String,
                                  ),
                                }.withoutNulls,
                              );
                            },
                            child: Container(
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
                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'Login',
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              fontSize: 24.0,
                                              letterSpacing:
                                                  valueOrDefault<double>(
                                                -0.96,
                                                -0.96,
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
                                      constraints: BoxConstraints(
                                        minHeight: 56.0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.emailTextController,
                                          focusNode: _model.emailFocusNode,
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          readOnly: true,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'E-Mail-Adresse',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
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
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                              .emailTextControllerValidator
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
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            FFIcons.kkeyBack,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 24.0,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Passwort ändern',
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
                                          ),
                                          Icon(
                                            FFIcons.krightArrow,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 24.0,
                                          ),
                                        ].divide(SizedBox(width: 16.0)),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 24.0)),
                                ),
                              ),
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
                              padding: EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'Profilnamen',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmallFamily,
                                            fontSize: 24.0,
                                            letterSpacing:
                                                valueOrDefault<double>(
                                              -0.96,
                                              -0.96,
                                            ),
                                            fontWeight: FontWeight.w500,
                                            lineHeight: 1.4,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .titleSmallIsCustom,
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
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            () {
                                              if ((_model.displaynameTextController
                                                              .text !=
                                                          null &&
                                                      _model.displaynameTextController
                                                              .text !=
                                                          '') &&
                                                  !valueOrDefault<bool>(
                                                    functions.validateHandle(_model
                                                        .displaynameTextController
                                                        .text),
                                                    false,
                                                  )) {
                                                return FlutterFlowTheme.of(
                                                        context)
                                                    .error;
                                              } else if ((_model
                                                      .displaynameFocusNode
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
                                              _model.displaynameTextController,
                                          focusNode:
                                              _model.displaynameFocusNode,
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: '@Benutzername',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.displaynameTextController
                                                                    .text !=
                                                                null &&
                                                            _model.displaynameTextController
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
                                          enableInteractiveSelection: true,
                                          validator: _model
                                              .displaynameTextControllerValidator
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
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 4.0, 0.0, 0.0),
                                      child: AutoSizeText(
                                        'Maximal 20 Zeichen. Erlaubte Zeichen: Buchstaben (a–z), Ziffern (0–9), Punkte (.) und Unterstriche (_)',
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              color: !valueOrDefault<bool>(
                                                        functions.validateHandle(
                                                            _model
                                                                .displaynameTextController
                                                                .text),
                                                        false,
                                                      ) &&
                                                      valueOrDefault<bool>(
                                                        _model.displaynameTextController
                                                                    .text !=
                                                                null &&
                                                            _model.displaynameTextController
                                                                    .text !=
                                                                '',
                                                        false,
                                                      )
                                                  ? FlutterFlowTheme.of(context)
                                                      .error
                                                  : FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 14.0,
                                              letterSpacing:
                                                  valueOrDefault<double>(
                                                -0.35,
                                                -0.35,
                                              ),
                                              fontWeight: FontWeight.w500,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
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
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            () {
                                              if ((_model.nameTextController
                                                              .text !=
                                                          null &&
                                                      _model.nameTextController
                                                              .text !=
                                                          '') &&
                                                  !functions.validateName(_model
                                                      .nameTextController
                                                      .text)) {
                                                return FlutterFlowTheme.of(
                                                        context)
                                                    .error;
                                              } else if ((_model.nameFocusNode
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
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'Vorname',
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
                                          enableInteractiveSelection: true,
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
                                  ),
                                  if (!functions.validateName(
                                          _model.nameTextController.text) &&
                                      (_model.nameTextController.text != null &&
                                          _model.nameTextController.text != ''))
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 4.0, 0.0, 0.0),
                                        child: AutoSizeText(
                                          'Gültigen Vornamen eingeben',
                                          maxLines: 1,
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                fontSize: 14.0,
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
                                                        .titleSmallIsCustom,
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
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            () {
                                              if ((_model.surnameTextController
                                                              .text !=
                                                          null &&
                                                      _model.surnameTextController
                                                              .text !=
                                                          '') &&
                                                  !functions.validateName(_model
                                                      .surnameTextController
                                                      .text)) {
                                                return FlutterFlowTheme.of(
                                                        context)
                                                    .error;
                                              } else if ((_model
                                                      .surnameFocusNode
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
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'Nachname',
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
                                          enableInteractiveSelection: true,
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
                                  ),
                                  if (!functions.validateName(
                                          _model.surnameTextController.text) &&
                                      (_model.surnameTextController.text !=
                                              null &&
                                          _model.surnameTextController.text !=
                                              ''))
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 4.0, 0.0, 0.0),
                                        child: AutoSizeText(
                                          'Gültigen Nachname eingeben',
                                          maxLines: 1,
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                fontSize: 14.0,
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
                                                        .titleSmallIsCustom,
                                              ),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 24.0, 0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.showUsername =
                                            !_model.showUsername;
                                        safeSetState(() {});
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Builder(
                                            builder: (context) {
                                              if (_model.showUsername) {
                                                return Container(
                                                  width: 18.0,
                                                  height: 18.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                    border: Border.all(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      width: 1.0,
                                                    ),
                                                  ),
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
                                                );
                                              } else {
                                                return Container(
                                                  width: 18.0,
                                                  height: 18.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                    border: Border.all(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Meinen Namen im Profil für alle anzeigen.',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    fontSize: 16.0,
                                                    letterSpacing:
                                                        valueOrDefault<double>(
                                                      -0.4,
                                                      -0.4,
                                                    ),
                                                    lineHeight: 1.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                            ),
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                              padding: EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 20.0),
                                    child: Text(
                                      'Profil-Info',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmallFamily,
                                            fontSize: 24.0,
                                            letterSpacing:
                                                valueOrDefault<double>(
                                              -0.96,
                                              -0.96,
                                            ),
                                            fontWeight: FontWeight.w500,
                                            lineHeight: 1.4,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .titleSmallIsCustom,
                                          ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Container(
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
                                            (_model.descFocusNode?.hasFocus ??
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
                                            AlignmentDirectional(-1.0, -1.0),
                                        child: Container(
                                          width: double.infinity,
                                          child: TextFormField(
                                            controller:
                                                _model.descTextController,
                                            focusNode: _model.descFocusNode,
                                            autofocus: false,
                                            textCapitalization:
                                                TextCapitalization.none,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: false,
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
                                                      _model.descTextController
                                                                      .text !=
                                                                  null &&
                                                              _model.descTextController
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
                                              hintText: 'Beschreibung',
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
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                            textAlign: TextAlign.start,
                                            maxLines: 10,
                                            minLines: 6,
                                            maxLength: 300,
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
                                            enableInteractiveSelection: true,
                                            validator: _model
                                                .descTextControllerValidator
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
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 0.0, 0.0),
                                    child: Text(
                                      '300 Zeichen',
                                      style: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .labelMediumFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText50,
                                            letterSpacing:
                                                valueOrDefault<double>(
                                              -0.35,
                                              -0.35,
                                            ),
                                            fontWeight: FontWeight.w500,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .labelMediumIsCustom,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
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
                              padding: EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Social media',
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmallFamily,
                                          fontSize: 24.0,
                                          letterSpacing: valueOrDefault<double>(
                                            -0.96,
                                            -0.96,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleSmallIsCustom,
                                        ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Container(
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
                                            (_model.instFocusNode?.hasFocus ??
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
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller: _model.instTextController,
                                          focusNode: _model.instFocusNode,
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.none,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'Instagram URL',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.instTextController
                                                                    .text !=
                                                                null &&
                                                            _model.instTextController
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
                                          enableInteractiveSelection: true,
                                          validator: _model
                                              .instTextControllerValidator
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
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Container(
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
                                            (_model.facebookFocusNode
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
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.facebookTextController,
                                          focusNode: _model.facebookFocusNode,
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.none,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'Facebook URL',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.facebookTextController
                                                                    .text !=
                                                                null &&
                                                            _model.facebookTextController
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
                                          enableInteractiveSelection: true,
                                          validator: _model
                                              .facebookTextControllerValidator
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
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Container(
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
                                            (_model.youtubeFocusNode
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
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.youtubeTextController,
                                          focusNode: _model.youtubeFocusNode,
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.none,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: 'YouTube URL',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: valueOrDefault<Color>(
                                                    _model.youtubeTextController
                                                                    .text !=
                                                                null &&
                                                            _model.youtubeTextController
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
                                          enableInteractiveSelection: true,
                                          validator: _model
                                              .youtubeTextControllerValidator
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
                                ].divide(SizedBox(height: 24.0)),
                              ),
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
                              padding: EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Adresse',
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmallFamily,
                                          fontSize: 24.0,
                                          letterSpacing: valueOrDefault<double>(
                                            -0.96,
                                            -0.96,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleSmallIsCustom,
                                        ),
                                  ),
                                  Container(
                                    constraints: BoxConstraints(
                                      minHeight: 56.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: valueOrDefault<Color>(
                                          (_model.landFocusNode?.hasFocus ??
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
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _model.landTextController,
                                        focusNode: _model.landFocusNode,
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
                                                    FlutterFlowTheme.of(context)
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
                                                    FlutterFlowTheme.of(context)
                                                        .labelMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                          focusedErrorBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.all(16.0),
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
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        enableInteractiveSelection: true,
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
                                    constraints: BoxConstraints(
                                      minHeight: 56.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: valueOrDefault<Color>(
                                          (_model
                                                      .plzFocusNode?.hasFocus ??
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
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _model.plzTextController,
                                        focusNode: _model.plzFocusNode,
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
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                color: valueOrDefault<Color>(
                                                  _model.plzTextController.text !=
                                                              null &&
                                                          _model.plzTextController
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
                                                    FlutterFlowTheme.of(context)
                                                        .labelMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                          focusedErrorBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.all(16.0),
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
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        enableInteractiveSelection: true,
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
                                    constraints: BoxConstraints(
                                      minHeight: 56.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: valueOrDefault<Color>(
                                          (_model.stadtFocusNode?.hasFocus ??
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
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _model.stadtTextController,
                                        focusNode: _model.stadtFocusNode,
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
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                color: valueOrDefault<Color>(
                                                  _model.stadtTextController.text !=
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
                                                    FlutterFlowTheme.of(context)
                                                        .labelMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                          focusedErrorBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.all(16.0),
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
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        enableInteractiveSelection: true,
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
                                    constraints: BoxConstraints(
                                      minHeight: 56.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: valueOrDefault<Color>(
                                          (_model.straeFocusNode?.hasFocus ??
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
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _model.straeTextController,
                                        focusNode: _model.straeFocusNode,
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
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                color: valueOrDefault<Color>(
                                                  _model.straeTextController.text !=
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
                                                    FlutterFlowTheme.of(context)
                                                        .labelMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                          focusedErrorBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.all(16.0),
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
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        enableInteractiveSelection: true,
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
                                    constraints: BoxConstraints(
                                      minHeight: 56.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: valueOrDefault<Color>(
                                          (_model.hausNrFocusNode?.hasFocus ??
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
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _model.hausNrTextController,
                                        focusNode: _model.hausNrFocusNode,
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
                                                    FlutterFlowTheme.of(context)
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
                                                    FlutterFlowTheme.of(context)
                                                        .labelMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                          focusedErrorBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.all(16.0),
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
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        enableInteractiveSelection: true,
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
                        ),
                        Align(
                          alignment: AlignmentDirectional(1.0, 1.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                36.0, 36.0, 36.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                Navigator.pop(context);
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  useSafeArea: true,
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: DeleteAccDialogWidget(),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));
                              },
                              text: 'Konto löschen',
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
                                      fontSize: 18.0,
                                      letterSpacing: valueOrDefault<double>(
                                        -0.63,
                                        -0.63,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      lineHeight: 1.5,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleSmallIsCustom,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(64.0),
                              ),
                            ),
                          ),
                        ),
                      ]
                          .addToStart(SizedBox(height: 8.0))
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
      ),
    );
  }
}
