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

bool hasMoreRatingUsers(
  List<GamesRow>? games,
  String? period,
  String? valueType,
  int? limit,
  int? page,
  List<InvitesRow>? invites,
) {
  int itemsPerPage = limit ?? 10;
  int currentPage = page ?? 1;
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

  // Collect unique users based on filter value
  Set<String> uniqueUsers = {};

  // Add users from games
  for (final game in filteredGames) {
    if (game.creatorUserId != null) {
      uniqueUsers.add(game.creatorUserId!);
    }
  }

  // Add users from invites based on filter value
  if (filterValue == 'valuable' || filterValue == 'active') {
    for (final invite in filteredInvites) {
      if (invite.inviterUserId != null) {
        uniqueUsers.add(invite.inviterUserId!);
      }
    }
  }

  // Calculate pagination
  int totalUsers = uniqueUsers.length;

  // Return false if no users found
  if (totalUsers == 0) {
    return false;
  }

  int totalPages = (totalUsers / itemsPerPage).ceil();
  return currentPage < totalPages;
}
