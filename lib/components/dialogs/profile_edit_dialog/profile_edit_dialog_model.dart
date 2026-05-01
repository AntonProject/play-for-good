import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/dialogs/delete_acc_dialog/delete_acc_dialog_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'profile_edit_dialog_widget.dart' show ProfileEditDialogWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileEditDialogModel extends FlutterFlowModel<ProfileEditDialogWidget> {
  ///  Local state fields for this component.

  String? photo;

  bool showUsername = false;

  ///  State fields for stateful widgets in this component.

  // State field(s) for Column widget.
  ScrollController? columnController;
  bool isDataUploading_uploadDataKn0 = false;
  FFUploadedFile uploadedLocalFile_uploadDataKn0 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataKn0 = '';

  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for displayname widget.
  FocusNode? displaynameFocusNode;
  TextEditingController? displaynameTextController;
  String? Function(BuildContext, String?)? displaynameTextControllerValidator;
  // State field(s) for name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  // State field(s) for surname widget.
  FocusNode? surnameFocusNode;
  TextEditingController? surnameTextController;
  String? Function(BuildContext, String?)? surnameTextControllerValidator;
  // State field(s) for desc widget.
  FocusNode? descFocusNode;
  TextEditingController? descTextController;
  String? Function(BuildContext, String?)? descTextControllerValidator;
  // State field(s) for inst widget.
  FocusNode? instFocusNode;
  TextEditingController? instTextController;
  String? Function(BuildContext, String?)? instTextControllerValidator;
  // State field(s) for facebook widget.
  FocusNode? facebookFocusNode;
  TextEditingController? facebookTextController;
  String? Function(BuildContext, String?)? facebookTextControllerValidator;
  // State field(s) for youtube widget.
  FocusNode? youtubeFocusNode;
  TextEditingController? youtubeTextController;
  String? Function(BuildContext, String?)? youtubeTextControllerValidator;
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
    emailFocusNode?.dispose();
    emailTextController?.dispose();

    displaynameFocusNode?.dispose();
    displaynameTextController?.dispose();

    nameFocusNode?.dispose();
    nameTextController?.dispose();

    surnameFocusNode?.dispose();
    surnameTextController?.dispose();

    descFocusNode?.dispose();
    descTextController?.dispose();

    instFocusNode?.dispose();
    instTextController?.dispose();

    facebookFocusNode?.dispose();
    facebookTextController?.dispose();

    youtubeFocusNode?.dispose();
    youtubeTextController?.dispose();

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
