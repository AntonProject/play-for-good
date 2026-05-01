import '/auth/base_auth_user_provider.dart';
import '/backend/supabase/supabase.dart';
import '/components/org_profile/org_profile_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'profile_games_orgs_dialog_model.dart';
export 'profile_games_orgs_dialog_model.dart';

class ProfileGamesOrgsDialogWidget extends StatefulWidget {
  const ProfileGamesOrgsDialogWidget({
    super.key,
    this.userId,
  });

  final String? userId;

  @override
  State<ProfileGamesOrgsDialogWidget> createState() =>
      _ProfileGamesOrgsDialogWidgetState();
}

class _ProfileGamesOrgsDialogWidgetState
    extends State<ProfileGamesOrgsDialogWidget> {
  late ProfileGamesOrgsDialogModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileGamesOrgsDialogModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Align(
          alignment: AlignmentDirectional(0.0, 1.0),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 600.0,
              maxHeight: MediaQuery.sizeOf(context).height * 0.95,
            ),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Color(0x19000000),
                  offset: Offset(
                    0.0,
                    -2.0,
                  ),
                  spreadRadius: 2.0,
                )
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: FutureBuilder<List<GamesRow>>(
              future: GamesTable().queryRows(
                queryFn: (q) => q.eqOrNull(
                  'creator_user_id',
                  widget!.userId,
                ),
              ),
              builder: (context, snapshot) {
                // Customize what your widget looks like when it's loading.
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                  );
                }
                List<GamesRow> containerGamesRowList = snapshot.data!;

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 2.0,
                        color: Color(0x10000000),
                        offset: Offset(
                          0.0,
                          -2.0,
                        ),
                        spreadRadius: 2.0,
                      )
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              4.0, 0.0, 4.0, 12.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      56.0, 0.0, 0.0, 0.0),
                                  child: Text(
                                    'Organisationen',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'DM Sans',
                                          fontSize: 20.0,
                                          letterSpacing: valueOrDefault<double>(
                                            -0.8,
                                            -0.8,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 1.4,
                                        ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 56.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(99.0),
                                ),
                                child: FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 99.0,
                                  buttonSize: 40.0,
                                  fillColor:
                                      FlutterFlowTheme.of(context).alternate,
                                  icon: Icon(
                                    FFIcons.kcheck2,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 14.0,
                                  ),
                                  showLoadingIndicator: true,
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 16.0, 0.0, 0.0),
                          child: FutureBuilder<List<OrganizationRow>>(
                            future: OrganizationTable().queryRows(
                              queryFn: (q) => q
                                  .eqOrNull(
                                    'test',
                                    FFDevEnvironmentValues().test,
                                  )
                                  .eqOrNull(
                                    'hide',
                                    false,
                                  )
                                  .eqOrNull(
                                    'sponsor',
                                    false,
                                  ),
                            ),
                            builder: (context, snapshot) {
                              // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SizedBox(
                                    width: 20.0,
                                    height: 20.0,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              List<OrganizationRow>
                                  containerOrganizationRowList = snapshot.data!;

                              return Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12.0, 32.0, 12.0, 32.0),
                                  child: Builder(
                                    builder: (context) {
                                      final organizations = functions
                                          .getOrgIdsSortedByGamesCount(
                                              containerGamesRowList.toList())
                                          .toList()
                                          .take(5)
                                          .toList();

                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children:
                                            List.generate(organizations.length,
                                                (organizationsIndex) {
                                          final organizationsItem =
                                              organizations[organizationsIndex];
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 16.0, 0.0, 16.0),
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    if (loggedIn) {
                                                      context.pushNamed(
                                                        OrganisationPageWidget
                                                            .routeName,
                                                        queryParameters: {
                                                          'orgId':
                                                              serializeParam(
                                                            organizationsItem,
                                                            ParamType.String,
                                                          ),
                                                        }.withoutNulls,
                                                      );
                                                    }
                                                  },
                                                  child: OrgProfileWidget(
                                                    key: Key(
                                                        'Keye38_${organizationsIndex}_of_${organizations.length}'),
                                                    image:
                                                        valueOrDefault<String>(
                                                      containerOrganizationRowList
                                                          .where((e) =>
                                                              e.id ==
                                                              organizationsItem)
                                                          .toList()
                                                          .firstOrNull
                                                          ?.imageUrl,
                                                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/d6ilkv8n1ka3/Avatar.png',
                                                    ),
                                                    title:
                                                        valueOrDefault<String>(
                                                      containerGamesRowList
                                                          .where((e) =>
                                                              e.organizationId ==
                                                              organizationsItem)
                                                          .toList()
                                                          .firstOrNull
                                                          ?.orgName,
                                                      'Organisation',
                                                    ),
                                                    goodGamesCount:
                                                        valueOrDefault<int>(
                                                      containerGamesRowList
                                                          .where((e) =>
                                                              e.organizationId ==
                                                              organizationsItem)
                                                          .toList()
                                                          .length,
                                                      1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
