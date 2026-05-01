import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'users_invites_comp_model.dart';
export 'users_invites_comp_model.dart';

class UsersInvitesCompWidget extends StatefulWidget {
  const UsersInvitesCompWidget({
    super.key,
    required this.userId,
    this.date,
  });

  final String? userId;
  final DateTime? date;

  @override
  State<UsersInvitesCompWidget> createState() => _UsersInvitesCompWidgetState();
}

class _UsersInvitesCompWidgetState extends State<UsersInvitesCompWidget> {
  late UsersInvitesCompModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UsersInvitesCompModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.gamesCount = await actions.gamesCount(
        widget!.userId,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UsersRow>>(
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
                      widget!.userId,
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
                width: 40.0,
                height: 40.0,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: CachedNetworkImage(
                  fadeInDuration: Duration(milliseconds: 500),
                  fadeOutDuration: Duration(milliseconds: 500),
                  imageUrl: valueOrDefault<String>(
                    rowUsersRow?.photoUrl,
                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/c527zeyipzi3/Profilbild.png',
                  ),
                  fit: BoxFit.cover,
                  errorWidget: (context, error, stackTrace) => Image.asset(
                    'assets/images/error_image.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${valueOrDefault<String>(
                        rowUsersRow?.displayName,
                        'unnamed',
                      )}',
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
                      'Registriert seit',
                      maxLines: 2,
                      style: FlutterFlowTheme.of(context).labelMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).labelMediumFamily,
                            letterSpacing: -0.35,
                            fontWeight: FontWeight.w500,
                            lineHeight: 1.5,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .labelMediumIsCustom,
                          ),
                    ),
                    Text(
                      dateTimeFormat(
                        "dd.MM.yyyy",
                        widget!.date,
                        locale: FFLocalizations.of(context).languageCode,
                      ).maybeHandleOverflow(
                        maxChars: 30,
                        replacement: '…',
                      ),
                      maxLines: 2,
                      style: FlutterFlowTheme.of(context).labelMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).labelMediumFamily,
                            letterSpacing: -0.35,
                            fontWeight: FontWeight.w500,
                            lineHeight: 1.5,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .labelMediumIsCustom,
                          ),
                    ),
                  ].divide(SizedBox(height: 4.0)),
                ),
              ),
              Text(
                valueOrDefault<String>(
                  formatNumber(
                    _model.gamesCount,
                    formatType: FormatType.custom,
                    format: '0 Games',
                    locale: '',
                  ),
                  '0 Games',
                ),
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
    );
  }
}
