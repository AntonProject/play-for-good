import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/empty_favoriten_profile/empty_favoriten_profile_widget.dart';
import '/components/organisation_comp/organisation_comp_widget.dart';
import '/components/users_follow_comp/users_follow_comp_widget.dart';
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
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'followers_list_model.dart';
export 'followers_list_model.dart';

class FollowersListWidget extends StatefulWidget {
  const FollowersListWidget({
    super.key,
    required this.userId,
  });

  final String? userId;

  @override
  State<FollowersListWidget> createState() => _FollowersListWidgetState();
}

class _FollowersListWidgetState extends State<FollowersListWidget> {
  late FollowersListModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FollowersListModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (loggedIn) {
        FFAppState().clearFollowUserCacheKey(
            '${FFAppState().refreshDate?.toString()}${currentUserUid}');

        safeSetState(() {});
      }
    });

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
    context.watch<FFAppState>();

    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Builder(
        builder: (context) {
          if (loggedIn) {
            return FutureBuilder<List<FollowersRow>>(
              future: FFAppState().followUser(
                uniqueQueryKey: '${valueOrDefault<String>(
                  FFAppState().refreshDate?.toString(),
                  '0',
                )}${currentUserUid}',
                requestFn: () => FollowersTable().queryRows(
                  queryFn: (q) => q.eqOrNull(
                    'follower_user_id',
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
                List<FollowersRow> containerFollowersRowList = snapshot.data!;

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
                    padding:
                        EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
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
                                    'Meine Favoriten',
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
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                              maxLines: 3,
                              minLines: 1,
                              cursorColor:
                                  FlutterFlowTheme.of(context).primaryText,
                              validator: _model.searchTextController1Validator
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
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              FFButtonWidget(
                                onPressed: () async {
                                  _model.tab = 'all';
                                  safeSetState(() {});
                                },
                                text: 'Alle',
                                options: FFButtonOptions(
                                  height: 34.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: valueOrDefault<Color>(
                                    _model.tab == 'all'
                                        ? FlutterFlowTheme.of(context)
                                            .primaryText
                                        : FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                    FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                  ),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: valueOrDefault<Color>(
                                          _model.tab == 'all'
                                              ? FlutterFlowTheme.of(context)
                                                  .primaryBackground
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                        fontSize: 12.0,
                                        letterSpacing: valueOrDefault<double>(
                                          -0.24,
                                          -0.24,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                  elevation: 0.0,
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(99.0),
                                ),
                              ),
                              FFButtonWidget(
                                onPressed: () async {
                                  _model.tab = 'orgs';
                                  safeSetState(() {});
                                },
                                text: 'Organisationen',
                                options: FFButtonOptions(
                                  height: 34.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: valueOrDefault<Color>(
                                    _model.tab == 'orgs'
                                        ? FlutterFlowTheme.of(context)
                                            .primaryText
                                        : FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                    FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                  ),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: valueOrDefault<Color>(
                                          _model.tab == 'orgs'
                                              ? FlutterFlowTheme.of(context)
                                                  .primaryBackground
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                        fontSize: 12.0,
                                        letterSpacing: valueOrDefault<double>(
                                          -0.24,
                                          -0.24,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                  elevation: 0.0,
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(99.0),
                                ),
                              ),
                              FFButtonWidget(
                                onPressed: () async {
                                  _model.tab = 'users';
                                  safeSetState(() {});
                                },
                                text: 'Players',
                                options: FFButtonOptions(
                                  height: 34.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: valueOrDefault<Color>(
                                    _model.tab == 'users'
                                        ? FlutterFlowTheme.of(context)
                                            .primaryText
                                        : FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                    FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                  ),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: valueOrDefault<Color>(
                                          _model.tab == 'users'
                                              ? FlutterFlowTheme.of(context)
                                                  .primaryBackground
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                        fontSize: 12.0,
                                        letterSpacing: valueOrDefault<double>(
                                          -0.24,
                                          -0.24,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                  elevation: 0.0,
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(99.0),
                                ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: SingleChildScrollView(
                              controller: _model.columnController,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      if (_model.tab == 'users') {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0,
                                                    valueOrDefault<double>(
                                                      containerFollowersRowList
                                                              .where((e) =>
                                                                  functions.searchName(
                                                                      e
                                                                          .followingUserName,
                                                                      _model
                                                                          .searchTextController1
                                                                          .text) &&
                                                                  (e.followingUserId !=
                                                                          null &&
                                                                      e.followingUserId !=
                                                                          ''))
                                                              .toList()
                                                              .isNotEmpty
                                                          ? 16.0
                                                          : 0.0,
                                                      0.0,
                                                    ),
                                                    0.0,
                                                    valueOrDefault<double>(
                                                      containerFollowersRowList
                                                              .where((e) =>
                                                                  functions.searchName(
                                                                      e
                                                                          .followingUserName,
                                                                      _model
                                                                          .searchTextController1
                                                                          .text) &&
                                                                  (e.followingUserId !=
                                                                          null &&
                                                                      e.followingUserId !=
                                                                          ''))
                                                              .toList()
                                                              .isNotEmpty
                                                          ? 16.0
                                                          : 0.0,
                                                      0.0,
                                                    )),
                                            child: Builder(
                                              builder: (context) {
                                                final users = containerFollowersRowList
                                                    .where((e) =>
                                                        functions.searchName(
                                                            e.followingUserName,
                                                            _model
                                                                .searchTextController1
                                                                .text) &&
                                                        (e.followingUserId !=
                                                                null &&
                                                            e.followingUserId !=
                                                                ''))
                                                    .toList()
                                                    .sortedList(
                                                        keyOf: (e) => e
                                                            .followingUserName!,
                                                        desc: false)
                                                    .toList();
                                                if (users.isEmpty) {
                                                  return Center(
                                                    child: Image.asset(
                                                      'assets/images/circleEmpty.png',
                                                      fit: BoxFit.contain,
                                                    ),
                                                  );
                                                }

                                                return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: List.generate(
                                                      users.length,
                                                      (usersIndex) {
                                                    final usersItem =
                                                        users[usersIndex];
                                                    return Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  32.0,
                                                                  0.0,
                                                                  32.0,
                                                                  0.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (usersIndex > 0)
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
                                                            child:
                                                                UsersFollowCompWidget(
                                                              key: Key(
                                                                  'Keyll5_${usersIndex}_of_${users.length}'),
                                                              userId: usersItem
                                                                  .followingUserId!,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      } else if (_model.tab == 'orgs') {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          child: Builder(
                                            builder: (context) {
                                              final orgs = containerFollowersRowList
                                                  .where((e) =>
                                                      functions.searchName(
                                                          e
                                                              .followingOrganizationName,
                                                          _model
                                                              .searchTextController1
                                                              .text) &&
                                                      (e.followingOrganizationId !=
                                                              null &&
                                                          e.followingOrganizationId !=
                                                              ''))
                                                  .toList()
                                                  .sortedList(
                                                      keyOf: (e) => e
                                                          .followingOrganizationName!,
                                                      desc: false)
                                                  .toList();
                                              if (orgs.isEmpty) {
                                                return Center(
                                                  child: Image.asset(
                                                    'assets/images/wishEmpty.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                );
                                              }

                                              return Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: List
                                                        .generate(orgs.length,
                                                            (orgsIndex) {
                                                  final orgsItem =
                                                      orgs[orgsIndex];
                                                  return Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(32.0, 0.0,
                                                                32.0, 0.0),
                                                    child: FutureBuilder<
                                                        List<OrganizationRow>>(
                                                      future:
                                                          OrganizationTable()
                                                              .querySingleRow(
                                                        queryFn: (q) =>
                                                            q.eqOrNull(
                                                          'id',
                                                          orgsItem
                                                              .followingOrganizationId,
                                                        ),
                                                      ),
                                                      builder:
                                                          (context, snapshot) {
                                                        // Customize what your widget looks like when it's loading.
                                                        if (!snapshot.hasData) {
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
                                                            columnOrganizationRowList =
                                                            snapshot.data!;

                                                        // Return an empty Container when the item does not exist.
                                                        if (snapshot
                                                            .data!.isEmpty) {
                                                          return Container();
                                                        }
                                                        final columnOrganizationRow =
                                                            columnOrganizationRowList
                                                                    .isNotEmpty
                                                                ? columnOrganizationRowList
                                                                    .first
                                                                : null;

                                                        return Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            if (orgsIndex > 0)
                                                              Divider(
                                                                height: 32.0,
                                                                thickness: 1.0,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                              ),
                                                            OrganisationCompWidget(
                                                              key: Key(
                                                                  'Keyk72_${orgsIndex}_of_${orgs.length}'),
                                                              orgRow:
                                                                  columnOrganizationRow!,
                                                              buttonText:
                                                                  'Auswählen',
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  );
                                                })
                                                    .addToStart(
                                                        SizedBox(height: 32.0))
                                                    .addToEnd(
                                                        SizedBox(height: 32.0)),
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          child: Builder(
                                            builder: (context) {
                                              final all = functions
                                                      .searchFollowers(
                                                          containerFollowersRowList
                                                              .toList(),
                                                          _model
                                                              .searchTextController1
                                                              .text)
                                                      ?.toList() ??
                                                  [];
                                              if (all.isEmpty) {
                                                return Center(
                                                  child: Image.asset(
                                                    'assets/images/wishEmpty.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                );
                                              }

                                              return Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: List.generate(
                                                        all.length, (allIndex) {
                                                  final allItem = all[allIndex];
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      if (allItem.followingOrganizationId !=
                                                              null &&
                                                          allItem.followingOrganizationId !=
                                                              '')
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      32.0,
                                                                      0.0,
                                                                      32.0,
                                                                      0.0),
                                                          child: FutureBuilder<
                                                              List<
                                                                  OrganizationRow>>(
                                                            future: OrganizationTable()
                                                                .querySingleRow(
                                                              queryFn: (q) =>
                                                                  q.eqOrNull(
                                                                'id',
                                                                allItem
                                                                    .followingOrganizationId,
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
                                                                    width: 20.0,
                                                                    height:
                                                                        20.0,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      valueColor:
                                                                          AlwaysStoppedAnimation<
                                                                              Color>(
                                                                        FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                              List<OrganizationRow>
                                                                  columnOrganizationRowList =
                                                                  snapshot
                                                                      .data!;

                                                              // Return an empty Container when the item does not exist.
                                                              if (snapshot.data!
                                                                  .isEmpty) {
                                                                return Container();
                                                              }
                                                              final columnOrganizationRow =
                                                                  columnOrganizationRowList
                                                                          .isNotEmpty
                                                                      ? columnOrganizationRowList
                                                                          .first
                                                                      : null;

                                                              return Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  if (allIndex >
                                                                      0)
                                                                    Divider(
                                                                      height:
                                                                          32.0,
                                                                      thickness:
                                                                          1.0,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                    ),
                                                                  OrganisationCompWidget(
                                                                    key: Key(
                                                                        'Keytd7_${allIndex}_of_${all.length}'),
                                                                    orgRow:
                                                                        columnOrganizationRow!,
                                                                    buttonText:
                                                                        'Auswählen',
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      if (allItem.followingUserId !=
                                                              null &&
                                                          allItem.followingUserId !=
                                                              '')
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      32.0,
                                                                      0.0,
                                                                      32.0,
                                                                      0.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              if (allIndex > 0)
                                                                Divider(
                                                                  height: 32.0,
                                                                  thickness:
                                                                      1.0,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                ),
                                                              UsersFollowCompWidget(
                                                                key: Key(
                                                                    'Keyada_${allIndex}_of_${all.length}'),
                                                                userId: allItem
                                                                    .followingUserId!,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  );
                                                })
                                                    .addToStart(
                                                        SizedBox(height: 32.0))
                                                    .addToEnd(
                                                        SizedBox(height: 32.0)),
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ].addToEnd(SizedBox(height: 100.0)),
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
                      ].addToStart(SizedBox(height: 12.0)),
                    ),
                  ),
                );
              },
            );
          } else {
            return Align(
              alignment: AlignmentDirectional(0.0, 1.0),
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
                                  'Meine Favoriten',
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
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 20.0),
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
                            EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 2.0, 0.0),
                        child: wrapWithModel(
                          model: _model.emptyFavoritenProfileModel,
                          updateCallback: () => safeSetState(() {}),
                          child: EmptyFavoritenProfileWidget(),
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
