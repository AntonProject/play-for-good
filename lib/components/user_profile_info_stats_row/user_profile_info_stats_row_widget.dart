import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'user_profile_info_stats_row_model.dart';
export 'user_profile_info_stats_row_model.dart';

class UserProfileInfoStatsRowWidget extends StatefulWidget {
  const UserProfileInfoStatsRowWidget({
    super.key,
    required this.title,
    required this.value,
    required this.number,
  });

  final String? title;
  final String? value;
  final String? number;

  @override
  State<UserProfileInfoStatsRowWidget> createState() =>
      _UserProfileInfoStatsRowWidgetState();
}

class _UserProfileInfoStatsRowWidgetState
    extends State<UserProfileInfoStatsRowWidget> {
  late UserProfileInfoStatsRowModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserProfileInfoStatsRowModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
            child: Text(
              valueOrDefault<String>(
                widget!.title,
                'Total Good Power',
              ),
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                    letterSpacing: valueOrDefault<double>(
                      -0.4,
                      -0.4,
                    ),
                    fontWeight: FontWeight.bold,
                    lineHeight: 1.5,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                  ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
          child: Text(
            valueOrDefault<String>(
              widget!.value,
              '100',
            ),
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                  letterSpacing: valueOrDefault<double>(
                    -0.4,
                    -0.4,
                  ),
                  fontWeight: FontWeight.bold,
                  lineHeight: 1.5,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary,
            boxShadow: [
              BoxShadow(
                blurRadius: 2.0,
                color: Color(0x50000000),
                offset: Offset(
                  0.0,
                  2.0,
                ),
                spreadRadius: 0.0,
              )
            ],
            borderRadius: BorderRadius.circular(360.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4.0,
                  color: Color(0x14000000),
                  offset: Offset(
                    0.0,
                    2.0,
                  ),
                  spreadRadius: 0.0,
                )
              ],
              borderRadius: BorderRadius.circular(360.0),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(18.0, 3.0, 18.0, 3.0),
              child: Text(
                valueOrDefault<String>(
                  widget!.number,
                  '3',
                ),
                maxLines: 3,
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      letterSpacing: valueOrDefault<double>(
                        -0.24,
                        -0.24,
                      ),
                      fontWeight: FontWeight.w500,
                      lineHeight: 1.5,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).labelSmallIsCustom,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
