import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/organisation_comp/organisation_comp_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'organisation_list_widget.dart' show OrganisationListWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OrganisationListModel extends FlutterFlowModel<OrganisationListWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for search widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? Function(BuildContext, String?)? searchTextControllerValidator;
  // State field(s) for Column widget.
  ScrollController? columnController;
  // Model for closeKeyboard component.
  late CloseKeyboardModel closeKeyboardModel;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    closeKeyboardModel = createModel(context, () => CloseKeyboardModel());
  }

  @override
  void dispose() {
    searchFocusNode?.dispose();
    searchTextController?.dispose();

    columnController?.dispose();
    closeKeyboardModel.dispose();
  }
}
