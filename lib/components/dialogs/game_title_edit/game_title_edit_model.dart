import '/backend/schema/structs/index.dart';
import '/components/close_keyboard_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'game_title_edit_widget.dart' show GameTitleEditWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GameTitleEditModel extends FlutterFlowModel<GameTitleEditWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  String? _textControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'title is required';
    }

    if (val.length > 50) {
      return 'Maximal 50 Zeichen';
    }

    return null;
  }

  // Model for closeKeyboard component.
  late CloseKeyboardModel closeKeyboardModel;

  @override
  void initState(BuildContext context) {
    textControllerValidator = _textControllerValidator;
    closeKeyboardModel = createModel(context, () => CloseKeyboardModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();

    closeKeyboardModel.dispose();
  }
}
