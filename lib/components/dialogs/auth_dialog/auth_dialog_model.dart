import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/components/dialogs/snack_bar_light_error/snack_bar_light_error_widget.dart';
import '/components/dialogs/snack_bar_white_success/snack_bar_white_success_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'auth_dialog_widget.dart' show AuthDialogWidget;
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthDialogModel extends FlutterFlowModel<AuthDialogWidget> {
  ///  Local state fields for this component.

  int? tab = 2;

  String? error = 'error';

  bool terms = false;

  bool remember = false;

  int currentAuthStep = 1;

  String? email;

  String? password;

  String? firstName;

  String? username;

  String? actionType;

  bool timerStart = false;

  bool codeError = false;

  ///  State fields for stateful widgets in this component.

  // State field(s) for Column widget.
  ScrollController? columnController;
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
  // Stores action output result for [Custom Action - signUpWithOtp] action in Button widget.
  String? singUp;
  // State field(s) for PinCode widget.
  TextEditingController? pinCodeController;
  FocusNode? pinCodeFocusNode;
  String? Function(BuildContext, String?)? pinCodeControllerValidator;
  // State field(s) for Timer widget.
  final timerInitialTimeMs = 60000;
  int timerMilliseconds = 60000;
  String timerValue = StopWatchTimer.getDisplayTime(
    60000,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  // Stores action output result for [Custom Action - resendOtp] action in Text widget.
  bool? resend;
  // Stores action output result for [Custom Action - verifyOtp] action in Button widget.
  String? verify;
  // Stores action output result for [Custom Action - signInAfterOtpVerification] action in Button widget.
  bool? auth;
  // Stores action output result for [Custom Action - isAdmin] action in Button widget.
  bool? adminLogin;
  // State field(s) for emailLoginPasswordReset widget.
  FocusNode? emailLoginPasswordResetFocusNode;
  TextEditingController? emailLoginPasswordResetTextController;
  String? Function(BuildContext, String?)?
      emailLoginPasswordResetTextControllerValidator;
  // Stores action output result for [Custom Action - sendPasswordResetOtp] action in Button widget.
  String? reset;
  // State field(s) for newPass widget.
  FocusNode? newPassFocusNode;
  TextEditingController? newPassTextController;
  late bool newPassVisibility;
  String? Function(BuildContext, String?)? newPassTextControllerValidator;
  // State field(s) for confirmPass widget.
  FocusNode? confirmPassFocusNode;
  TextEditingController? confirmPassTextController;
  late bool confirmPassVisibility;
  String? Function(BuildContext, String?)? confirmPassTextControllerValidator;
  // Stores action output result for [Custom Action - updatePassword] action in Button widget.
  String? update;
  InstantTimer? instantTimer;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    passSigninVisibility = false;
    passLoginVisibility = false;
    pinCodeController = TextEditingController();
    newPassVisibility = false;
    confirmPassVisibility = false;
  }

  @override
  void dispose() {
    columnController?.dispose();
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    displayNameFocusNode?.dispose();
    displayNameTextController?.dispose();

    emailSigninFocusNode?.dispose();
    emailSigninTextController?.dispose();

    passSigninFocusNode?.dispose();
    passSigninTextController?.dispose();

    emailLoginFocusNode?.dispose();
    emailLoginTextController?.dispose();

    passLoginFocusNode?.dispose();
    passLoginTextController?.dispose();

    pinCodeFocusNode?.dispose();
    pinCodeController?.dispose();

    timerController.dispose();
    emailLoginPasswordResetFocusNode?.dispose();
    emailLoginPasswordResetTextController?.dispose();

    newPassFocusNode?.dispose();
    newPassTextController?.dispose();

    confirmPassFocusNode?.dispose();
    confirmPassTextController?.dispose();

    instantTimer?.cancel();
  }
}
