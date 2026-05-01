import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/empty_favoriten_profile/empty_favoriten_profile_widget.dart';
import '/components/organisation_comp/organisation_comp_widget.dart';
import '/components/users_follow_comp/users_follow_comp_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'followers_list_widget.dart' show FollowersListWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FollowersListModel extends FlutterFlowModel<FollowersListWidget> {
  ///  Local state fields for this component.

  String tab = 'all';

  ///  State fields for stateful widgets in this component.

  // State field(s) for search widget.
  FocusNode? searchFocusNode1;
  TextEditingController? searchTextController1;
  String? Function(BuildContext, String?)? searchTextController1Validator;
  // State field(s) for Column widget.
  ScrollController? columnController;
  // Model for closeKeyboard component.
  late CloseKeyboardModel closeKeyboardModel;
  // State field(s) for search widget.
  FocusNode? searchFocusNode2;
  TextEditingController? searchTextController2;
  String? Function(BuildContext, String?)? searchTextController2Validator;
  // Model for emptyFavoritenProfile component.
  late EmptyFavoritenProfileModel emptyFavoritenProfileModel;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    closeKeyboardModel = createModel(context, () => CloseKeyboardModel());
    emptyFavoritenProfileModel =
        createModel(context, () => EmptyFavoritenProfileModel());
  }

  @override
  void dispose() {
    searchFocusNode1?.dispose();
    searchTextController1?.dispose();

    columnController?.dispose();
    closeKeyboardModel.dispose();
    searchFocusNode2?.dispose();
    searchTextController2?.dispose();

    emptyFavoritenProfileModel.dispose();
  }
}
