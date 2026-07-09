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

int ratingUserLichtwatt(
  List<GamesRow>? games,
  String userId,
  String? period,
  String? valueType,
  List<InvitesRow>? invites,
  int? totalUsersLength,
) {
  String filterPeriod = period ?? 'gesamt';
  String filterValue = valueType ?? 'valuable';

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
    DateTime startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    startDate = startOfLastMonth;
  } else if (filterPeriod == 'dieser_monat') {
    startDate = DateTime(now.year, now.month, 1);
  } else if (filterPeriod == 'gesamt') {
    startDate = null;
  } else if (filterPeriod == 'saison') {
    startDate = null;
  }

  Map<String, double> userScores = {};
  Map<String, int> userGameCounts = {};

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
        userGameCounts[creatorId] = (userGameCounts[creatorId] ?? 0) + 1;

        double gameScore = 0;
        if (filterValue == 'valuable' || filterValue == 'social') {
          gameScore = game.lichtwatt?.toDouble() ?? 0;
        } else if (filterValue == 'generous') {
          gameScore = game.userMoney?.toDouble() ?? 0;
        } else if (filterValue == 'active') {
          gameScore = 1;
        }

        userScores[creatorId] = (userScores[creatorId] ?? 0) + gameScore;
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

        if (!includeInvite) continue;

        String inviterId = invite.inviterUserId!;

        double inviteScore = 0;
        if (filterValue == 'valuable' || filterValue == 'social') {
          inviteScore = invite.lichtwatt?.toDouble() ?? 0;
        } else if (filterValue == 'generous') {
          inviteScore = 0;
        } else if (filterValue == 'active') {
          inviteScore = 1;
        }

        userScores[inviterId] = (userScores[inviterId] ?? 0) + inviteScore;
      }
    }
  }

  // Handle 'active' filter value separately
  if (filterValue == 'active') {
    Map<String, double> activeScores = {};

    // Add game counts
    for (String key in userGameCounts.keys) {
      activeScores[key] = userGameCounts[key]!.toDouble();
    }

    // Add invite counts
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
                  invite.usedAt!
                      .isBefore(endOfLastMonth.add(Duration(days: 1)));
            } else {
              includeInvite =
                  invite.usedAt!.isAfter(startDate.subtract(Duration(days: 1)));
            }
          }

          if (includeInvite) {
            String inviterId = invite.inviterUserId!;
            activeScores[inviterId] = (activeScores[inviterId] ?? 0) + 1;
          }
        }
      }
    }

    userScores = activeScores;
  }

  // Return 0 if user not found in scores
  if (!userScores.containsKey(userId)) {
    return totalUsersLength ?? 0;
  }

  // Calculate ranking
  double userScore = userScores[userId]!;
  int usersWithHigherScore = 0;

  for (final entry in userScores.entries) {
    if (entry.value > userScore) {
      usersWithHigherScore++;
    }
  }

  return usersWithHigherScore + 1;
}
