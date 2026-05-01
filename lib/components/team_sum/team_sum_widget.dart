import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'team_sum_model.dart';
export 'team_sum_model.dart';

class TeamSumWidget extends StatefulWidget {
  const TeamSumWidget({
    super.key,
    required this.text,
    required this.sum,
    required this.icon,
    required this.title,
  });

  final String? text;
  final double? sum;
  final Widget? icon;
  final String? title;

  @override
  State<TeamSumWidget> createState() => _TeamSumWidgetState();
}

class _TeamSumWidgetState extends State<TeamSumWidget> {
  late TeamSumModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeamSumModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 24.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              shape: BoxShape.circle,
            ),
            child: widget!.icon!,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valueOrDefault<String>(
                    widget!.title,
                    'Team-Punkte',
                  ),
                  maxLines: 1,
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleSmallFamily,
                        letterSpacing: valueOrDefault<double>(
                          -0.4,
                          -0.4,
                        ),
                        fontWeight: FontWeight.bold,
                        lineHeight: 1.5,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                      ),
                ),
                Text(
                  valueOrDefault<String>(
                    widget!.text,
                    '78 Punkte je 0,10 €',
                  ),
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleSmallFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 14.0,
                        letterSpacing: valueOrDefault<double>(
                          -0.35,
                          -0.35,
                        ),
                        fontWeight: FontWeight.w500,
                        lineHeight: 1.5,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${valueOrDefault<String>(
              functions.numFormat(valueOrDefault<String>(
                widget!.sum?.toString(),
                '0',
              )),
              '0',
            )} €',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  letterSpacing: valueOrDefault<double>(
                    -0.63,
                    -0.63,
                  ),
                  fontWeight: FontWeight.bold,
                  lineHeight: 1.5,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleMediumIsCustom,
                ),
          ),
        ].divide(SizedBox(width: 16.0)),
      ),
    );
  }
}
