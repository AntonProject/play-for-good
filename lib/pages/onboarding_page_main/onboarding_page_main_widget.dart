import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'onboarding_page_main_model.dart';
export 'onboarding_page_main_model.dart';

class OnboardingPageMainWidget extends StatefulWidget {
  const OnboardingPageMainWidget({super.key});

  static String routeName = 'OnboardingPageMain';
  static String routePath = '/onboardingPageMain';

  @override
  State<OnboardingPageMainWidget> createState() =>
      _OnboardingPageMainWidgetState();
}

class _OnboardingPageMainWidgetState extends State<OnboardingPageMainWidget> {
  late OnboardingPageMainModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingPageMainModel());

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
        title: 'OnboardingPageMain',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.transparent,
            body: Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: double.infinity,
              child: Stack(
                children: [
                  PageView(
                    controller: _model.pageViewController ??=
                        PageController(initialPage: 0),
                    scrollDirection: Axis.horizontal,
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.asset(
                              'assets/images/onboarding_step_2.png',
                            ).image,
                          ),
                        ),
                        child: SafeArea(
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 166.0),
                                  child: SingleChildScrollView(
                                    primary: false,
                                    controller: _model.columnController1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    44.0, 36.0, 44.0, 0.0),
                                            child: Text(
                                              'PLAY A BIGGER GAME',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyLarge
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLargeFamily,
                                                    color: Color(0xFFFAFAF9),
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
                                                            .bodyLargeIsCustom,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  44.0, 12.0, 44.0, 0.0),
                                          child: Text(
                                            'Mach’ dein bestes Spiel',
                                            style: FlutterFlowTheme.of(context)
                                                .displayMedium
                                                .override(
                                                  fontFamily: 'Dela Gothic One',
                                                  color: Color(0xFFFAFAF9),
                                                  fontSize: 40.0,
                                                  letterSpacing:
                                                      valueOrDefault<double>(
                                                    -1.8,
                                                    -1.8,
                                                  ),
                                                  fontWeight: FontWeight.normal,
                                                  lineHeight: 1.2,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  44.0, 12.0, 44.0, 0.0),
                                          child: Text(
                                            'Erfasse Punkte nach einem Spiel, lege deinen €insatz pro Punkt fest, und verwandle sie in Spenden - wir nennen sie Good €nergy.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyLargeFamily,
                                                  color: Color(0xFFFAFAF9),
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
                                                          .bodyLargeIsCustom,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  44.0, 37.0, 44.0, 0.0),
                                          child: Image.asset(
                                            'assets/images/onboarding_step_2_content.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, 1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        44.0, 0.0, 44.0, 46.0),
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        await _model.pageViewController
                                            ?.nextPage(
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.ease,
                                        );
                                      },
                                      text: 'Weiter',
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 56.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconAlignment: IconAlignment.end,
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              color: Color(0xFFFAFAF9),
                                              letterSpacing: -0.4,
                                              fontWeight: FontWeight.w600,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(99.0),
                                      ),
                                      showLoadingIndicator: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.asset(
                              'assets/images/onboarding_step_3.png',
                            ).image,
                          ),
                        ),
                        child: SafeArea(
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 166.0),
                                  child: SingleChildScrollView(
                                    primary: false,
                                    controller: _model.columnController2,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    44.0, 36.0, 44.0, 0.0),
                                            child: Text(
                                              'YOUR GAME. YOUR CHOICE.',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyLarge
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLargeFamily,
                                                    color: Color(0xFFFAFAF9),
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
                                                            .bodyLargeIsCustom,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  44.0, 12.0, 44.0, 0.0),
                                          child: Text(
                                            'Hör’ auf dein Herz',
                                            style: FlutterFlowTheme.of(context)
                                                .displayMedium
                                                .override(
                                                  fontFamily: 'Dela Gothic One',
                                                  color: Color(0xFFFAFAF9),
                                                  fontSize: 40.0,
                                                  letterSpacing:
                                                      valueOrDefault<double>(
                                                    -1.8,
                                                    -1.8,
                                                  ),
                                                  fontWeight: FontWeight.normal,
                                                  lineHeight: 1.2,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  44.0, 12.0, 44.0, 0.0),
                                          child: Text(
                                            'Spende Good €nergy an Non-Profits deiner Wahl, deren Arbeit dein Herz bewegt.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyLargeFamily,
                                                  color: Color(0xFFFAFAF9),
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
                                                          .bodyLargeIsCustom,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  44.0, 37.0, 44.0, 0.0),
                                          child: Image.asset(
                                            'assets/images/onboarding_step_3_content.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, 1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        44.0, 0.0, 44.0, 46.0),
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        await _model.pageViewController
                                            ?.nextPage(
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.ease,
                                        );
                                      },
                                      text: 'Weiter',
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 56.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconAlignment: IconAlignment.end,
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              color: Color(0xFFFAFAF9),
                                              letterSpacing: -0.4,
                                              fontWeight: FontWeight.w600,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(99.0),
                                      ),
                                      showLoadingIndicator: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.asset(
                              'assets/images/onboarding_step_4.png',
                            ).image,
                          ),
                        ),
                        child: SafeArea(
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 166.0),
                                  child: SingleChildScrollView(
                                    primary: false,
                                    controller: _model.columnController3,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    44.0, 36.0, 44.0, 0.0),
                                            child: Text(
                                              'WIN FOR GOOD VIBES',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyLarge
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLargeFamily,
                                                    color: Color(0xFFFAFAF9),
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
                                                            .bodyLargeIsCustom,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  44.0, 12.0, 76.0, 0.0),
                                          child: AutoSizeText(
                                            'Freu’ dich auf Competition',
                                            minFontSize: 36.0,
                                            style: FlutterFlowTheme.of(context)
                                                .displayMedium
                                                .override(
                                                  fontFamily: 'Dela Gothic One',
                                                  color: Color(0xFFFAFAF9),
                                                  fontSize: 40.0,
                                                  letterSpacing:
                                                      valueOrDefault<double>(
                                                    -1.8,
                                                    -1.8,
                                                  ),
                                                  fontWeight: FontWeight.normal,
                                                  lineHeight: 1.2,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  44.0, 12.0, 44.0, 0.0),
                                          child: Text(
                                            'Play for better lives. Win for good vibes. Nimm an Good Games teil - unserer virtuellen Championship und hol dir den Titel.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyLargeFamily,
                                                  color: Color(0xFFFAFAF9),
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
                                                          .bodyLargeIsCustom,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  44.0, 37.0, 44.0, 0.0),
                                          child: Image.asset(
                                            'assets/images/onboarding_step_4_content.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, 1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        44.0, 0.0, 44.0, 46.0),
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        await _model.pageViewController
                                            ?.nextPage(
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.ease,
                                        );
                                      },
                                      text: 'Weiter',
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 56.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconAlignment: IconAlignment.end,
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              color: Color(0xFFFAFAF9),
                                              letterSpacing:
                                                  valueOrDefault<double>(
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
                                        borderRadius:
                                            BorderRadius.circular(99.0),
                                      ),
                                      showLoadingIndicator: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.asset(
                              'assets/images/onboarding_step_5.png',
                            ).image,
                          ),
                        ),
                        child: SafeArea(
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 166.0),
                                  child: SingleChildScrollView(
                                    primary: false,
                                    controller: _model.columnController4,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    44.0, 36.0, 44.0, 0.0),
                                            child: Text(
                                              'MAKE A DIFFERENCE',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyLarge
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLargeFamily,
                                                    color: Color(0xFFFAFAF9),
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
                                                            .bodyLargeIsCustom,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  44.0, 12.0, 44.0, 0.0),
                                          child: Text(
                                            'Sei stolz auf dich',
                                            style: FlutterFlowTheme.of(context)
                                                .displayMedium
                                                .override(
                                                  fontFamily: 'Dela Gothic One',
                                                  color: Color(0xFFFAFAF9),
                                                  fontSize: 40.0,
                                                  letterSpacing:
                                                      valueOrDefault<double>(
                                                    -1.8,
                                                    -1.8,
                                                  ),
                                                  fontWeight: FontWeight.normal,
                                                  lineHeight: 1.2,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  44.0, 12.0, 44.0, 0.0),
                                          child: Text(
                                            'Behalte deine Game Stats und deine Wirkung - die Good Power, gemessen in Lichtwatt - immer im Auge und sei stolz darauf.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyLargeFamily,
                                                  color: Color(0xFFFAFAF9),
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
                                                          .bodyLargeIsCustom,
                                                ),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    44.0, 52.0, 44.0, 0.0),
                                            child: Image.asset(
                                              'assets/images/onboarding_step_5_content.png',
                                              fit: BoxFit.cover,
                                              alignment: Alignment(0.0, 0.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, 1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        44.0, 0.0, 44.0, 46.0),
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        FFAppState().onboardingCompleted = true;
                                        if (FFAppState().hasUserLoggedOut) {
                                          context
                                              .goNamed(LoginWidget.routeName);
                                        } else {
                                          context.goNamed(
                                              HomePageWidget.routeName);
                                        }
                                      },
                                      text: 'Los geht’s',
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 56.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconAlignment: IconAlignment.end,
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              color: Color(0xFFFAFAF9),
                                              letterSpacing: -0.4,
                                              fontWeight: FontWeight.w600,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(99.0),
                                      ),
                                      showLoadingIndicator: false,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, 1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 19.0),
                                    child: Text(
                                      'Ohne Registrierung erkunden',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmallFamily,
                                            color: Colors.white,
                                            letterSpacing:
                                                valueOrDefault<double>(
                                              -0.24,
                                              -0.24,
                                            ),
                                            fontWeight: FontWeight.w500,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .labelSmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, 1.0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          0.0,
                          0.0,
                          valueOrDefault<double>(
                            MediaQuery.paddingOf(context).bottom + 142,
                            142.0,
                          )),
                      child: smooth_page_indicator.SmoothPageIndicator(
                        controller: _model.pageViewController ??=
                            PageController(initialPage: 0),
                        count: 4,
                        axisDirection: Axis.horizontal,
                        onDotClicked: (i) async {
                          await _model.pageViewController!.animateToPage(
                            i,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                          safeSetState(() {});
                        },
                        effect: smooth_page_indicator.SlideEffect(
                          spacing: 8.0,
                          radius: 8.0,
                          dotWidth: 8.0,
                          dotHeight: 8.0,
                          dotColor: Color(0xCBFAFAF9),
                          activeDotColor: Color(0xFFFAFAF9),
                          paintStyle: PaintingStyle.fill,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
