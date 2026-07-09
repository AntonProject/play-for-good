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

List<GamesRow>? lastGamesOrg(List<GamesRow>? games) {
  if (games == null || games.isEmpty) {
    return null;
  }

  // Calculate total scores per organization and find latest game
  Map<String, double> orgTotalLichtwatt = {};
  Map<String, GamesRow> orgLatestGame = {};

  for (final game in games) {
    if (game.organizationId != null && game.lichtwatt != null) {
      String orgId = game.organizationId!;

      // Sum up lichtwatt for organization
      orgTotalLichtwatt[orgId] =
          (orgTotalLichtwatt[orgId] ?? 0) + game.lichtwatt!;

      // Keep the latest game for this organization (by date)
      if (!orgLatestGame.containsKey(orgId)) {
        orgLatestGame[orgId] = game;
      } else {
        // Compare dates and keep the latest one
        if (game.gameDate != null && orgLatestGame[orgId]!.gameDate != null) {
          if (game.gameDate!.isAfter(orgLatestGame[orgId]!.gameDate!)) {
            orgLatestGame[orgId] = game;
          }
        } else if (game.gameDate != null &&
            orgLatestGame[orgId]!.gameDate == null) {
          // If current game has date but stored doesn't, prefer current
          orgLatestGame[orgId] = game;
        }
        // If neither has date or stored game has date but current doesn't,
        // keep the stored one (no change needed)
      }
    }
  }

  // Sort organizations by total score (descending - highest first)
  List<MapEntry<String, double>> sortedOrgs =
      orgTotalLichtwatt.entries.toList();
  sortedOrgs.sort((a, b) => b.value.compareTo(a.value));

  // Create result list with UNIQUE organizations (maximum 5)
  List<GamesRow> result = [];
  Set<String> addedOrganizations =
      {}; // Track added organizations to ensure uniqueness

  int maxOrgs = math.min(5, sortedOrgs.length);

  for (int i = 0; i < maxOrgs; i++) {
    String orgId = sortedOrgs[i].key;

    // Only add if organization hasn't been added yet (ensures uniqueness)
    if (orgLatestGame.containsKey(orgId) &&
        !addedOrganizations.contains(orgId)) {
      result.add(orgLatestGame[orgId]!);
      addedOrganizations.add(orgId); // Mark this organization as added
    }
  }

  return result.isEmpty ? null : result;
}
