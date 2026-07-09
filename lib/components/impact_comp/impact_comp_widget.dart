import '/backend/supabase/supabase.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'impact_comp_model.dart';
export 'impact_comp_model.dart';

class ImpactCompWidget extends StatefulWidget {
  const ImpactCompWidget({
    super.key,
    required this.game,
  });

  final GamesRow? game;

  @override
  State<ImpactCompWidget> createState() => _ImpactCompWidgetState();
}

class _ImpactCompWidgetState extends State<ImpactCompWidget> {
  late ImpactCompModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImpactCompModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrganizationRow>>(
      future: _model.orgGameImpact(
        uniqueQueryKey: '${widget!.game?.id}${widget!.game?.organizationId}',
        requestFn: () => OrganizationTable().querySingleRow(
          queryFn: (q) => q.eqOrNull(
            'id',
            widget!.game?.organizationId,
          ),
        ),
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

        // Return an empty Container when the item does not exist.
        if (snapshot.data!.isEmpty) {
          return Container();
        }
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
              GamePageWidget.routeName,
              queryParameters: {
                'gameRow': serializeParam(
                  widget!.game,
                  ParamType.SupabaseRow,
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
                child: InkWell(
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
                  child: wrapWithModel(
                    model: _model.imageModel,
                    updateCallback: () => safeSetState(() {}),
                    child: ImageWidget(
                      size: 40.0,
                      image: valueOrDefault<String>(
                        rowOrganizationRow?.imageUrl,
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/d6ilkv8n1ka3/Avatar.png',
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 4.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateTimeFormat(
                          "dd.MM.yyyy",
                          widget!.game!.gameDate!,
                          locale: FFLocalizations.of(context).languageCode,
                        ),
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontSize: 12.0,
                              letterSpacing: -0.24,
                              lineHeight: 1.2,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                      ),
                      Text(
                        valueOrDefault<String>(
                          widget!.game?.title,
                          'unnamed',
                        ),
                        maxLines: 3,
                        style:
                            FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .displaySmallFamily,
                                  fontSize: 16.0,
                                  letterSpacing: -0.4,
                                  lineHeight: 1.1,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .displaySmallIsCustom,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        valueOrDefault<String>(
                          rowOrganizationRow?.title,
                          'unnamed',
                        ),
                        maxLines: 4,
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 14.0,
                              letterSpacing: -0.35,
                              lineHeight: 1.2,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ].divide(SizedBox(height: 2.0)),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: Align(
                  alignment: AlignmentDirectional(1.0, 0.0),
                  child: Text(
                    '${valueOrDefault<String>(
                      functions.numFormat(valueOrDefault<String>(
                        ((widget!.game!.userMoney!) +
                                (widget!.game!.teamMoney!) +
                                (widget!.game!.siegMoney!) +
                                (widget!.game!.additionalDonationMoney!))
                            .toString(),
                        '0',
                      )),
                      '0',
                    )} €',
                    style: FlutterFlowTheme.of(context).displaySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).displaySmallFamily,
                          fontSize: 16.0,
                          letterSpacing: -0.4,
                          lineHeight: 1.5,
                          useGoogleFonts: !FlutterFlowTheme.of(context)
                              .displaySmallIsCustom,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
