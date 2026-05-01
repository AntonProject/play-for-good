import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'login_admin_widget.dart' show LoginAdminWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginAdminModel extends FlutterFlowModel<LoginAdminWidget> {
  ///  Local state fields for this page.

  int? tab = 1;

  String? error = '';

  bool terms = false;

  bool remember = false;

  ///  State fields for stateful widgets in this page.

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
  String? loginAdmin;

  @override
  void initState(BuildContext context) {
    passLoginVisibility = false;
  }

  @override
  void dispose() {
    emailLoginFocusNode?.dispose();
    emailLoginTextController?.dispose();

    passLoginFocusNode?.dispose();
    passLoginTextController?.dispose();
  }
}
