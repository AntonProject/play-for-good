import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/empty_good_circle_profile/empty_good_circle_profile_widget.dart';
import '/components/users_invites_comp/users_invites_comp_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/request_manager.dart';

import 'invites_list_widget.dart' show InvitesListWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InvitesListModel extends FlutterFlowModel<InvitesListWidget> {
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
  // Model for emptyGoodCircleProfile component.
  late EmptyGoodCircleProfileModel emptyGoodCircleProfileModel;

  /// Query cache managers for this widget.

  final _orgListManager = FutureRequestManager<List<InvitesRow>>();
  Future<List<InvitesRow>> orgList({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<InvitesRow>> Function() requestFn,
  }) =>
      _orgListManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearOrgListCache() => _orgListManager.clear();
  void clearOrgListCacheKey(String? uniqueKey) =>
      _orgListManager.clearRequest(uniqueKey);

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    closeKeyboardModel = createModel(context, () => CloseKeyboardModel());
    emptyGoodCircleProfileModel =
        createModel(context, () => EmptyGoodCircleProfileModel());
  }

  @override
  void dispose() {
    searchFocusNode1?.dispose();
    searchTextController1?.dispose();

    columnController?.dispose();
    closeKeyboardModel.dispose();
    searchFocusNode2?.dispose();
    searchTextController2?.dispose();

    emptyGoodCircleProfileModel.dispose();

    /// Dispose query cache managers for this widget.

    clearOrgListCache();
  }
}
