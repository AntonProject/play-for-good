import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'org_profile_model.dart';
export 'org_profile_model.dart';

class OrgProfileWidget extends StatefulWidget {
  const OrgProfileWidget({
    super.key,
    String? image,
    required this.title,
    required this.goodGamesCount,
  }) : this.image = image ??
            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/play-for-good-o0lpcq/assets/d6ilkv8n1ka3/Avatar.png';

  final String image;
  final String? title;
  final int? goodGamesCount;

  @override
  State<OrgProfileWidget> createState() => _OrgProfileWidgetState();
}

class _OrgProfileWidgetState extends State<OrgProfileWidget> {
  late OrgProfileModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrgProfileModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
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
              Text(
                '${valueOrDefault<String>(
                  widget!.goodGamesCount?.toString(),
                  '1',
                )}${widget!.goodGamesCount == 1 ? ' Good Game' : ' Good Games'}',
                maxLines: 4,
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                      fontSize: 14.0,
                      letterSpacing: valueOrDefault<double>(
                        -0.35,
                        -0.35,
                      ),
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
      ].divide(SizedBox(width: 16.0)),
    );
  }
}
