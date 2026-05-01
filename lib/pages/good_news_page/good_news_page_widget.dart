import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/apbar_b_g/apbar_b_g_widget.dart';
import '/components/navbar/navbar_widget.dart';
import '/components/post_comp/post_comp_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'good_news_page_model.dart';
export 'good_news_page_model.dart';

class GoodNewsPageWidget extends StatefulWidget {
  const GoodNewsPageWidget({super.key});

  static String routeName = 'GoodNewsPage';
  static String routePath = '/goodNewsPage';

  @override
  State<GoodNewsPageWidget> createState() => _GoodNewsPageWidgetState();
}

class _GoodNewsPageWidgetState extends State<GoodNewsPageWidget> {
  late GoodNewsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GoodNewsPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
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
        title: 'GoodNewsPage',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Stack(
              children: [
                SingleChildScrollView(
                  controller: _model.columnController,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Stack(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            children: [
                              Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  minHeight: 350.0,
                                ),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: Image.asset(
                                      'assets/images/Wallet.png',
                                    ).image,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    12.0, 140.0, 12.0, 0.0),
                                child: StreamBuilder<List<PostsRow>>(
                                  stream: FFAppState().posts(
                                    uniqueQueryKey:
                                        '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                                    requestFn: () =>
                                        _model.columnSupabaseStream ??= SupaFlow
                                            .client
                                            .from("posts")
                                            .stream(primaryKey: ['id'])
                                            .order('created_at')
                                            .map((list) => list
                                                .map((item) => PostsRow(item))
                                                .toList()),
                                  ),
                                  builder: (context, snapshot) {
                                    // Customize what your widget looks like when it's loading.
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SizedBox(
                                          width: 40.0,
                                          height: 40.0,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    List<PostsRow> columnPostsRowList =
                                        snapshot.data!;

                                    if (columnPostsRowList.isEmpty) {
                                      return ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        child: Image.asset(
                                          'assets/images/Post.png',
                                          fit: BoxFit.fill,
                                        ),
                                      );
                                    }

                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                          columnPostsRowList.length,
                                          (columnIndex) {
                                        final columnPostsRow =
                                            columnPostsRowList[columnIndex];
                                        return PostCompWidget(
                                          key: Key(
                                              'Keyc5u_${columnIndex}_of_${columnPostsRowList.length}'),
                                          post: columnPostsRow,
                                        );
                                      }).divide(SizedBox(height: 24.0)),
                                    );
                                  },
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
                        ],
                      ),
                    ].addToEnd(SizedBox(height: 150.0)),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.navbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: NavbarWidget(
                      pageNumber: 2,
                    ),
                  ),
                ),
                wrapWithModel(
                  model: _model.apbarBGModel,
                  updateCallback: () => safeSetState(() {}),
                  updateOnChange: true,
                  child: ApbarBGWidget(
                    title: 'Good News',
                    text: 'Gutes tun. Gutes zeigen. Gutes feiern.',
                    backgroundColor: valueOrDefault<Color>(
                      _model.visible
                          ? Colors.transparent
                          : FlutterFlowTheme.of(context).accent3,
                      FlutterFlowTheme.of(context).accent3,
                    ),
                    gradientColor: valueOrDefault<Color>(
                      _model.visible
                          ? Colors.transparent
                          : FlutterFlowTheme.of(context).accent2,
                      FlutterFlowTheme.of(context).accent2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
