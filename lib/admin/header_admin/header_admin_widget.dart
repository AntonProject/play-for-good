import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'header_admin_model.dart';
export 'header_admin_model.dart';

class HeaderAdminWidget extends StatefulWidget {
  const HeaderAdminWidget({
    super.key,
    required this.openDrawer,
    String? title,
    required this.navigate,
    this.subtitle,
  }) : this.title = title ?? 'Statistic';

  final Future Function()? openDrawer;
  final String title;
  final Future Function()? navigate;
  final String? subtitle;

  @override
  State<HeaderAdminWidget> createState() => _HeaderAdminWidgetState();
}

class _HeaderAdminWidgetState extends State<HeaderAdminWidget> {
  late HeaderAdminModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HeaderAdminModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: Border.all(
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (responsiveVisibility(
            context: context,
            tabletLandscape: false,
            desktop: false,
          ))
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
              child: FlutterFlowIconButton(
                borderRadius: 8.0,
                buttonSize: 40.0,
                icon: Icon(
                  FFIcons.klist,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 24.0,
                ),
                onPressed: () async {
                  unawaited(
                    () async {
                      await widget.openDrawer?.call();
                    }(),
                  );
                },
              ),
            ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    unawaited(
                      () async {
                        await widget.navigate?.call();
                      }(),
                    );
                  },
                  child: Text(
                    valueOrDefault<String>(
                      widget!.title,
                      'Statistic',
                    ),
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleMediumFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleMediumIsCustom,
                        ),
                  ),
                ),
                if (widget!.subtitle != null && widget!.subtitle != '')
                  Text(
                    widget!.subtitle!,
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleMediumFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleMediumIsCustom,
                        ),
                  ),
              ].divide(SizedBox(width: 8.0)),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
            child: Builder(
              builder: (context) {
                if (Theme.of(context).brightness == Brightness.light) {
                  return FlutterFlowIconButton(
                    borderRadius: 99.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      Icons.dark_mode_outlined,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      setDarkModeSetting(context, ThemeMode.dark);
                    },
                  );
                } else {
                  return FlutterFlowIconButton(
                    borderRadius: 99.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      Icons.light_mode,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      setDarkModeSetting(context, ThemeMode.light);
                    },
                  );
                }
              },
            ),
          ),
        ].addToStart(SizedBox(width: 24.0)).addToEnd(SizedBox(width: 24.0)),
      ),
    );
  }
}
