import '/auth/supabase_auth/auth_util.dart';
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
import 'games_user_comp_model.dart';
export 'games_user_comp_model.dart';

class GamesUserCompWidget extends StatefulWidget {
  const GamesUserCompWidget({
    super.key,
    required this.userId,
    int? rating,
    required this.games,
    required this.invites,
    String? value,
    String? period,
  })  : this.rating = rating ?? 1,
        this.value = value ?? 'valuable',
        this.period = period ?? 'gesamt';

  final String? userId;
  final int rating;
  final List<GamesRow>? games;
  final List<InvitesRow>? invites;
  final String value;
  final String period;

  @override
  State<GamesUserCompWidget> createState() => _GamesUserCompWidgetState();
}

class _GamesUserCompWidgetState extends State<GamesUserCompWidget> {
  late GamesUserCompModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GamesUserCompModel());

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
      child: FutureBuilder<List<UsersRow>>(
        future: UsersTable().querySingleRow(
          queryFn: (q) => q.eqOrNull(
            'id',
            widget!.userId,
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
          List<UsersRow> rowUsersRowList = snapshot.data!;

          final rowUsersRow =
              rowUsersRowList.isNotEmpty ? rowUsersRowList.first : null;

          return InkWell(
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
                        rowUsersRow?.id,
                        ParamType.String,
                      ),
                    }.withoutNulls,
                  );
                }(),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30.0,
                  decoration: BoxDecoration(),
                  child: Text(
                    valueOrDefault<String>(
                      widget!.rating.toString(),
                      '1',
                    ),
                    maxLines: 1,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          color: valueOrDefault<Color>(
                            rowUsersRow?.id == currentUserUid
                                ? FlutterFlowTheme.of(context).primary
                                : FlutterFlowTheme.of(context).primaryText,
                            FlutterFlowTheme.of(context).primaryText,
                          ),
                          fontSize: 14.0,
                          letterSpacing: -0.35,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.5,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                        ),
                  ),
                ),
                Expanded(
                  flex: 6,
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
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                          ),
                        ),
                        child: wrapWithModel(
                          model: _model.imageModel,
                          updateCallback: () => safeSetState(() {}),
                          child: ImageWidget(
                            size: 40.0,
                            image: valueOrDefault<String>(
                              rowUsersRow?.photoUrl,
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          valueOrDefault<String>(
                            rowUsersRow?.displayName,
                            'unnamed',
                          ),
                          maxLines: 4,
                          style: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleSmallFamily,
                                color: valueOrDefault<Color>(
                                  rowUsersRow?.id == currentUserUid
                                      ? FlutterFlowTheme.of(context).primary
                                      : FlutterFlowTheme.of(context)
                                          .primaryText,
                                  FlutterFlowTheme.of(context).primaryText,
                                ),
                                fontSize: 16.0,
                                letterSpacing: -0.4,
                                fontWeight: FontWeight.bold,
                                lineHeight: 1.1,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .titleSmallIsCustom,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ].divide(SizedBox(width: 16.0)),
                  ),
                ),
                Flexible(
                  child: Align(
                    alignment: AlignmentDirectional(1.0, 0.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 0.0),
                      child: Text(
                        valueOrDefault<String>(
                          functions.formatCompactWithComma(
                              functions.getUserRatingScore(
                                  widget!.games
                                      ?.where((e) =>
                                          (e.status == 'completed') &&
                                          (e.creatorUserId == widget!.userId))
                                      .toList()
                                      ?.toList(),
                                  widget!.period,
                                  widget!.value,
                                  widget!.invites?.toList(),
                                  widget!.userId!)!),
                          '0',
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        style: FlutterFlowTheme.of(context)
                            .titleMedium
                            .override(
                              fontFamily: FlutterFlowTheme.of(context)
                                  .titleMediumFamily,
                              color: valueOrDefault<Color>(
                                rowUsersRow?.id == currentUserUid
                                    ? FlutterFlowTheme.of(context).primary
                                    : FlutterFlowTheme.of(context).primaryText,
                                FlutterFlowTheme.of(context).primaryText,
                              ),
                              fontSize: 16.0,
                              letterSpacing: -0.4,
                              fontWeight: FontWeight.bold,
                              lineHeight: 1.5,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleMediumIsCustom,
                            ),
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
