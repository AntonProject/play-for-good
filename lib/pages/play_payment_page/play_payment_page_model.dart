import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/dialogs/auth_dialog/auth_dialog_widget.dart';
import '/components/dialogs/cancel_game_dialog/cancel_game_dialog_widget.dart';
import '/components/dialogs/donat_add/donat_add_widget.dart';
import '/components/dialogs/game_title_edit/game_title_edit_widget.dart';
import '/components/dialogs/organisation_list_play/organisation_list_play_widget.dart';
import '/components/dialogs/receipt_dialog/receipt_dialog_widget.dart';
import '/components/dialogs/snack_bar/snack_bar_widget.dart';
import '/components/image/image_widget.dart';
import '/components/organisation_comp/organisation_comp_widget.dart';
import '/components/organizations_home_empty/organizations_home_empty_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'play_payment_page_widget.dart' show PlayPaymentPageWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PlayPaymentPageModel extends FlutterFlowModel<PlayPaymentPageWidget> {
  ///  Local state fields for this page.

  String? paymentType = 'card';

  bool saveMethod = true;

  GameStruct? gamePage;
  void updateGamePageStruct(Function(GameStruct) updateFn) {
    updateFn(gamePage ??= GameStruct());
  }

  bool visible = true;

  /// Show full screen loader while stripe is open
  bool isPaymentProcessing = false;

  bool guestReceiptCheckbox = false;

  ///  State fields for stateful widgets in this page.

  Stream<List<UsersRow>>? stackSupabaseStream;
  // State field(s) for Column widget.
  ScrollController? columnController1;
  // Model for Image component.
  late ImageModel imageModel1;
  // Model for organisationComp component.
  late OrganisationCompModel organisationCompModel1;
  // Model for organizationsHomeEmpty component.
  late OrganizationsHomeEmptyModel organizationsHomeEmptyModel1;
  // State field(s) for name widget.
  FocusNode? nameFocusNode1;
  TextEditingController? nameTextController1;
  String? Function(BuildContext, String?)? nameTextController1Validator;
  // State field(s) for surname widget.
  FocusNode? surnameFocusNode1;
  TextEditingController? surnameTextController1;
  String? Function(BuildContext, String?)? surnameTextController1Validator;
  // State field(s) for emailLogin widget.
  FocusNode? emailLoginFocusNode1;
  TextEditingController? emailLoginTextController1;
  String? Function(BuildContext, String?)? emailLoginTextController1Validator;
  // Stores action output result for [Backend Call - Update Row(s)] action in Row widget.
  List<UsersRow>? receipt;
  // Stores action output result for [Backend Call - Update Row(s)] action in Row widget.
  List<UsersRow>? receipt2;
  // Stores action output result for [Backend Call - Update Row(s)] action in Row widget.
  List<UsersRow>? receipt3;
  // Stores action output result for [Backend Call - Update Row(s)] action in Row widget.
  List<UsersRow>? receipt4;
  // Stores action output result for [Backend Call - Update Row(s)] action in Row widget.
  List<UsersRow>? emailsOld;
  // Stores action output result for [Backend Call - Update Row(s)] action in Row widget.
  List<UsersRow>? emailsOld2;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UsersRow>? emails;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UsersRow>? emails2;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  GamesRow? newGame;
  // Stores action output result for [Backend Call - API (createPaymentCheckout)] action in Button widget.
  ApiCallResponse? paymentStripe1;
  // Stores action output result for [Custom Action - openStripeCheckout] action in Button widget.
  String? gameIdFromStripe;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UsersRow>? nameUpdate;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UsersRow>? paymentMethodUser;
  // Model for closeKeyboard component.
  late CloseKeyboardModel closeKeyboardModel1;
  // State field(s) for Column widget.
  ScrollController? columnController2;
  // Model for Image component.
  late ImageModel imageModel2;
  // Model for organisationComp component.
  late OrganisationCompModel organisationCompModel2;
  // Model for organizationsHomeEmpty component.
  late OrganizationsHomeEmptyModel organizationsHomeEmptyModel2;
  // State field(s) for name widget.
  FocusNode? nameFocusNode2;
  TextEditingController? nameTextController2;
  String? Function(BuildContext, String?)? nameTextController2Validator;
  // State field(s) for surname widget.
  FocusNode? surnameFocusNode2;
  TextEditingController? surnameTextController2;
  String? Function(BuildContext, String?)? surnameTextController2Validator;
  // State field(s) for emailLogin widget.
  FocusNode? emailLoginFocusNode2;
  TextEditingController? emailLoginTextController2;
  String? Function(BuildContext, String?)? emailLoginTextController2Validator;
  // Stores action output result for [Bottom Sheet - authDialog] action in Button widget.
  bool? success;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UsersRow>? userRows;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UsersRow>? updateOrgDel;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UsersRow>? updateOrg;
  // Model for closeKeyboard component.
  late CloseKeyboardModel closeKeyboardModel2;

  @override
  void initState(BuildContext context) {
    columnController1 = ScrollController();
    imageModel1 = createModel(context, () => ImageModel());
    organisationCompModel1 =
        createModel(context, () => OrganisationCompModel());
    organizationsHomeEmptyModel1 =
        createModel(context, () => OrganizationsHomeEmptyModel());
    closeKeyboardModel1 = createModel(context, () => CloseKeyboardModel());
    columnController2 = ScrollController();
    imageModel2 = createModel(context, () => ImageModel());
    organisationCompModel2 =
        createModel(context, () => OrganisationCompModel());
    organizationsHomeEmptyModel2 =
        createModel(context, () => OrganizationsHomeEmptyModel());
    closeKeyboardModel2 = createModel(context, () => CloseKeyboardModel());
  }

  @override
  void dispose() {
    columnController1?.dispose();
    imageModel1.dispose();
    organisationCompModel1.dispose();
    organizationsHomeEmptyModel1.dispose();
    nameFocusNode1?.dispose();
    nameTextController1?.dispose();

    surnameFocusNode1?.dispose();
    surnameTextController1?.dispose();

    emailLoginFocusNode1?.dispose();
    emailLoginTextController1?.dispose();

    closeKeyboardModel1.dispose();
    columnController2?.dispose();
    imageModel2.dispose();
    organisationCompModel2.dispose();
    organizationsHomeEmptyModel2.dispose();
    nameFocusNode2?.dispose();
    nameTextController2?.dispose();

    surnameFocusNode2?.dispose();
    surnameTextController2?.dispose();

    emailLoginFocusNode2?.dispose();
    emailLoginTextController2?.dispose();

    closeKeyboardModel2.dispose();
  }
}
