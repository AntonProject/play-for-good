import '/admin/admin_dialog/admin_dialog_widget.dart';
import '/admin/create_receipt_dialog/create_receipt_dialog_widget.dart';
import '/admin/drawer_admin/drawer_admin_widget.dart';
import '/admin/header_admin/header_admin_widget.dart';
import '/admin/receipts_dialog_admin_table/receipts_dialog_admin_table_widget.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'dart:async';
import 'receipts_admin_widget.dart' show ReceiptsAdminWidget;
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReceiptsAdminModel extends FlutterFlowModel<ReceiptsAdminWidget> {
  ///  Local state fields for this page.

  bool isAsc = true;

  int? sortIndex = 1;

  DateTime? selectedDate;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - isAdmin] action in ReceiptsAdmin widget.
  bool? admin;
  // Model for DrawerAdmin component.
  late DrawerAdminModel drawerAdminModel1;
  // Model for headerAdmin component.
  late HeaderAdminModel headerAdminModel;
  Completer<List<ReceiptsRow>>? requestCompleter;
  DateTime? datePicked;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController =
      FlutterFlowDataTableController<ReceiptsRow>();
  // Model for DrawerAdmin component.
  late DrawerAdminModel drawerAdminModel2;

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
    paginatedDataTableController.dispose();
    drawerAdminModel2.dispose();
  }

  /// Additional helper methods.
  Future waitForRequestCompleted({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = requestCompleter?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
