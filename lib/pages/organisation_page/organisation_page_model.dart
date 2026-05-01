import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/dialogs/snack_bar/snack_bar_widget.dart';
import '/components/image/image_widget.dart';
import '/components/post_comp/post_comp_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/request_manager.dart';

import 'organisation_page_widget.dart' show OrganisationPageWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OrganisationPageModel extends FlutterFlowModel<OrganisationPageWidget> {
  ///  Local state fields for this page.

  int? tab = 1;

  bool visible = true;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController1;
  // State field(s) for Column widget.
  ScrollController? columnController2;
  // Model for Image component.
  late ImageModel imageModel;
  Stream<List<GamesRow>>? containerSupabaseStream;
  Stream<List<PostsRow>>? columnSupabaseStream;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UsersRow>? chosen;

  /// Query cache managers for this widget.

  final _followManager = FutureRequestManager<List<FollowersRow>>();
  Future<List<FollowersRow>> follow({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<FollowersRow>> Function() requestFn,
  }) =>
      _followManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearFollowCache() => _followManager.clear();
  void clearFollowCacheKey(String? uniqueKey) =>
      _followManager.clearRequest(uniqueKey);

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
    columnController1 = ScrollController();
    columnController2 = ScrollController();
    imageModel = createModel(context, () => ImageModel());
  }

  @override
  void dispose() {
    columnController1?.dispose();
    columnController2?.dispose();
    imageModel.dispose();

    /// Dispose query cache managers for this widget.

    clearFollowCache();

    clearOrgCache();
  }
}
