import '/backend/supabase/supabase.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/request_manager.dart';

import '/index.dart';
import 'games_org_comp_widget.dart' show GamesOrgCompWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GamesOrgCompModel extends FlutterFlowModel<GamesOrgCompWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Image component.
  late ImageModel imageModel;

  /// Query cache managers for this widget.

  final _orgManager = FutureRequestManager<List<OrganizationRow>>();
  Future<List<OrganizationRow>> org({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<OrganizationRow>> Function() requestFn,
  }) =>
      _orgManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearOrgCache() => _orgManager.clear();
  void clearOrgCacheKey(String? uniqueKey) =>
      _orgManager.clearRequest(uniqueKey);

  @override
  void initState(BuildContext context) {
    imageModel = createModel(context, () => ImageModel());
  }

  @override
  void dispose() {
    imageModel.dispose();

    /// Dispose query cache managers for this widget.

    clearOrgCache();
  }
}
