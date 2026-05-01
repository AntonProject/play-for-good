import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'onboarding_page_initial_model.dart';
export 'onboarding_page_initial_model.dart';

class OnboardingPageInitialWidget extends StatefulWidget {
  const OnboardingPageInitialWidget({super.key});

  static String routeName = 'OnboardingPageInitial';
  static String routePath = '/onboardingPageInitial';

  @override
  State<OnboardingPageInitialWidget> createState() =>
      _OnboardingPageInitialWidgetState();
}

class _OnboardingPageInitialWidgetState
    extends State<OnboardingPageInitialWidget> {
  late OnboardingPageInitialModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingPageInitialModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().onboardingCompleted == true) {
        if (FFAppState().hasUserLoggedOut) {
          context.goNamed(LoginWidget.routeName);
        } else {
          context.goNamed(HomePageWidget.routeName);
        }
      } else {
        _model.isInitialPageStateLoading = false;
        safeSetState(() {});
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
    context.watch<FFAppState>();

    return Title(
        title: 'OnboardingPageInitial',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.transparent,
            body: Builder(
              builder: (context) {
                if (!_model.isInitialPageStateLoading) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image.asset(
                          'assets/images/onboarding_step_1.png',
                        ).image,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(),
                      child: SingleChildScrollView(
                        controller: _model.columnController,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(-1.0, -1.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    44.0,
                                    valueOrDefault<double>(
                                      MediaQuery.paddingOf(context).bottom + 32,
                                      32.0,
                                    ),
                                    0.0,
                                    0.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: SvgPicture.asset(
                                    'assets/images/ball.svg',
                                    width: 62.4,
                                    height: 62.38,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  44.0, 220.62, 44.0, 0.0),
                              child: Text(
                                'Willkommen im Club',
                                style: FlutterFlowTheme.of(context)
                                    .displayMedium
                                    .override(
                                      fontFamily: 'Dela Gothic One',
                                      color: Color(0xFFFAFAF9),
                                      fontSize: 40.0,
                                      letterSpacing: valueOrDefault<double>(
                                        -1.8,
                                        -1.8,
                                      ),
                                      fontWeight: FontWeight.normal,
                                      lineHeight: 1.2,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  44.0, 24.0, 44.0, 0.0),
                              child: Text(
                                'Wir sind Players For Good - eine Gemeinschaft aus Basketball-Spieler:innen und Fans, die die Energie des Basketballs in Unterstützung für gemeinnützige Organisationen  verwandeln - für ein besseres Leben anderer Menschen, für eine bessere Zukunft unserer Gesellschaft.',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyLargeFamily,
                                      color: Color(0xFFFAFAF9),
                                      letterSpacing: valueOrDefault<double>(
                                        -0.4,
                                        -0.4,
                                      ),
                                      fontWeight: FontWeight.w500,
                                      lineHeight: 1.5,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyLargeIsCustom,
                                    ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, 1.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    44.0,
                                    81.0,
                                    44.0,
                                    valueOrDefault<double>(
                                      MediaQuery.paddingOf(context).bottom + 46,
                                      46.0,
                                    )),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    context.goNamed(
                                        OnboardingPageMainWidget.routeName);
                                  },
                                  text: 'Tour starten',
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 56.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    iconAlignment: IconAlignment.end,
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context).primary,
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
                                    borderRadius: BorderRadius.circular(99.0),
                                  ),
                                  showLoadingIndicator: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Image.asset(
                    'assets/images/splash.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  );
                }
              },
            ),
          ),
        ));
  }
}
