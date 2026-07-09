import '/auth/supabase_auth/auth_util.dart';
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
import 'org_comp_home_model.dart';
export 'org_comp_home_model.dart';

class OrgCompHomeWidget extends StatefulWidget {
  const OrgCompHomeWidget({
    super.key,
    required this.game,
    required this.games,
  });

  final GamesRow? game;
  final List<GamesRow>? games;

  @override
  State<OrgCompHomeWidget> createState() => _OrgCompHomeWidgetState();
}

class _OrgCompHomeWidgetState extends State<OrgCompHomeWidget> {
  late OrgCompHomeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrgCompHomeModel());

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
        future: _model.orgHome(
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
                    widget!.game?.organizationId,
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
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/d6ilkv8n1ka3/Avatar.png',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 4.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateTimeFormat(
                            "dd.MM.yyyy",
                            widget!.game!.createdAt,
                            locale: FFLocalizations.of(context).languageCode,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleSmallFamily,
                                color:
                                    FlutterFlowTheme.of(context).primaryText75,
                                fontSize: 12.0,
                                letterSpacing: valueOrDefault<double>(
                                  -0.24,
                                  -0.24,
                                ),
                                fontWeight: FontWeight.w500,
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
                          maxLines: 4,
                          style: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleSmallFamily,
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
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Kürzlich gesendet ${valueOrDefault<String>(
                            functions.numFormat(valueOrDefault<String>(
                              (valueOrDefault<double>(
                                        widget!.games
                                            ?.where((e) =>
                                                (e.organizationId ==
                                                    widget!.game
                                                        ?.organizationId) &&
                                                ((e.status == 'completed') &&
                                                    (e.creatorUserId ==
                                                        currentUserUid)))
                                            .toList()
                                            ?.lastOrNull
                                            ?.userMoney,
                                        0.0,
                                      ) +
                                      valueOrDefault<double>(
                                        widget!.games
                                            ?.where((e) =>
                                                (e.organizationId ==
                                                    widget!.game
                                                        ?.organizationId) &&
                                                ((e.status == 'completed') &&
                                                    (e.creatorUserId ==
                                                        currentUserUid)))
                                            .toList()
                                            ?.lastOrNull
                                            ?.teamMoney,
                                        0.0,
                                      ) +
                                      valueOrDefault<double>(
                                        widget!.games
                                            ?.where((e) =>
                                                (e.organizationId ==
                                                    widget!.game
                                                        ?.organizationId) &&
                                                ((e.status == 'completed') &&
                                                    (e.creatorUserId ==
                                                        currentUserUid)))
                                            .toList()
                                            ?.lastOrNull
                                            ?.siegMoney,
                                        0.0,
                                      ))
                                  .toString(),
                              '0',
                            )),
                            '0',
                          )} €',
                          maxLines: 4,
                          style: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleSmallFamily,
                                fontSize: 14.0,
                                letterSpacing: valueOrDefault<double>(
                                  -0.35,
                                  -0.35,
                                ),
                                fontWeight: FontWeight.w500,
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
                          (valueOrDefault<double>(
                                    functions.totalSum(widget!.games
                                        ?.where((e) =>
                                            (e.organizationId ==
                                                widget!.game?.organizationId) &&
                                            ((e.status == 'completed') &&
                                                (e.creatorUserId ==
                                                    currentUserUid)))
                                        .toList()
                                        ?.map((e) => e.userMoney)
                                        .withoutNulls
                                        .toList()
                                        ?.toList()),
                                    0.0,
                                  ) +
                                  valueOrDefault<double>(
                                    functions.totalSum(widget!.games
                                        ?.where((e) =>
                                            (e.organizationId ==
                                                widget!.game?.organizationId) &&
                                            ((e.status == 'completed') &&
                                                (e.creatorUserId ==
                                                    currentUserUid)))
                                        .toList()
                                        ?.map((e) => e.teamMoney)
                                        .withoutNulls
                                        .toList()
                                        ?.toList()),
                                    0.0,
                                  ) +
                                  valueOrDefault<double>(
                                    functions.totalSum(widget!.games
                                        ?.where((e) =>
                                            (e.organizationId ==
                                                widget!.game?.organizationId) &&
                                            ((e.status == 'completed') &&
                                                (e.creatorUserId ==
                                                    currentUserUid)))
                                        .toList()
                                        ?.map((e) => e.siegMoney)
                                        .withoutNulls
                                        .toList()
                                        ?.toList()),
                                    0.0,
                                  ))
                              .toString(),
                          '0',
                        )),
                        '0',
                      )} €',
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
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleMediumIsCustom,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
