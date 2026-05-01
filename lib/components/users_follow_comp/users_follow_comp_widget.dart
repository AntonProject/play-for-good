import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'users_follow_comp_model.dart';
export 'users_follow_comp_model.dart';

class UsersFollowCompWidget extends StatefulWidget {
  const UsersFollowCompWidget({
    super.key,
    required this.userId,
  });

  final String? userId;

  @override
  State<UsersFollowCompWidget> createState() => _UsersFollowCompWidgetState();
}

class _UsersFollowCompWidgetState extends State<UsersFollowCompWidget> {
  late UsersFollowCompModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UsersFollowCompModel());

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
                    if ((rowUsersRow?.firstName != null &&
                            rowUsersRow?.firstName != '') ||
                        (rowUsersRow?.surname != null &&
                            rowUsersRow?.surname != ''))
                      Text(
                        valueOrDefault<String>(
                          '${rowUsersRow?.firstName != null && rowUsersRow?.firstName != '' ? rowUsersRow?.firstName : ''} ${rowUsersRow?.surname != null && rowUsersRow?.surname != '' ? rowUsersRow?.surname : ''}',
                          ' unnamed',
                        ),
                        maxLines: 1,
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleLargeFamily,
                              color: FlutterFlowTheme.of(context).primaryText75,
                              fontSize: 14.0,
                              letterSpacing: -0.35,
                              fontWeight: FontWeight.bold,
                              lineHeight: 1.5,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleLargeIsCustom,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ].divide(SizedBox(height: 4.0)),
                ),
              ),
              FutureBuilder<List<FollowersRow>>(
                future: _model.follow(
                  requestFn: () => FollowersTable().querySingleRow(
                    queryFn: (q) => q
                        .eqOrNull(
                          'follower_user_id',
                          currentUserUid,
                        )
                        .eqOrNull(
                          'following_user_id',
                          widget!.userId,
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
                  List<FollowersRow> rowFollowersRowList = snapshot.data!;

                  final rowFollowersRow = rowFollowersRowList.isNotEmpty
                      ? rowFollowersRowList.first
                      : null;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (valueOrDefault<bool>(
                        rowFollowersRow?.id != null &&
                            rowFollowersRow?.id != '',
                        false,
                      ))
                        FlutterFlowIconButton(
                          borderRadius: 8.0,
                          buttonSize: 40.0,
                          icon: Icon(
                            FFIcons.kwishOn,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            await FollowersTable().delete(
                              matchingRows: (rows) => rows.eqOrNull(
                                'id',
                                rowFollowersRow?.id,
                              ),
                            );
                            FFAppState().refreshDate = getCurrentTimestamp;
                            FFAppState().update(() {});
                            _model.clearFollowCache();
                            FFAppState().clearFollowUserCacheKey(
                                '${valueOrDefault<String>(
                              FFAppState().refreshDate?.toString(),
                              '0',
                            )}${currentUserUid}');

                            FFAppState().update(() {});

                            safeSetState(() {});
                          },
                        ),
                      if (valueOrDefault<bool>(
                        rowFollowersRow?.id == null ||
                            rowFollowersRow?.id == '',
                        true,
                      ))
                        FlutterFlowIconButton(
                          borderRadius: 8.0,
                          buttonSize: 40.0,
                          icon: Icon(
                            FFIcons.kwishOff,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            _model.followCreate =
                                await FollowersTable().insert({
                              'created_at':
                                  supaSerialize<DateTime>(getCurrentTimestamp),
                              'follower_user_id': currentUserUid,
                              'following_user_id': widget!.userId,
                              'following_user_name':
                                  '${rowUsersRow?.displayName} ${rowUsersRow?.firstName} ${rowUsersRow?.surname}',
                            });
                            FFAppState().refreshDate = getCurrentTimestamp;
                            FFAppState().update(() {});
                            _model.clearFollowCache();
                            FFAppState().clearFollowUserCacheKey(
                                '${valueOrDefault<String>(
                              FFAppState().refreshDate?.toString(),
                              '0',
                            )}${currentUserUid}');

                            FFAppState().update(() {});

                            safeSetState(() {});
                          },
                        ),
                    ],
                  );
                },
              ),
            ].divide(SizedBox(width: 16.0)),
          ),
        );
      },
    );
  }
}
