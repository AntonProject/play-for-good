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

double? getUserRatingScore(
  List<GamesRow>? games,
  String? period,
  String? valueType,
  List<InvitesRow>? invites,
  String userId,
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
      // Only games for this user
      if (game.creatorUserId != userId) {
        continue;
      }

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
      // Only invites from this user
      if (invite.inviterUserId != userId) {
        continue;
      }

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

  double userScore = 0;
  int gameCount = 0;

  // Calculate score from games
  for (final game in filteredGames) {
    gameCount++;

    double gameScore = 0;
    if (filterValue == 'valuable') {
      gameScore = game.lichtwatt?.toDouble() ?? 0;
    } else if (filterValue == 'generous') {
      double userMoney = game.userMoney?.toDouble() ?? 0;
      double teamMoney = game.teamMoney?.toDouble() ?? 0;
      double siegMoney = game.siegMoney?.toDouble() ?? 0;
      double additionalDonation = game.additionalDonationMoney?.toDouble() ?? 0;
      gameScore = userMoney + teamMoney + siegMoney + additionalDonation;
    } else if (filterValue == 'social') {
      // For social: always 1 per game (since all donate to one company for now)
      gameScore = 1;
    } else if (filterValue == 'active') {
      gameScore = 1;
    }

    userScore += gameScore;
  }

  // Add scores from invites for valuable filter only
  if (filterValue == 'valuable') {
    for (final invite in filteredInvites) {
      double inviteScore = invite.lichtwatt?.toDouble() ?? 0;
      userScore += inviteScore;
    }
    // Signup +100 moved to the backend ledger (gg_v2.point_awards).
  }

  // For 'active' filter, return game count
  if (filterValue == 'active') {
    return gameCount.toDouble();
  }

  // For 'social' filter, return game count (1 per game)
  if (filterValue == 'social') {
    return gameCount.toDouble();
  }

  // Always return score, default is 0
  return userScore;
}
