import '/auth/supabase_auth/auth_util.dart';
import '/components/dialogs/snack_bar/snack_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'login_widget.dart' show LoginWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginModel extends FlutterFlowModel<LoginWidget> {
  ///  Local state fields for this page.

  int? tab = 2;

  String? error = 'error';

  bool terms = false;

  bool remember = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController1;
  // State field(s) for name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  // State field(s) for display_name widget.
  FocusNode? displayNameFocusNode;
  TextEditingController? displayNameTextController;
  String? Function(BuildContext, String?)? displayNameTextControllerValidator;
  // State field(s) for emailSignin widget.
  FocusNode? emailSigninFocusNode;
  TextEditingController? emailSigninTextController;
  String? Function(BuildContext, String?)? emailSigninTextControllerValidator;
  // State field(s) for passSignin widget.
  FocusNode? passSigninFocusNode;
  TextEditingController? passSigninTextController;
  late bool passSigninVisibility;
  String? Function(BuildContext, String?)? passSigninTextControllerValidator;
  // Stores action output result for [Custom Action - signUpWithOtp] action in Button widget.
  String? singUp;
  // State field(s) for Column widget.
  ScrollController? columnController2;
  // State field(s) for emailLogin widget.
  FocusNode? emailLoginFocusNode;
  TextEditingController? emailLoginTextController;
  String? Function(BuildContext, String?)? emailLoginTextControllerValidator;
  // State field(s) for passLogin widget.
  FocusNode? passLoginFocusNode;
  TextEditingController? passLoginTextController;
  late bool passLoginVisibility;
  String? Function(BuildContext, String?)? passLoginTextControllerValidator;
  // Stores action output result for [Custom Action - sendSignInOtp] action in Button widget.
  String? login;

  @override
  void initState(BuildContext context) {
    columnController1 = ScrollController();
    passSigninVisibility = false;
    columnController2 = ScrollController();
    passLoginVisibility = false;
  }

  @override
  void dispose() {
    columnController1?.dispose();
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    displayNameFocusNode?.dispose();
    displayNameTextController?.dispose();

    emailSigninFocusNode?.dispose();
    emailSigninTextController?.dispose();

    passSigninFocusNode?.dispose();
    passSigninTextController?.dispose();

    columnController2?.dispose();
    emailLoginFocusNode?.dispose();
    emailLoginTextController?.dispose();

    passLoginFocusNode?.dispose();
    passLoginTextController?.dispose();
  }
}
