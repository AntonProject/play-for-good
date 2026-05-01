import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/close_keyboard_widget.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'types_points_widget.dart' show TypesPointsWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TypesPointsModel extends FlutterFlowModel<TypesPointsWidget> {
  ///  Local state fields for this component.

  String? chosenType;

  GameStruct? gameDT;
  void updateGameDTStruct(Function(GameStruct) updateFn) {
    updateFn(gameDT ??= GameStruct());
  }

  ///  State fields for stateful widgets in this component.

  // Model for Image component.
  late ImageModel imageModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for closeKeyboard component.
  late CloseKeyboardModel closeKeyboardModel;

  @override
  void initState(BuildContext context) {
    imageModel = createModel(context, () => ImageModel());
    closeKeyboardModel = createModel(context, () => CloseKeyboardModel());
  }

  @override
  void dispose() {
    imageModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    closeKeyboardModel.dispose();
  }
}
