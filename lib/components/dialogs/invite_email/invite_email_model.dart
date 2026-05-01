import '/components/close_keyboard_widget.dart';
import '/components/dialogs/snack_bar/snack_bar_widget.dart';
import '/components/dialogs/snack_bar_light_error/snack_bar_light_error_widget.dart';
import '/components/dialogs/snack_bar_white_success/snack_bar_white_success_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'invite_email_widget.dart' show InviteEmailWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InviteEmailModel extends FlutterFlowModel<InviteEmailWidget> {
  ///  Local state fields for this component.

  bool error = false;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Custom Action - inviteUser] action in IconButton widget.
  String? invite;
  // State field(s) for Column widget.
  ScrollController? columnController;
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

  // Stores action output result for [Custom Action - inviteUser] action in Button widget.
  String? inviteCopy;
  // Model for closeKeyboard component.
  late CloseKeyboardModel closeKeyboardModel;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    textControllerValidator = _textControllerValidator;
    closeKeyboardModel = createModel(context, () => CloseKeyboardModel());
  }

  @override
  void dispose() {
    columnController?.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    closeKeyboardModel.dispose();
  }
}
