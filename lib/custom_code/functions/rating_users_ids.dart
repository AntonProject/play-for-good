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

List<String>? ratingUsersIds(
  List<GamesRow>? games,
  String? period,
  String? valueType,
  int? limit,
  int? page,
  List<InvitesRow>? invites,
) {
  String filterPeriod = period ?? 'gesamt';
  String filterValue = valueType ?? 'valuable';
  int itemsPerPage = limit ?? 10;
  int currentPage = page ?? 1;

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
  }

  List<GamesRow> filteredGames = [];

  // Process games if available
  if (games != null && games.isNotEmpty) {
    for (final game in games) {
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

      if (includeGame) {
        filteredGames.add(game);
      }
    }
  }

  List<InvitesRow> filteredInvites = [];

  // Process invites if available
  if (invites != null && invites.isNotEmpty) {
    for (final invite in invites) {
      if (invite.wasUsed == true) {
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
          filteredInvites.add(invite);
        }
      }
    }
  }

  Map<String, double> userScores = {};
  Map<String, int> userGameCounts = {};

  // Process games for scores
  for (final game in filteredGames) {
    if (game.creatorUserId != null) {
      String creatorId = game.creatorUserId!;
      userGameCounts[creatorId] = (userGameCounts[creatorId] ?? 0) + 1;

      double gameScore = 0;
      if (filterValue == 'valuable') {
        gameScore = game.lichtwatt?.toDouble() ?? 0;
      } else if (filterValue == 'generous') {
        double userMoney = game.userMoney?.toDouble() ?? 0;
        double teamMoney = game.teamMoney?.toDouble() ?? 0;
        double siegMoney = game.siegMoney?.toDouble() ?? 0;
        double additionalDonation =
            game.additionalDonationMoney?.toDouble() ?? 0;
        gameScore = userMoney + teamMoney + siegMoney + additionalDonation;
      } else if (filterValue == 'social') {
        // FIXED: Count games (matching getUserRatingScore logic)
        gameScore = 1;
      } else if (filterValue == 'active') {
        gameScore = 1;
      }

      userScores[creatorId] = (userScores[creatorId] ?? 0) + gameScore;
    }
  }

  // Add scores from invites for valuable filter only
  if (filterValue == 'valuable') {
    for (final invite in filteredInvites) {
      if (invite.inviterUserId != null) {
        String inviterId = invite.inviterUserId!;
        double inviteScore = invite.lichtwatt?.toDouble() ?? 0;
        userScores[inviterId] = (userScores[inviterId] ?? 0) + inviteScore;
      }
    }
  }

  // Return empty list if no scores found
  if (userScores.isEmpty) {
    return [];
  }

  // Filter out users with zero scores
  Map<String, double> filteredScores = {};
  for (final entry in userScores.entries) {
    if (entry.value > 0) {
      filteredScores[entry.key] = entry.value;
    }
  }

  // Return empty list if no users with positive scores
  if (filteredScores.isEmpty) {
    return [];
  }

  // Sort users by score (descending), then by userId for stable sorting
  List<MapEntry<String, double>> sortedUsers = filteredScores.entries.toList();
  sortedUsers.sort((a, b) {
    int scoreComparison = b.value.compareTo(a.value);
    if (scoreComparison != 0) {
      return scoreComparison;
    }
    // FIXED: If scores are equal, sort by userId for consistent ranking
    return a.key.compareTo(b.key);
  });

  // Extract user IDs in ranking order
  List<String> userIds = sortedUsers.map((entry) => entry.key).toList();

  // Apply pagination
  int startIndex = (currentPage - 1) * itemsPerPage;
  int endIndex = startIndex + itemsPerPage;

  if (startIndex >= userIds.length) {
    return [];
  }

  if (endIndex > userIds.length) {
    endIndex = userIds.length;
  }

  return userIds.sublist(startIndex, endIndex);
}
