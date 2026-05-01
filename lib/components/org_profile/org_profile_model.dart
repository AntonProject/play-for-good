import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'org_profile_widget.dart' show OrgProfileWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OrgProfileModel extends FlutterFlowModel<OrgProfileWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Image component.
  late ImageModel imageModel;

  @override
  void initState(BuildContext context) {
    imageModel = createModel(context, () => ImageModel());
  }

  @override
  void dispose() {
    imageModel.dispose();
  }
}
