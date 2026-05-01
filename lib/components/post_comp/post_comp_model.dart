import '/backend/supabase/supabase.dart';
import '/components/image/image_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/request_manager.dart';

import '/index.dart';
import 'post_comp_widget.dart' show PostCompWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PostCompModel extends FlutterFlowModel<PostCompWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Image component.
  late ImageModel imageModel1;
  // Model for Image component.
  late ImageModel imageModel2;
  // Model for Image component.
  late ImageModel imageModel3;

  /// Query cache managers for this widget.

  final _orgPostManager = FutureRequestManager<List<OrganizationRow>>();
  Future<List<OrganizationRow>> orgPost({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<OrganizationRow>> Function() requestFn,
  }) =>
      _orgPostManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearOrgPostCache() => _orgPostManager.clear();
  void clearOrgPostCacheKey(String? uniqueKey) =>
      _orgPostManager.clearRequest(uniqueKey);

  final _userPostManager = FutureRequestManager<List<UsersRow>>();
  Future<List<UsersRow>> userPost({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<UsersRow>> Function() requestFn,
  }) =>
      _userPostManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearUserPostCache() => _userPostManager.clear();
  void clearUserPostCacheKey(String? uniqueKey) =>
      _userPostManager.clearRequest(uniqueKey);

  @override
  void initState(BuildContext context) {
    imageModel1 = createModel(context, () => ImageModel());
    imageModel2 = createModel(context, () => ImageModel());
    imageModel3 = createModel(context, () => ImageModel());
  }

  @override
  void dispose() {
    imageModel1.dispose();
    imageModel2.dispose();
    imageModel3.dispose();

    /// Dispose query cache managers for this widget.

    clearOrgPostCache();

    clearUserPostCache();
  }
}
