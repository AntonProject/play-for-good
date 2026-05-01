import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'receipt_dialog_widget.dart' show ReceiptDialogWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReceiptDialogModel extends FlutterFlowModel<ReceiptDialogWidget> {
  ///  Local state fields for this component.

  bool error = false;

  ///  State fields for stateful widgets in this component.

  Stream<List<UsersRow>>? containerSupabaseStream;
  // State field(s) for Column widget.
  ScrollController? columnController;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  // State field(s) for surname widget.
  FocusNode? surnameFocusNode;
  TextEditingController? surnameTextController;
  String? Function(BuildContext, String?)? surnameTextControllerValidator;
  // State field(s) for land widget.
  FocusNode? landFocusNode;
  TextEditingController? landTextController;
  String? Function(BuildContext, String?)? landTextControllerValidator;
  // State field(s) for plz widget.
  FocusNode? plzFocusNode;
  TextEditingController? plzTextController;
  String? Function(BuildContext, String?)? plzTextControllerValidator;
  // State field(s) for Stadt widget.
  FocusNode? stadtFocusNode;
  TextEditingController? stadtTextController;
  String? Function(BuildContext, String?)? stadtTextControllerValidator;
  // State field(s) for Strae widget.
  FocusNode? straeFocusNode;
  TextEditingController? straeTextController;
  String? Function(BuildContext, String?)? straeTextControllerValidator;
  // State field(s) for Haus-Nr widget.
  FocusNode? hausNrFocusNode;
  TextEditingController? hausNrTextController;
  String? Function(BuildContext, String?)? hausNrTextControllerValidator;
  // Model for closeKeyboard component.
  late CloseKeyboardModel closeKeyboardModel;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    closeKeyboardModel = createModel(context, () => CloseKeyboardModel());
  }

  @override
  void dispose() {
    columnController?.dispose();
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    surnameFocusNode?.dispose();
    surnameTextController?.dispose();

    landFocusNode?.dispose();
    landTextController?.dispose();

    plzFocusNode?.dispose();
    plzTextController?.dispose();

    stadtFocusNode?.dispose();
    stadtTextController?.dispose();

    straeFocusNode?.dispose();
    straeTextController?.dispose();

    hausNrFocusNode?.dispose();
    hausNrTextController?.dispose();

    closeKeyboardModel.dispose();
  }
}
