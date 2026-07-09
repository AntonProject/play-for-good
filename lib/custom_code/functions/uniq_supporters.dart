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

int uniqSupporters(
  List<GamesRow>? games,
  String orgId,
) {
// Check if games list is null or empty
  if (games == null || games.isEmpty) {
    return 0;
  }

  // Check if orgId is null or empty
  if (orgId.isEmpty) {
    return 0;
  }

  // Set to store unique user IDs
  Set<String> uniqueUsers = <String>{};

  // Iterate through all games
  for (final game in games) {
    // Check if game belongs to the specified organization
    if (game.organizationId == orgId) {
      // Check if creator user ID exists and is not null
      if (game.creatorUserId != null && game.creatorUserId!.isNotEmpty) {
        // Add user ID to set (duplicates will be automatically ignored)
        uniqueUsers.add(game.creatorUserId!);
      }
    }
  }

  // Return the count of unique supporters
  return uniqueUsers.length;
}
