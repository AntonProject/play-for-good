import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'apbar_b_g_model.dart';
export 'apbar_b_g_model.dart';

class ApbarBGWidget extends StatefulWidget {
  const ApbarBGWidget({
    super.key,
    required this.title,
    required this.text,
    Color? backgroundColor,
    Color? gradientColor,
  })  : this.backgroundColor = backgroundColor ?? const Color(0xFFE80C37),
        this.gradientColor = gradientColor ?? const Color(0xFFB70B2C);

  final String? title;
  final String? text;
  final Color backgroundColor;
  final Color gradientColor;

  @override
  State<ApbarBGWidget> createState() => _ApbarBGWidgetState();
}

class _ApbarBGWidgetState extends State<ApbarBGWidget> {
  late ApbarBGModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ApbarBGModel());

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

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: 160.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            valueOrDefault<Color>(
              widget!.backgroundColor,
              FlutterFlowTheme.of(context).accent3,
            ),
            valueOrDefault<Color>(
              widget!.gradientColor,
              FlutterFlowTheme.of(context).accent2,
            )
          ],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(1.0, 0.0),
          end: AlignmentDirectional(-1.0, 0),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 60.0, 0.0, 14.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget!.title!,
                    style: FlutterFlowTheme.of(context).labelLarge.override(
                          fontFamily: 'Dela Gothic One',
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          fontSize: 22.0,
                          letterSpacing: 0.0,
                          lineHeight: 1.9,
                        ),
                  ),
                  Text(
                    widget!.text!,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          fontSize: 14.0,
                          letterSpacing: -0.24,
                          fontWeight: FontWeight.normal,
                          lineHeight: 1.5,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<UsersRow>>(
              future: FFAppState().user(
                uniqueQueryKey:
                    '${currentUserUid}${FFAppState().refreshDate?.toString()}',
                requestFn: () => UsersTable().querySingleRow(
                  queryFn: (q) => q.eqOrNull(
                    'id',
                    currentUserUid,
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

                final containerUsersRow = containerUsersRowList.isNotEmpty
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
                                valueOrDefault<String>(
                                  currentUserUid,
                                  'guest',
                                ),
                                ParamType.String,
                              ),
                            }.withoutNulls,
                          );
                        }(),
                      );
                    },
                    child: wrapWithModel(
                      model: _model.imageModel,
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
          ]
              .divide(SizedBox(width: 4.0))
              .addToStart(SizedBox(width: 24.0))
              .addToEnd(SizedBox(width: 24.0)),
        ),
      ),
    );
  }
}
