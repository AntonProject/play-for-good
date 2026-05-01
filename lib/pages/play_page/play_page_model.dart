import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/dialogs/cancel_game_dialog/cancel_game_dialog_widget.dart';
import '/components/dialogs/game_title_edit/game_title_edit_widget.dart';
import '/components/dialogs/organisation_list_play/organisation_list_play_widget.dart';
import '/components/dialogs/types_points/types_points_widget.dart';
import '/components/dialogs/types_points_single/types_points_single_widget.dart';
import '/components/image/image_widget.dart';
import '/components/pfg_org_sum/pfg_org_sum_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'play_page_widget.dart' show PlayPageWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PlayPageModel extends FlutterFlowModel<PlayPageWidget> {
  ///  Local state fields for this page.

  List<String> chosenPoints = ['user'];
  void addToChosenPoints(String item) => chosenPoints.add(item);
  void removeFromChosenPoints(String item) => chosenPoints.remove(item);
  void removeAtIndexFromChosenPoints(int index) => chosenPoints.removeAt(index);
  void insertAtIndexInChosenPoints(int index, String item) =>
      chosenPoints.insert(index, item);
  void updateChosenPointsAtIndex(int index, Function(String) updateFn) =>
      chosenPoints[index] = updateFn(chosenPoints[index]);

  GameStruct? game;
  void updateGameStruct(Function(GameStruct) updateFn) {
    updateFn(game ??= GameStruct());
  }

  bool visible = true;

  ///  State fields for stateful widgets in this page.

  Stream<List<UsersRow>>? stackSupabaseStream;
  // State field(s) for Column widget.
  ScrollController? columnController1;
  // Model for Image component.
  late ImageModel imageModel1;
  // Model for Image component.
  late ImageModel imageModel2;
  // State field(s) for userPoints widget.
  FocusNode? userPointsFocusNode1;
  TextEditingController? userPointsTextController1;
  String? Function(BuildContext, String?)? userPointsTextController1Validator;
  // State field(s) for teamPoints widget.
  FocusNode? teamPointsFocusNode1;
  TextEditingController? teamPointsTextController1;
  String? Function(BuildContext, String?)? teamPointsTextController1Validator;
  // Model for pfgOrgSum component.
  late PfgOrgSumModel pfgOrgSumModel1;
  // Model for closeKeyboard component.
  late CloseKeyboardModel closeKeyboardModel1;
  // State field(s) for Column widget.
  ScrollController? columnController2;
  // Model for Image component.
  late ImageModel imageModel3;
  // Model for Image component.
  late ImageModel imageModel4;
  // State field(s) for userPoints widget.
  FocusNode? userPointsFocusNode2;
  TextEditingController? userPointsTextController2;
  String? Function(BuildContext, String?)? userPointsTextController2Validator;
  // State field(s) for teamPoints widget.
  FocusNode? teamPointsFocusNode2;
  TextEditingController? teamPointsTextController2;
  String? Function(BuildContext, String?)? teamPointsTextController2Validator;
  // Model for pfgOrgSum component.
  late PfgOrgSumModel pfgOrgSumModel2;
  // Model for closeKeyboard component.
  late CloseKeyboardModel closeKeyboardModel2;

  @override
  void initState(BuildContext context) {
    columnController1 = ScrollController();
    imageModel1 = createModel(context, () => ImageModel());
    imageModel2 = createModel(context, () => ImageModel());
    pfgOrgSumModel1 = createModel(context, () => PfgOrgSumModel());
    closeKeyboardModel1 = createModel(context, () => CloseKeyboardModel());
    columnController2 = ScrollController();
    imageModel3 = createModel(context, () => ImageModel());
    imageModel4 = createModel(context, () => ImageModel());
    pfgOrgSumModel2 = createModel(context, () => PfgOrgSumModel());
    closeKeyboardModel2 = createModel(context, () => CloseKeyboardModel());
  }

  @override
  void dispose() {
    columnController1?.dispose();
    imageModel1.dispose();
    imageModel2.dispose();
    userPointsFocusNode1?.dispose();
    userPointsTextController1?.dispose();

    teamPointsFocusNode1?.dispose();
    teamPointsTextController1?.dispose();

    pfgOrgSumModel1.dispose();
    closeKeyboardModel1.dispose();
    columnController2?.dispose();
    imageModel3.dispose();
    imageModel4.dispose();
    userPointsFocusNode2?.dispose();
    userPointsTextController2?.dispose();

    teamPointsFocusNode2?.dispose();
    teamPointsTextController2?.dispose();

    pfgOrgSumModel2.dispose();
    closeKeyboardModel2.dispose();
  }
}
