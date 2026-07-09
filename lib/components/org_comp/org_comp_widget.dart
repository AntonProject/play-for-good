import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'org_comp_model.dart';
export 'org_comp_model.dart';

class OrgCompWidget extends StatefulWidget {
  const OrgCompWidget({
    super.key,
    String? image,
    required this.title,
    required this.desc,
    required this.sum,
  }) : this.image = image ??
            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/d6ilkv8n1ka3/Avatar.png';

  final String image;
  final String? title;
  final String? desc;
  final double? sum;

  @override
  State<OrgCompWidget> createState() => _OrgCompWidgetState();
}

class _OrgCompWidgetState extends State<OrgCompWidget> {
  late OrgCompModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrgCompModel());

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
                  widget!.image,
                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/d6ilkv8n1ka3/Avatar.png',
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 4.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valueOrDefault<String>(
                      widget!.title,
                      'Blau-Gelbes Kreuz ...',
                    ),
                    maxLines: 3,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          fontSize: 16.0,
                          letterSpacing: -0.4,
                          fontWeight: FontWeight.bold,
                          lineHeight: 1.1,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    valueOrDefault<String>(
                      widget!.desc,
                      'Erspielte Punkte',
                    ),
                    maxLines: 4,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          fontSize: 14.0,
                          letterSpacing: -0.35,
                          fontWeight: FontWeight.w500,
                          lineHeight: 1.2,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
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
                '${functions.numFormat(valueOrDefault<String>(
                  widget!.sum?.toString(),
                  '0',
                ))} €',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleMediumFamily,
                      letterSpacing: -0.63,
                      fontWeight: FontWeight.bold,
                      lineHeight: 1.5,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleMediumIsCustom,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
