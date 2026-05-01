import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'snack_bar_white_success_model.dart';
export 'snack_bar_white_success_model.dart';

class SnackBarWhiteSuccessWidget extends StatefulWidget {
  const SnackBarWhiteSuccessWidget({
    super.key,
    String? text,
    bool? error,
  })  : this.text = text ?? 'Zu Favoriten hinzugefügt',
        this.error = error ?? false;

  final String text;
  final bool error;

  @override
  State<SnackBarWhiteSuccessWidget> createState() =>
      _SnackBarWhiteSuccessWidgetState();
}

class _SnackBarWhiteSuccessWidgetState
    extends State<SnackBarWhiteSuccessWidget> {
  late SnackBarWhiteSuccessModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SnackBarWhiteSuccessModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(
        Duration(
          milliseconds: 3000,
        ),
      );
      Navigator.pop(context);
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
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(14.0, 16.0, 14.0, 34.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          Navigator.pop(context);
        },
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 600.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(28.0, 20.0, 28.0, 20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    valueOrDefault<String>(
                      widget!.text,
                      'Erfolgreich',
                    ),
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).labelMediumFamily,
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: valueOrDefault<double>(
                            -0.35,
                            -0.35,
                          ),
                          fontWeight: FontWeight.w500,
                          lineHeight: 1.5,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).labelMediumIsCustom,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!widget!.error)
                  Icon(
                    FFIcons.kcheckCircle,
                    color: Color(0xFF26C274),
                    size: 36.0,
                  ),
              ].divide(SizedBox(width: 16.0)),
            ),
          ),
        ),
      ),
    );
  }
}
