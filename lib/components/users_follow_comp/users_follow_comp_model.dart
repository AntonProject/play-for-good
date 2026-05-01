import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/flutter_flow/request_manager.dart';

import '/index.dart';
import 'users_follow_comp_widget.dart' show UsersFollowCompWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UsersFollowCompModel extends FlutterFlowModel<UsersFollowCompWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - Delete Row(s)] action in IconButton widget.
  List<FollowersRow>? delete;
  // Stores action output result for [Backend Call - Insert Row] action in IconButton widget.
  FollowersRow? followCreate;

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

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    /// Dispose query cache managers for this widget.

    clearFollowCache();
  }
}
