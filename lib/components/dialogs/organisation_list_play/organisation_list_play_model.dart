import '/auth/base_auth_user_provider.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/organisation_comp_play/organisation_comp_play_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'organisation_list_play_widget.dart' show OrganisationListPlayWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OrganisationListPlayModel
    extends FlutterFlowModel<OrganisationListPlayWidget> {
  ///  Local state fields for this component.

  String? guestChosenOrgId;

  ///  State fields for stateful widgets in this component.

  // State field(s) for search widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? Function(BuildContext, String?)? searchTextControllerValidator;
  // State field(s) for Column widget.
  ScrollController? columnController;
  // Stores action output result for [Backend Call - Update Row(s)] action in organisationCompPlay widget.
  List<UsersRow>? updateOrgDel;
  // Stores action output result for [Backend Call - Update Row(s)] action in organisationCompPlay widget.
  List<UsersRow>? updateOrg;
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
