import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'organisation_comp_play_model.dart';
export 'organisation_comp_play_model.dart';

class OrganisationCompPlayWidget extends StatefulWidget {
  const OrganisationCompPlayWidget({
    super.key,
    required this.orgRow,
    this.selectedOrgId,
    this.update,
  });

  final OrganizationRow? orgRow;
  final String? selectedOrgId;
  final Future Function()? update;

  @override
  State<OrganisationCompPlayWidget> createState() =>
      _OrganisationCompPlayWidgetState();
}

class _OrganisationCompPlayWidgetState
    extends State<OrganisationCompPlayWidget> {
  late OrganisationCompPlayModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrganisationCompPlayModel());

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
        await widget.update?.call();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
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
            child: Container(
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
                        fontSize: 16.0,
                        letterSpacing: valueOrDefault<double>(
                          -0.4,
                          -0.4,
                        ),
                        fontWeight: FontWeight.bold,
                        lineHeight: 1.1,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget!.orgRow?.city != null && widget!.orgRow?.city != '')
                  Text(
                    widget!.orgRow!.city!,
                    maxLines: 2,
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
                          lineHeight: 1.2,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleLargeIsCustom,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ].divide(SizedBox(height: 2.0)),
            ),
          ),
          Container(
            width: 60.0,
            height: 50.0,
            decoration: BoxDecoration(),
            child: Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Builder(
                builder: (context) {
                  if (widget!.selectedOrgId == widget!.orgRow?.id) {
                    return Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).primaryText,
                          width: 7.0,
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ].divide(SizedBox(width: 16.0)),
      ),
    );
  }
}
