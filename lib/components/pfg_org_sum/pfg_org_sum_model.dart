import '/backend/supabase/supabase.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'pfg_org_sum_widget.dart' show PfgOrgSumWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PfgOrgSumModel extends FlutterFlowModel<PfgOrgSumWidget> {
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
