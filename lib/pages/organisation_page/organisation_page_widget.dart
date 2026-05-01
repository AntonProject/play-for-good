import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/dialogs/snack_bar/snack_bar_widget.dart';
import '/components/image/image_widget.dart';
import '/components/post_comp/post_comp_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'organisation_page_model.dart';
export 'organisation_page_model.dart';

class OrganisationPageWidget extends StatefulWidget {
  const OrganisationPageWidget({
    super.key,
    this.orgId,
  });

  final String? orgId;

  static String routeName = 'OrganisationPage';
  static String routePath = '/organisationPage';

  @override
  State<OrganisationPageWidget> createState() => _OrganisationPageWidgetState();
}

class _OrganisationPageWidgetState extends State<OrganisationPageWidget> {
  late OrganisationPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrganisationPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      setDarkModeSetting(context, ThemeMode.light);
      await actions.setStatusBarColor(
        false,
      );
    });

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
        title: 'OrganisationPage',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Align(
              alignment: AlignmentDirectional(0.0, -1.0),
              child: FutureBuilder<List<OrganizationRow>>(
                future: _model.org(
                  uniqueQueryKey: valueOrDefault<String>(
                    widget!.orgId,
                    '0',
                  ),
                  requestFn: () => OrganizationTable().querySingleRow(
                    queryFn: (q) => q.eqOrNull(
                      'id',
                      widget!.orgId,
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  }
                  List<OrganizationRow> stackOrganizationRowList =
                      snapshot.data!;

                  // Return an empty Container when the item does not exist.
                  if (snapshot.data!.isEmpty) {
                    return Container();
                  }
                  final stackOrganizationRow =
                      stackOrganizationRowList.isNotEmpty
                          ? stackOrganizationRowList.first
                          : null;

                  return Stack(
                    alignment: AlignmentDirectional(0.0, 1.0),
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0.0, -1.0),
                        child: SingleChildScrollView(
                          controller: _model.columnController1,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Stack(
                                alignment: AlignmentDirectional(0.0, -1.0),
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(0.0, -1.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, -1.0),
                                          child: Container(
                                            constraints: BoxConstraints(
                                              minHeight: 470.0,
                                            ),
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: Image.asset(
                                                  'assets/images/Organization_profile_page3.png',
                                                ).image,
                                              ),
                                            ),
                                            child: SingleChildScrollView(
                                              primary: false,
                                              controller:
                                                  _model.columnController2,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    width: 96.0,
                                                    height: 96.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        width: 4.0,
                                                      ),
                                                    ),
                                                    child: wrapWithModel(
                                                      model: _model.imageModel,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child: ImageWidget(
                                                        size: 96.0,
                                                        image: valueOrDefault<
                                                            String>(
                                                          stackOrganizationRow
                                                              ?.imageUrl,
                                                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/d6ilkv8n1ka3/Avatar.png',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 16.0,
                                                                0.0, 0.0),
                                                    child: Text(
                                                      '@${valueOrDefault<String>(
                                                        stackOrganizationRow
                                                            ?.displayName,
                                                        'unnamed',
                                                      )}',
                                                      maxLines: 3,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelLarge
                                                              .override(
                                                                fontFamily:
                                                                    'Dela Gothic One',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                fontSize: 20.0,
                                                                letterSpacing:
                                                                    valueOrDefault<
                                                                        double>(
                                                                  -0.7,
                                                                  -0.7,
                                                                ),
                                                                lineHeight: 1.5,
                                                              ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 4.0,
                                                                0.0, 14.0),
                                                    child: Text(
                                                      valueOrDefault<String>(
                                                        stackOrganizationRow
                                                            ?.title,
                                                        'unnamed',
                                                      ),
                                                      maxLines: 3,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                fontSize: 11.0,
                                                                letterSpacing:
                                                                    valueOrDefault<
                                                                        double>(
                                                                  -0.22,
                                                                  -0.22,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                lineHeight: 1.5,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  StreamBuilder<List<GamesRow>>(
                                                    stream: _model
                                                            .containerSupabaseStream ??=
                                                        SupaFlow.client
                                                            .from("games")
                                                            .stream(
                                                                primaryKey: [
                                                                  'id'
                                                                ])
                                                            .eqOrNull(
                                                              'organization_id',
                                                              widget!.orgId,
                                                            )
                                                            .map((list) => list
                                                                .map((item) =>
                                                                    GamesRow(
                                                                        item))
                                                                .toList()),
                                                    builder:
                                                        (context, snapshot) {
                                                      // Customize what your widget looks like when it's loading.
                                                      if (!snapshot.hasData) {
                                                        return Center(
                                                          child: SizedBox(
                                                            width: 50,
                                                            height: 50,
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                      Color>(
                                                                Colors
                                                                    .transparent,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      List<GamesRow>
                                                          containerGamesRowList =
                                                          snapshot.data!;

                                                      return Container(
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: 600.0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      12.0,
                                                                      0.0,
                                                                      12.0,
                                                                      30.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      valueOrDefault<
                                                                          String>(
                                                                        functions
                                                                            .formatCompactWithComma(valueOrDefault<double>(
                                                                          functions
                                                                              .uniqSupporters(containerGamesRowList.where((e) => e.status == 'completed').toList(), widget!.orgId!)
                                                                              .toDouble(),
                                                                          0.0,
                                                                        )),
                                                                        '0',
                                                                      ).maybeHandleOverflow(
                                                                        maxChars:
                                                                            10,
                                                                        replacement:
                                                                            '…',
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          1,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).titleMediumFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryBackground,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.63,
                                                                              -0.63,
                                                                            ),
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                          ),
                                                                    ),
                                                                    AutoSizeText(
                                                                      'Supporters',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          1,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary75,
                                                                            fontSize:
                                                                                11.0,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.22,
                                                                              -0.22,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 44.0,
                                                                child:
                                                                    VerticalDivider(
                                                                  thickness:
                                                                      1.0,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      valueOrDefault<
                                                                          String>(
                                                                        functions
                                                                            .formatCompactWithComma(valueOrDefault<double>(
                                                                          functions.totalSumPeriodGoodEnergyOrg(
                                                                              containerGamesRowList.where((e) => e.status == 'completed').toList(),
                                                                              Period.gesamt.name),
                                                                          0.0,
                                                                        )),
                                                                        '0',
                                                                      ).maybeHandleOverflow(
                                                                        maxChars:
                                                                            10,
                                                                        replacement:
                                                                            '…',
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          1,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).titleMediumFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryBackground,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.63,
                                                                              -0.63,
                                                                            ),
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                          ),
                                                                    ),
                                                                    AutoSizeText(
                                                                      '€nergy empfangen',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          1,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary75,
                                                                            fontSize:
                                                                                11.0,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.22,
                                                                              -0.22,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 44.0,
                                                                child:
                                                                    VerticalDivider(
                                                                  thickness:
                                                                      1.0,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      '0',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          1,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).titleMediumFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryBackground,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.63,
                                                                              -0.63,
                                                                            ),
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                          ),
                                                                    ),
                                                                    AutoSizeText(
                                                                      'Social Score',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          1,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary75,
                                                                            fontSize:
                                                                                11.0,
                                                                            letterSpacing:
                                                                                valueOrDefault<double>(
                                                                              -0.22,
                                                                              -0.22,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            lineHeight:
                                                                                1.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(36.0, 0.0,
                                                                36.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        if (loggedIn)
                                                          FutureBuilder<
                                                              List<
                                                                  FollowersRow>>(
                                                            future:
                                                                _model.follow(
                                                              uniqueQueryKey:
                                                                  '${widget!.orgId}${FFAppState().refreshDate?.toString()}',
                                                              requestFn: () =>
                                                                  FollowersTable()
                                                                      .querySingleRow(
                                                                queryFn: (q) => q
                                                                    .eqOrNull(
                                                                      'follower_user_id',
                                                                      currentUserUid,
                                                                    )
                                                                    .eqOrNull(
                                                                      'following_organization_id',
                                                                      widget!
                                                                          .orgId,
                                                                    ),
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
                                                                    width: 50,
                                                                    height: 50,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      valueColor:
                                                                          AlwaysStoppedAnimation<
                                                                              Color>(
                                                                        Colors
                                                                            .transparent,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                              List<FollowersRow>
                                                                  columnFollowersRowList =
                                                                  snapshot
                                                                      .data!;

                                                              final columnFollowersRow =
                                                                  columnFollowersRowList
                                                                          .isNotEmpty
                                                                      ? columnFollowersRowList
                                                                          .first
                                                                      : null;

                                                              return Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      if (valueOrDefault<
                                                                          bool>(
                                                                        columnFollowersRow?.id ==
                                                                                null ||
                                                                            columnFollowersRow?.id ==
                                                                                '',
                                                                        false,
                                                                      ))
                                                                        Container(
                                                                          width:
                                                                              60.0,
                                                                          height:
                                                                              60.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryBackground,
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
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Stack(
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
                                                                                    await FollowersTable().insert({
                                                                                      'created_at': supaSerialize<DateTime>(getCurrentTimestamp),
                                                                                      'follower_user_id': currentUserUid,
                                                                                      'following_organization_id': widget!.orgId,
                                                                                      'following_organization_name': '${stackOrganizationRow?.title} ${stackOrganizationRow?.displayName}',
                                                                                    });
                                                                                    FFAppState().refreshDate = getCurrentTimestamp;
                                                                                    FFAppState().update(() {});
                                                                                    _model.clearFollowCache();
                                                                                    FFAppState().clearFollowUserCacheKey('${valueOrDefault<String>(
                                                                                      FFAppState().refreshDate?.toString(),
                                                                                      '0',
                                                                                    )}${currentUserUid}');

                                                                                    safeSetState(() {});
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      if (valueOrDefault<
                                                                          bool>(
                                                                        columnFollowersRow?.id !=
                                                                                null &&
                                                                            columnFollowersRow?.id !=
                                                                                '',
                                                                        false,
                                                                      ))
                                                                        Container(
                                                                          width:
                                                                              60.0,
                                                                          height:
                                                                              60.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryBackground,
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
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Stack(
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
                                                                                        columnFollowersRow?.id,
                                                                                      ),
                                                                                    );
                                                                                    FFAppState().refreshDate = getCurrentTimestamp;
                                                                                    FFAppState().update(() {});
                                                                                    _model.clearFollowCache();
                                                                                    FFAppState().clearFollowUserCacheKey('${valueOrDefault<String>(
                                                                                      FFAppState().refreshDate?.toString(),
                                                                                      '0',
                                                                                    )}${currentUserUid}');

                                                                                    safeSetState(() {});
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  Text(
                                                                    'Zu Favoriten',
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
                                                                    height:
                                                                        8.0)),
                                                              );
                                                            },
                                                          ),
                                                        if (stackOrganizationRow
                                                                    ?.websiteUrl !=
                                                                null &&
                                                            stackOrganizationRow
                                                                    ?.websiteUrl !=
                                                                '')
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Container(
                                                                width: 60.0,
                                                                height: 60.0,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      blurRadius:
                                                                          2.0,
                                                                      color: Color(
                                                                          0x0F000000),
                                                                      offset:
                                                                          Offset(
                                                                        0.0,
                                                                        2.0,
                                                                      ),
                                                                      spreadRadius:
                                                                          2.0,
                                                                    )
                                                                  ],
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Stack(
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            40.0,
                                                                        height:
                                                                            40.0,
                                                                        clipBehavior:
                                                                            Clip.antiAlias,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/images/web.png',
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          FlutterFlowIconButton(
                                                                        borderRadius:
                                                                            99.0,
                                                                        buttonSize:
                                                                            80.0,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .arrow_back,
                                                                          size:
                                                                              0.0,
                                                                        ),
                                                                        showLoadingIndicator:
                                                                            true,
                                                                        onPressed:
                                                                            () async {
                                                                          await launchURL(
                                                                              stackOrganizationRow!.websiteUrl!);
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Text(
                                                                'Webseite',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleMediumFamily,
                                                                      fontSize:
                                                                          12.0,
                                                                      letterSpacing:
                                                                          valueOrDefault<
                                                                              double>(
                                                                        -0.24,
                                                                        -0.24,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      lineHeight:
                                                                          1.5,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleMediumIsCustom,
                                                                    ),
                                                              ),
                                                            ].divide(SizedBox(
                                                                height: 8.0)),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ].addToStart(
                                                    SizedBox(height: 120.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: 600.0,
                                          ),
                                          decoration: BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        12.0, 24.0, 12.0, 0.0),
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
                                                            text: 'Über uns',
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
                                                            text: 'Posts',
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
                                                                    ? Colors
                                                                        .transparent
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                Colors
                                                                    .transparent,
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
                                                      ].divide(
                                                          SizedBox(width: 4.0)),
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
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    36.0,
                                                                    16.0,
                                                                    36.0,
                                                                    0.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                stackOrganizationRow
                                                                    ?.title,
                                                                'unnamed',
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .titleSmallFamily,
                                                                    fontSize:
                                                                        18.0,
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
                                                                        !FlutterFlowTheme.of(context)
                                                                            .titleSmallIsCustom,
                                                                  ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          16.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Text(
                                                                valueOrDefault<
                                                                    String>(
                                                                  stackOrganizationRow
                                                                      ?.description,
                                                                  'Sports superhero. Training for the office chair Olympics and holds the world record in sock throwing. Training for the office chair Olympics and holds the world record in sock throwing. Training for the office chair Olympics and holds the world record in sock throwing.',
                                                                ),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      letterSpacing:
                                                                          valueOrDefault<
                                                                              double>(
                                                                        -0.35,
                                                                        -0.35,
                                                                      ),
                                                                      lineHeight:
                                                                          1.5,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
                                                                    ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          12.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Text(
                                                                'Reg.-Nr.: ${valueOrDefault<String>(
                                                                  stackOrganizationRow
                                                                      ?.registration,
                                                                  '-',
                                                                )}',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText,
                                                                      fontSize:
                                                                          10.0,
                                                                      letterSpacing:
                                                                          valueOrDefault<
                                                                              double>(
                                                                        -0.2,
                                                                        -0.2,
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
                                                              ),
                                                            ),
                                                            Text(
                                                              'Stadt: ${valueOrDefault<String>(
                                                                stackOrganizationRow
                                                                    ?.city,
                                                                '-',
                                                              )}',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .titleSmallFamily,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    fontSize:
                                                                        10.0,
                                                                    letterSpacing:
                                                                        valueOrDefault<
                                                                            double>(
                                                                      -0.2,
                                                                      -0.2,
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
                                                            ),
                                                          ].addToEnd(SizedBox(
                                                              height: 150.0)),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    return Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  12.0,
                                                                  24.0,
                                                                  12.0,
                                                                  0.0),
                                                      child: StreamBuilder<
                                                          List<PostsRow>>(
                                                        stream: FFAppState()
                                                            .orgPosts(
                                                          uniqueQueryKey:
                                                              '${widget!.orgId}${FFAppState().refreshDate?.toString()}',
                                                          requestFn: () => _model
                                                                  .columnSupabaseStream ??=
                                                              SupaFlow.client
                                                                  .from("posts")
                                                                  .stream(
                                                                      primaryKey: [
                                                                        'id'
                                                                      ])
                                                                  .eqOrNull(
                                                                    'organization_id',
                                                                    widget!
                                                                        .orgId,
                                                                  )
                                                                  .order(
                                                                      'created_at')
                                                                  .map((list) => list
                                                                      .map((item) =>
                                                                          PostsRow(
                                                                              item))
                                                                      .toList()),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Center(
                                                              child: SizedBox(
                                                                width: 50,
                                                                height: 50,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                          Color>(
                                                                    Colors
                                                                        .transparent,
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
                                                            return Image.asset(
                                                              'assets/images/emptyPostProfile.png',
                                                            );
                                                          }

                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: List.generate(
                                                                columnPostsRowList
                                                                    .length,
                                                                (columnIndex) {
                                                              final columnPostsRow =
                                                                  columnPostsRowList[
                                                                      columnIndex];
                                                              return PostCompWidget(
                                                                key: Key(
                                                                    'Keykj2_${columnIndex}_of_${columnPostsRowList.length}'),
                                                                post:
                                                                    columnPostsRow,
                                                              );
                                                            }).divide(SizedBox(
                                                                height: 24.0)),
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 50.0,
                                    height: 50.0,
                                    child: custom_widgets.Visibilitydetector(
                                      width: 50.0,
                                      height: 50.0,
                                      visibilityThreshold: 0.5,
                                      action: (visible, visibility) async {
                                        _model.visible = visible!;
                                        safeSetState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ].addToEnd(SizedBox(height: 150.0)),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 1.0),
                        child: FutureBuilder<List<UsersRow>>(
                          future: FFAppState().user(
                            uniqueQueryKey:
                                '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                            requestFn: () => UsersTable().querySingleRow(
                              queryFn: (q) => q.eqOrNull(
                                'id',
                                currentUserUid,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.transparent,
                                    ),
                                  ),
                                ),
                              );
                            }
                            List<UsersRow> containerUsersRowList =
                                snapshot.data!;

                            // Return an empty Container when the item does not exist.
                            if (snapshot.data!.isEmpty) {
                              return Container();
                            }
                            final containerUsersRow =
                                containerUsersRowList.isNotEmpty
                                    ? containerUsersRowList.first
                                    : null;

                            return Container(
                              constraints: BoxConstraints(
                                maxWidth: 600.0,
                              ),
                              decoration: BoxDecoration(),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    36.0, 0.0, 36.0, 34.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(99.0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 14.0,
                                      sigmaY: 14.0,
                                    ),
                                    child: Builder(
                                      builder: (context) => FFButtonWidget(
                                        onPressed: (containerUsersRow
                                                    ?.chosenOrg ==
                                                widget!.orgId)
                                            ? null
                                            : () async {
                                                await UsersTable().update(
                                                  data: {
                                                    'chosen_org': widget!.orgId,
                                                  },
                                                  matchingRows: (rows) =>
                                                      rows.eqOrNull(
                                                    'id',
                                                    containerUsersRow?.id,
                                                  ),
                                                );
                                                FFAppState().refreshDate =
                                                    getCurrentTimestamp;
                                                FFAppState().update(() {});
                                                FFAppState().clearUserCache();
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
                                                                  0.0, -1.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(
                                                                  dialogContext)
                                                              .unfocus();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                        child: SnackBarWidget(
                                                          text:
                                                              'Organisation fürs nächste Game gespeichert.',
                                                          error: false,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );

                                                safeSetState(() {});
                                              },
                                        text: valueOrDefault<String>(
                                          containerUsersRow?.chosenOrg ==
                                                  widget!.orgId
                                              ? 'Organisation ausgewählt'
                                              : 'Organisation auswählen',
                                          'Organisation auswählen',
                                        ),
                                        options: FFButtonOptions(
                                          width: double.infinity,
                                          height: 56.0,
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 0.0, 16.0, 0.0),
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
                                                fontSize: 18.0,
                                                letterSpacing:
                                                    valueOrDefault<double>(
                                                  -0.63,
                                                  -0.63,
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
                                              BorderRadius.circular(64.0),
                                          disabledColor:
                                              FlutterFlowTheme.of(context)
                                                  .primary30,
                                          disabledTextColor:
                                              FlutterFlowTheme.of(context)
                                                  .primary75,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, -1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                valueOrDefault<Color>(
                                  _model.visible
                                      ? Colors.transparent
                                      : FlutterFlowTheme.of(context).accent3,
                                  FlutterFlowTheme.of(context).accent3,
                                ),
                                valueOrDefault<Color>(
                                  _model.visible
                                      ? Colors.transparent
                                      : FlutterFlowTheme.of(context).accent2,
                                  FlutterFlowTheme.of(context).accent2,
                                )
                              ],
                              stops: [0.0, 1.0],
                              begin: AlignmentDirectional(1.0, 0.0),
                              end: AlignmentDirectional(-1.0, 0),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 60.0, 16.0, 12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 56.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(99.0),
                                  ),
                                  child: FlutterFlowIconButton(
                                    borderColor: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    borderRadius: 99.0,
                                    borderWidth: 1.0,
                                    buttonSize: 40.0,
                                    icon: Icon(
                                      FFIcons.karrowLeftLong,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      size: 24.0,
                                    ),
                                    onPressed: () async {
                                      context.safePop();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ));
  }
}
