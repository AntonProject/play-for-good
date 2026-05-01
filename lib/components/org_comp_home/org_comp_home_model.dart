import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/request_manager.dart';

import '/index.dart';
import 'org_comp_home_widget.dart' show OrgCompHomeWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OrgCompHomeModel extends FlutterFlowModel<OrgCompHomeWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Image component.
  late ImageModel imageModel;

  /// Query cache managers for this widget.

  final _orgHomeManager = FutureRequestManager<List<OrganizationRow>>();
  Future<List<OrganizationRow>> orgHome({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<OrganizationRow>> Function() requestFn,
  }) =>
      _orgHomeManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearOrgHomeCache() => _orgHomeManager.clear();
  void clearOrgHomeCacheKey(String? uniqueKey) =>
      _orgHomeManager.clearRequest(uniqueKey);

  @override
  void initState(BuildContext context) {
    imageModel = createModel(context, () => ImageModel());
  }

  @override
  void dispose() {
    imageModel.dispose();

    /// Dispose query cache managers for this widget.

    clearOrgHomeCache();
  }
}
