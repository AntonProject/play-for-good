import '/components/dialogs/home_info_dialog/home_info_dialog_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_page_score_empty_model.dart';
export 'home_page_score_empty_model.dart';

class HomePageScoreEmptyWidget extends StatefulWidget {
  const HomePageScoreEmptyWidget({super.key});

  @override
  State<HomePageScoreEmptyWidget> createState() =>
      _HomePageScoreEmptyWidgetState();
}

class _HomePageScoreEmptyWidgetState extends State<HomePageScoreEmptyWidget> {
  late HomePageScoreEmptyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageScoreEmptyModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14.0),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 450.0,
          maxWidth: 600.0,
          maxHeight: 500.0,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: Image.asset(
              'assets/images/Good_Score_Card2.png',
            ).image,
          ),
          borderRadius: BorderRadius.circular(28.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(28.0, 20.0, 28.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    FFIcons.klogoMini2,
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    size: 40.0,
                  ),
                  FlutterFlowIconButton(
                    borderRadius: 8.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      FFIcons.kinfoCircle,
                      color: FlutterFlowTheme.of(context).info,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        useSafeArea: true,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: HomeInfoDialogWidget(),
                          );
                        },
                      ).then((value) => safeSetState(() {}));
                    },
                  ),
                ].divide(SizedBox(width: 8.0)),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(32.0, 32.0, 32.0, 0.0),
                  child: AutoSizeText(
                    'WILLKOMMEN,\nPLAYER \nFOR GOOD!',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Dela Gothic One',
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          fontSize: 28.0,
                          letterSpacing: 0.0,
                          lineHeight: 1.43,
                        ),
                  ),
                ),
                Container(
                  width: 200.0,
                  height: 1.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).focus,
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(36.0, 0.0, 36.0, 36.0),
                  child: AutoSizeText(
                    'Bereit für ein Spiel, das mehr \nbewegt? Verwandle deine \nLeidenschaft für Basketball in \nGood €nergy und werde Teil einer\nBewegung voller Good Power.',
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          fontSize: 16.0,
                          letterSpacing: -0.4,
                          fontWeight: FontWeight.bold,
                          lineHeight: 1.5,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                        ),
                  ),
                ),
              ].divide(SizedBox(height: 16.0)).addToEnd(SizedBox(height: 24.0)),
            ),
          ].divide(SizedBox(height: 12.0)),
        ),
      ),
    );
  }
}
