import '/backend/supabase/supabase.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'games_org_comp_model.dart';
export 'games_org_comp_model.dart';

class GamesOrgCompWidget extends StatefulWidget {
  const GamesOrgCompWidget({
    super.key,
    required this.game,
    int? index,
    int? pageNumber,
  })  : this.index = index ?? 0,
        this.pageNumber = pageNumber ?? 1;

  final GamesRow? game;
  final int index;
  final int pageNumber;

  @override
  State<GamesOrgCompWidget> createState() => _GamesOrgCompWidgetState();
}

class _GamesOrgCompWidgetState extends State<GamesOrgCompWidget> {
  late GamesOrgCompModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GamesOrgCompModel());

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
      child: FutureBuilder<List<OrganizationRow>>(
        future: _model.org(
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

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                valueOrDefault<String>(
                  (((valueOrDefault<int>(
                                        widget!.pageNumber,
                                        1,
                                      ) -
                                      1) *
                                  10 +
                              valueOrDefault<int>(
                                widget!.index,
                                1,
                              ) +
                              1) ??
                          1)
                      .toString(),
                  '1',
                ),
                maxLines: 1,
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                      fontSize: 14.0,
                      letterSpacing: -0.35,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.5,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleSmallIsCustom,
                    ),
              ),
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
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valueOrDefault<String>(
                        dateTimeFormat(
                          "dd.MM.yyyy",
                          widget!.game?.createdAt,
                          locale: FFLocalizations.of(context).languageCode,
                        ),
                        '-',
                      ),
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).titleSmallFamily,
                            color: FlutterFlowTheme.of(context).primaryText75,
                            fontSize: 12.0,
                            letterSpacing: -0.24,
                            fontWeight: FontWeight.w500,
                            lineHeight: 1.5,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleSmallIsCustom,
                          ),
                    ),
                    Text(
                      valueOrDefault<String>(
                        widget!.game?.title,
                        'Game #1',
                      ).maybeHandleOverflow(
                        maxChars: 15,
                        replacement: '…',
                      ),
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).titleSmallFamily,
                            letterSpacing: -0.4,
                            fontWeight: FontWeight.bold,
                            lineHeight: 1.5,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleSmallIsCustom,
                          ),
                    ),
                    Text(
                      valueOrDefault<String>(
                        rowOrganizationRow?.title,
                        'unnamed',
                      ),
                      maxLines: 3,
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).titleSmallFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 14.0,
                            letterSpacing: -0.35,
                            fontWeight: FontWeight.w500,
                            lineHeight: 1.5,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleSmallIsCustom,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AutoSizeText(
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
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleMediumFamily,
                        color: FlutterFlowTheme.of(context).tertiary,
                        letterSpacing: -0.4,
                        fontWeight: FontWeight.bold,
                        lineHeight: 1.5,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleMediumIsCustom,
                      ),
                ),
              ),
              Expanded(
                child: Text(
                  valueOrDefault<String>(
                    functions.formatCompactWithComma(valueOrDefault<double>(
                      widget!.game?.lichtwatt,
                      0.0,
                    )),
                    '0',
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleMediumFamily,
                        fontSize: 16.0,
                        letterSpacing: -0.4,
                        fontWeight: FontWeight.bold,
                        lineHeight: 1.5,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleMediumIsCustom,
                      ),
                ),
              ),
            ].divide(SizedBox(width: 16.0)),
          );
        },
      ),
    );
  }
}
