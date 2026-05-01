import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'organisation_comp_model.dart';
export 'organisation_comp_model.dart';

class OrganisationCompWidget extends StatefulWidget {
  const OrganisationCompWidget({
    super.key,
    required this.orgRow,
    required this.buttonText,
  });

  final OrganizationRow? orgRow;
  final String? buttonText;

  @override
  State<OrganisationCompWidget> createState() => _OrganisationCompWidgetState();
}

class _OrganisationCompWidgetState extends State<OrganisationCompWidget> {
  late OrganisationCompModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrganisationCompModel());

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
              widget!.orgRow?.id,
              ParamType.String,
            ),
          }.withoutNulls,
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
                widget!.orgRow?.imageUrl,
                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/d6ilkv8n1ka3/Avatar.png',
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
                  valueOrDefault<String>(
                    widget!.orgRow?.title,
                    'unnamed',
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
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget!.orgRow?.city != null && widget!.orgRow?.city != '')
                  Text(
                    widget!.orgRow!.city!,
                    maxLines: 1,
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleLargeFamily,
                          color: FlutterFlowTheme.of(context).primaryText75,
                          fontSize: 14.0,
                          letterSpacing: valueOrDefault<double>(
                            -0.35,
                            -0.35,
                          ),
                          fontWeight: FontWeight.bold,
                          lineHeight: 1.5,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleLargeIsCustom,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (loggedIn)
            FutureBuilder<List<FollowersRow>>(
              future: _model.follow(
                uniqueQueryKey:
                    '${widget!.orgRow?.id}${FFAppState().refreshDate?.toString()}',
                requestFn: () => FollowersTable().querySingleRow(
                  queryFn: (q) => q
                      .eqOrNull(
                        'follower_user_id',
                        currentUserUid,
                      )
                      .eqOrNull(
                        'following_organization_id',
                        widget!.orgRow?.id,
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
                      rowFollowersRow?.id != null && rowFollowersRow?.id != '',
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
                          FFAppState().clearFollowUserCache();

                          FFAppState().update(() {});

                          safeSetState(() {});
                        },
                      ),
                    if (valueOrDefault<bool>(
                      rowFollowersRow?.id == null || rowFollowersRow?.id == '',
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
                          _model.followCreate = await FollowersTable().insert({
                            'created_at':
                                supaSerialize<DateTime>(getCurrentTimestamp),
                            'follower_user_id': currentUserUid,
                            'following_organization_id': widget!.orgRow?.id,
                            'following_organization_name':
                                '${widget!.orgRow?.title} ${widget!.orgRow?.displayName}',
                          });
                          FFAppState().refreshDate = getCurrentTimestamp;
                          FFAppState().update(() {});
                          _model.clearFollowCache();
                          FFAppState().clearFollowUserCache();

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
  }
}
