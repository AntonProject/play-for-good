import '/backend/api_requests/api_manager.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import 'package:flutter/material.dart';

Future login(BuildContext context) async {}

Future refresh(BuildContext context) async {
  unawaited(
    () async {}(),
  );
  FFAppState().refreshDate = getCurrentTimestamp;
  FFAppState().update(() {});
  FFAppState().clearGamesCache();
  FFAppState().clearPostsCache();
  FFAppState().clearGamesUserCache();
  FFAppState().clearUserPostsCache();
  FFAppState().clearUserCache();
  FFAppState().clearOrgPostsCache();
  FFAppState().clearInvitesCache();
  FFAppState().clearFollowUserCache();
}
