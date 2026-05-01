import '/backend/supabase/supabase.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pfg_org_for_guest_model.dart';
export 'pfg_org_for_guest_model.dart';

class PfgOrgForGuestWidget extends StatefulWidget {
  const PfgOrgForGuestWidget({super.key});

  @override
  State<PfgOrgForGuestWidget> createState() => _PfgOrgForGuestWidgetState();
}

class _PfgOrgForGuestWidgetState extends State<PfgOrgForGuestWidget> {
  late PfgOrgForGuestModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PfgOrgForGuestModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(22.0, 0.0, 30.0, 0.0),
      child: FutureBuilder<List<OrganizationRow>>(
        future: OrganizationTable().querySingleRow(
          queryFn: (q) => q.or(
              "title.eq.\"Players For Good gGmbH\", display_name.eq.\"playersforgood\""),
        ),
        builder: (context, snapshot) {
          // Customize what your widget looks like when it's loading.
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                width: 40.0,
                height: 40.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.transparent,
                  ),
                ),
              ),
            );
          }
          List<OrganizationRow> rowOrganizationRowList = snapshot.data!;

          final rowOrganizationRow = rowOrganizationRowList.isNotEmpty
              ? rowOrganizationRowList.first
              : null;

          return InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(
                OrganisationPageWidget.routeName,
                queryParameters: {
                  'orgId': serializeParam(
                    rowOrganizationRow?.id,
                    ParamType.String,
                  ),
                }.withoutNulls,
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                  ),
                  child: wrapWithModel(
                    model: _model.imageModel,
                    updateCallback: () => safeSetState(() {}),
                    child: ImageWidget(
                      size: 40.0,
                      image: valueOrDefault<String>(
                        rowOrganizationRow?.imageUrl,
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/42sgzx6uejhj/Vector.png',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        valueOrDefault<String>(
                          rowOrganizationRow?.title,
                          'Players For Good',
                        ),
                        maxLines: 3,
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              letterSpacing: valueOrDefault<double>(
                                -0.4,
                                -0.4,
                              ),
                              fontWeight: FontWeight.bold,
                              lineHeight: 1.5,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '0,10 € je eigener Punkt\n5 Games, max. 2 €/Game',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 14.0,
                              letterSpacing: valueOrDefault<double>(
                                -0.35,
                                -0.35,
                              ),
                              fontWeight: FontWeight.w500,
                              lineHeight: 1.5,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '0 €',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleMediumFamily,
                        fontSize: 16.0,
                        letterSpacing: valueOrDefault<double>(
                          -0.4,
                          -0.4,
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
        },
      ),
    );
  }
}
