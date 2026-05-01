import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'energy_comp_model.dart';
export 'energy_comp_model.dart';

class EnergyCompWidget extends StatefulWidget {
  const EnergyCompWidget({super.key});

  @override
  State<EnergyCompWidget> createState() => _EnergyCompWidgetState();
}

class _EnergyCompWidgetState extends State<EnergyCompWidget> {
  late EnergyCompModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EnergyCompModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return FutureBuilder<List<InvitesRow>>(
      future: InvitesTable().queryRows(
        queryFn: (q) => q
            .eqOrNull(
              'inviter_user_id',
              currentUserUid,
            )
            .eqOrNull(
              'was_used',
              true,
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
        List<InvitesRow> invitesContainerInvitesRowList = snapshot.data!;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 600.0,
          ),
          decoration: BoxDecoration(),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
            child: StreamBuilder<List<GamesRow>>(
              stream: _model.gamesContainerSupabaseStream ??= SupaFlow.client
                  .from("games")
                  .stream(primaryKey: ['id'])
                  .eqOrNull(
                    'status',
                    'completed',
                  )
                  .map((list) => list.map((item) => GamesRow(item)).toList()),
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
                List<GamesRow> gamesContainerGamesRowList = snapshot.data!;

                return Container(
                  width: double.infinity,
                  height: 230.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: Image.asset(
                        'assets/images/Good_Score_Card3.png',
                      ).image,
                    ),
                    borderRadius: BorderRadius.circular(28.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 20.0, 20.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              FFIcons.klogoMini2,
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              size: 40.0,
                            ),
                            Text(
                              'Good €nergy',
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleSmallFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    fontSize: 14.0,
                                    letterSpacing: -0.35,
                                    fontWeight: FontWeight.w600,
                                    lineHeight: 1.5,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .titleSmallIsCustom,
                                  ),
                            ),
                            Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(),
                            ),
                          ].divide(SizedBox(width: 8.0)),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 1.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 8.0),
                            child: Text(
                              valueOrDefault<String>(
                                functions.formatCompactWithComma(
                                    valueOrDefault<double>(
                                  functions.totalSumPeriodGoodPower(
                                      gamesContainerGamesRowList
                                          .where((e) =>
                                              e.creatorUserId == currentUserUid)
                                          .toList(),
                                      Period.gesamt.name),
                                  0.0,
                                )),
                                '0',
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Dela Gothic One',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    fontSize: 32.0,
                                    letterSpacing: 0.0,
                                    lineHeight: 1.0,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 20.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    valueOrDefault<String>(
                                      functions.formatCompactWithComma(
                                          valueOrDefault<double>(
                                        functions.totalSumPeriodGoodPower(
                                            gamesContainerGamesRowList
                                                .where((e) =>
                                                    e.creatorUserId ==
                                                    currentUserUid)
                                                .toList(),
                                            Period.woche.name),
                                        0.0,
                                      )),
                                      '0',
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Dela Gothic One',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          fontSize: 16.0,
                                          letterSpacing: -0.56,
                                          lineHeight: 1.5,
                                        ),
                                  ),
                                  Text(
                                    'Diese Woche',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          fontSize: 11.0,
                                          letterSpacing: -0.22,
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                  Text(
                                    '#${valueOrDefault<String>(
                                      functions
                                          .ratingUserLichtwatt(
                                              gamesContainerGamesRowList
                                                  .toList(),
                                              currentUserUid,
                                              Period.woche.name,
                                              RatingGamesFilter.valuable.name,
                                              invitesContainerInvitesRowList
                                                  .toList(),
                                              0)
                                          .toString(),
                                      '0',
                                    )}',
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmallFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          fontSize: 10.0,
                                          letterSpacing: -0.2,
                                          fontWeight: FontWeight.bold,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleSmallIsCustom,
                                        ),
                                  ),
                                ].addToStart(SizedBox(height: 16.0)),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    height: 32.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      borderRadius: BorderRadius.circular(99.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          12.0, 0.0, 12.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            FFIcons.kaward,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                            size: 16.0,
                                          ),
                                          Text(
                                            '#${valueOrDefault<String>(
                                              functions
                                                  .ratingUserGamesByGoodEnergy(
                                                      gamesContainerGamesRowList
                                                          .where((e) =>
                                                              e.status ==
                                                              'completed')
                                                          .toList(),
                                                      currentUserUid,
                                                      Period.gesamt.name)
                                                  .toString(),
                                              '0',
                                            )}',
                                            style: FlutterFlowTheme.of(context)
                                                .titleSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  fontSize: 12.0,
                                                  letterSpacing: -0.24,
                                                  fontWeight: FontWeight.bold,
                                                  lineHeight: 1.5,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmallIsCustom,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    valueOrDefault<String>(
                                      functions.formatCompactWithComma(
                                          valueOrDefault<double>(
                                        functions.totalSumPeriodGoodPower(
                                            gamesContainerGamesRowList
                                                .where((e) =>
                                                    e.creatorUserId ==
                                                    currentUserUid)
                                                .toList(),
                                            Period.monat.name),
                                        0.0,
                                      )),
                                      '0',
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Dela Gothic One',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          fontSize: 16.0,
                                          letterSpacing: -0.56,
                                          lineHeight: 1.5,
                                        ),
                                  ),
                                  Text(
                                    'Diesen Monat',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          fontSize: 11.0,
                                          letterSpacing: -0.22,
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                  Text(
                                    '#${valueOrDefault<String>(
                                      functions
                                          .ratingUserLichtwatt(
                                              gamesContainerGamesRowList
                                                  .toList(),
                                              currentUserUid,
                                              Period.monat.name,
                                              RatingGamesFilter.valuable.name,
                                              invitesContainerInvitesRowList
                                                  .toList(),
                                              0)
                                          .toString(),
                                      '0',
                                    )}',
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmallFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          fontSize: 10.0,
                                          letterSpacing: -0.2,
                                          fontWeight: FontWeight.bold,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleSmallIsCustom,
                                        ),
                                  ),
                                ].addToStart(SizedBox(height: 16.0)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
