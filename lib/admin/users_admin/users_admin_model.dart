import '/admin/admin_dialog/admin_dialog_widget.dart';
import '/admin/dialog_admin_table/dialog_admin_table_widget.dart';
import '/admin/drawer_admin/drawer_admin_widget.dart';
import '/admin/header_admin/header_admin_widget.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/request_manager.dart';

import '/index.dart';
import 'users_admin_widget.dart' show UsersAdminWidget;
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UsersAdminModel extends FlutterFlowModel<UsersAdminWidget> {
  ///  Local state fields for this page.

  bool isAsc = true;

  int? sortIndex = 1;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - isAdmin] action in UsersAdmin widget.
  bool? admin;
  // Model for DrawerAdmin component.
  late DrawerAdminModel drawerAdminModel1;
  // Model for headerAdmin component.
  late HeaderAdminModel headerAdminModel;
  // State field(s) for search widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? Function(BuildContext, String?)? searchTextControllerValidator;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController =
      FlutterFlowDataTableController<UsersRow>();
  // Stores action output result for [Custom Action - deleteUser] action in IconButton widget.
  String? delete;
  // Model for DrawerAdmin component.
  late DrawerAdminModel drawerAdminModel2;

  /// Query cache managers for this widget.

  final _usersManager = FutureRequestManager<List<UsersRow>>();
  Future<List<UsersRow>> users({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<UsersRow>> Function() requestFn,
  }) =>
      _usersManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearUsersCache() => _usersManager.clear();
  void clearUsersCacheKey(String? uniqueKey) =>
      _usersManager.clearRequest(uniqueKey);

  @override
  void initState(BuildContext context) {
    drawerAdminModel1 = createModel(context, () => DrawerAdminModel());
    headerAdminModel = createModel(context, () => HeaderAdminModel());
    drawerAdminModel2 = createModel(context, () => DrawerAdminModel());
  }

  @override
  void dispose() {
    drawerAdminModel1.dispose();
    headerAdminModel.dispose();
    searchFocusNode?.dispose();
    searchTextController?.dispose();

    paginatedDataTableController.dispose();
    drawerAdminModel2.dispose();

    /// Dispose query cache managers for this widget.

    clearUsersCache();
  }
}
