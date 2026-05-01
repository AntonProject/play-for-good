import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'donat_add_model.dart';
export 'donat_add_model.dart';

class DonatAddWidget extends StatefulWidget {
  const DonatAddWidget({
    super.key,
    this.game,
    required this.update,
  });

  final GameStruct? game;
  final Future Function(double? donatMoney)? update;

  @override
  State<DonatAddWidget> createState() => _DonatAddWidgetState();
}

class _DonatAddWidgetState extends State<DonatAddWidget> {
  late DonatAddModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DonatAddModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.gameDT = widget!.game;
      safeSetState(() {});
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
    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600.0,
          maxHeight: MediaQuery.sizeOf(context).height * 0.95,
        ),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 8.0,
              color: Color(0x19000000),
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
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.95,
          ),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 6.0, 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 56.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 99.0,
                        buttonSize: 40.0,
                        fillColor: FlutterFlowTheme.of(context).alternate,
                        icon: Icon(
                          FFIcons.kxmark,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Beitrag anpassen',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              fontSize: 20.0,
                              letterSpacing: valueOrDefault<double>(
                                -0.8,
                                -0.8,
                              ),
                              fontWeight: FontWeight.w500,
                              lineHeight: 1.4,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                      ),
                    ),
                    Container(
                      width: 56.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 99.0,
                        buttonSize: 40.0,
                        fillColor: FlutterFlowTheme.of(context).alternate,
                        icon: Icon(
                          FFIcons.kcheck2,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 14.0,
                        ),
                        showLoadingIndicator: true,
                        onPressed: () async {
                          await widget.update?.call(
                            _model.gameDT?.donatMoney,
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  child: SingleChildScrollView(
                    controller: _model.columnController,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 32.0, 0.0, 32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        32.0, 0.0, 32.0, 16.0),
                                    child: Text(
                                      'Players For Good gGmbH ist eine gemeinnützige Organisation und ist auch auf Spenden bzw. €nergy angewiesen! \n\nMit deiner freiwilligen Unterstützung hilfst du uns, diese App und weitere Angebote zu entwickeln, um mehr gute Menschen zu erreichen und ihnen zu helfen, Gutes für ihre Mitmenschen zu tun. Jede €nergy zählt!',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            fontSize: 14.0,
                                            letterSpacing:
                                                valueOrDefault<double>(
                                              -0.35,
                                              -0.35,
                                            ),
                                            fontWeight: FontWeight.normal,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    if (_model.gameDT!.donatMoney < 1.0) {
                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            32.0, 24.0, 32.0, 24.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(32.0),
                                          child: Image.asset(
                                            'assets/images/Image_0_contribution.png',
                                            width: double.infinity,
                                            height: 230.0,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      );
                                    } else if (_model.gameDT?.donatMoney ==
                                        1.0) {
                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            32.0, 24.0, 32.0, 24.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(32.0),
                                          child: Image.asset(
                                            'assets/images/Image_1-2_contribution.png',
                                            width: double.infinity,
                                            height: 230.0,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      );
                                    } else if (_model.gameDT?.donatMoney ==
                                        3.0) {
                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            32.0, 24.0, 32.0, 24.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(32.0),
                                          child: Image.asset(
                                            'assets/images/Image_3-4_contribution.png',
                                            width: double.infinity,
                                            height: 230.0,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      );
                                    } else if (_model.gameDT?.donatMoney ==
                                        5.0) {
                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            32.0, 24.0, 32.0, 24.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(32.0),
                                          child: Image.asset(
                                            'assets/images/Image_5-9_contribution.png',
                                            width: double.infinity,
                                            height: 230.0,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      );
                                    } else if (_model.gameDT?.donatMoney ==
                                        10.0) {
                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            32.0, 24.0, 32.0, 24.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(32.0),
                                          child: Image.asset(
                                            'assets/images/Image_10-19_contribution.png',
                                            width: double.infinity,
                                            height: 230.0,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            32.0, 24.0, 32.0, 24.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(32.0),
                                          child: Image.asset(
                                            'assets/images/Image_20_contribution.png',
                                            width: double.infinity,
                                            height: 230.0,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      40.0, 16.0, 40.0, 0.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/Text.png',
                                      width: double.infinity,
                                      height: 24.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      36.0, 0.0, 32.0, 0.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 80.0,
                                    child: custom_widgets.CustomDonationSlider(
                                      width: double.infinity,
                                      height: 80.0,
                                      currentValue: _model.gameDT!.donatMoney,
                                      activeColor:
                                          FlutterFlowTheme.of(context).success,
                                      inactiveColor:
                                          FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      thumbColor:
                                          FlutterFlowTheme.of(context).success,
                                      thumbInnerColor:
                                          FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      trackHeight: 8.0,
                                      thumbSize: 20.0,
                                      update: (value) async {
                                        _model.updateGameDTStruct(
                                          (e) => e
                                            ..donatMoney =
                                                (value!).round().toDouble(),
                                        );
                                        safeSetState(() {});
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      32.0, 12.0, 32.0, 0.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              valueOrDefault<String>(
                                                formatNumber(
                                                  _model.gameDT?.donatMoney,
                                                  formatType: FormatType.custom,
                                                  format: '0 €',
                                                  locale: '',
                                                ),
                                                '0 €',
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    letterSpacing:
                                                        valueOrDefault<double>(
                                                      -0.4,
                                                      -0.4,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                    lineHeight: 1.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                            ),
                                          ),
                                          Container(
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(99.0),
                                              border: Border.all(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .success,
                                              ),
                                            ),
                                            child: Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        16.0, 0.0, 16.0, 0.0),
                                                child: Text(
                                                  'Gesamtbetrag: ${valueOrDefault<String>(
                                                    functions.numFormat(
                                                        valueOrDefault<String>(
                                                      (_model.gameDT!
                                                                  .userMoney +
                                                              _model.gameDT!
                                                                  .teamMoney +
                                                              _model.gameDT!
                                                                  .siegMoney +
                                                              (_model.gameDT!
                                                                  .donatMoney
                                                                  .round()
                                                                  .toDouble()))
                                                          .toString(),
                                                      '0',
                                                    )),
                                                    '0',
                                                  )} €',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmallFamily,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .success,
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
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        32.0, 24.0, 32.0, 0.0),
                                    child: Text(
                                      'Wir schätzen deine Unterstützung sehr! 🙏❤️',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            fontSize: 14.0,
                                            letterSpacing:
                                                valueOrDefault<double>(
                                              -0.35,
                                              -0.35,
                                            ),
                                            fontWeight: FontWeight.normal,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ].addToStart(SizedBox(height: 8.0)),
                            ),
                          ),
                        ),
                      ].addToStart(SizedBox(height: 12.0)),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(14.0, 32.0, 14.0, 34.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      await widget.update?.call(
                        _model.gameDT?.donatMoney,
                      );
                      Navigator.pop(context);
                    },
                    text: 'Speichern',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconAlignment: IconAlignment.end,
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).success,
                      textStyle: FlutterFlowTheme.of(context)
                          .titleSmall
                          .override(
                            fontFamily:
                                FlutterFlowTheme.of(context).titleSmallFamily,
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            fontSize: 18.0,
                            letterSpacing: valueOrDefault<double>(
                              -0.63,
                              -0.63,
                            ),
                            fontWeight: FontWeight.w600,
                            lineHeight: 1.5,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleSmallIsCustom,
                          ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(99.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
