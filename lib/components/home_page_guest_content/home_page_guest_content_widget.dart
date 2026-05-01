import '/backend/supabase/supabase.dart';
import '/components/dialogs/auth_dialog/auth_dialog_widget.dart';
import '/components/home_page_score/home_page_score_widget.dart';
import '/components/home_page_score_empty/home_page_score_empty_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_page_guest_content_model.dart';
export 'home_page_guest_content_model.dart';

class HomePageGuestContentWidget extends StatefulWidget {
  const HomePageGuestContentWidget({
    super.key,
    required this.games,
  });

  final List<GamesRow>? games;

  @override
  State<HomePageGuestContentWidget> createState() =>
      _HomePageGuestContentWidgetState();
}

class _HomePageGuestContentWidgetState
    extends State<HomePageGuestContentWidget> {
  late HomePageGuestContentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageGuestContentModel());

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(
          builder: (context) {
            if (FFAppState().hasGuestGetLichtwatt == true) {
              return wrapWithModel(
                model: _model.homePageScoreModel,
                updateCallback: () => safeSetState(() {}),
                child: HomePageScoreWidget(
                  games: widget!.games,
                  invites: [],
                ),
              );
            } else {
              return wrapWithModel(
                model: _model.homePageScoreEmptyModel,
                updateCallback: () => safeSetState(() {}),
                child: HomePageScoreEmptyWidget(),
              );
            }
          },
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/images/ball.png',
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
                              context.pushNamed(PlayPageWidget.routeName);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Play',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleMediumFamily,
                          fontSize: 12.0,
                          letterSpacing: -0.24,
                          fontWeight: FontWeight.bold,
                          lineHeight: 1.5,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleMediumIsCustom,
                        ),
                  ),
                ].divide(SizedBox(height: 8.0)),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/images/l48xv_.png',
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
                              ).then((value) =>
                                  safeSetState(() => _model.success = value));

                              safeSetState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Invite',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleMediumFamily,
                          fontSize: 12.0,
                          letterSpacing: -0.24,
                          fontWeight: FontWeight.bold,
                          lineHeight: 1.5,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleMediumIsCustom,
                        ),
                  ),
                ].divide(SizedBox(height: 8.0)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
