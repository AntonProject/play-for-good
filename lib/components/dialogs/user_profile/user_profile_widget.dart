import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/dialogs/auth_dialog/auth_dialog_widget.dart';
import '/components/dialogs/followers_list/followers_list_widget.dart';
import '/components/dialogs/invites_list/invites_list_widget.dart';
import '/components/dialogs/profile_edit_dialog/profile_edit_dialog_widget.dart';
import '/components/dialogs/profile_games_orgs_dialog/profile_games_orgs_dialog_widget.dart';
import '/components/dialogs/sponsor_list/sponsor_list_widget.dart';
import '/components/empty_post_profile/empty_post_profile_widget.dart';
import '/components/image/image_widget.dart';
import '/components/org_profile/org_profile_widget.dart';
import '/components/post_comp/post_comp_widget.dart';
import '/components/profile_option/profile_option_widget.dart';
import '/components/user_profile_info_stats_row/user_profile_info_stats_row_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'user_profile_model.dart';
export 'user_profile_model.dart';

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({
    super.key,
    required this.userId,
  });

  final String? userId;

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  late UserProfileModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserProfileModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget!.userId == currentUserUid) {
        _model.tab = 3;
        safeSetState(() {});
      }
    });

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
          if (widget!.userId != 'guest') {
            return FutureBuilder<List<UsersRow>>(
              future: UsersTable().queryRows(
                queryFn: (q) => q,
              ),
              builder: (context, snapshot) {
                // Customize what your widget looks like when it's loading.
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.transparent,
                        ),
                      ),
                    ),
                  );
                }
                List<UsersRow> allUsersContainerUsersRowList = snapshot.data!;

                return Container(
                  decoration: BoxDecoration(),
                  child: FutureBuilder<List<InvitesRow>>(
                    future: InvitesTable().queryRows(
                      queryFn: (q) => q.eqOrNull(
                        'inviter_user_id',
                        widget!.userId,
                      ),
                    ),
                    builder: (context, snapshot) {
                      // Customize what your widget looks like when it's loading.
                      if (!snapshot.hasData) {
                        return Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.transparent,
                              ),
                            ),
                          ),
                        );
                      }
                      List<InvitesRow> invitesContainerInvitesRowList =
                          snapshot.data!;

                      return Container(
                        decoration: BoxDecoration(),
                        child: FutureBuilder<List<GamesRow>>(
                          future: GamesTable().queryRows(
                            queryFn: (q) => q.eqOrNull(
                              'creator_user_id',
                              widget!.userId,
                            ),
                          ),
                          builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
                            if (!snapshot.hasData) {
                              return Center(
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.transparent,
                                    ),
                                  ),
                                ),
                              );
                            }
                            List<GamesRow> gamesContainerGamesRowList =
                                snapshot.data!;

                            return Container(
                              decoration: BoxDecoration(),
                              child: FutureBuilder<List<UsersRow>>(
                                future: FFAppState().user(
                                  uniqueQueryKey:
                                      '${widget!.userId}${FFAppState().refreshDate?.toString()}',
                                  requestFn: () => UsersTable().querySingleRow(
                                    queryFn: (q) => q.eqOrNull(
                                      'id',
                                      widget!.userId,
                                    ),
                                  ),
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  List<UsersRow> userContainerUsersRowList =
                                      snapshot.data!;

                                  final userContainerUsersRow =
                                      userContainerUsersRowList.isNotEmpty
                                          ? userContainerUsersRowList.first
                                          : null;

                                  return Container(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.95,
                                    constraints: BoxConstraints(
                                      maxWidth: 600.0,
                                    ),
                                    decoration: BoxDecoration(
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
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional(0.0, -1.0),
                                      child: SingleChildScrollView(
                                        controller: _model.columnController1,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            if (false)
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, -1.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(16.0),
                                                      topRight:
                                                          Radius.circular(16.0),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                16.0,
                                                                12.0,
                                                                16.0,
                                                                0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          width: 56.0,
                                                          height: 40.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        99.0),
                                                          ),
                                                          child:
                                                              FlutterFlowIconButton(
                                                            borderColor: Colors
                                                                .transparent,
                                                            borderRadius: 99.0,
                                                            buttonSize: 40.0,
                                                            fillColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .alternate,
                                                            icon: Icon(
                                                              FFIcons.kxmark,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 24.0,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, -1.0),
                                              child: Container(
                                                constraints: BoxConstraints(
                                                  minHeight: 400.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: Image.asset(
                                                      'assets/images/user_profile_background.png',
                                                    ).image,
                                                  ),
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, -1.0),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, -1.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0.0,
                                                                1.0,
                                                                0.0,
                                                                valueOrDefault<
                                                                    double>(
                                                                  widget!.userId !=
                                                                          currentUserUid
                                                                      ? 0.0
                                                                      : 76.0,
                                                                  0.0,
                                                                )),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  -1.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        16.0,
                                                                        8.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Container(
                                                              width: 56.0,
                                                              height: 40.0,
                                                              decoration:
                                                                  BoxDecoration(),
                                                              child:
                                                                  FlutterFlowIconButton(
                                                                borderColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                borderRadius:
                                                                    99.0,
                                                                borderWidth:
                                                                    1.0,
                                                                buttonSize:
                                                                    40.0,
                                                                icon: Icon(
                                                                  FFIcons.kleft,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  size: 14.0,
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 96.0,
                                                          height: 96.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius:
                                                                    48.0,
                                                                color: Color(
                                                                    0x2E000000),
                                                                offset: Offset(
                                                                  0.0,
                                                                  24.0,
                                                                ),
                                                                spreadRadius:
                                                                    12.0,
                                                              )
                                                            ],
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Container(
                                                            width: 96.0,
                                                            height: 96.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryBackground,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  blurRadius:
                                                                      8.0,
                                                                  color: Color(
                                                                      0x0A000000),
                                                                  offset:
                                                                      Offset(
                                                                    0.0,
                                                                    4.0,
                                                                  ),
                                                                  spreadRadius:
                                                                      12.0,
                                                                )
                                                              ],
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                width: 4.0,
                                                              ),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child:
                                                                  wrapWithModel(
                                                                model: _model
                                                                    .imageModel1,
                                                                updateCallback: () =>
                                                                    safeSetState(
                                                                        () {}),
                                                                child:
                                                                    ImageWidget(
                                                                  size: 96.0,
                                                                  image:
                                                                      valueOrDefault<
                                                                          String>(
                                                                    userContainerUsersRow
                                                                        ?.photoUrl,
                                                                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        16.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Text(
                                                              widget!.userId !=
                                                                      'guest'
                                                                  ? valueOrDefault<
                                                                      String>(
                                                                      '@${valueOrDefault<String>(
                                                                        userContainerUsersRow
                                                                            ?.displayName,
                                                                        'unnamed',
                                                                      )}',
                                                                      '@unnamed',
                                                                    )
                                                                  : '@playerforgood_${valueOrDefault<String>(
                                                                      (valueOrDefault<int>(
                                                                                allUsersContainerUsersRowList.length,
                                                                                0,
                                                                              ) +
                                                                              1)
                                                                          .toString(),
                                                                      '235',
                                                                    )}',
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
                                                                    fontSize:
                                                                        20.0,
                                                                    letterSpacing:
                                                                        valueOrDefault<
                                                                            double>(
                                                                      -0.7,
                                                                      -0.7,
                                                                    ),
                                                                    lineHeight:
                                                                        1.5,
                                                                  ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        4.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Text(
                                                              widget!.userId !=
                                                                      'guest'
                                                                  ? valueOrDefault<
                                                                      String>(
                                                                      '${userContainerUsersRow?.firstName != null && userContainerUsersRow?.firstName != '' ? userContainerUsersRow?.firstName : ''} ${userContainerUsersRow?.surname != null && userContainerUsersRow?.surname != '' ? userContainerUsersRow?.surname : ''}',
                                                                      ' unnamed',
                                                                    )
                                                                  : 'Gastnutzer',
                                                              maxLines: 3,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .labelSmallFamily,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                    letterSpacing:
                                                                        valueOrDefault<
                                                                            double>(
                                                                      -0.2,
                                                                      -0.2,
                                                                    ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    lineHeight:
                                                                        1.5,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .labelSmallIsCustom,
                                                                  ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      18.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Container(
                                                            height: 67.0,
                                                            decoration:
                                                                BoxDecoration(),
                                                            child: Stack(
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          -1.0),
                                                                  child: Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      '${valueOrDefault<String>(
                                                                        widget!.userId !=
                                                                                'guest'
                                                                            ? formatNumber(
                                                                                functions.getUserRatingScore(gamesContainerGamesRowList.where((e) => (e.creatorUserId == widget!.userId) && (e.status == 'completed')).toList(), 'gesamt', 'valuable', invitesContainerInvitesRowList.toList(), widget!.userId!),
                                                                                formatType: FormatType.custom,
                                                                                format: '',
                                                                                locale: '',
                                                                              )
                                                                            : '100',
                                                                        '100',
                                                                      )} LW',
                                                                      '100 LW',
                                                                    ),
                                                                    maxLines: 3,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .displaySmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Dela Gothic One',
                                                                          color:
                                                                              Color(0xFFC4AF7F),
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          lineHeight:
                                                                              1.5,
                                                                        ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          1.0),
                                                                  child: Text(
                                                                    'Good Power',
                                                                    maxLines: 3,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).labelSmallFamily,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryBackground,
                                                                          fontSize:
                                                                              11.0,
                                                                          letterSpacing:
                                                                              valueOrDefault<double>(
                                                                            -0.2,
                                                                            -0.2,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          lineHeight:
                                                                              1.5,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                        ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        8.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: StreamBuilder<
                                                                List<GamesRow>>(
                                                              stream:
                                                                  FFAppState()
                                                                      .games(
                                                                uniqueQueryKey:
                                                                    '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                                                                requestFn: () => _model.containerSupabaseStream1 ??= SupaFlow
                                                                    .client
                                                                    .from(
                                                                        "games")
                                                                    .stream(
                                                                        primaryKey: [
                                                                          'id'
                                                                        ])
                                                                    .eqOrNull(
                                                                      'status',
                                                                      'completed',
                                                                    )
                                                                    .map((list) => list
                                                                        .map((item) =>
                                                                            GamesRow(item))
                                                                        .toList()),
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
                                                                List<GamesRow>
                                                                    containerGamesRowList =
                                                                    snapshot
                                                                        .data!;

                                                                return Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        blurRadius:
                                                                            2.0,
                                                                        color: Color(
                                                                            0x50000000),
                                                                        offset:
                                                                            Offset(
                                                                          0.0,
                                                                          2.0,
                                                                        ),
                                                                        spreadRadius:
                                                                            0.0,
                                                                      )
                                                                    ],
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            360.0),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          blurRadius:
                                                                              4.0,
                                                                          color:
                                                                              Color(0x14000000),
                                                                          offset:
                                                                              Offset(
                                                                            0.0,
                                                                            2.0,
                                                                          ),
                                                                          spreadRadius:
                                                                              0.0,
                                                                        )
                                                                      ],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              360.0),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          18.0,
                                                                          3.0,
                                                                          18.0,
                                                                          3.0),
                                                                      child:
                                                                          Text(
                                                                        '#${valueOrDefault<String>(
                                                                          functions
                                                                              .ratingUsersPerUser(containerGamesRowList.toList(), 'gesamt', 'valuable', invitesContainerInvitesRowList.toList(), widget!.userId, allUsersContainerUsersRowList.length)
                                                                              .toString(),
                                                                          '0',
                                                                        )}',
                                                                        maxLines:
                                                                            3,
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.24,
                                                                                -0.24,
                                                                              ),
                                                                              fontWeight: FontWeight.w500,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                            ),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        if ((widget!.userId !=
                                                                currentUserUid) &&
                                                            loggedIn)
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        50.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                  height: 80.0,
                                                                  decoration:
                                                                      BoxDecoration(),
                                                                  child: FutureBuilder<
                                                                      List<
                                                                          FollowersRow>>(
                                                                    future: FFAppState()
                                                                        .followUser(
                                                                      uniqueQueryKey:
                                                                          '${widget!.userId}${FFAppState().refreshDate?.toString()}',
                                                                      requestFn:
                                                                          () =>
                                                                              FollowersTable().querySingleRow(
                                                                        queryFn: (q) => q
                                                                            .eqOrNull(
                                                                              'follower_user_id',
                                                                              currentUserUid,
                                                                            )
                                                                            .eqOrNull(
                                                                              'following_user_id',
                                                                              widget!.userId,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      // Customize what your widget looks like when it's loading.
                                                                      if (!snapshot
                                                                          .hasData) {
                                                                        return Center(
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                40.0,
                                                                            height:
                                                                                40.0,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                                                Colors.transparent,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                      List<FollowersRow>
                                                                          rowFollowersRowList =
                                                                          snapshot
                                                                              .data!;

                                                                      final rowFollowersRow = rowFollowersRowList
                                                                              .isNotEmpty
                                                                          ? rowFollowersRowList
                                                                              .first
                                                                          : null;

                                                                      return Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children:
                                                                            [
                                                                          if (rowFollowersRow?.id == null ||
                                                                              rowFollowersRow?.id == '')
                                                                            Container(
                                                                              width: 60.0,
                                                                              height: 60.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    blurRadius: 2.0,
                                                                                    color: Color(0x0F000000),
                                                                                    offset: Offset(
                                                                                      0.0,
                                                                                      2.0,
                                                                                    ),
                                                                                    spreadRadius: 2.0,
                                                                                  )
                                                                                ],
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: Stack(
                                                                                children: [
                                                                                  Align(
                                                                                    alignment: AlignmentDirectional(0.0, 0.0),
                                                                                    child: ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(8.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/wish.png',
                                                                                        width: 40.0,
                                                                                        height: 40.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Align(
                                                                                    alignment: AlignmentDirectional(0.0, 0.0),
                                                                                    child: FlutterFlowIconButton(
                                                                                      borderRadius: 99.0,
                                                                                      buttonSize: 80.0,
                                                                                      icon: Icon(
                                                                                        Icons.arrow_back,
                                                                                        size: 0.0,
                                                                                      ),
                                                                                      showLoadingIndicator: true,
                                                                                      onPressed: () async {
                                                                                        _model.follow = await FollowersTable().insert({
                                                                                          'created_at': supaSerialize<DateTime>(getCurrentTimestamp),
                                                                                          'follower_user_id': currentUserUid,
                                                                                          'following_user_id': widget!.userId,
                                                                                          'following_user_name': '${userContainerUsersRow?.displayName} ${userContainerUsersRow?.firstName} ${userContainerUsersRow?.surname}',
                                                                                        });
                                                                                        FFAppState().refreshDate = getCurrentTimestamp;
                                                                                        FFAppState().update(() {});
                                                                                        FFAppState().clearFollowUserCacheKey('${valueOrDefault<String>(
                                                                                          FFAppState().refreshDate?.toString(),
                                                                                          '0',
                                                                                        )}${currentUserUid}');

                                                                                        FFAppState().update(() {});

                                                                                        safeSetState(() {});
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          if (rowFollowersRow?.id != null &&
                                                                              rowFollowersRow?.id != '')
                                                                            Container(
                                                                              width: 60.0,
                                                                              height: 60.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    blurRadius: 2.0,
                                                                                    color: Color(0x0F000000),
                                                                                    offset: Offset(
                                                                                      0.0,
                                                                                      2.0,
                                                                                    ),
                                                                                    spreadRadius: 2.0,
                                                                                  )
                                                                                ],
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: Stack(
                                                                                children: [
                                                                                  Align(
                                                                                    alignment: AlignmentDirectional(0.0, 0.0),
                                                                                    child: ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(8.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/wishOn.png',
                                                                                        width: 40.0,
                                                                                        height: 40.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Align(
                                                                                    alignment: AlignmentDirectional(0.0, 0.0),
                                                                                    child: FlutterFlowIconButton(
                                                                                      borderRadius: 99.0,
                                                                                      buttonSize: 80.0,
                                                                                      icon: Icon(
                                                                                        Icons.arrow_back,
                                                                                        size: 0.0,
                                                                                      ),
                                                                                      showLoadingIndicator: true,
                                                                                      onPressed: () async {
                                                                                        await FollowersTable().delete(
                                                                                          matchingRows: (rows) => rows.eqOrNull(
                                                                                            'id',
                                                                                            rowFollowersRow?.id,
                                                                                          ),
                                                                                        );
                                                                                        FFAppState().refreshDate = getCurrentTimestamp;
                                                                                        FFAppState().update(() {});
                                                                                        FFAppState().clearFollowUserCacheKey('${valueOrDefault<String>(
                                                                                          FFAppState().refreshDate?.toString(),
                                                                                          '0',
                                                                                        )}${currentUserUid}');

                                                                                        FFAppState().update(() {});

                                                                                        safeSetState(() {});
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'Favorite',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleMediumFamily,
                                                                        fontSize:
                                                                            12.0,
                                                                        letterSpacing:
                                                                            valueOrDefault<double>(
                                                                          -0.24,
                                                                          -0.24,
                                                                        ),
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        lineHeight:
                                                                            1.5,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  height: 8.0)),
                                                            ),
                                                          ),
                                                      ].addToStart(SizedBox(
                                                          height: 16.0)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, -1.0),
                                              child: Container(
                                                constraints: BoxConstraints(
                                                  minHeight:
                                                      MediaQuery.sizeOf(context)
                                                              .height *
                                                          0.5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  14.0,
                                                                  24.0,
                                                                  14.0,
                                                                  0.0),
                                                      child: Container(
                                                        height: 48.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      32.0),
                                                          border: Border.all(
                                                            color: Colors
                                                                .transparent,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    FFButtonWidget(
                                                                  onPressed:
                                                                      () async {
                                                                    _model.tab =
                                                                        1;
                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text: 'Info',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        40.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: valueOrDefault<
                                                                        Color>(
                                                                      _model.tab == 1
                                                                          ? FlutterFlowTheme.of(context)
                                                                              .secondary
                                                                          : Colors
                                                                              .transparent,
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondary,
                                                                    ),
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).titleSmallFamily,
                                                                          color:
                                                                              valueOrDefault<Color>(
                                                                            _model.tab == 1
                                                                                ? FlutterFlowTheme.of(context).primaryBackground
                                                                                : FlutterFlowTheme.of(context).primaryText,
                                                                            FlutterFlowTheme.of(context).primaryBackground,
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
                                                                    elevation:
                                                                        0.0,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            99.0),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    FFButtonWidget(
                                                                  onPressed:
                                                                      () async {
                                                                    _model.tab =
                                                                        2;
                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text: 'Posts',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        40.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: valueOrDefault<
                                                                        Color>(
                                                                      _model.tab == 2
                                                                          ? FlutterFlowTheme.of(context)
                                                                              .secondary
                                                                          : Colors
                                                                              .transparent,
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondary,
                                                                    ),
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).titleSmallFamily,
                                                                          color:
                                                                              valueOrDefault<Color>(
                                                                            _model.tab == 2
                                                                                ? FlutterFlowTheme.of(context).primaryBackground
                                                                                : FlutterFlowTheme.of(context).primaryText,
                                                                            FlutterFlowTheme.of(context).primaryBackground,
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
                                                                    elevation:
                                                                        0.0,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            99.0),
                                                                  ),
                                                                ),
                                                              ),
                                                              if ((widget!.userId ==
                                                                      currentUserUid) ||
                                                                  (widget!.userId ==
                                                                      'guest'))
                                                                Expanded(
                                                                  child:
                                                                      FFButtonWidget(
                                                                    onPressed:
                                                                        () async {
                                                                      _model.tab =
                                                                          3;
                                                                      safeSetState(
                                                                          () {});
                                                                    },
                                                                    text:
                                                                        'Mein Profil',
                                                                    options:
                                                                        FFButtonOptions(
                                                                      height:
                                                                          40.0,
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                                      iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                      color: valueOrDefault<
                                                                          Color>(
                                                                        _model.tab ==
                                                                                3
                                                                            ? FlutterFlowTheme.of(context).secondary
                                                                            : Colors.transparent,
                                                                        FlutterFlowTheme.of(context)
                                                                            .secondary,
                                                                      ),
                                                                      textStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).titleSmallFamily,
                                                                            color:
                                                                                valueOrDefault<Color>(
                                                                              _model.tab == 3 ? FlutterFlowTheme.of(context).primaryBackground : FlutterFlowTheme.of(context).primaryText,
                                                                              FlutterFlowTheme.of(context).primaryBackground,
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
                                                                      elevation:
                                                                          0.0,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              99.0),
                                                                    ),
                                                                  ),
                                                                ),
                                                            ].divide(SizedBox(
                                                                width: 4.0)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Builder(
                                                      builder: (context) {
                                                        if (_model.tab == 1) {
                                                          return Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Padding(
                                                              padding: EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      14.0,
                                                                      0.0,
                                                                      14.0,
                                                                      valueOrDefault<
                                                                          double>(
                                                                        MediaQuery.paddingOf(context).bottom +
                                                                            48,
                                                                        48.0,
                                                                      )),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  if ((widget!.userId !=
                                                                          'guest') &&
                                                                      (userContainerUsersRow?.info !=
                                                                              null &&
                                                                          userContainerUsersRow?.info !=
                                                                              ''))
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          26.0,
                                                                          24.0,
                                                                          26.0,
                                                                          8.0),
                                                                      child:
                                                                          Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          userContainerUsersRow
                                                                              ?.info,
                                                                          'info',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.35,
                                                                                -0.35,
                                                                              ),
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Align(
                                                                        alignment: AlignmentDirectional(
                                                                            -1.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              12.0,
                                                                              24.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              Text(
                                                                            'Unterstützte Organisationen',
                                                                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                                  letterSpacing: valueOrDefault<double>(
                                                                                    -0.63,
                                                                                    -0.63,
                                                                                  ),
                                                                                  fontWeight: FontWeight.w500,
                                                                                  lineHeight: 1.4,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              double.infinity,
                                                                          constraints:
                                                                              BoxConstraints(
                                                                            minHeight:
                                                                                82.0,
                                                                            maxWidth:
                                                                                600.0,
                                                                          ),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                BorderRadius.circular(16.0),
                                                                          ),
                                                                          child:
                                                                              Builder(
                                                                            builder:
                                                                                (context) {
                                                                              if ((widget!.userId == 'guest') || !(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList().isNotEmpty)) {
                                                                                return Padding(
                                                                                  padding: EdgeInsets.all(16.0),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 4.0, 4.0),
                                                                                        child: Icon(
                                                                                          FFIcons.kdonate,
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                          size: 32.0,
                                                                                        ),
                                                                                      ),
                                                                                      Text(
                                                                                        'Noch keine unterstützt',
                                                                                        style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                              fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                              letterSpacing: valueOrDefault<double>(
                                                                                                -0.4,
                                                                                                -0.4,
                                                                                              ),
                                                                                              fontWeight: FontWeight.bold,
                                                                                              lineHeight: 1.5,
                                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                            ),
                                                                                      ),
                                                                                    ].divide(SizedBox(width: 16.0)),
                                                                                  ),
                                                                                );
                                                                              } else {
                                                                                return FutureBuilder<List<OrganizationRow>>(
                                                                                  future: OrganizationTable().queryRows(
                                                                                    queryFn: (q) => q
                                                                                        .eqOrNull(
                                                                                          'hide',
                                                                                          false,
                                                                                        )
                                                                                        .eqOrNull(
                                                                                          'sponsor',
                                                                                          false,
                                                                                        ),
                                                                                  ),
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
                                                                                    List<OrganizationRow> containerOrganizationRowList = snapshot.data!;

                                                                                    return Container(
                                                                                      decoration: BoxDecoration(),
                                                                                      child: Column(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: EdgeInsets.all(12.0),
                                                                                            child: Builder(
                                                                                              builder: (context) {
                                                                                                final organizations = functions.getOrgIdsSortedByGamesCount(gamesContainerGamesRowList.where((e) => e.status == 'completed').toList()).toList().take(5).toList();

                                                                                                return Column(
                                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                                  children: List.generate(organizations.length, (organizationsIndex) {
                                                                                                    final organizationsItem = organizations[organizationsIndex];
                                                                                                    return Column(
                                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                                      children: [
                                                                                                        Padding(
                                                                                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                                                                                                          child: InkWell(
                                                                                                            splashColor: Colors.transparent,
                                                                                                            focusColor: Colors.transparent,
                                                                                                            hoverColor: Colors.transparent,
                                                                                                            highlightColor: Colors.transparent,
                                                                                                            onTap: () async {
                                                                                                              if (loggedIn) {
                                                                                                                context.pushNamed(
                                                                                                                  OrganisationPageWidget.routeName,
                                                                                                                  queryParameters: {
                                                                                                                    'orgId': serializeParam(
                                                                                                                      organizationsItem,
                                                                                                                      ParamType.String,
                                                                                                                    ),
                                                                                                                  }.withoutNulls,
                                                                                                                );
                                                                                                              }
                                                                                                            },
                                                                                                            child: OrgProfileWidget(
                                                                                                              key: Key('Keyfs5_${organizationsIndex}_of_${organizations.length}'),
                                                                                                              image: valueOrDefault<String>(
                                                                                                                containerOrganizationRowList.where((e) => e.id == organizationsItem).toList().firstOrNull?.imageUrl,
                                                                                                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/d6ilkv8n1ka3/Avatar.png',
                                                                                                              ),
                                                                                                              title: valueOrDefault<String>(
                                                                                                                gamesContainerGamesRowList.where((e) => e.organizationId == organizationsItem).toList().firstOrNull?.orgName,
                                                                                                                'Organisation',
                                                                                                              ),
                                                                                                              goodGamesCount: valueOrDefault<int>(
                                                                                                                gamesContainerGamesRowList.where((e) => e.organizationId == organizationsItem).toList().length,
                                                                                                                1,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                        if (functions.getOrgIdsSortedByGamesCount(gamesContainerGamesRowList.toList()).length > (organizationsIndex + 1))
                                                                                                          Divider(
                                                                                                            height: 1.0,
                                                                                                            thickness: 1.0,
                                                                                                            color: FlutterFlowTheme.of(context).primaryText,
                                                                                                          ),
                                                                                                      ],
                                                                                                    );
                                                                                                  }),
                                                                                                );
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                          if (functions.getOrgIdsSortedByGamesCount(gamesContainerGamesRowList.toList()).length > 5)
                                                                                            Padding(
                                                                                              padding: EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 12.0),
                                                                                              child: InkWell(
                                                                                                splashColor: Colors.transparent,
                                                                                                focusColor: Colors.transparent,
                                                                                                hoverColor: Colors.transparent,
                                                                                                highlightColor: Colors.transparent,
                                                                                                onTap: () async {
                                                                                                  await showModalBottomSheet(
                                                                                                    isScrollControlled: true,
                                                                                                    backgroundColor: Colors.transparent,
                                                                                                    barrierColor: Color(0x66000000),
                                                                                                    context: context,
                                                                                                    builder: (context) {
                                                                                                      return Padding(
                                                                                                        padding: MediaQuery.viewInsetsOf(context),
                                                                                                        child: ProfileGamesOrgsDialogWidget(
                                                                                                          userId: widget!.userId,
                                                                                                        ),
                                                                                                      );
                                                                                                    },
                                                                                                  ).then((value) => safeSetState(() {}));
                                                                                                },
                                                                                                child: Row(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  children: [
                                                                                                    Container(
                                                                                                      width: 40.0,
                                                                                                      height: 40.0,
                                                                                                      decoration: BoxDecoration(),
                                                                                                      alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                      child: Icon(
                                                                                                        FFIcons.keye,
                                                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                                                        size: 24.0,
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Text(
                                                                                                        'Mehr',
                                                                                                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                                              fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                                                                                                              letterSpacing: valueOrDefault<double>(
                                                                                                                -0.4,
                                                                                                                -0.4,
                                                                                                              ),
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              lineHeight: 1.5,
                                                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                                                                                                            ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Container(
                                                                                                      width: 48.0,
                                                                                                      height: 40.0,
                                                                                                      decoration: BoxDecoration(),
                                                                                                      alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                      child: Icon(
                                                                                                        FFIcons.krightArrow,
                                                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                                                        size: 24.0,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ].divide(SizedBox(width: 16.0)),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                );
                                                                              }
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Align(
                                                                        alignment: AlignmentDirectional(
                                                                            -1.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              12.0,
                                                                              24.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              Text(
                                                                            'Stats',
                                                                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                                  letterSpacing: valueOrDefault<double>(
                                                                                    -0.63,
                                                                                    -0.63,
                                                                                  ),
                                                                                  fontWeight: FontWeight.w500,
                                                                                  lineHeight: 1.4,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Stack(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            1.0),
                                                                        children: [
                                                                          Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.stretch,
                                                                            children: [
                                                                              Divider(
                                                                                height: 1.0,
                                                                                thickness: 1.0,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    InkWell(
                                                                                      splashColor: Colors.transparent,
                                                                                      focusColor: Colors.transparent,
                                                                                      hoverColor: Colors.transparent,
                                                                                      highlightColor: Colors.transparent,
                                                                                      onTap: () async {
                                                                                        _model.infoStatsPeriod = 1;
                                                                                        safeSetState(() {});
                                                                                      },
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(),
                                                                                        child: Align(
                                                                                          alignment: AlignmentDirectional(0.0, 0.0),
                                                                                          child: Padding(
                                                                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 15.0),
                                                                                            child: Text(
                                                                                              'Aktuelle Saison',
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                    color: _model.infoStatsPeriod == 1 ? Color(0xFFA88551) : FlutterFlowTheme.of(context).primaryText,
                                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                                      -0.35,
                                                                                                      -0.35,
                                                                                                    ),
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                    lineHeight: 1.5,
                                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                  ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Divider(
                                                                                      height: 0.0,
                                                                                      thickness: 2.0,
                                                                                      color: _model.infoStatsPeriod == 1 ? Color(0xFFA88551) : Colors.transparent,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    InkWell(
                                                                                      splashColor: Colors.transparent,
                                                                                      focusColor: Colors.transparent,
                                                                                      hoverColor: Colors.transparent,
                                                                                      highlightColor: Colors.transparent,
                                                                                      onTap: () async {
                                                                                        _model.infoStatsPeriod = 2;
                                                                                        safeSetState(() {});
                                                                                      },
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(),
                                                                                        child: Align(
                                                                                          alignment: AlignmentDirectional(0.0, 0.0),
                                                                                          child: Padding(
                                                                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 15.0),
                                                                                            child: Text(
                                                                                              'All-Time',
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                    color: _model.infoStatsPeriod == 2 ? Color(0xFFA88551) : FlutterFlowTheme.of(context).primaryText,
                                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                                      -0.35,
                                                                                                      -0.35,
                                                                                                    ),
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                    lineHeight: 1.5,
                                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                  ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Divider(
                                                                                      height: 0.0,
                                                                                      thickness: 2.0,
                                                                                      color: _model.infoStatsPeriod == 2 ? Color(0xFFA88551) : Colors.transparent,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            18.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child: StreamBuilder<
                                                                            List<GamesRow>>(
                                                                          stream:
                                                                              FFAppState().games(
                                                                            uniqueQueryKey:
                                                                                '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                                                                            requestFn: () => _model.containerSupabaseStream2 ??= SupaFlow.client
                                                                                .from("games")
                                                                                .stream(primaryKey: ['id'])
                                                                                .eqOrNull(
                                                                                  'status',
                                                                                  'completed',
                                                                                )
                                                                                .map((list) => list.map((item) => GamesRow(item)).toList()),
                                                                          ),
                                                                          builder:
                                                                              (context, snapshot) {
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
                                                                            List<GamesRow>
                                                                                containerGamesRowList =
                                                                                snapshot.data!;

                                                                            return Container(
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                borderRadius: BorderRadius.circular(16.0),
                                                                                shape: BoxShape.rectangle,
                                                                              ),
                                                                              child: Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(30.0, 28.0, 30.0, 28.0),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    wrapWithModel(
                                                                                      model: _model.userProfileInfoStatsRowModel1,
                                                                                      updateCallback: () => safeSetState(() {}),
                                                                                      updateOnChange: true,
                                                                                      child: UserProfileInfoStatsRowWidget(
                                                                                        title: 'Total Good Power',
                                                                                        value: valueOrDefault<String>(
                                                                                          widget!.userId != 'guest'
                                                                                              ? formatNumber(
                                                                                                  functions.getUserRatingScore(
                                                                                                      containerGamesRowList.where((e) => widget!.userId == e.creatorUserId).toList(),
                                                                                                      valueOrDefault<String>(
                                                                                                        _model.infoStatsPeriod == 1 ? 'saison' : 'gesamt',
                                                                                                        'gesamt',
                                                                                                      ),
                                                                                                      'valuable',
                                                                                                      invitesContainerInvitesRowList.toList(),
                                                                                                      widget!.userId!),
                                                                                                  formatType: FormatType.custom,
                                                                                                  format: '',
                                                                                                  locale: '',
                                                                                                )
                                                                                              : '100',
                                                                                          '100',
                                                                                        ),
                                                                                        number: '#${widget!.userId != 'guest' ? valueOrDefault<String>(
                                                                                            functions
                                                                                                .ratingUsersPerUser(
                                                                                                    containerGamesRowList.toList(),
                                                                                                    valueOrDefault<String>(
                                                                                                      _model.infoStatsPeriod == 1 ? 'saison' : 'gesamt',
                                                                                                      'saison',
                                                                                                    ),
                                                                                                    'valuable',
                                                                                                    invitesContainerInvitesRowList.toList(),
                                                                                                    widget!.userId,
                                                                                                    allUsersContainerUsersRowList.length)
                                                                                                .toString(),
                                                                                            '0',
                                                                                          ) : valueOrDefault<String>(
                                                                                            (valueOrDefault<int>(
                                                                                                      allUsersContainerUsersRowList.length,
                                                                                                      0,
                                                                                                    ) +
                                                                                                    1)
                                                                                                .toString(),
                                                                                            '235',
                                                                                          )}',
                                                                                      ),
                                                                                    ),
                                                                                    Divider(
                                                                                      height: 1.0,
                                                                                      thickness: 1.0,
                                                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                                                    ),
                                                                                    wrapWithModel(
                                                                                      model: _model.userProfileInfoStatsRowModel2,
                                                                                      updateCallback: () => safeSetState(() {}),
                                                                                      updateOnChange: true,
                                                                                      child: UserProfileInfoStatsRowWidget(
                                                                                        title: 'Punkte per Game',
                                                                                        value: valueOrDefault<String>(
                                                                                          widget!.userId != 'guest'
                                                                                              ? formatNumber(
                                                                                                  functions.getUserRatingScore(
                                                                                                      containerGamesRowList.where((e) => widget!.userId == e.creatorUserId).toList(),
                                                                                                      valueOrDefault<String>(
                                                                                                        _model.infoStatsPeriod == 1 ? 'saison' : 'gesamt',
                                                                                                        'gesamt',
                                                                                                      ),
                                                                                                      'generous',
                                                                                                      invitesContainerInvitesRowList.toList(),
                                                                                                      widget!.userId!),
                                                                                                  formatType: FormatType.custom,
                                                                                                  format: '',
                                                                                                  locale: '',
                                                                                                )
                                                                                              : '0',
                                                                                          '0',
                                                                                        ),
                                                                                        number: '#${widget!.userId != 'guest' ? valueOrDefault<String>(
                                                                                            functions
                                                                                                .ratingUsersPerUser(
                                                                                                    containerGamesRowList.toList(),
                                                                                                    valueOrDefault<String>(
                                                                                                      _model.infoStatsPeriod == 1 ? 'saison' : 'gesamt',
                                                                                                      'saison',
                                                                                                    ),
                                                                                                    'generous',
                                                                                                    invitesContainerInvitesRowList.toList(),
                                                                                                    widget!.userId,
                                                                                                    allUsersContainerUsersRowList.length)
                                                                                                .toString(),
                                                                                            '0',
                                                                                          ) : valueOrDefault<String>(
                                                                                            (valueOrDefault<int>(
                                                                                                      allUsersContainerUsersRowList.length,
                                                                                                      0,
                                                                                                    ) +
                                                                                                    1)
                                                                                                .toString(),
                                                                                            '235',
                                                                                          )}',
                                                                                      ),
                                                                                    ),
                                                                                    Divider(
                                                                                      height: 1.0,
                                                                                      thickness: 1.0,
                                                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                                                    ),
                                                                                    wrapWithModel(
                                                                                      model: _model.userProfileInfoStatsRowModel3,
                                                                                      updateCallback: () => safeSetState(() {}),
                                                                                      updateOnChange: true,
                                                                                      child: UserProfileInfoStatsRowWidget(
                                                                                        title: 'Good Games',
                                                                                        value: valueOrDefault<String>(
                                                                                          widget!.userId != 'guest'
                                                                                              ? formatNumber(
                                                                                                  functions.getUserRatingScore(
                                                                                                      containerGamesRowList.where((e) => widget!.userId == e.creatorUserId).toList(),
                                                                                                      valueOrDefault<String>(
                                                                                                        _model.infoStatsPeriod == 1 ? 'saison' : 'gesamt',
                                                                                                        'gesamt',
                                                                                                      ),
                                                                                                      'active',
                                                                                                      invitesContainerInvitesRowList.toList(),
                                                                                                      widget!.userId!),
                                                                                                  formatType: FormatType.custom,
                                                                                                  format: '',
                                                                                                  locale: '',
                                                                                                )
                                                                                              : '0',
                                                                                          '0',
                                                                                        ),
                                                                                        number: '#${widget!.userId != 'guest' ? valueOrDefault<String>(
                                                                                            functions
                                                                                                .ratingUsersPerUser(
                                                                                                    containerGamesRowList.toList(),
                                                                                                    valueOrDefault<String>(
                                                                                                      _model.infoStatsPeriod == 1 ? 'saison' : 'gesamt',
                                                                                                      'saison',
                                                                                                    ),
                                                                                                    'active',
                                                                                                    invitesContainerInvitesRowList.toList(),
                                                                                                    widget!.userId,
                                                                                                    allUsersContainerUsersRowList.length)
                                                                                                .toString(),
                                                                                            '0',
                                                                                          ) : valueOrDefault<String>(
                                                                                            (valueOrDefault<int>(
                                                                                                      allUsersContainerUsersRowList.length,
                                                                                                      0,
                                                                                                    ) +
                                                                                                    1)
                                                                                                .toString(),
                                                                                            '235',
                                                                                          )}',
                                                                                      ),
                                                                                    ),
                                                                                    Divider(
                                                                                      height: 1.0,
                                                                                      thickness: 1.0,
                                                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                                                    ),
                                                                                    wrapWithModel(
                                                                                      model: _model.userProfileInfoStatsRowModel4,
                                                                                      updateCallback: () => safeSetState(() {}),
                                                                                      updateOnChange: true,
                                                                                      child: UserProfileInfoStatsRowWidget(
                                                                                        title: 'Supporters',
                                                                                        value: valueOrDefault<String>(
                                                                                          widget!.userId != 'guest'
                                                                                              ? formatNumber(
                                                                                                  functions.getUserRatingScore(
                                                                                                      containerGamesRowList.where((e) => widget!.userId == e.creatorUserId).toList(),
                                                                                                      valueOrDefault<String>(
                                                                                                        _model.infoStatsPeriod == 1 ? 'saison' : 'gesamt',
                                                                                                        'gesamt',
                                                                                                      ),
                                                                                                      'social',
                                                                                                      invitesContainerInvitesRowList.toList(),
                                                                                                      widget!.userId!),
                                                                                                  formatType: FormatType.custom,
                                                                                                  format: '',
                                                                                                  locale: '',
                                                                                                )
                                                                                              : '0',
                                                                                          '0',
                                                                                        ),
                                                                                        number: '#${widget!.userId != 'guest' ? valueOrDefault<String>(
                                                                                            functions
                                                                                                .ratingUsersPerUser(
                                                                                                    containerGamesRowList.toList(),
                                                                                                    valueOrDefault<String>(
                                                                                                      _model.infoStatsPeriod == 1 ? 'saison' : 'gesamt',
                                                                                                      'saison',
                                                                                                    ),
                                                                                                    'social',
                                                                                                    invitesContainerInvitesRowList.toList(),
                                                                                                    widget!.userId,
                                                                                                    allUsersContainerUsersRowList.length)
                                                                                                .toString(),
                                                                                            '0',
                                                                                          ) : valueOrDefault<String>(
                                                                                            (valueOrDefault<int>(
                                                                                                      allUsersContainerUsersRowList.length,
                                                                                                      0,
                                                                                                    ) +
                                                                                                    1)
                                                                                                .toString(),
                                                                                            '235',
                                                                                          )}',
                                                                                      ),
                                                                                    ),
                                                                                  ].divide(SizedBox(height: 24.0)),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  if (widget!
                                                                          .userId !=
                                                                      'guest')
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          0.0,
                                                                          58.0,
                                                                          0.0,
                                                                          8.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children:
                                                                            [
                                                                          if (valueOrDefault<
                                                                              bool>(
                                                                            userContainerUsersRow?.instagramUrl != null &&
                                                                                userContainerUsersRow?.instagramUrl != '',
                                                                            false,
                                                                          ))
                                                                            FlutterFlowIconButton(
                                                                              borderColor: Colors.transparent,
                                                                              borderRadius: 8.0,
                                                                              buttonSize: 40.0,
                                                                              fillColor: Colors.transparent,
                                                                              icon: Icon(
                                                                                FFIcons.kinstagram,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                size: 24.0,
                                                                              ),
                                                                              onPressed: () async {
                                                                                unawaited(
                                                                                  () async {
                                                                                    await launchURL(functions.instagramUrlParse(userContainerUsersRow?.instagramUrl)!);
                                                                                  }(),
                                                                                );
                                                                              },
                                                                            ),
                                                                          if (valueOrDefault<
                                                                              bool>(
                                                                            userContainerUsersRow?.facebookUrl != null &&
                                                                                userContainerUsersRow?.facebookUrl != '',
                                                                            false,
                                                                          ))
                                                                            FlutterFlowIconButton(
                                                                              borderColor: Colors.transparent,
                                                                              borderRadius: 8.0,
                                                                              buttonSize: 40.0,
                                                                              fillColor: Colors.transparent,
                                                                              icon: Icon(
                                                                                FFIcons.kfacebookTag,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                size: 24.0,
                                                                              ),
                                                                              onPressed: () async {
                                                                                unawaited(
                                                                                  () async {
                                                                                    await launchURL(functions.facebookUrlParse(userContainerUsersRow?.facebookUrl)!);
                                                                                  }(),
                                                                                );
                                                                              },
                                                                            ),
                                                                          if (valueOrDefault<
                                                                              bool>(
                                                                            userContainerUsersRow?.youtubeUrl != null &&
                                                                                userContainerUsersRow?.youtubeUrl != '',
                                                                            false,
                                                                          ))
                                                                            FlutterFlowIconButton(
                                                                              borderColor: Colors.transparent,
                                                                              borderRadius: 8.0,
                                                                              buttonSize: 40.0,
                                                                              fillColor: Colors.transparent,
                                                                              icon: Icon(
                                                                                FFIcons.kyoutube,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                size: 24.0,
                                                                              ),
                                                                              onPressed: () async {
                                                                                unawaited(
                                                                                  () async {
                                                                                    await launchURL(functions.youtubeUrlParse(userContainerUsersRow?.youtubeUrl)!);
                                                                                  }(),
                                                                                );
                                                                              },
                                                                            ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                    ),
                                                                  if (false)
                                                                    Builder(
                                                                      builder:
                                                                          (context) {
                                                                        if (loggedIn) {
                                                                          return Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Padding(
                                                                                padding: EdgeInsets.all(24.0),
                                                                                child: Text(
                                                                                  valueOrDefault<String>(
                                                                                    userContainerUsersRow?.info,
                                                                                    'no info',
                                                                                  ),
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                        letterSpacing: valueOrDefault<double>(
                                                                                          -0.35,
                                                                                          -0.35,
                                                                                        ),
                                                                                        lineHeight: 1.5,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets.all(24.0),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    if (valueOrDefault<bool>(
                                                                                      userContainerUsersRow?.instagramUrl != null && userContainerUsersRow?.instagramUrl != '',
                                                                                      false,
                                                                                    ))
                                                                                      FlutterFlowIconButton(
                                                                                        borderColor: Colors.transparent,
                                                                                        borderRadius: 8.0,
                                                                                        buttonSize: 40.0,
                                                                                        fillColor: Colors.transparent,
                                                                                        icon: Icon(
                                                                                          FFIcons.kinstagram,
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                          size: 24.0,
                                                                                        ),
                                                                                        onPressed: () async {
                                                                                          unawaited(
                                                                                            () async {
                                                                                              await launchURL(functions.instagramUrlParse(userContainerUsersRow?.instagramUrl)!);
                                                                                            }(),
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    if (valueOrDefault<bool>(
                                                                                      userContainerUsersRow?.facebookUrl != null && userContainerUsersRow?.facebookUrl != '',
                                                                                      false,
                                                                                    ))
                                                                                      FlutterFlowIconButton(
                                                                                        borderColor: Colors.transparent,
                                                                                        borderRadius: 8.0,
                                                                                        buttonSize: 40.0,
                                                                                        fillColor: Colors.transparent,
                                                                                        icon: Icon(
                                                                                          FFIcons.kfacebookTag,
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                          size: 24.0,
                                                                                        ),
                                                                                        onPressed: () async {
                                                                                          unawaited(
                                                                                            () async {
                                                                                              await launchURL(functions.facebookUrlParse(userContainerUsersRow?.facebookUrl)!);
                                                                                            }(),
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    if (valueOrDefault<bool>(
                                                                                      userContainerUsersRow?.youtubeUrl != null && userContainerUsersRow?.youtubeUrl != '',
                                                                                      false,
                                                                                    ))
                                                                                      FlutterFlowIconButton(
                                                                                        borderColor: Colors.transparent,
                                                                                        borderRadius: 8.0,
                                                                                        buttonSize: 40.0,
                                                                                        fillColor: Colors.transparent,
                                                                                        icon: Icon(
                                                                                          FFIcons.kyoutube,
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                          size: 24.0,
                                                                                        ),
                                                                                        onPressed: () async {
                                                                                          unawaited(
                                                                                            () async {
                                                                                              await launchURL(functions.youtubeUrlParse(userContainerUsersRow?.youtubeUrl)!);
                                                                                            }(),
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                  ].divide(SizedBox(width: 24.0)),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        } else {
                                                                          return Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Align(
                                                                                alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                child: Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 24.0, 0.0, 0.0),
                                                                                  child: Text(
                                                                                    'Unterstützte Organisationen',
                                                                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                          fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                                          letterSpacing: valueOrDefault<double>(
                                                                                            -0.63,
                                                                                            -0.63,
                                                                                          ),
                                                                                          fontWeight: FontWeight.w500,
                                                                                          lineHeight: 1.4,
                                                                                          useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                                        ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                                                                child: Container(
                                                                                  width: double.infinity,
                                                                                  constraints: BoxConstraints(
                                                                                    minHeight: 82.0,
                                                                                    maxWidth: 600.0,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    borderRadius: BorderRadius.circular(16.0),
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(16.0),
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Icon(
                                                                                          FFIcons.kdonate,
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                          size: 40.0,
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(
                                                                                                'Finde deine Organisation',
                                                                                                style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                                      letterSpacing: valueOrDefault<double>(
                                                                                                        -0.4,
                                                                                                        -0.4,
                                                                                                      ),
                                                                                                      fontWeight: FontWeight.bold,
                                                                                                      lineHeight: 1.5,
                                                                                                      useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                                    ),
                                                                                              ),
                                                                                              Text(
                                                                                                'Keine Organisationen gewählt',
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                      fontSize: 14.0,
                                                                                                      letterSpacing: valueOrDefault<double>(
                                                                                                        -0.35,
                                                                                                        -0.35,
                                                                                                      ),
                                                                                                      fontWeight: FontWeight.normal,
                                                                                                      lineHeight: 1.5,
                                                                                                      useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                    ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ].divide(SizedBox(width: 16.0)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Align(
                                                                                alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                child: Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 24.0, 0.0, 0.0),
                                                                                  child: Text(
                                                                                    'Stats',
                                                                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                          fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                                          letterSpacing: valueOrDefault<double>(
                                                                                            -0.63,
                                                                                            -0.63,
                                                                                          ),
                                                                                          fontWeight: FontWeight.w500,
                                                                                          lineHeight: 1.4,
                                                                                          useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                                        ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Stack(
                                                                                alignment: AlignmentDirectional(0.0, 1.0),
                                                                                children: [
                                                                                  Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                    children: [
                                                                                      Divider(
                                                                                        height: 1.0,
                                                                                        thickness: 1.0,
                                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            InkWell(
                                                                                              splashColor: Colors.transparent,
                                                                                              focusColor: Colors.transparent,
                                                                                              hoverColor: Colors.transparent,
                                                                                              highlightColor: Colors.transparent,
                                                                                              onTap: () async {
                                                                                                _model.infoStatsPeriod = 1;
                                                                                                safeSetState(() {});
                                                                                              },
                                                                                              child: Container(
                                                                                                decoration: BoxDecoration(),
                                                                                                child: Align(
                                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                  child: Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 15.0),
                                                                                                    child: Text(
                                                                                                      'Aktuelle Saison',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                            color: _model.infoStatsPeriod == 1 ? Color(0xFFA88551) : FlutterFlowTheme.of(context).primaryText,
                                                                                                            letterSpacing: valueOrDefault<double>(
                                                                                                              -0.35,
                                                                                                              -0.35,
                                                                                                            ),
                                                                                                            fontWeight: FontWeight.w600,
                                                                                                            lineHeight: 1.5,
                                                                                                            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Divider(
                                                                                              height: 0.0,
                                                                                              thickness: 2.0,
                                                                                              color: _model.infoStatsPeriod == 1 ? Color(0xFFA88551) : Colors.transparent,
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        child: InkWell(
                                                                                          splashColor: Colors.transparent,
                                                                                          focusColor: Colors.transparent,
                                                                                          hoverColor: Colors.transparent,
                                                                                          highlightColor: Colors.transparent,
                                                                                          onTap: () async {
                                                                                            _model.infoStatsPeriod = 2;
                                                                                            safeSetState(() {});
                                                                                          },
                                                                                          child: Column(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            children: [
                                                                                              Container(
                                                                                                decoration: BoxDecoration(),
                                                                                                child: Align(
                                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                  child: Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 15.0),
                                                                                                    child: Text(
                                                                                                      'All-Time',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                                            color: _model.infoStatsPeriod == 2 ? Color(0xFFA88551) : FlutterFlowTheme.of(context).primaryText,
                                                                                                            letterSpacing: valueOrDefault<double>(
                                                                                                              -0.35,
                                                                                                              -0.35,
                                                                                                            ),
                                                                                                            fontWeight: FontWeight.w600,
                                                                                                            lineHeight: 1.5,
                                                                                                            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Divider(
                                                                                                height: 0.0,
                                                                                                thickness: 2.0,
                                                                                                color: _model.infoStatsPeriod == 2 ? Color(0xFFA88551) : Colors.transparent,
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(
                                                                                    0.0,
                                                                                    18.0,
                                                                                    0.0,
                                                                                    valueOrDefault<double>(
                                                                                      MediaQuery.paddingOf(context).bottom + 48,
                                                                                      48.0,
                                                                                    )),
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    borderRadius: BorderRadius.circular(16.0),
                                                                                    shape: BoxShape.rectangle,
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(30.0, 28.0, 30.0, 28.0),
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        wrapWithModel(
                                                                                          model: _model.userProfileInfoStatsRowModel5,
                                                                                          updateCallback: () => safeSetState(() {}),
                                                                                          child: UserProfileInfoStatsRowWidget(
                                                                                            title: 'Total Good Power',
                                                                                            value: '100',
                                                                                            number: '3',
                                                                                          ),
                                                                                        ),
                                                                                        Divider(
                                                                                          height: 1.0,
                                                                                          thickness: 1.0,
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                        ),
                                                                                        wrapWithModel(
                                                                                          model: _model.userProfileInfoStatsRowModel6,
                                                                                          updateCallback: () => safeSetState(() {}),
                                                                                          child: UserProfileInfoStatsRowWidget(
                                                                                            title: 'Punkte per Game',
                                                                                            value: '0',
                                                                                            number: '5',
                                                                                          ),
                                                                                        ),
                                                                                        Divider(
                                                                                          height: 1.0,
                                                                                          thickness: 1.0,
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                        ),
                                                                                        wrapWithModel(
                                                                                          model: _model.userProfileInfoStatsRowModel7,
                                                                                          updateCallback: () => safeSetState(() {}),
                                                                                          child: UserProfileInfoStatsRowWidget(
                                                                                            title: 'Good Games',
                                                                                            value: '0',
                                                                                            number: '12',
                                                                                          ),
                                                                                        ),
                                                                                        Divider(
                                                                                          height: 1.0,
                                                                                          thickness: 1.0,
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                        ),
                                                                                        wrapWithModel(
                                                                                          model: _model.userProfileInfoStatsRowModel8,
                                                                                          updateCallback: () => safeSetState(() {}),
                                                                                          child: UserProfileInfoStatsRowWidget(
                                                                                            title: 'Supporters',
                                                                                            value: '1',
                                                                                            number: '1',
                                                                                          ),
                                                                                        ),
                                                                                      ].divide(SizedBox(height: 24.0)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        }
                                                                      },
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        } else if (_model.tab ==
                                                            2) {
                                                          return Builder(
                                                            builder: (context) {
                                                              if ((widget!.userId !=
                                                                      'guest') &&
                                                                  (userContainerUsersRow!
                                                                          .gamesCount! >
                                                                      0)) {
                                                                return Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            14.0,
                                                                            18.0,
                                                                            14.0,
                                                                            0.0),
                                                                    child: StreamBuilder<
                                                                        List<
                                                                            PostsRow>>(
                                                                      stream: FFAppState()
                                                                          .userPosts(
                                                                        uniqueQueryKey:
                                                                            '${widget!.userId}${FFAppState().refreshDate?.toString()}',
                                                                        requestFn: () => _model.columnSupabaseStream ??= SupaFlow
                                                                            .client
                                                                            .from(
                                                                                "posts")
                                                                            .stream(primaryKey: [
                                                                              'id'
                                                                            ])
                                                                            .eqOrNull(
                                                                              'user_id',
                                                                              widget!.userId,
                                                                            )
                                                                            .order(
                                                                                'created_at')
                                                                            .map((list) =>
                                                                                list.map((item) => PostsRow(item)).toList()),
                                                                      ),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        // Customize what your widget looks like when it's loading.
                                                                        if (!snapshot
                                                                            .hasData) {
                                                                          return Center(
                                                                            child:
                                                                                SizedBox(
                                                                              width: 200.0,
                                                                              height: 200.0,
                                                                              child: CircularProgressIndicator(
                                                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                                                  FlutterFlowTheme.of(context).primaryBackground,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }
                                                                        List<PostsRow>
                                                                            columnPostsRowList =
                                                                            snapshot.data!;

                                                                        if (columnPostsRowList
                                                                            .isEmpty) {
                                                                          return EmptyPostProfileWidget();
                                                                        }

                                                                        return Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: List.generate(
                                                                              columnPostsRowList.length,
                                                                              (columnIndex) {
                                                                            final columnPostsRow =
                                                                                columnPostsRowList[columnIndex];
                                                                            return PostCompWidget(
                                                                              key: Key('Key5oi_${columnIndex}_of_${columnPostsRowList.length}'),
                                                                              post: columnPostsRow,
                                                                            );
                                                                          }).divide(
                                                                              SizedBox(height: 24.0)),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                );
                                                              } else {
                                                                return Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          14.0,
                                                                          18.0,
                                                                          14.0,
                                                                          valueOrDefault<
                                                                              double>(
                                                                            MediaQuery.paddingOf(context).bottom +
                                                                                24,
                                                                            24.0,
                                                                          )),
                                                                  child:
                                                                      wrapWithModel(
                                                                    model: _model
                                                                        .emptyPostProfileModel1,
                                                                    updateCallback: () =>
                                                                        safeSetState(
                                                                            () {}),
                                                                    child:
                                                                        EmptyPostProfileWidget(),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                          );
                                                        } else {
                                                          return Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          14.0,
                                                                          0.0,
                                                                          4.0,
                                                                          0.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            24.0,
                                                                            0.0,
                                                                            0.0),
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        borderRadius:
                                                                            BorderRadius.circular(16.0),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            32.0,
                                                                            24.0,
                                                                            32.0,
                                                                            24.0),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                if (loggedIn) {
                                                                                  await showModalBottomSheet(
                                                                                    isScrollControlled: true,
                                                                                    backgroundColor: Colors.transparent,
                                                                                    useSafeArea: true,
                                                                                    context: context,
                                                                                    builder: (context) {
                                                                                      return Padding(
                                                                                        padding: MediaQuery.viewInsetsOf(context),
                                                                                        child: ProfileEditDialogWidget(
                                                                                          user: userContainerUsersRow!,
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  ).then((value) => safeSetState(() {}));
                                                                                } else {
                                                                                  await showModalBottomSheet(
                                                                                    isScrollControlled: true,
                                                                                    backgroundColor: Colors.transparent,
                                                                                    barrierColor: Color(0x66000000),
                                                                                    context: context,
                                                                                    builder: (context) {
                                                                                      return Padding(
                                                                                        padding: MediaQuery.viewInsetsOf(context),
                                                                                        child: AuthDialogWidget(),
                                                                                      );
                                                                                    },
                                                                                  ).then((value) => safeSetState(() => _model.success = value));
                                                                                }

                                                                                safeSetState(() {});
                                                                              },
                                                                              child: wrapWithModel(
                                                                                model: _model.profileOptionModel1,
                                                                                updateCallback: () => safeSetState(() {}),
                                                                                child: ProfileOptionWidget(
                                                                                  icon: Icon(
                                                                                    FFIcons.kuser,
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    size: 24.0,
                                                                                  ),
                                                                                  title: 'Profil editieren',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              height: 32.0,
                                                                              thickness: 1.0,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                            ),
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                showModalBottomSheet(
                                                                                  isScrollControlled: true,
                                                                                  backgroundColor: Colors.transparent,
                                                                                  useSafeArea: true,
                                                                                  context: context,
                                                                                  builder: (context) {
                                                                                    return Padding(
                                                                                      padding: MediaQuery.viewInsetsOf(context),
                                                                                      child: FollowersListWidget(
                                                                                        userId: widget!.userId!,
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ).then((value) => safeSetState(() {}));
                                                                              },
                                                                              child: wrapWithModel(
                                                                                model: _model.profileOptionModel2,
                                                                                updateCallback: () => safeSetState(() {}),
                                                                                child: ProfileOptionWidget(
                                                                                  icon: Icon(
                                                                                    FFIcons.kwishOff,
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    size: 24.0,
                                                                                  ),
                                                                                  title: 'Meine Favoriten',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              height: 32.0,
                                                                              thickness: 1.0,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                            ),
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                showModalBottomSheet(
                                                                                  isScrollControlled: true,
                                                                                  backgroundColor: Colors.transparent,
                                                                                  useSafeArea: true,
                                                                                  context: context,
                                                                                  builder: (context) {
                                                                                    return Padding(
                                                                                      padding: MediaQuery.viewInsetsOf(context),
                                                                                      child: SponsorListWidget(
                                                                                        userId: widget!.userId!,
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ).then((value) => safeSetState(() {}));
                                                                              },
                                                                              child: wrapWithModel(
                                                                                model: _model.profileOptionModel3,
                                                                                updateCallback: () => safeSetState(() {}),
                                                                                child: ProfileOptionWidget(
                                                                                  icon: Icon(
                                                                                    FFIcons.kuser2,
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    size: 24.0,
                                                                                  ),
                                                                                  title: 'Meine Sponsoren',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              height: 32.0,
                                                                              thickness: 1.0,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                            ),
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                showModalBottomSheet(
                                                                                  isScrollControlled: true,
                                                                                  backgroundColor: Colors.transparent,
                                                                                  useSafeArea: true,
                                                                                  context: context,
                                                                                  builder: (context) {
                                                                                    return Padding(
                                                                                      padding: MediaQuery.viewInsetsOf(context),
                                                                                      child: InvitesListWidget(
                                                                                        userId: widget!.userId!,
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ).then((value) => safeSetState(() {}));
                                                                              },
                                                                              child: wrapWithModel(
                                                                                model: _model.profileOptionModel4,
                                                                                updateCallback: () => safeSetState(() {}),
                                                                                child: ProfileOptionWidget(
                                                                                  icon: Icon(
                                                                                    FFIcons.klink,
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    size: 24.0,
                                                                                  ),
                                                                                  title: 'Mein Good Circle',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              height: 32.0,
                                                                              thickness: 1.0,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                            ),
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                unawaited(
                                                                                  () async {
                                                                                    await launchURL(FFAppConstants.feedbacks);
                                                                                  }(),
                                                                                );
                                                                              },
                                                                              child: wrapWithModel(
                                                                                model: _model.profileOptionModel5,
                                                                                updateCallback: () => safeSetState(() {}),
                                                                                child: ProfileOptionWidget(
                                                                                  icon: Icon(
                                                                                    FFIcons.kquestionMark,
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    size: 24.0,
                                                                                  ),
                                                                                  title: 'Hilfe und Feedback',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ].addToStart(SizedBox(height: 16.0)).addToEnd(SizedBox(height: 16.0)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if (loggedIn)
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              1.0,
                                                                              1.0),
                                                                      child:
                                                                          Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            44.0,
                                                                            32.0,
                                                                            44.0,
                                                                            0.0),
                                                                        child:
                                                                            FFButtonWidget(
                                                                          onPressed:
                                                                              () async {
                                                                            GoRouter.of(context).prepareAuthEvent(true);
                                                                            await authManager.signOut();
                                                                            GoRouter.of(context).clearRedirectLocation();

                                                                            FFAppState().hasUserLoggedOut =
                                                                                true;

                                                                            context.goNamedAuth(
                                                                              LoginWidget.routeName,
                                                                              context.mounted,
                                                                              ignoreRedirect: true,
                                                                            );
                                                                          },
                                                                          text:
                                                                              'Abmelden',
                                                                          icon:
                                                                              Icon(
                                                                            FFIcons.klogOut,
                                                                            size:
                                                                                20.0,
                                                                          ),
                                                                          options:
                                                                              FFButtonOptions(
                                                                            width:
                                                                                double.infinity,
                                                                            height:
                                                                                56.0,
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
                                                                            iconColor:
                                                                                FlutterFlowTheme.of(context).primaryBackground,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: valueOrDefault<double>(
                                                                                    -0.4,
                                                                                    -0.4,
                                                                                  ),
                                                                                  fontWeight: FontWeight.w600,
                                                                                  lineHeight: 1.5,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                ),
                                                                            elevation:
                                                                                0.0,
                                                                            borderRadius:
                                                                                BorderRadius.circular(64.0),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              24.0),
                                                                      child:
                                                                          Text(
                                                                        'Service von Players For Good gGmbH',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.35,
                                                                                -0.35,
                                                                              ),
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: double
                                                                        .infinity,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16.0),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          32.0,
                                                                          24.0,
                                                                          32.0,
                                                                          24.0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children:
                                                                            [
                                                                          InkWell(
                                                                            splashColor:
                                                                                Colors.transparent,
                                                                            focusColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap:
                                                                                () async {
                                                                              unawaited(
                                                                                () async {
                                                                                  await launchURL(FFAppConstants.website);
                                                                                }(),
                                                                              );
                                                                            },
                                                                            child:
                                                                                Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  'Über Players For Good',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Divider(
                                                                            height:
                                                                                32.0,
                                                                            thickness:
                                                                                1.0,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                          ),
                                                                          InkWell(
                                                                            splashColor:
                                                                                Colors.transparent,
                                                                            focusColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap:
                                                                                () async {
                                                                              unawaited(
                                                                                () async {
                                                                                  await launchURL(FFAppConstants.policy);
                                                                                }(),
                                                                              );
                                                                            },
                                                                            child:
                                                                                Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  'Datenschutz',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Divider(
                                                                            height:
                                                                                32.0,
                                                                            thickness:
                                                                                1.0,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                          ),
                                                                          InkWell(
                                                                            splashColor:
                                                                                Colors.transparent,
                                                                            focusColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap:
                                                                                () async {
                                                                              unawaited(
                                                                                () async {
                                                                                  await launchURL(FFAppConstants.terms);
                                                                                }(),
                                                                              );
                                                                            },
                                                                            child:
                                                                                Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  'Nutzungsbedingungen',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Divider(
                                                                            height:
                                                                                32.0,
                                                                            thickness:
                                                                                1.0,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                          ),
                                                                          InkWell(
                                                                            splashColor:
                                                                                Colors.transparent,
                                                                            focusColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap:
                                                                                () async {
                                                                              unawaited(
                                                                                () async {
                                                                                  await launchURL(FFAppConstants.impressum);
                                                                                }(),
                                                                              );
                                                                            },
                                                                            child:
                                                                                Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  'Impressum',
                                                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          if (valueOrDefault<
                                                                              bool>(
                                                                            (userContainerUsersRow?.role == 'admin') &&
                                                                                kDebugMode,
                                                                            false,
                                                                          ))
                                                                            Divider(
                                                                              height: 32.0,
                                                                              thickness: 1.0,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                            ),
                                                                          if (valueOrDefault<
                                                                              bool>(
                                                                            (userContainerUsersRow?.role == 'admin') &&
                                                                                kDebugMode,
                                                                            false,
                                                                          ))
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                context.goNamed(
                                                                                  StatisticsAdminWidget.routeName,
                                                                                  extra: <String, dynamic>{
                                                                                    '__transition_info__': TransitionInfo(
                                                                                      hasTransition: true,
                                                                                      transitionType: PageTransitionType.fade,
                                                                                      duration: Duration(milliseconds: 0),
                                                                                    ),
                                                                                  },
                                                                                );

                                                                                FFAppState().adminPage = AdminPages.statistics.name;
                                                                                FFAppState().update(() {});
                                                                              },
                                                                              child: Text(
                                                                                'Admin panel',
                                                                                style: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      lineHeight: 1.5,
                                                                                      useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                        ].addToStart(SizedBox(height: 16.0)).addToEnd(SizedBox(height: 16.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ].addToEnd(
                                                                    SizedBox(
                                                                        height:
                                                                            34.0)),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return FutureBuilder<List<UsersRow>>(
              future: UsersTable().queryRows(
                queryFn: (q) => q,
              ),
              builder: (context, snapshot) {
                // Customize what your widget looks like when it's loading.
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.transparent,
                        ),
                      ),
                    ),
                  );
                }
                List<UsersRow> allUsersContainerUsersRowList = snapshot.data!;

                return Container(
                  decoration: BoxDecoration(),
                  child: Container(
                    height: MediaQuery.sizeOf(context).height * 0.95,
                    constraints: BoxConstraints(
                      maxWidth: 600.0,
                    ),
                    decoration: BoxDecoration(
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
                    child: Align(
                      alignment: AlignmentDirectional(0.0, -1.0),
                      child: SingleChildScrollView(
                        controller: _model.columnController2,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (false)
                              Align(
                                alignment: AlignmentDirectional(0.0, -1.0),
                                child: Container(
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
                                        16.0, 12.0, 16.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .alternate,
                                            icon: Icon(
                                              FFIcons.kleft,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 14.0,
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
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
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .alternate,
                                            icon: Icon(
                                              FFIcons.kxmark,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 24.0,
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            Align(
                              alignment: AlignmentDirectional(0.0, -1.0),
                              child: Container(
                                constraints: BoxConstraints(
                                  minHeight: 410.0,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: Image.asset(
                                      'assets/images/user_profile_updaded_bg.png',
                                    ).image,
                                  ),
                                ),
                                alignment: AlignmentDirectional(0.0, -1.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 1.0, 0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 8.0, 0.0, 0.0),
                                          child: Container(
                                            width: 56.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(),
                                            child: FlutterFlowIconButton(
                                              borderColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius: 99.0,
                                              borderWidth: 1.0,
                                              buttonSize: 40.0,
                                              icon: Icon(
                                                FFIcons.kleft,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                size: 14.0,
                                              ),
                                              onPressed: () async {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 96.0,
                                        height: 96.0,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 48.0,
                                              color: Color(0x2E000000),
                                              offset: Offset(
                                                0.0,
                                                24.0,
                                              ),
                                              spreadRadius: 12.0,
                                            )
                                          ],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          width: 96.0,
                                          height: 96.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 8.0,
                                                color: Color(0x0A000000),
                                                offset: Offset(
                                                  0.0,
                                                  4.0,
                                                ),
                                                spreadRadius: 12.0,
                                              )
                                            ],
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              width: 4.0,
                                            ),
                                          ),
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: wrapWithModel(
                                              model: _model.imageModel2,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: ImageWidget(
                                                size: 96.0,
                                                image:
                                                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 16.0, 0.0, 0.0),
                                          child: Text(
                                            '@playerforgood_${valueOrDefault<String>(
                                              (valueOrDefault<int>(
                                                        allUsersContainerUsersRowList
                                                            .length,
                                                        0,
                                                      ) +
                                                      1)
                                                  .toString(),
                                              '235',
                                            )}',
                                            maxLines: 3,
                                            style: FlutterFlowTheme.of(context)
                                                .labelLarge
                                                .override(
                                                  fontFamily: 'Dela Gothic One',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  fontSize: 20.0,
                                                  letterSpacing:
                                                      valueOrDefault<double>(
                                                    -0.7,
                                                    -0.7,
                                                  ),
                                                  lineHeight: 1.5,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 4.0, 0.0, 0.0),
                                          child: Text(
                                            'Gastnutzer',
                                            maxLines: 3,
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmallFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  letterSpacing:
                                                      valueOrDefault<double>(
                                                    -0.2,
                                                    -0.2,
                                                  ),
                                                  fontWeight: FontWeight.bold,
                                                  lineHeight: 1.5,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmallIsCustom,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 18.0, 0.0, 0.0),
                                        child: Container(
                                          height: 67.0,
                                          decoration: BoxDecoration(),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, -1.0),
                                                child: Text(
                                                  '100 LW',
                                                  maxLines: 3,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .displaySmall
                                                      .override(
                                                        fontFamily:
                                                            'Dela Gothic One',
                                                        color:
                                                            Color(0xFFC4AF7F),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        lineHeight: 1.5,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 1.0),
                                                child: Text(
                                                  'Good Power',
                                                  maxLines: 3,
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            fontSize: 11.0,
                                                            letterSpacing:
                                                                valueOrDefault<
                                                                    double>(
                                                              -0.2,
                                                              -0.2,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            lineHeight: 1.5,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallIsCustom,
                                                          ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 0.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 2.0,
                                                  color: Color(0x50000000),
                                                  offset: Offset(
                                                    0.0,
                                                    2.0,
                                                  ),
                                                  spreadRadius: 0.0,
                                                )
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(360.0),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                boxShadow: [
                                                  BoxShadow(
                                                    blurRadius: 4.0,
                                                    color: Color(0x14000000),
                                                    offset: Offset(
                                                      0.0,
                                                      2.0,
                                                    ),
                                                    spreadRadius: 0.0,
                                                  )
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        360.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        18.0, 3.0, 18.0, 3.0),
                                                child: Text(
                                                  '#${valueOrDefault<String>(
                                                    (valueOrDefault<int>(
                                                              allUsersContainerUsersRowList
                                                                  .length,
                                                              0,
                                                            ) +
                                                            1)
                                                        .toString(),
                                                    '235',
                                                  )}',
                                                  maxLines: 3,
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            letterSpacing:
                                                                valueOrDefault<
                                                                    double>(
                                                              -0.24,
                                                              -0.24,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            lineHeight: 1.5,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallIsCustom,
                                                          ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].addToStart(SizedBox(height: 16.0)),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, -1.0),
                              child: Container(
                                constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.sizeOf(context).height * 0.5,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          14.0, 24.0, 14.0, 0.0),
                                      child: Container(
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
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
                                                  text: 'Info',
                                                  options: FFButtonOptions(
                                                    height: 40.0,
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                                16.0, 0.0),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    color:
                                                        valueOrDefault<Color>(
                                                      _model.tab == 1
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary
                                                          : Colors.transparent,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                    ),
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
                                                          color: valueOrDefault<
                                                              Color>(
                                                            _model.tab == 1
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground
                                                                : FlutterFlowTheme.of(
                                                                        context)
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
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                                    elevation: 0.0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            99.0),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: FFButtonWidget(
                                                  onPressed: () async {
                                                    _model.tab = 2;
                                                    safeSetState(() {});
                                                  },
                                                  text: 'Posts',
                                                  options: FFButtonOptions(
                                                    height: 40.0,
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                                16.0, 0.0),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    color:
                                                        valueOrDefault<Color>(
                                                      _model.tab == 2
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary
                                                          : Colors.transparent,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                    ),
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
                                                          color: valueOrDefault<
                                                              Color>(
                                                            _model.tab == 2
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground
                                                                : FlutterFlowTheme.of(
                                                                        context)
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
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                                    elevation: 0.0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            99.0),
                                                  ),
                                                ),
                                              ),
                                              if ((widget!.userId ==
                                                      currentUserUid) ||
                                                  (widget!.userId == 'guest'))
                                                Expanded(
                                                  child: FFButtonWidget(
                                                    onPressed: () async {
                                                      _model.tab = 3;
                                                      safeSetState(() {});
                                                    },
                                                    text: 'Mein Profil',
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
                                                          valueOrDefault<Color>(
                                                        _model.tab == 3
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .secondary
                                                            : Colors
                                                                .transparent,
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
                                                                          3
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground
                                                                      : FlutterFlowTheme.of(
                                                                              context)
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
                                                    ),
                                                  ),
                                                ),
                                            ].divide(SizedBox(width: 4.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Builder(
                                      builder: (context) {
                                        if (_model.tab == 1) {
                                          return Align(
                                            alignment:
                                                AlignmentDirectional(-1.0, 0.0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      14.0,
                                                      0.0,
                                                      14.0,
                                                      valueOrDefault<double>(
                                                        MediaQuery.paddingOf(
                                                                    context)
                                                                .bottom +
                                                            48,
                                                        48.0,
                                                      )),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      12.0,
                                                                      24.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Text(
                                                            'Unterstützte Organisationen',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMediumFamily,
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
                                                                          .titleMediumIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    8.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          constraints:
                                                              BoxConstraints(
                                                            minHeight: 82.0,
                                                            maxWidth: 600.0,
                                                          ),
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
                                                                    16.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          4.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    FFIcons
                                                                        .kdonate,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 32.0,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Noch keine unterstützt',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.4,
                                                                                -0.4,
                                                                              ),
                                                                              fontWeight: FontWeight.bold,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                            ),
                                                                      ),
                                                                      Text(
                                                                        'Starte dein erstes Good Game',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                              fontSize: 14.0,
                                                                              letterSpacing: valueOrDefault<double>(
                                                                                -0.35,
                                                                                -0.35,
                                                                              ),
                                                                              fontWeight: FontWeight.normal,
                                                                              lineHeight: 1.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 16.0)),
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
                                                                      12.0,
                                                                      24.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Text(
                                                            'Stats',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMediumFamily,
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
                                                                          .titleMediumIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      Stack(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 1.0),
                                                        children: [
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              Divider(
                                                                height: 1.0,
                                                                thickness: 1.0,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
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
                                                                        _model.infoStatsPeriod =
                                                                            1;
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(),
                                                                        child:
                                                                            Align(
                                                                          alignment: AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                12.0,
                                                                                0.0,
                                                                                15.0),
                                                                            child:
                                                                                Text(
                                                                              'Aktuelle Saison',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    color: _model.infoStatsPeriod == 1 ? Color(0xFFA88551) : FlutterFlowTheme.of(context).primaryText,
                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                      -0.35,
                                                                                      -0.35,
                                                                                    ),
                                                                                    fontWeight: FontWeight.w600,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      height:
                                                                          0.0,
                                                                      thickness:
                                                                          2.0,
                                                                      color: _model.infoStatsPeriod ==
                                                                              1
                                                                          ? Color(
                                                                              0xFFA88551)
                                                                          : Colors
                                                                              .transparent,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
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
                                                                        _model.infoStatsPeriod =
                                                                            2;
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(),
                                                                        child:
                                                                            Align(
                                                                          alignment: AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                12.0,
                                                                                0.0,
                                                                                15.0),
                                                                            child:
                                                                                Text(
                                                                              'All-Time',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    color: _model.infoStatsPeriod == 2 ? Color(0xFFA88551) : FlutterFlowTheme.of(context).primaryText,
                                                                                    letterSpacing: valueOrDefault<double>(
                                                                                      -0.35,
                                                                                      -0.35,
                                                                                    ),
                                                                                    fontWeight: FontWeight.w600,
                                                                                    lineHeight: 1.5,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      height:
                                                                          0.0,
                                                                      thickness:
                                                                          2.0,
                                                                      color: _model.infoStatsPeriod ==
                                                                              2
                                                                          ? Color(
                                                                              0xFFA88551)
                                                                          : Colors
                                                                              .transparent,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    18.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16.0),
                                                            shape: BoxShape
                                                                .rectangle,
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        30.0,
                                                                        28.0,
                                                                        30.0,
                                                                        28.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                wrapWithModel(
                                                                  model: _model
                                                                      .userProfileInfoStatsRowModel9,
                                                                  updateCallback: () =>
                                                                      safeSetState(
                                                                          () {}),
                                                                  updateOnChange:
                                                                      true,
                                                                  child:
                                                                      UserProfileInfoStatsRowWidget(
                                                                    title:
                                                                        'Total Good Power',
                                                                    value:
                                                                        '100',
                                                                    number:
                                                                        '#${valueOrDefault<String>(
                                                                      (valueOrDefault<int>(
                                                                                allUsersContainerUsersRowList.length,
                                                                                0,
                                                                              ) +
                                                                              1)
                                                                          .toString(),
                                                                      '235',
                                                                    )}',
                                                                  ),
                                                                ),
                                                                Divider(
                                                                  height: 1.0,
                                                                  thickness:
                                                                      1.0,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                ),
                                                                wrapWithModel(
                                                                  model: _model
                                                                      .userProfileInfoStatsRowModel10,
                                                                  updateCallback: () =>
                                                                      safeSetState(
                                                                          () {}),
                                                                  updateOnChange:
                                                                      true,
                                                                  child:
                                                                      UserProfileInfoStatsRowWidget(
                                                                    title:
                                                                        'Punkte per Game',
                                                                    value: '0',
                                                                    number:
                                                                        '#${valueOrDefault<String>(
                                                                      (valueOrDefault<int>(
                                                                                allUsersContainerUsersRowList.length,
                                                                                0,
                                                                              ) +
                                                                              1)
                                                                          .toString(),
                                                                      '235',
                                                                    )}',
                                                                  ),
                                                                ),
                                                                Divider(
                                                                  height: 1.0,
                                                                  thickness:
                                                                      1.0,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                ),
                                                                wrapWithModel(
                                                                  model: _model
                                                                      .userProfileInfoStatsRowModel11,
                                                                  updateCallback: () =>
                                                                      safeSetState(
                                                                          () {}),
                                                                  updateOnChange:
                                                                      true,
                                                                  child:
                                                                      UserProfileInfoStatsRowWidget(
                                                                    title:
                                                                        'Good Games',
                                                                    value: '0',
                                                                    number:
                                                                        '#${valueOrDefault<String>(
                                                                      (valueOrDefault<int>(
                                                                                allUsersContainerUsersRowList.length,
                                                                                0,
                                                                              ) +
                                                                              1)
                                                                          .toString(),
                                                                      '235',
                                                                    )}',
                                                                  ),
                                                                ),
                                                                Divider(
                                                                  height: 1.0,
                                                                  thickness:
                                                                      1.0,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                ),
                                                                wrapWithModel(
                                                                  model: _model
                                                                      .userProfileInfoStatsRowModel12,
                                                                  updateCallback: () =>
                                                                      safeSetState(
                                                                          () {}),
                                                                  updateOnChange:
                                                                      true,
                                                                  child:
                                                                      UserProfileInfoStatsRowWidget(
                                                                    title:
                                                                        'Supporters',
                                                                    value: '0',
                                                                    number:
                                                                        '#${valueOrDefault<String>(
                                                                      (valueOrDefault<int>(
                                                                                allUsersContainerUsersRowList.length,
                                                                                0,
                                                                              ) +
                                                                              1)
                                                                          .toString(),
                                                                      '235',
                                                                    )}',
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  height:
                                                                      24.0)),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        } else if (_model.tab == 2) {
                                          return Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    14.0,
                                                    18.0,
                                                    14.0,
                                                    valueOrDefault<double>(
                                                      MediaQuery.paddingOf(
                                                                  context)
                                                              .bottom +
                                                          24,
                                                      24.0,
                                                    )),
                                            child: wrapWithModel(
                                              model:
                                                  _model.emptyPostProfileModel2,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: EmptyPostProfileWidget(),
                                            ),
                                          );
                                        } else {
                                          return Align(
                                            alignment:
                                                AlignmentDirectional(-1.0, 0.0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      14.0, 0.0, 4.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 24.0,
                                                                0.0, 0.0),
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
                                                            InkWell(
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
                                                                await showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  barrierColor:
                                                                      Color(
                                                                          0x66000000),
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
                                                                      child:
                                                                          AuthDialogWidget(),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(() =>
                                                                        _model.successAuth =
                                                                            value));

                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              child:
                                                                  wrapWithModel(
                                                                model: _model
                                                                    .profileOptionModel6,
                                                                updateCallback: () =>
                                                                    safeSetState(
                                                                        () {}),
                                                                child:
                                                                    ProfileOptionWidget(
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kuser,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                  title:
                                                                      'Profil editieren',
                                                                ),
                                                              ),
                                                            ),
                                                            Divider(
                                                              height: 32.0,
                                                              thickness: 1.0,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                            ),
                                                            InkWell(
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
                                                                showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  useSafeArea:
                                                                      true,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
                                                                      child:
                                                                          FollowersListWidget(
                                                                        userId:
                                                                            widget!.userId!,
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));
                                                              },
                                                              child:
                                                                  wrapWithModel(
                                                                model: _model
                                                                    .profileOptionModel7,
                                                                updateCallback: () =>
                                                                    safeSetState(
                                                                        () {}),
                                                                child:
                                                                    ProfileOptionWidget(
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kwishOff,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                  title:
                                                                      'Meine Favoriten',
                                                                ),
                                                              ),
                                                            ),
                                                            Divider(
                                                              height: 32.0,
                                                              thickness: 1.0,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                            ),
                                                            InkWell(
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
                                                                showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  useSafeArea:
                                                                      true,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
                                                                      child:
                                                                          SponsorListWidget(
                                                                        userId:
                                                                            widget!.userId!,
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));
                                                              },
                                                              child:
                                                                  wrapWithModel(
                                                                model: _model
                                                                    .profileOptionModel8,
                                                                updateCallback: () =>
                                                                    safeSetState(
                                                                        () {}),
                                                                child:
                                                                    ProfileOptionWidget(
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kuser2,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                  title:
                                                                      'Meine Sponsoren',
                                                                ),
                                                              ),
                                                            ),
                                                            Divider(
                                                              height: 32.0,
                                                              thickness: 1.0,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                            ),
                                                            InkWell(
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
                                                                showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  useSafeArea:
                                                                      true,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
                                                                      child:
                                                                          InvitesListWidget(
                                                                        userId:
                                                                            widget!.userId!,
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));
                                                              },
                                                              child:
                                                                  wrapWithModel(
                                                                model: _model
                                                                    .profileOptionModel9,
                                                                updateCallback: () =>
                                                                    safeSetState(
                                                                        () {}),
                                                                child:
                                                                    ProfileOptionWidget(
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .klink,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                  title:
                                                                      'Mein Good Circle',
                                                                ),
                                                              ),
                                                            ),
                                                            Divider(
                                                              height: 32.0,
                                                              thickness: 1.0,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                            ),
                                                            InkWell(
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
                                                                unawaited(
                                                                  () async {
                                                                    await launchURL(
                                                                        FFAppConstants
                                                                            .feedbacks);
                                                                  }(),
                                                                );
                                                              },
                                                              child:
                                                                  wrapWithModel(
                                                                model: _model
                                                                    .profileOptionModel10,
                                                                updateCallback: () =>
                                                                    safeSetState(
                                                                        () {}),
                                                                child:
                                                                    ProfileOptionWidget(
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kquestionMark,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                  title:
                                                                      'Hilfe und Feedback',
                                                                ),
                                                              ),
                                                            ),
                                                          ]
                                                              .addToStart(
                                                                  SizedBox(
                                                                      height:
                                                                          16.0))
                                                              .addToEnd(SizedBox(
                                                                  height:
                                                                      16.0)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.0, 1.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  44.0,
                                                                  32.0,
                                                                  44.0,
                                                                  0.0),
                                                      child: FFButtonWidget(
                                                        onPressed: () async {
                                                          await showModalBottomSheet(
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            barrierColor: Color(
                                                                0x66000000),
                                                            context: context,
                                                            builder: (context) {
                                                              return Padding(
                                                                padding: MediaQuery
                                                                    .viewInsetsOf(
                                                                        context),
                                                                child:
                                                                    AuthDialogWidget(),
                                                              );
                                                            },
                                                          ).then((value) =>
                                                              safeSetState(() =>
                                                                  _model.wasSuccessAuth =
                                                                      value));

                                                          safeSetState(() {});
                                                        },
                                                        text: 'Anmelden',
                                                        icon: Icon(
                                                          FFIcons.klogInV3,
                                                          size: 24.0,
                                                        ),
                                                        options:
                                                            FFButtonOptions(
                                                          width:
                                                              double.infinity,
                                                          height: 56.0,
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      0.0,
                                                                      16.0,
                                                                      0.0),
                                                          iconAlignment:
                                                              IconAlignment.end,
                                                          iconPadding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          iconColor: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
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
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
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
                                                                      64.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(24.0),
                                                      child: Text(
                                                        'Service von Players For Good gGmbH',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      valueOrDefault<
                                                                          double>(
                                                                    -0.35,
                                                                    -0.35,
                                                                  ),
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
                                                  Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
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
                                                            MainAxisSize.min,
                                                        children: [
                                                          InkWell(
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
                                                              unawaited(
                                                                () async {
                                                                  await launchURL(
                                                                      FFAppConstants
                                                                          .website);
                                                                }(),
                                                              );
                                                            },
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  'Über Players For Good',
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
                                                              ],
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 32.0,
                                                            thickness: 1.0,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                          ),
                                                          InkWell(
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
                                                              unawaited(
                                                                () async {
                                                                  await launchURL(
                                                                      FFAppConstants
                                                                          .policy);
                                                                }(),
                                                              );
                                                            },
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  'Datenschutz',
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
                                                              ],
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 32.0,
                                                            thickness: 1.0,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                          ),
                                                          InkWell(
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
                                                              unawaited(
                                                                () async {
                                                                  await launchURL(
                                                                      FFAppConstants
                                                                          .terms);
                                                                }(),
                                                              );
                                                            },
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  'Nutzungsbedingungen',
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
                                                              ],
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 32.0,
                                                            thickness: 1.0,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                          ),
                                                          InkWell(
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
                                                              unawaited(
                                                                () async {
                                                                  await launchURL(
                                                                      FFAppConstants
                                                                          .impressum);
                                                                }(),
                                                              );
                                                            },
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  'Impressum',
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
                                                              ],
                                                            ),
                                                          ),
                                                        ]
                                                            .addToStart(
                                                                SizedBox(
                                                                    height:
                                                                        16.0))
                                                            .addToEnd(SizedBox(
                                                                height: 16.0)),
                                                      ),
                                                    ),
                                                  ),
                                                ].addToEnd(
                                                    SizedBox(height: 34.0)),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
