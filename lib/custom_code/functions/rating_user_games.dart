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

int ratingUserGames(
  List<GamesRow>? games,
  String userId,
  String? period,
  List<InvitesRow>? invites,
) {
  String filterPeriod = period ?? 'gesamt';
  DateTime now = DateTime.now();
  DateTime? startDate;

  // Define filtering period
  if (filterPeriod == 'woche') {
    int weekday = now.weekday;
    startDate = now.subtract(Duration(days: weekday - 1));
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
  } else if (filterPeriod == 'monat') {
    startDate = DateTime(now.year, now.month, 1);
  } else if (filterPeriod == 'letzter_monat') {
    startDate = DateTime(now.year, now.month - 1, 1);
  } else if (filterPeriod == 'dieser_monat') {
    startDate = DateTime(now.year, now.month, 1);
  } else if (filterPeriod == 'gesamt') {
    startDate = null;
  } else if (filterPeriod == 'saison') {
    startDate = null;
  } else {
    startDate = DateTime(now.year, now.month, 1);
  }

  Map<String, int> userActivityCount = {};

  // Process games if available
  if (games != null && games.isNotEmpty) {
    for (final game in games) {
      if (game.creatorUserId != null) {
        bool includeGame = true;

        if (startDate != null && game.gameDate != null) {
          if (filterPeriod == 'letzter_monat') {
            DateTime endOfLastMonth =
                DateTime(now.year, now.month, 0, 23, 59, 59);
            includeGame = game.gameDate!
                    .isAfter(startDate.subtract(Duration(days: 1))) &&
                game.gameDate!.isBefore(endOfLastMonth.add(Duration(days: 1)));
          } else {
            includeGame =
                game.gameDate!.isAfter(startDate.subtract(Duration(days: 1)));
          }
        }

        if (!includeGame) continue;

        String creatorId = game.creatorUserId!;
        userActivityCount[creatorId] = (userActivityCount[creatorId] ?? 0) + 1;
      }
    }
  }

  // Process invites if available
  if (invites != null && invites.isNotEmpty) {
    for (final invite in invites) {
      if (invite.inviterUserId != null && invite.wasUsed == true) {
        bool includeInvite = true;

        if (startDate != null && invite.usedAt != null) {
          if (filterPeriod == 'letzter_monat') {
            DateTime endOfLastMonth =
                DateTime(now.year, now.month, 0, 23, 59, 59);
            includeInvite = invite.usedAt!
                    .isAfter(startDate.subtract(Duration(days: 1))) &&
                invite.usedAt!.isBefore(endOfLastMonth.add(Duration(days: 1)));
          } else {
            includeInvite =
                invite.usedAt!.isAfter(startDate.subtract(Duration(days: 1)));
          }
        }

        if (includeInvite) {
          String inviterId = invite.inviterUserId!;
          userActivityCount[inviterId] =
              (userActivityCount[inviterId] ?? 0) + 1;
        }
      }
    }
  }

  // Return 0 if user not found in activity count
  if (!userActivityCount.containsKey(userId)) {
    return 0;
  }

  // Calculate ranking based on activity count
  int userScore = userActivityCount[userId]!;
  int usersWithHigherScore = 0;

  for (final entry in userActivityCount.entries) {
    if (entry.value > userScore) {
      usersWithHigherScore++;
    }
  }

  return usersWithHigherScore + 1;
}
