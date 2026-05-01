import '/backend/supabase/supabase.dart';
import '/components/dialogs/auth_dialog/auth_dialog_widget.dart';
import '/components/home_page_score/home_page_score_widget.dart';
import '/components/home_page_score_empty/home_page_score_empty_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'home_page_guest_content_widget.dart' show HomePageGuestContentWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePageGuestContentModel
    extends FlutterFlowModel<HomePageGuestContentWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for homePageScore component.
  late HomePageScoreModel homePageScoreModel;
  // Model for homePageScoreEmpty component.
  late HomePageScoreEmptyModel homePageScoreEmptyModel;
  // Stores action output result for [Bottom Sheet - authDialog] action in IconButton widget.
  bool? success;

  @override
  void initState(BuildContext context) {
    homePageScoreModel = createModel(context, () => HomePageScoreModel());
    homePageScoreEmptyModel =
        createModel(context, () => HomePageScoreEmptyModel());
  }

  @override
  void dispose() {
    homePageScoreModel.dispose();
    homePageScoreEmptyModel.dispose();
  }
}
