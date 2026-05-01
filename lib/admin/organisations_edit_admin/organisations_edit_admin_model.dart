import '/admin/drawer_admin/drawer_admin_widget.dart';
import '/admin/header_admin/header_admin_widget.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'organisations_edit_admin_widget.dart' show OrganisationsEditAdminWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class OrganisationsEditAdminModel
    extends FlutterFlowModel<OrganisationsEditAdminWidget> {
  ///  Local state fields for this page.

  String? photo;

  String? file;

  String? type;

  String? sctructure;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Custom Action - isAdmin] action in OrganisationsEditAdmin widget.
  bool? admin;
  // Model for DrawerAdmin component.
  late DrawerAdminModel drawerAdminModel1;
  // Model for headerAdmin component.
  late HeaderAdminModel headerAdminModel;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<OrganizationRow>? newOrg;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<OrganizationRow>? org;
  // State field(s) for Column widget.
  ScrollController? columnController;
  bool isDataUploading_uploadDataKn01 = false;
  FFUploadedFile uploadedLocalFile_uploadDataKn01 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataKn01 = '';

  // State field(s) for handle widget.
  FocusNode? handleFocusNode;
  TextEditingController? handleTextController;
  String? Function(BuildContext, String?)? handleTextControllerValidator;
  String? _handleTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Hanlde is required';
    }

    if (val.length < 1) {
      return 'Min 1 symbol';
    }
    if (val.length > 50) {
      return 'Max 50 symbols';
    }
    if (!RegExp('^[a-zA-Z0-9._*-]+\$').hasMatch(val)) {
      return 'Invalid format';
    }
    return null;
  }

  // State field(s) for Organizationname widget.
  FocusNode? organizationnameFocusNode;
  TextEditingController? organizationnameTextController;
  String? Function(BuildContext, String?)?
      organizationnameTextControllerValidator;
  String? _organizationnameTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Name is required';
    }

    if (val.length < 1) {
      return 'Min 1 symbol';
    }
    if (val.length > 100) {
      return 'Max 100 symbols';
    }

    return null;
  }

  // State field(s) for categoryDD widget.
  List<String>? categoryDDValue;
  FormFieldController<List<String>>? categoryDDValueController;
  // State field(s) for Description widget.
  FocusNode? descriptionFocusNode;
  TextEditingController? descriptionTextController;
  String? Function(BuildContext, String?)? descriptionTextControllerValidator;
  // State field(s) for Websiteurl widget.
  FocusNode? websiteurlFocusNode;
  TextEditingController? websiteurlTextController;
  String? Function(BuildContext, String?)? websiteurlTextControllerValidator;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for typeDD widget.
  String? typeDDValue;
  FormFieldController<String>? typeDDValueController;
  // State field(s) for sctructureDD widget.
  String? sctructureDDValue;
  FormFieldController<String>? sctructureDDValueController;
  // State field(s) for Regnumber widget.
  FocusNode? regnumberFocusNode;
  TextEditingController? regnumberTextController;
  String? Function(BuildContext, String?)? regnumberTextControllerValidator;
  bool isDataUploading_uploadFile = false;
  FFUploadedFile uploadedLocalFile_uploadFile =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadFile = '';

  // State field(s) for hideSwitch widget.
  bool? hideSwitchValue;
  // State field(s) for stripeLive widget.
  FocusNode? stripeLiveFocusNode;
  TextEditingController? stripeLiveTextController;
  String? Function(BuildContext, String?)? stripeLiveTextControllerValidator;
  // State field(s) for stripeTest widget.
  FocusNode? stripeTestFocusNode;
  TextEditingController? stripeTestTextController;
  String? Function(BuildContext, String?)? stripeTestTextControllerValidator;
  // State field(s) for contactName widget.
  FocusNode? contactNameFocusNode;
  TextEditingController? contactNameTextController;
  String? Function(BuildContext, String?)? contactNameTextControllerValidator;
  String? _contactNameTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Contact name is required';
    }

    if (val.length < 1) {
      return 'Min 1 symbol';
    }
    if (val.length > 50) {
      return 'Max 50 symbols';
    }

    return null;
  }

  // State field(s) for contactSurname widget.
  FocusNode? contactSurnameFocusNode;
  TextEditingController? contactSurnameTextController;
  String? Function(BuildContext, String?)?
      contactSurnameTextControllerValidator;
  String? _contactSurnameTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Contact surname is required';
    }

    if (val.length < 1) {
      return 'Min 1 symbol';
    }
    if (val.length > 50) {
      return 'Max 50 symbols';
    }

    return null;
  }

  // State field(s) for contactEmail widget.
  FocusNode? contactEmailFocusNode;
  TextEditingController? contactEmailTextController;
  String? Function(BuildContext, String?)? contactEmailTextControllerValidator;
  String? _contactEmailTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Contact email is required';
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

  // State field(s) for street widget.
  FocusNode? streetFocusNode;
  TextEditingController? streetTextController;
  String? Function(BuildContext, String?)? streetTextControllerValidator;
  // State field(s) for house widget.
  FocusNode? houseFocusNode;
  TextEditingController? houseTextController;
  String? Function(BuildContext, String?)? houseTextControllerValidator;
  // State field(s) for postal widget.
  FocusNode? postalFocusNode;
  TextEditingController? postalTextController;
  String? Function(BuildContext, String?)? postalTextControllerValidator;
  // State field(s) for City widget.
  FocusNode? cityFocusNode;
  TextEditingController? cityTextController;
  String? Function(BuildContext, String?)? cityTextControllerValidator;
  // State field(s) for country widget.
  FocusNode? countryFocusNode;
  TextEditingController? countryTextController;
  String? Function(BuildContext, String?)? countryTextControllerValidator;
  // Model for DrawerAdmin component.
  late DrawerAdminModel drawerAdminModel2;

  @override
  void initState(BuildContext context) {
    drawerAdminModel1 = createModel(context, () => DrawerAdminModel());
    headerAdminModel = createModel(context, () => HeaderAdminModel());
    columnController = ScrollController();
    handleTextControllerValidator = _handleTextControllerValidator;
    organizationnameTextControllerValidator =
        _organizationnameTextControllerValidator;
    contactNameTextControllerValidator = _contactNameTextControllerValidator;
    contactSurnameTextControllerValidator =
        _contactSurnameTextControllerValidator;
    contactEmailTextControllerValidator = _contactEmailTextControllerValidator;
    drawerAdminModel2 = createModel(context, () => DrawerAdminModel());
  }

  @override
  void dispose() {
    drawerAdminModel1.dispose();
    headerAdminModel.dispose();
    columnController?.dispose();
    handleFocusNode?.dispose();
    handleTextController?.dispose();

    organizationnameFocusNode?.dispose();
    organizationnameTextController?.dispose();

    descriptionFocusNode?.dispose();
    descriptionTextController?.dispose();

    websiteurlFocusNode?.dispose();
    websiteurlTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    regnumberFocusNode?.dispose();
    regnumberTextController?.dispose();

    stripeLiveFocusNode?.dispose();
    stripeLiveTextController?.dispose();

    stripeTestFocusNode?.dispose();
    stripeTestTextController?.dispose();

    contactNameFocusNode?.dispose();
    contactNameTextController?.dispose();

    contactSurnameFocusNode?.dispose();
    contactSurnameTextController?.dispose();

    contactEmailFocusNode?.dispose();
    contactEmailTextController?.dispose();

    streetFocusNode?.dispose();
    streetTextController?.dispose();

    houseFocusNode?.dispose();
    houseTextController?.dispose();

    postalFocusNode?.dispose();
    postalTextController?.dispose();

    cityFocusNode?.dispose();
    cityTextController?.dispose();

    countryFocusNode?.dispose();
    countryTextController?.dispose();

    drawerAdminModel2.dispose();
  }
}
