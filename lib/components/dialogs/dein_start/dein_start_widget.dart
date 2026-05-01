import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dein_start_model.dart';
export 'dein_start_model.dart';

class DeinStartWidget extends StatefulWidget {
  const DeinStartWidget({super.key});

  @override
  State<DeinStartWidget> createState() => _DeinStartWidgetState();
}

class _DeinStartWidgetState extends State<DeinStartWidget> {
  late DeinStartModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeinStartModel());

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
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
            0.0,
            WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
                WidgetsBinding
                    .instance.platformDispatcher.views.first.devicePixelRatio,
            0.0,
            0.0),
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 8.0,
                color: Color(0x1A000000),
                offset: Offset(
                  0.0,
                  valueOrDefault<double>(
                    -2,
                    -2.0,
                  ),
                ),
                spreadRadius: valueOrDefault<double>(
                  -2,
                  -2.0,
                ),
              )
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2.0,
                  color: Color(0xF0000000),
                  offset: Offset(0.0, 0.0),
                  spreadRadius: valueOrDefault<double>(
                    -2,
                    -2.0,
                  ),
                )
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 15.0, 0.0, 15.0),
                        child: Text(
                          'Dein Start',
                          style:
                              FlutterFlowTheme.of(context).titleLarge.override(
                                    fontFamily: 'Dela Gothic One',
                                    letterSpacing: valueOrDefault<double>(
                                      -0.8,
                                      -0.8,
                                    ),
                                    fontWeight: FontWeight.normal,
                                    lineHeight: 1.4,
                                  ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        primary: false,
                        controller: _model.columnController,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 22.0, 24.0, 0.0),
                              child: Text(
                                'Mit dem Herunterladen unserer App hast du den ersten Schritt zum aktiven Mitglied der Player For Good Gemeinschaft gemacht.\n\nDurch dein Interesse an positiver Wirkung allein hast du 100 Lichtwatt an Good Power erzeugt. Danke dir dafür!',
                                style: FlutterFlowTheme.of(context)
                                    .labelLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .labelLargeFamily,
                                      color: Colors.black,
                                      letterSpacing: valueOrDefault<double>(
                                        -0.4,
                                        -0.4,
                                      ),
                                      fontWeight: FontWeight.w500,
                                      lineHeight: 1.5,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .labelLargeIsCustom,
                                    ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(),
                                  child: Image.asset(
                                    'assets/images/grafik.png',
                                    width: 280.0,
                                    height: 280.0,
                                    fit: BoxFit.cover,
                                    alignment: Alignment(0.0, 0.0),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 5.0, 0.0, 0.0),
                                child: Text(
                                  'Good Power',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .headlineSmallFamily,
                                        letterSpacing: valueOrDefault<double>(
                                          -0.96,
                                          -0.96,
                                        ),
                                        lineHeight: 1.4,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .headlineSmallIsCustom,
                                      ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Text(
                                '+ 100',
                                style: FlutterFlowTheme.of(context)
                                    .displayMedium
                                    .override(
                                      fontFamily: 'Dela Gothic One',
                                      fontSize: 40.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Text(
                                'Lichtwatt',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      letterSpacing: valueOrDefault<double>(
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
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  44.0,
                                  60.0,
                                  44.0,
                                  valueOrDefault<double>(
                                    MediaQuery.paddingOf(context).bottom + 24,
                                    24.0,
                                  )),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  Navigator.pop(context);
                                },
                                text: 'Alles klar',
                                options: FFButtonOptions(
                                  height: 56.0,
                                  padding: EdgeInsets.all(16.0),
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
                                        letterSpacing: valueOrDefault<double>(
                                          -0.4,
                                          -0.4,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(360.0),
                                ),
                                showLoadingIndicator: false,
                              ),
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
        ),
      ),
    );
  }
}
