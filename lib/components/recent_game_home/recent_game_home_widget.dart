import '/backend/supabase/supabase.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'recent_game_home_model.dart';
export 'recent_game_home_model.dart';

class RecentGameHomeWidget extends StatefulWidget {
  const RecentGameHomeWidget({
    super.key,
    required this.game,
  });

  final GamesRow? game;

  @override
  State<RecentGameHomeWidget> createState() => _RecentGameHomeWidgetState();
}

class _RecentGameHomeWidgetState extends State<RecentGameHomeWidget> {
  late RecentGameHomeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecentGameHomeModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      child: Container(
        width: 280.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).customColor1,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 26.0, 0.0, 26.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(22.0, 0.0, 22.0, 18.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<List<UsersRow>>(
                      future: _model.userGameHome(
                        uniqueQueryKey:
                            '${widget!.game?.id}${widget!.game?.creatorUserId}',
                        requestFn: () => UsersTable().querySingleRow(
                          queryFn: (q) => q.eqOrNull(
                            'id',
                            widget!.game?.creatorUserId,
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
                        List<UsersRow> containerUsersRowList = snapshot.data!;

                        // Return an empty Container when the item does not exist.
                        if (snapshot.data!.isEmpty) {
                          return Container();
                        }
                        final containerUsersRow =
                            containerUsersRowList.isNotEmpty
                                ? containerUsersRowList.first
                                : null;

                        return Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              unawaited(
                                () async {
                                  context.pushNamed(
                                    UserProfilePageWidget.routeName,
                                    queryParameters: {
                                      'userId': serializeParam(
                                        containerUsersRow?.id,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );
                                }(),
                              );
                            },
                            child: wrapWithModel(
                              model: _model.imageModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: ImageWidget(
                                size: 40.0,
                                image: valueOrDefault<String>(
                                  containerUsersRow?.photoUrl,
                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          valueOrDefault<String>(
                            functions
                                .formatCompactWithComma(valueOrDefault<double>(
                              widget!.game?.lichtwatt,
                              0.0,
                            )),
                            '0',
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Dela Gothic One',
                                    fontSize: 24.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                        Text(
                          'Lichtwatt',
                          style: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleSmallFamily,
                                color:
                                    FlutterFlowTheme.of(context).primaryText75,
                                fontSize: 10.0,
                                letterSpacing: valueOrDefault<double>(
                                  -0.2,
                                  -0.2,
                                ),
                                fontWeight: FontWeight.w500,
                                lineHeight: 1.5,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .titleSmallIsCustom,
                              ),
                        ),
                      ],
                    ),
                    FutureBuilder<List<OrganizationRow>>(
                      future: _model.orgGameHome(
                        uniqueQueryKey:
                            '${widget!.game?.id}${widget!.game?.organizationId}',
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
                        List<OrganizationRow> containerOrganizationRowList =
                            snapshot.data!;

                        // Return an empty Container when the item does not exist.
                        if (snapshot.data!.isEmpty) {
                          return Container();
                        }
                        final containerOrganizationRow =
                            containerOrganizationRowList.isNotEmpty
                                ? containerOrganizationRowList.first
                                : null;

                        return Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                            shape: BoxShape.circle,
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
                                    containerOrganizationRow?.id,
                                    ParamType.String,
                                  ),
                                }.withoutNulls,
                              );
                            },
                            child: wrapWithModel(
                              model: _model.imageModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: ImageWidget(
                                size: 40.0,
                                image: valueOrDefault<String>(
                                  containerOrganizationRow?.imageUrl,
                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/d6ilkv8n1ka3/Avatar.png',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                height: 0.0,
                thickness: 1.0,
                indent: 16.0,
                endIndent: 16.0,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
              Align(
                alignment: AlignmentDirectional(-1.0, 0.0),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(24.0, 14.0, 24.0, 0.0),
                  child: Text(
                    valueOrDefault<String>(
                      widget!.game?.title,
                      'unnamed',
                    ),
                    maxLines: 2,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          fontSize: 16.0,
                          letterSpacing: -0.4,
                          fontWeight: FontWeight.bold,
                          lineHeight: 1.5,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(-1.0, 0.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 6.0),
                  child: Text(
                    dateTimeFormat(
                      "dd.MM.yyyy",
                      widget!.game!.gameDate!,
                      locale: FFLocalizations.of(context).languageCode,
                    ),
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          color: FlutterFlowTheme.of(context).primaryText75,
                          fontSize: 12.0,
                          letterSpacing: valueOrDefault<double>(
                            -0.24,
                            -0.24,
                          ),
                          fontWeight: FontWeight.w500,
                          lineHeight: 1.5,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                        ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          FFIcons.kgoogle,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 12.0,
                        ),
                        Text(
                          valueOrDefault<String>(
                            functions.numFormat(valueOrDefault<String>(
                              ((widget!.game!.userPoints!) +
                                      (widget!.game!.teamPoints!) +
                                      (widget!.game!.siegPoints!))
                                  .toString(),
                              '0',
                            )),
                            '0',
                          ),
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
                                fontWeight: FontWeight.bold,
                                lineHeight: 1.5,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .titleSmallIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(width: 4.0)),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          FFIcons.keuro,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 12.0,
                        ),
                        Text(
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
                                fontWeight: FontWeight.bold,
                                lineHeight: 1.5,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .titleSmallIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(width: 4.0)),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          FFIcons.kgroup,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 12.0,
                        ),
                        Text(
                          '1',
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
                                fontWeight: FontWeight.bold,
                                lineHeight: 1.5,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .titleSmallIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(width: 4.0)),
                    ),
                  ].divide(SizedBox(width: 12.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
