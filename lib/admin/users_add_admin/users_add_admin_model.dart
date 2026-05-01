import '/admin/drawer_admin/drawer_admin_widget.dart';
import '/admin/header_admin/header_admin_widget.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/dialogs/snack_bar/snack_bar_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'users_add_admin_widget.dart' show UsersAddAdminWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class UsersAddAdminModel extends FlutterFlowModel<UsersAddAdminWidget> {
  ///  Local state fields for this page.

  String? photo;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Custom Action - isAdmin] action in UsersAddAdmin widget.
  bool? admin;
  // Model for DrawerAdmin component.
  late DrawerAdminModel drawerAdminModel1;
  // Model for headerAdmin component.
  late HeaderAdminModel headerAdminModel;
  // Stores action output result for [Custom Action - createUserByAdmin] action in Button widget.
  String? newUser;
  // State field(s) for Column widget.
  ScrollController? columnController;
  bool isDataUploading_uploadDataKn0123 = false;
  FFUploadedFile uploadedLocalFile_uploadDataKn0123 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataKn0123 = '';

  // State field(s) for handle widget.
  FocusNode? handleFocusNode;
  TextEditingController? handleTextController;
  String? Function(BuildContext, String?)? handleTextControllerValidator;
  String? _handleTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Hanlde is required';
    }

    if (val.length < 1) {
      return 'Min 1 symbols';
    }
    if (val.length > 50) {
      return 'Max 50 symbols';
    }
    if (!RegExp('^[a-zA-Z0-9._*-]+\$').hasMatch(val)) {
      return 'Invalid format';
    }
    return null;
  }

  // State field(s) for username widget.
  FocusNode? usernameFocusNode;
  TextEditingController? usernameTextController;
  String? Function(BuildContext, String?)? usernameTextControllerValidator;
  // State field(s) for surname widget.
  FocusNode? surnameFocusNode;
  TextEditingController? surnameTextController;
  String? Function(BuildContext, String?)? surnameTextControllerValidator;
  // State field(s) for info widget.
  FocusNode? infoFocusNode;
  TextEditingController? infoTextController;
  String? Function(BuildContext, String?)? infoTextControllerValidator;
  // State field(s) for gender widget.
  String? genderValue;
  FormFieldController<String>? genderValueController;
  // State field(s) for Instagram widget.
  FocusNode? instagramFocusNode;
  TextEditingController? instagramTextController;
  String? Function(BuildContext, String?)? instagramTextControllerValidator;
  // State field(s) for Facebook widget.
  FocusNode? facebookFocusNode;
  TextEditingController? facebookTextController;
  String? Function(BuildContext, String?)? facebookTextControllerValidator;
  // State field(s) for Youtube widget.
  FocusNode? youtubeFocusNode;
  TextEditingController? youtubeTextController;
  String? Function(BuildContext, String?)? youtubeTextControllerValidator;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  String? _emailTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Email is required';
    }

    if (val.length < 5) {
      return 'Min 5 symbols';
    }
    if (val.length > 50) {
      return 'Max 50 symbols';
    }
    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Invalid format';
    }
    return null;
  }

  // State field(s) for pass widget.
  FocusNode? passFocusNode;
  TextEditingController? passTextController;
  late bool passVisibility;
  String? Function(BuildContext, String?)? passTextControllerValidator;
  String? _passTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (val.length < 6) {
      return 'Min 6 symbols';
    }
    if (val.length > 50) {
      return 'Max 50 symbols';
    }
    if (!RegExp('^[a-zA-Z0-9._*-]+\$').hasMatch(val)) {
      return 'Invalid format';
    }
    return null;
  }

  // State field(s) for State widget.
  FocusNode? stateFocusNode;
  TextEditingController? stateTextController;
  String? Function(BuildContext, String?)? stateTextControllerValidator;
  // State field(s) for City widget.
  FocusNode? cityFocusNode;
  TextEditingController? cityTextController;
  String? Function(BuildContext, String?)? cityTextControllerValidator;
  // State field(s) for PostalCode widget.
  FocusNode? postalCodeFocusNode;
  TextEditingController? postalCodeTextController;
  String? Function(BuildContext, String?)? postalCodeTextControllerValidator;
  // State field(s) for Street widget.
  FocusNode? streetFocusNode;
  TextEditingController? streetTextController;
  String? Function(BuildContext, String?)? streetTextControllerValidator;
  // State field(s) for Housenumber widget.
  FocusNode? housenumberFocusNode;
  TextEditingController? housenumberTextController;
  String? Function(BuildContext, String?)? housenumberTextControllerValidator;
  // Model for DrawerAdmin component.
  late DrawerAdminModel drawerAdminModel2;

  @override
  void initState(BuildContext context) {
    drawerAdminModel1 = createModel(context, () => DrawerAdminModel());
    headerAdminModel = createModel(context, () => HeaderAdminModel());
    columnController = ScrollController();
    handleTextControllerValidator = _handleTextControllerValidator;
    emailTextControllerValidator = _emailTextControllerValidator;
    passVisibility = false;
    passTextControllerValidator = _passTextControllerValidator;
    drawerAdminModel2 = createModel(context, () => DrawerAdminModel());
  }

  @override
  void dispose() {
    drawerAdminModel1.dispose();
    headerAdminModel.dispose();
    columnController?.dispose();
    handleFocusNode?.dispose();
    handleTextController?.dispose();

    usernameFocusNode?.dispose();
    usernameTextController?.dispose();

    surnameFocusNode?.dispose();
    surnameTextController?.dispose();

    infoFocusNode?.dispose();
    infoTextController?.dispose();

    instagramFocusNode?.dispose();
    instagramTextController?.dispose();

    facebookFocusNode?.dispose();
    facebookTextController?.dispose();

    youtubeFocusNode?.dispose();
    youtubeTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    passFocusNode?.dispose();
    passTextController?.dispose();

    stateFocusNode?.dispose();
    stateTextController?.dispose();

    cityFocusNode?.dispose();
    cityTextController?.dispose();

    postalCodeFocusNode?.dispose();
    postalCodeTextController?.dispose();

    streetFocusNode?.dispose();
    streetTextController?.dispose();

    housenumberFocusNode?.dispose();
    housenumberTextController?.dispose();

    drawerAdminModel2.dispose();
  }
}
