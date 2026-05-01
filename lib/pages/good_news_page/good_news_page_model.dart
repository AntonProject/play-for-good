import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/apbar_b_g/apbar_b_g_widget.dart';
import '/components/navbar/navbar_widget.dart';
import '/components/post_comp/post_comp_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'good_news_page_widget.dart' show GoodNewsPageWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GoodNewsPageModel extends FlutterFlowModel<GoodNewsPageWidget> {
  ///  Local state fields for this page.

  bool visible = true;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController;
  Stream<List<PostsRow>>? columnSupabaseStream;
  // Model for navbar component.
  late NavbarModel navbarModel;
  // Model for apbarBG component.
  late ApbarBGModel apbarBGModel;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    navbarModel = createModel(context, () => NavbarModel());
    apbarBGModel = createModel(context, () => ApbarBGModel());
  }

  @override
  void dispose() {
    columnController?.dispose();
    navbarModel.dispose();
    apbarBGModel.dispose();
  }
}
