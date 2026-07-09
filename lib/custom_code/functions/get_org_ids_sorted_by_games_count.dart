import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/flutter_flow/custom_functions.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/uploaded_file.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

List<String> getOrgIdsSortedByGamesCount(List<GamesRow> games) {
  final Map<String, int> countMap = {};
  for (final game in games) {
    final orgId = game.organizationId;
    if (orgId != null && orgId.isNotEmpty) {
      countMap[orgId] = (countMap[orgId] ?? 0) + 1;
    }
  }
  final sorted = countMap.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.map((e) => e.key).toList();
}
