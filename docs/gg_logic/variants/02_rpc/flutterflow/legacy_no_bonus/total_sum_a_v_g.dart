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
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

double totalSumAVG(
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

  // List<double> userTotals = userTotalLichtwatt.values.toList();
  // double maxTotal = userTotals.reduce((a, b) => a > b ? a : b);

  // // If no userId provided, return maximum total
  // if (userId == null) {
  //   // Add auth bonus(100 Lichtwatt) to all items
  //   final totalUsersAuthBonus = userTotals.length * 100;
  //   return maxTotal + totalUsersAuthBonus;
  // }

  // // Return 0 if maxTotal is 0 (avoid division by zero)
  // if (maxTotal == 0) return 0.0;

  // // Calculate average excluding current user
  // double currentUserTotal = userTotalLichtwatt[userId] ?? 0.0;
  // double sum = userTotals.reduce((a, b) => a + b);
  // double sumWithoutCurrent = sum - currentUserTotal;
  // int userCount = userTotals.length;
  // int userCountWithoutCurrent = userCount - 1;

  // // If only current user exists or no other users, return 0
  // if (userCountWithoutCurrent <= 0) return 0.0;

  // // Return absolute average value (not percentage)
  // // The widget will calculate the percentage itself
  // double average = sumWithoutCurrent / userCountWithoutCurrent;
  // return average;

  final int allUsersCount = totalUsersCount ?? userTotalLichtwatt.length;

  // Signup +100 moved to the backend ledger (gg_v2.point_awards).
  const double authBonus = 0.0;
  userTotalLichtwatt = userTotalLichtwatt.map(
    (key, value) => MapEntry(key, value + authBonus),
  );

  // Add current user with bonus if not in map
  if (userId != null && !userTotalLichtwatt.containsKey(userId)) {
    userTotalLichtwatt[userId] = authBonus;
  }

  // Return 100 if no activity data but user exists
  if (userTotalLichtwatt.isEmpty) {
    return (userId != null) ? authBonus : 0.0;
  }

  List<double> userTotals = userTotalLichtwatt.values.toList();
  double maxTotal = userTotals.reduce((a, b) => a > b ? a : b);

  // No userId — return max as upper bound for the AVG gauge scale
  if (userId == null) {
    return maxTotal;
  }

  if (maxTotal == 0) return 0.0;

  // Calculate average excluding current user, including inactive users
  double currentUserTotal = userTotalLichtwatt[userId] ?? authBonus;
  double sum = userTotals.reduce((a, b) => a + b);
  double sumWithoutCurrent = sum - currentUserTotal;

  int activeOtherUsers = userTotalLichtwatt.length -
      (userTotalLichtwatt.containsKey(userId) ? 1 : 0);
  int totalOtherUsers = allUsersCount - 1;
  int inactiveOtherUsers = totalOtherUsers - activeOtherUsers;
  double inactiveOthersTotal = inactiveOtherUsers * authBonus;

  if (totalOtherUsers <= 0) return 0.0;

  double average = (sumWithoutCurrent + inactiveOthersTotal) / totalOtherUsers;
  return average;
}
