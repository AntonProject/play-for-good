import '/components/dialogs/organisation_list/organisation_list_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'organizations_home_empty_model.dart';
export 'organizations_home_empty_model.dart';

class OrganizationsHomeEmptyWidget extends StatefulWidget {
  const OrganizationsHomeEmptyWidget({
    super.key,
    required this.userId,
  });

  final String? userId;

  @override
  State<OrganizationsHomeEmptyWidget> createState() =>
      _OrganizationsHomeEmptyWidgetState();
}

class _OrganizationsHomeEmptyWidgetState
    extends State<OrganizationsHomeEmptyWidget> {
  late OrganizationsHomeEmptyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrganizationsHomeEmptyModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(14.0, 8.0, 14.0, 0.0),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 82.0,
          maxWidth: 600.0,
        ),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                child: Icon(
                  FFIcons.kdonate,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 32.0,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keine Organisationen gewählt',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              fontSize: 12.0,
                              letterSpacing: valueOrDefault<double>(
                                -0.24,
                                -0.24,
                              ),
                              fontWeight: FontWeight.w500,
                              lineHeight: 1.5,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                      Text(
                        'Finde deine Organisation',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              fontSize: 16.0,
                              letterSpacing: valueOrDefault<double>(
                                -0.4,
                                -0.4,
                              ),
                              fontWeight: FontWeight.bold,
                              lineHeight: 1.1,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                      ),
                    ].divide(SizedBox(height: 4.0)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                child: Container(
                  width: 56.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondary,
                    borderRadius: BorderRadius.circular(99.0),
                  ),
                  child: FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 99.0,
                    buttonSize: 40.0,
                    fillColor: FlutterFlowTheme.of(context).secondary,
                    icon: Icon(
                      FFIcons.kplus,
                      color: FlutterFlowTheme.of(context).primaryBackground,
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
                            child: OrganisationListWidget(
                              userId: widget!.userId!,
                            ),
                          );
                        },
                      ).then((value) => safeSetState(() {}));
                    },
                  ),
                ),
              ),
            ].divide(SizedBox(width: 16.0)),
          ),
        ),
      ),
    );
  }
}
