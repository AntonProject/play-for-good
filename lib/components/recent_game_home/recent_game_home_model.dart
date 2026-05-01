import '/backend/supabase/supabase.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/request_manager.dart';

import '/index.dart';
import 'recent_game_home_widget.dart' show RecentGameHomeWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RecentGameHomeModel extends FlutterFlowModel<RecentGameHomeWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Image component.
  late ImageModel imageModel1;
  // Model for Image component.
  late ImageModel imageModel2;

  /// Query cache managers for this widget.

  final _userGameHomeManager = FutureRequestManager<List<UsersRow>>();
  Future<List<UsersRow>> userGameHome({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<UsersRow>> Function() requestFn,
  }) =>
      _userGameHomeManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearUserGameHomeCache() => _userGameHomeManager.clear();
  void clearUserGameHomeCacheKey(String? uniqueKey) =>
      _userGameHomeManager.clearRequest(uniqueKey);

  final _orgGameHomeManager = FutureRequestManager<List<OrganizationRow>>();
  Future<List<OrganizationRow>> orgGameHome({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<OrganizationRow>> Function() requestFn,
  }) =>
      _orgGameHomeManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearOrgGameHomeCache() => _orgGameHomeManager.clear();
  void clearOrgGameHomeCacheKey(String? uniqueKey) =>
      _orgGameHomeManager.clearRequest(uniqueKey);

  @override
  void initState(BuildContext context) {
    imageModel1 = createModel(context, () => ImageModel());
    imageModel2 = createModel(context, () => ImageModel());
  }

  @override
  void dispose() {
    imageModel1.dispose();
    imageModel2.dispose();

    /// Dispose query cache managers for this widget.

    clearUserGameHomeCache();

    clearOrgGameHomeCache();
  }
}
