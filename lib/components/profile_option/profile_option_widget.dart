import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'profile_option_model.dart';
export 'profile_option_model.dart';

class ProfileOptionWidget extends StatefulWidget {
  const ProfileOptionWidget({
    super.key,
    required this.icon,
    required this.title,
  });

  final Widget? icon;
  final String? title;

  @override
  State<ProfileOptionWidget> createState() => _ProfileOptionWidgetState();
}

class _ProfileOptionWidgetState extends State<ProfileOptionWidget> {
  late ProfileOptionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileOptionModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          widget!.icon!,
          Expanded(
            child: Text(
              valueOrDefault<String>(
                widget!.title,
                'Card',
              ),
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                    letterSpacing: valueOrDefault<double>(
                      -0.4,
                      -0.4,
                    ),
                    fontWeight: FontWeight.w600,
                    lineHeight: 1.5,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).titleSmallIsCustom,
                  ),
            ),
          ),
          Icon(
            FFIcons.krightArrow,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 24.0,
          ),
        ].divide(SizedBox(width: 16.0)).addToEnd(SizedBox(width: 8.0)),
      ),
    );
  }
}
