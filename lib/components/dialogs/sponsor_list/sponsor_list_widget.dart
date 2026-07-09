import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/pfg_org_for_guest/pfg_org_for_guest_widget.dart';
import '/components/pfg_org_sum_home/pfg_org_sum_home_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'sponsor_list_model.dart';
export 'sponsor_list_model.dart';

class SponsorListWidget extends StatefulWidget {
  const SponsorListWidget({
    super.key,
    required this.userId,
  });

  final String? userId;

  @override
  State<SponsorListWidget> createState() => _SponsorListWidgetState();
}

class _SponsorListWidgetState extends State<SponsorListWidget> {
  late SponsorListModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SponsorListModel());

    _model.searchTextController1 ??= TextEditingController();
    _model.searchFocusNode1 ??= FocusNode();
    _model.searchFocusNode1!.addListener(() => safeSetState(() {}));
    _model.searchTextController2 ??= TextEditingController();
    _model.searchFocusNode2 ??= FocusNode();
    _model.searchFocusNode2!.addListener(() => safeSetState(() {}));
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
      child: Builder(
        builder: (context) {
          if (loggedIn) {
            return FutureBuilder<List<OrganizationRow>>(
              future: OrganizationTable().queryRows(
                queryFn: (q) => q
                    .eqOrNull(
                      'sponsor',
                      true,
                    )
                    .eqOrNull(
                      'test',
                      FFDevEnvironmentValues().test,
                    )
                    .eqOrNull(
                      'hide',
                      false,
                    )
                    .order('title', ascending: true),
              ),
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
                List<OrganizationRow> containerOrganizationRowList =
                    snapshot.data!;

                return Container(
                  decoration: BoxDecoration(),
                  child: FutureBuilder<List<GamesRow>>(
                    future: _model.games(
                      uniqueQueryKey: valueOrDefault<String>(
                        currentUserUid,
                        '0',
                      ),
                      requestFn: () => GamesTable().queryRows(
                        queryFn: (q) => q.eqOrNull(
                          'creator_user_id',
                          widget!.userId,
                        ),
                      ),
                    ),
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
                      List<GamesRow> containerGamesRowList = snapshot.data!;

                      return Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: 90.0,
                          maxWidth: 600.0,
                          maxHeight: MediaQuery.sizeOf(context).height * 0.95,
                        ),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
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
                                        borderRadius:
                                            BorderRadius.circular(99.0),
                                      ),
                                      child: FlutterFlowIconButton(
                                        borderColor: Colors.transparent,
                                        borderRadius: 99.0,
                                        buttonSize: 40.0,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .alternate,
                                        icon: Icon(
                                          FFIcons.kleft,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 14.0,
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
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 40.0, 0.0),
                                        child: Text(
                                          'Meine Sponsoren',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                fontSize: 20.0,
                                                letterSpacing:
                                                    valueOrDefault<double>(
                                                  -0.8,
                                                  -0.8,
                                                ),
                                                fontWeight: FontWeight.w500,
                                                lineHeight: 1.4,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmallIsCustom,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _model.searchTextController1,
                                    focusNode: _model.searchFocusNode1,
                                    onChanged: (_) => EasyDebounce.debounce(
                                      '_model.searchTextController1',
                                      Duration(milliseconds: 50),
                                      () async {
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
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    textInputAction: TextInputAction.done,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmallFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText75,
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
                                                    .titleSmallIsCustom,
                                          ),
                                      hintText: 'Suche nach Name',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .labelMediumFamily,
                                            color: FlutterFlowTheme.of(context)
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
                                                !FlutterFlowTheme.of(context)
                                                    .labelMediumIsCustom,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .focus,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      contentPadding: EdgeInsets.all(16.0),
                                      prefixIcon: Icon(
                                        FFIcons.ksearch,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText50,
                                        size: 20.0,
                                      ),
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
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
                                    maxLines: 3,
                                    minLines: 1,
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    validator: _model
                                        .searchTextController1Validator
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
                                                        .sentences),
                                          );
                                        }),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: _model.columnController,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Builder(
                                        builder: (context) {
                                          if (containerGamesRowList
                                                  .where((e) =>
                                                      e.status == 'completed')
                                                  .toList()
                                                  .length >
                                              0) {
                                            return Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 16.0, 0.0, 0.0),
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
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 4.0, 0.0, 4.0),
                                                  child: Builder(
                                                    builder: (context) {
                                                      final containerVar = functions
                                                              .searchOrg(
                                                                  containerOrganizationRowList
                                                                      .where((e) => FFDevEnvironmentValues()
                                                                              .test
                                                                          ? (e.stripeAccountId != null &&
                                                                              e.stripeAccountId !=
                                                                                  '')
                                                                          : (e.stripeAccountIdLive != null &&
                                                                              e.stripeAccountIdLive !=
                                                                                  ''))
                                                                      .toList(),
                                                                  _model
                                                                      .searchTextController1
                                                                      .text,
                                                                  '',
                                                                  '')
                                                              ?.sortedList(
                                                                  keyOf: (e) =>
                                                                      e.energy!,
                                                                  desc: true)
                                                              ?.toList() ??
                                                          [];
                                                      if (containerVar
                                                          .isEmpty) {
                                                        return Center(
                                                          child: Image.asset(
                                                            'assets/images/emptySponsors.png',
                                                            fit: BoxFit.contain,
                                                          ),
                                                        );
                                                      }

                                                      return ListView.builder(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        itemCount:
                                                            containerVar.length,
                                                        itemBuilder: (context,
                                                            containerVarIndex) {
                                                          final containerVarItem =
                                                              containerVar[
                                                                  containerVarIndex];
                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              if (containerVarIndex >
                                                                  0)
                                                                Divider(
                                                                  height: 1.0,
                                                                  thickness:
                                                                      1.0,
                                                                  indent: 16.0,
                                                                  endIndent:
                                                                      16.0,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            16.0),
                                                                child:
                                                                    PfgOrgSumHomeWidget(
                                                                  key: Key(
                                                                      'Keyqz3_${containerVarIndex}_of_${containerVar.length}'),
                                                                  sum: containerGamesRowList
                                                                              .where((e) =>
                                                                                  e.status ==
                                                                                  'completed')
                                                                              .toList()
                                                                              .length >
                                                                          0
                                                                      ? valueOrDefault<
                                                                          double>(
                                                                          functions.totalSum(containerGamesRowList
                                                                              .where((e) => (e.sponsorMoney! > 0.0) && ((e.status == 'completed') && (e.creatorUserId == currentUserUid)))
                                                                              .toList()
                                                                              .map((e) => e.sponsorMoney)
                                                                              .withoutNulls
                                                                              .toList()),
                                                                          0.0,
                                                                        )
                                                                      : 0.0,
                                                                  date: containerGamesRowList
                                                                              .where((e) =>
                                                                                  e.status ==
                                                                                  'completed')
                                                                              .toList()
                                                                              .length >
                                                                          0
                                                                      ? containerGamesRowList
                                                                          .where((e) =>
                                                                              (e.sponsorMoney! > 0.0) &&
                                                                              (e.status == 'completed'))
                                                                          .toList()
                                                                          .lastOrNull!
                                                                          .createdAt
                                                                      : getCurrentTimestamp,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 16.0, 0.0, 0.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.asset(
                                                  'assets/images/emptySponsors.png',
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ].addToEnd(SizedBox(height: 34.0)),
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
                            ].addToStart(SizedBox(height: 12.0)),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Container(
              decoration: BoxDecoration(),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: 90.0,
                  maxWidth: 600.0,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.95,
                ),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
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
                                  FFIcons.kleft,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 14.0,
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
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 40.0, 0.0),
                                child: Text(
                                  'Meine Sponsoren',
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
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                        child: Container(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _model.searchTextController2,
                            focusNode: _model.searchFocusNode2,
                            onChanged: (_) => EasyDebounce.debounce(
                              '_model.searchTextController2',
                              Duration(milliseconds: 50),
                              () async {
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
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.done,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleSmallFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText75,
                                    fontSize: 16.0,
                                    letterSpacing: valueOrDefault<double>(
                                      -0.4,
                                      -0.4,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1.5,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .titleSmallIsCustom,
                                  ),
                              hintText: 'Suche nach Name',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .labelMediumFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText50,
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
                                  color: Colors.transparent,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).focus,
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
                              contentPadding: EdgeInsets.all(16.0),
                              prefixIcon: Icon(
                                FFIcons.ksearch,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText50,
                                size: 20.0,
                              ),
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
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                            maxLines: 3,
                            minLines: 1,
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            validator: _model.searchTextController2Validator
                                .asValidator(context),
                            inputFormatters: [
                              if (!isAndroid && !isiOS)
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  return TextEditingValue(
                                    selection: newValue.selection,
                                    text: newValue.text.toCapitalization(
                                        TextCapitalization.sentences),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 20.0),
                            child: wrapWithModel(
                              model: _model.pfgOrgForGuestModel,
                              updateCallback: () => safeSetState(() {}),
                              child: PfgOrgForGuestWidget(),
                            ),
                          ),
                        ),
                      ),
                    ].addToStart(SizedBox(height: 12.0)),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
