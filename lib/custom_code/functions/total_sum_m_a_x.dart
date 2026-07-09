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

double totalSumMAX(
  List<GamesRow>? games,
  String? period,
  String? userId,
  List<InvitesRow>? invites,
  int? totalUsersCount,
) {
  String filterPeriod = period ?? 'gesamt';
  DateTime now = DateTime.now();
  DateTime? startDate;
  DateTime? endDate;

  // Define filtering period with correct date ranges
  if (filterPeriod == 'woche') {
    int weekday = now.weekday;
    startDate = now.subtract(Duration(days: weekday - 1));
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
    endDate =
        startDate.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  } else if (filterPeriod == 'monat' || filterPeriod == 'dieser_monat') {
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 1)
        .subtract(Duration(milliseconds: 1));
  } else if (filterPeriod == 'letzter_monat') {
    startDate = DateTime(now.year, now.month - 1, 1);
    endDate =
        DateTime(now.year, now.month, 1).subtract(Duration(milliseconds: 1));
  } else if (filterPeriod == 'gesamt' || filterPeriod == 'saison') {
    startDate = null;
    endDate = null;
  } else {
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 1)
        .subtract(Duration(milliseconds: 1));
  }

  Map<String, double> userTotalLichtwatt = {};

  // Process games if available
  if (games != null && games.isNotEmpty) {
    for (final game in games) {
      if (game.creatorUserId != null && game.lichtwatt != null) {
        bool includeGame = true;

        // Apply date filtering if period is specified
        if (startDate != null && endDate != null && game.gameDate != null) {
          includeGame = game.gameDate!
                  .isAfter(startDate.subtract(Duration(milliseconds: 1))) &&
              game.gameDate!.isBefore(endDate.add(Duration(milliseconds: 1)));
        }

        if (includeGame) {
          String creatorId = game.creatorUserId!;
          userTotalLichtwatt[creatorId] =
              (userTotalLichtwatt[creatorId] ?? 0) + game.lichtwatt!;
        }
      }
    }
  }

  // Process invites if available
  if (invites != null && invites.isNotEmpty) {
    for (final invite in invites) {
      if (invite.inviterUserId != null &&
          invite.lichtwatt != null &&
          invite.wasUsed == true) {
        bool includeInvite = true;

        // Apply date filtering if period is specified
        if (startDate != null && endDate != null && invite.usedAt != null) {
          includeInvite = invite.usedAt!
                  .isAfter(startDate.subtract(Duration(milliseconds: 1))) &&
              invite.usedAt!.isBefore(endDate.add(Duration(milliseconds: 1)));
        }

        if (includeInvite) {
          String inviterId = invite.inviterUserId!;
          userTotalLichtwatt[inviterId] =
              (userTotalLichtwatt[inviterId] ?? 0) + invite.lichtwatt!;
        }
      }
    }
  }

  // // Return 0 if no data found
  // if (userTotalLichtwatt.isEmpty) return 0.0;

  // // If userId provided, return that user's total
  // if (userId != null) {
  //   return userTotalLichtwatt[userId] ?? 0.0;
  // }

  // // Return maximum value among all users
  // return userTotalLichtwatt.values.reduce((a, b) => a > b ? a : b);

  // Add auth bonus (100 LW) to all users in map
  userTotalLichtwatt = userTotalLichtwatt.map(
    (key, value) => MapEntry(key, value + 100),
  );

  // Add current user with bonus if not in map
  if (userId != null && !userTotalLichtwatt.containsKey(userId)) {
    userTotalLichtwatt[userId] = 100.0;
  }

  // Return 100 if no activity data but users exist
  if (userTotalLichtwatt.isEmpty) {
    final bool hasUsers = (totalUsersCount ?? 0) > 0;
    return (userId != null || hasUsers) ? 100.0 : 0.0;
  }

  // If userId provided, return that user's total (includes bonus)
  if (userId != null) {
    return userTotalLichtwatt[userId] ?? 100.0;
  }

  // Return maximum value among all users (includes bonus)
  return userTotalLichtwatt.values.reduce((a, b) => a > b ? a : b);
}
