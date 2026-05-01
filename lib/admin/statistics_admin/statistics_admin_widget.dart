import '/admin/drawer_admin/drawer_admin_widget.dart';
import '/admin/header_admin/header_admin_widget.dart';
import '/admin/statistic_card_admin/statistic_card_admin_widget.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'statistics_admin_model.dart';
export 'statistics_admin_model.dart';

class StatisticsAdminWidget extends StatefulWidget {
  const StatisticsAdminWidget({super.key});

  static String routeName = 'StatisticsAdmin';
  static String routePath = '/statisticsAdmin';

  @override
  State<StatisticsAdminWidget> createState() => _StatisticsAdminWidgetState();
}

class _StatisticsAdminWidgetState extends State<StatisticsAdminWidget> {
  late StatisticsAdminModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StatisticsAdminModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.admin = await actions.isAdmin(
        currentUserUid,
      );
      if (_model.admin!) {
        await Future.wait([
          Future(() async {
            _model.gamesCount = await actions.gamesCount(
              '',
            );
            _model.gamesNum = valueOrDefault<int>(
              _model.gamesCount,
              0,
            );
            safeSetState(() {});
          }),
          Future(() async {
            _model.usersCount = await actions.usersCount();
            _model.usersNum = valueOrDefault<int>(
              _model.usersCount,
              0,
            );
            safeSetState(() {});
          }),
          Future(() async {
            _model.postsCount = await actions.postsCount(
              '',
            );
            _model.postsNum = valueOrDefault<int>(
              _model.postsCount,
              0,
            );
            safeSetState(() {});
          }),
          Future(() async {
            _model.orgCount = await actions.orgsCount();
            _model.orgsNum = _model.orgCount;
            safeSetState(() {});
          }),
        ]);
        safeSetState(() {});
      } else {
        context.goNamed(
          LoginAdminWidget.routeName,
          extra: <String, dynamic>{
            '__transition_info__': TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 0),
            ),
          },
        );
      }
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
    return Title(
        title: 'StatisticsAdmin',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            drawer: Drawer(
              elevation: 16.0,
              child: wrapWithModel(
                model: _model.drawerAdminModel2,
                updateCallback: () => safeSetState(() {}),
                updateOnChange: true,
                child: DrawerAdminWidget(
                  closeDrawer: () async {
                    if (scaffoldKey.currentState!.isDrawerOpen ||
                        scaffoldKey.currentState!.isEndDrawerOpen) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
            body: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (responsiveVisibility(
                  context: context,
                  phone: false,
                  tablet: false,
                ))
                  wrapWithModel(
                    model: _model.drawerAdminModel1,
                    updateCallback: () => safeSetState(() {}),
                    updateOnChange: true,
                    child: DrawerAdminWidget(
                      closeDrawer: () async {
                        if (scaffoldKey.currentState!.isDrawerOpen ||
                            scaffoldKey.currentState!.isEndDrawerOpen) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      wrapWithModel(
                        model: _model.headerAdminModel,
                        updateCallback: () => safeSetState(() {}),
                        updateOnChange: true,
                        child: HeaderAdminWidget(
                          title: 'Statistics',
                          openDrawer: () async {
                            scaffoldKey.currentState!.openDrawer();
                          },
                          navigate: () async {
                            FFAppState().adminPage = AdminPages.statistics.name;
                            FFAppState().update(() {});

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
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<List<GamesRow>>(
                          future: GamesTable().queryRows(
                            queryFn: (q) => q.eqOrNull(
                              'status',
                              'completed',
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
                            List<GamesRow> containerGamesRowList =
                                snapshot.data!;

                            return Container(
                              height: MediaQuery.sizeOf(context).height * 0.9,
                              decoration: BoxDecoration(),
                              child: SingleChildScrollView(
                                controller: _model.columnController,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.all(valueOrDefault<double>(
                                        () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 12.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 24.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 48.0;
                                          } else {
                                            return 48.0;
                                          }
                                        }(),
                                        48.0,
                                      )),
                                      child: Wrap(
                                        spacing: 24.0,
                                        runSpacing: 24.0,
                                        alignment: WrapAlignment.start,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        direction: Axis.horizontal,
                                        runAlignment: WrapAlignment.start,
                                        verticalDirection:
                                            VerticalDirection.down,
                                        clipBehavior: Clip.none,
                                        children: [
                                          wrapWithModel(
                                            model: _model.goodPowerModel,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: StatisticCardAdminWidget(
                                              icon: Icon(
                                                FFIcons.kflash2,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                size: 24.0,
                                              ),
                                              title: 'Good Power',
                                              count: valueOrDefault<String>(
                                                functions
                                                    .formatCompactWithComma(
                                                        valueOrDefault<double>(
                                                  functions.totalSum(
                                                      containerGamesRowList
                                                          .map((e) =>
                                                              e.lichtwatt)
                                                          .withoutNulls
                                                          .toList()),
                                                  0.0,
                                                )),
                                                '0',
                                              ),
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gamesModel,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: StatisticCardAdminWidget(
                                              icon: Icon(
                                                FFIcons.ktrophy,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                size: 24.0,
                                              ),
                                              title: 'Games',
                                              count: valueOrDefault<String>(
                                                _model.gamesNum?.toString(),
                                                '0',
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              FFAppState().adminPage =
                                                  AdminPages.users.name;
                                              FFAppState().update(() {});

                                              context.pushNamed(
                                                UsersAdminWidget.routeName,
                                                extra: <String, dynamic>{
                                                  '__transition_info__':
                                                      TransitionInfo(
                                                    hasTransition: true,
                                                    transitionType:
                                                        PageTransitionType.fade,
                                                    duration: Duration(
                                                        milliseconds: 0),
                                                  ),
                                                },
                                              );
                                            },
                                            child: wrapWithModel(
                                              model: _model.usersModel,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: StatisticCardAdminWidget(
                                                icon: Icon(
                                                  FFIcons.kgroup2,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 24.0,
                                                ),
                                                title: 'Users',
                                                count: valueOrDefault<String>(
                                                  _model.usersNum?.toString(),
                                                  '0',
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              FFAppState().adminPage =
                                                  AdminPages.posts.name;
                                              FFAppState().update(() {});

                                              context.pushNamed(
                                                PostsAdminWidget.routeName,
                                                extra: <String, dynamic>{
                                                  '__transition_info__':
                                                      TransitionInfo(
                                                    hasTransition: true,
                                                    transitionType:
                                                        PageTransitionType.fade,
                                                    duration: Duration(
                                                        milliseconds: 0),
                                                  ),
                                                },
                                              );
                                            },
                                            child: wrapWithModel(
                                              model: _model.postsModel,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: StatisticCardAdminWidget(
                                                icon: Icon(
                                                  FFIcons.kinstagram,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 24.0,
                                                ),
                                                title: 'Posts',
                                                count: valueOrDefault<String>(
                                                  _model.postsNum?.toString(),
                                                  '0',
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              FFAppState().adminPage =
                                                  AdminPages.organisations.name;
                                              FFAppState().update(() {});

                                              context.pushNamed(
                                                OrganisationsAdminWidget
                                                    .routeName,
                                                extra: <String, dynamic>{
                                                  '__transition_info__':
                                                      TransitionInfo(
                                                    hasTransition: true,
                                                    transitionType:
                                                        PageTransitionType.fade,
                                                    duration: Duration(
                                                        milliseconds: 0),
                                                  ),
                                                },
                                              );
                                            },
                                            child: wrapWithModel(
                                              model: _model.orgsModel,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: StatisticCardAdminWidget(
                                                icon: Icon(
                                                  FFIcons.kdonate,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 24.0,
                                                ),
                                                title: 'Organisations',
                                                count: valueOrDefault<String>(
                                                  _model.orgsNum?.toString(),
                                                  '0',
                                                ),
                                              ),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
