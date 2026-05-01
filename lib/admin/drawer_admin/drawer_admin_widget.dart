import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'drawer_admin_model.dart';
export 'drawer_admin_model.dart';

class DrawerAdminWidget extends StatefulWidget {
  const DrawerAdminWidget({
    super.key,
    required this.closeDrawer,
  });

  final Future Function()? closeDrawer;

  @override
  State<DrawerAdminWidget> createState() => _DrawerAdminWidgetState();
}

class _DrawerAdminWidgetState extends State<DrawerAdminWidget> {
  late DrawerAdminModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DrawerAdminModel());

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

    return Container(
      width: 300.0,
      height: MediaQuery.sizeOf(context).height * 1.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: Border.all(
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 48.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Play For Good',
                      style: FlutterFlowTheme.of(context).labelLarge.override(
                            fontFamily: 'Dela Gothic One',
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 20.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                  Icon(
                    FFIcons.klogoMini2,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 40.0,
                  ),
                ].divide(SizedBox(width: 4.0)),
              ),
            ),
            MouseRegion(
              opaque: false,
              cursor: MouseCursor.defer ?? MouseCursor.defer,
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  FFAppState().adminPage = AdminPages.statistics.name;
                  FFAppState().update(() {});
                  if (MediaQuery.sizeOf(context).width < 500.0) {
                    unawaited(
                      () async {
                        await widget.closeDrawer?.call();
                      }(),
                    );
                  }

                  context.pushNamed(
                    StatisticsAdminWidget.routeName,
                    extra: <String, dynamic>{
                      '__transition_info__': TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: valueOrDefault<Color>(
                      () {
                        if (_model.mouseRegionHovered1!) {
                          return FlutterFlowTheme.of(context).primaryBackground;
                        } else if (FFAppState().adminPage ==
                            AdminPages.statistics.name) {
                          return FlutterFlowTheme.of(context).primaryBackground;
                        } else {
                          return FlutterFlowTheme.of(context).alternate;
                        }
                      }(),
                      FlutterFlowTheme.of(context).primaryBackground,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        FFIcons.khome,
                        color: valueOrDefault<Color>(
                          () {
                            if (FFAppState().adminPage ==
                                AdminPages.statistics.name) {
                              return FlutterFlowTheme.of(context).primaryText;
                            } else if (_model.mouseRegionHovered1!) {
                              return FlutterFlowTheme.of(context).secondaryText;
                            } else {
                              return FlutterFlowTheme.of(context).secondaryText;
                            }
                          }(),
                          FlutterFlowTheme.of(context).primaryText,
                        ),
                        size: 20.0,
                      ),
                      Text(
                        'Statistics',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              color: valueOrDefault<Color>(
                                () {
                                  if (FFAppState().adminPage ==
                                      AdminPages.statistics.name) {
                                    return FlutterFlowTheme.of(context)
                                        .primaryText;
                                  } else if (_model.mouseRegionHovered1!) {
                                    return FlutterFlowTheme.of(context)
                                        .secondaryText;
                                  } else {
                                    return FlutterFlowTheme.of(context)
                                        .secondaryText;
                                  }
                                }(),
                                FlutterFlowTheme.of(context).primaryText,
                              ),
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                      ),
                    ]
                        .divide(SizedBox(width: 16.0))
                        .addToStart(SizedBox(width: 16.0)),
                  ),
                ),
              ),
              onEnter: ((event) async {
                safeSetState(() => _model.mouseRegionHovered1 = true);
              }),
              onExit: ((event) async {
                safeSetState(() => _model.mouseRegionHovered1 = false);
              }),
            ),
            MouseRegion(
              opaque: false,
              cursor: MouseCursor.defer ?? MouseCursor.defer,
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  FFAppState().adminPage = AdminPages.users.name;
                  FFAppState().update(() {});
                  if (MediaQuery.sizeOf(context).width < 500.0) {
                    unawaited(
                      () async {
                        await widget.closeDrawer?.call();
                      }(),
                    );
                  }

                  context.pushNamed(
                    UsersAdminWidget.routeName,
                    extra: <String, dynamic>{
                      '__transition_info__': TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: valueOrDefault<Color>(
                      () {
                        if (_model.mouseRegionHovered2!) {
                          return FlutterFlowTheme.of(context).primaryBackground;
                        } else if (FFAppState().adminPage ==
                            AdminPages.users.name) {
                          return FlutterFlowTheme.of(context).primaryBackground;
                        } else {
                          return FlutterFlowTheme.of(context).alternate;
                        }
                      }(),
                      FlutterFlowTheme.of(context).alternate,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        FFIcons.kgroup2,
                        color: valueOrDefault<Color>(
                          () {
                            if (FFAppState().adminPage ==
                                AdminPages.users.name) {
                              return FlutterFlowTheme.of(context).primaryText;
                            } else if (_model.mouseRegionHovered2!) {
                              return FlutterFlowTheme.of(context).secondaryText;
                            } else {
                              return FlutterFlowTheme.of(context).secondaryText;
                            }
                          }(),
                          FlutterFlowTheme.of(context).secondaryText,
                        ),
                        size: 24.0,
                      ),
                      Text(
                        'Users',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              color: valueOrDefault<Color>(
                                () {
                                  if (FFAppState().adminPage ==
                                      AdminPages.users.name) {
                                    return FlutterFlowTheme.of(context)
                                        .primaryText;
                                  } else if (_model.mouseRegionHovered2!) {
                                    return FlutterFlowTheme.of(context)
                                        .secondaryText;
                                  } else {
                                    return FlutterFlowTheme.of(context)
                                        .secondaryText;
                                  }
                                }(),
                                FlutterFlowTheme.of(context).secondaryText,
                              ),
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                      ),
                    ]
                        .divide(SizedBox(width: 16.0))
                        .addToStart(SizedBox(width: 16.0)),
                  ),
                ),
              ),
              onEnter: ((event) async {
                safeSetState(() => _model.mouseRegionHovered2 = true);
              }),
              onExit: ((event) async {
                safeSetState(() => _model.mouseRegionHovered2 = false);
              }),
            ),
            MouseRegion(
              opaque: false,
              cursor: MouseCursor.defer ?? MouseCursor.defer,
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  FFAppState().adminPage = AdminPages.organisations.name;
                  FFAppState().update(() {});
                  if (MediaQuery.sizeOf(context).width < 500.0) {
                    unawaited(
                      () async {
                        await widget.closeDrawer?.call();
                      }(),
                    );
                  }

                  context.pushNamed(
                    OrganisationsAdminWidget.routeName,
                    extra: <String, dynamic>{
                      '__transition_info__': TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: valueOrDefault<Color>(
                      () {
                        if (_model.mouseRegionHovered3!) {
                          return FlutterFlowTheme.of(context).primaryBackground;
                        } else if (FFAppState().adminPage ==
                            AdminPages.organisations.name) {
                          return FlutterFlowTheme.of(context).primaryBackground;
                        } else {
                          return FlutterFlowTheme.of(context).alternate;
                        }
                      }(),
                      FlutterFlowTheme.of(context).alternate,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        FFIcons.kdonate,
                        color: valueOrDefault<Color>(
                          () {
                            if (FFAppState().adminPage ==
                                AdminPages.organisations.name) {
                              return FlutterFlowTheme.of(context).primaryText;
                            } else if (_model.mouseRegionHovered3!) {
                              return FlutterFlowTheme.of(context).secondaryText;
                            } else {
                              return FlutterFlowTheme.of(context).secondaryText;
                            }
                          }(),
                          FlutterFlowTheme.of(context).secondaryText,
                        ),
                        size: 24.0,
                      ),
                      Text(
                        'Organisations',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              color: valueOrDefault<Color>(
                                () {
                                  if (FFAppState().adminPage ==
                                      AdminPages.organisations.name) {
                                    return FlutterFlowTheme.of(context)
                                        .primaryText;
                                  } else if (_model.mouseRegionHovered3!) {
                                    return FlutterFlowTheme.of(context)
                                        .secondaryText;
                                  } else {
                                    return FlutterFlowTheme.of(context)
                                        .secondaryText;
                                  }
                                }(),
                                FlutterFlowTheme.of(context).secondaryText,
                              ),
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                      ),
                    ]
                        .divide(SizedBox(width: 16.0))
                        .addToStart(SizedBox(width: 16.0)),
                  ),
                ),
              ),
              onEnter: ((event) async {
                safeSetState(() => _model.mouseRegionHovered3 = true);
              }),
              onExit: ((event) async {
                safeSetState(() => _model.mouseRegionHovered3 = false);
              }),
            ),
            MouseRegion(
              opaque: false,
              cursor: MouseCursor.defer ?? MouseCursor.defer,
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  FFAppState().adminPage = AdminPages.posts.name;
                  FFAppState().update(() {});
                  if (MediaQuery.sizeOf(context).width < 500.0) {
                    unawaited(
                      () async {
                        await widget.closeDrawer?.call();
                      }(),
                    );
                  }

                  context.pushNamed(
                    PostsAdminWidget.routeName,
                    extra: <String, dynamic>{
                      '__transition_info__': TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: valueOrDefault<Color>(
                      () {
                        if (_model.mouseRegionHovered4!) {
                          return FlutterFlowTheme.of(context).primaryBackground;
                        } else if (FFAppState().adminPage ==
                            AdminPages.posts.name) {
                          return FlutterFlowTheme.of(context).primaryBackground;
                        } else {
                          return FlutterFlowTheme.of(context).alternate;
                        }
                      }(),
                      FlutterFlowTheme.of(context).alternate,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        FFIcons.kinstagram,
                        color: valueOrDefault<Color>(
                          () {
                            if (FFAppState().adminPage ==
                                AdminPages.posts.name) {
                              return FlutterFlowTheme.of(context).primaryText;
                            } else if (_model.mouseRegionHovered4!) {
                              return FlutterFlowTheme.of(context).secondaryText;
                            } else {
                              return FlutterFlowTheme.of(context).secondaryText;
                            }
                          }(),
                          FlutterFlowTheme.of(context).secondaryText,
                        ),
                        size: 24.0,
                      ),
                      Text(
                        'Posts',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              color: valueOrDefault<Color>(
                                () {
                                  if (FFAppState().adminPage ==
                                      AdminPages.posts.name) {
                                    return FlutterFlowTheme.of(context)
                                        .primaryText;
                                  } else if (_model.mouseRegionHovered4!) {
                                    return FlutterFlowTheme.of(context)
                                        .secondaryText;
                                  } else {
                                    return FlutterFlowTheme.of(context)
                                        .secondaryText;
                                  }
                                }(),
                                FlutterFlowTheme.of(context).secondaryText,
                              ),
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                      ),
                    ]
                        .divide(SizedBox(width: 16.0))
                        .addToStart(SizedBox(width: 16.0)),
                  ),
                ),
              ),
              onEnter: ((event) async {
                safeSetState(() => _model.mouseRegionHovered4 = true);
              }),
              onExit: ((event) async {
                safeSetState(() => _model.mouseRegionHovered4 = false);
              }),
            ),
            MouseRegion(
              opaque: false,
              cursor: MouseCursor.defer ?? MouseCursor.defer,
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  FFAppState().adminPage = AdminPages.receipts.name;
                  FFAppState().update(() {});
                  if (MediaQuery.sizeOf(context).width < 500.0) {
                    unawaited(
                      () async {
                        await widget.closeDrawer?.call();
                      }(),
                    );
                  }

                  context.pushNamed(
                    ReceiptsAdminWidget.routeName,
                    extra: <String, dynamic>{
                      '__transition_info__': TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: valueOrDefault<Color>(
                      () {
                        if (_model.mouseRegionHovered5!) {
                          return FlutterFlowTheme.of(context).primaryBackground;
                        } else if (FFAppState().adminPage ==
                            AdminPages.receipts.name) {
                          return FlutterFlowTheme.of(context).primaryBackground;
                        } else {
                          return FlutterFlowTheme.of(context).alternate;
                        }
                      }(),
                      FlutterFlowTheme.of(context).alternate,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        FFIcons.kmail,
                        color: valueOrDefault<Color>(
                          () {
                            if (FFAppState().adminPage ==
                                AdminPages.posts.name) {
                              return FlutterFlowTheme.of(context).primaryText;
                            } else if (_model.mouseRegionHovered5!) {
                              return FlutterFlowTheme.of(context).secondaryText;
                            } else {
                              return FlutterFlowTheme.of(context).secondaryText;
                            }
                          }(),
                          FlutterFlowTheme.of(context).secondaryText,
                        ),
                        size: 24.0,
                      ),
                      Text(
                        'Receipts',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              color: valueOrDefault<Color>(
                                () {
                                  if (FFAppState().adminPage ==
                                      AdminPages.receipts.name) {
                                    return FlutterFlowTheme.of(context)
                                        .primaryText;
                                  } else if (_model.mouseRegionHovered5!) {
                                    return FlutterFlowTheme.of(context)
                                        .secondaryText;
                                  } else {
                                    return FlutterFlowTheme.of(context)
                                        .secondaryText;
                                  }
                                }(),
                                FlutterFlowTheme.of(context).secondaryText,
                              ),
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                      ),
                    ]
                        .divide(SizedBox(width: 16.0))
                        .addToStart(SizedBox(width: 16.0)),
                  ),
                ),
              ),
              onEnter: ((event) async {
                safeSetState(() => _model.mouseRegionHovered5 = true);
              }),
              onExit: ((event) async {
                safeSetState(() => _model.mouseRegionHovered5 = false);
              }),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
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
                  List<UsersRow> rowUsersRowList = snapshot.data!;

                  // Return an empty Container when the item does not exist.
                  if (snapshot.data!.isEmpty) {
                    return Container();
                  }
                  final rowUsersRow =
                      rowUsersRowList.isNotEmpty ? rowUsersRowList.first : null;

                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          valueOrDefault<String>(
                            rowUsersRow?.email,
                            'email',
                          ),
                          maxLines: 1,
                          style: FlutterFlowTheme.of(context)
                              .titleLarge
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleLargeFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .titleLargeIsCustom,
                              ),
                        ),
                      ),
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).alternate,
                          shape: BoxShape.circle,
                        ),
                        child: wrapWithModel(
                          model: _model.imageModel,
                          updateCallback: () => safeSetState(() {}),
                          child: ImageWidget(
                            size: 40.0,
                            image: valueOrDefault<String>(
                              rowUsersRow?.photoUrl,
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                            ),
                          ),
                        ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  );
                },
              ),
            ),
            Align(
              alignment: AlignmentDirectional(-1.0, 0.0),
              child: FFButtonWidget(
                onPressed: () async {
                  GoRouter.of(context).prepareAuthEvent();
                  await authManager.signOut();
                  GoRouter.of(context).clearRedirectLocation();

                  context.goNamedAuth(
                    LoginAdminWidget.routeName,
                    context.mounted,
                    extra: <String, dynamic>{
                      '__transition_info__': TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
                text: 'Abmelden',
                icon: Icon(
                  FFIcons.klogOut,
                  size: 24.0,
                ),
                options: FFButtonOptions(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconAlignment: IconAlignment.end,
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: Colors.transparent,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleSmallFamily,
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                      ),
                  elevation: 0.0,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ]
              .divide(SizedBox(height: 24.0))
              .addToStart(SizedBox(height: 48.0))
              .addToEnd(SizedBox(height: 48.0)),
        ),
      ),
    );
  }
}
