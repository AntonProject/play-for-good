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

bool hasMoreGames(
  List<GamesRow>? games,
  String? period,
  String? valueType,
  int? limit,
  int? page,
) {
  if (games == null || games.isEmpty) {
    return false;
  }

  int itemsPerPage = limit ?? 10;
  int currentPage = page ?? 1;

  String filterPeriod = period ?? 'gesamt';
  String filterValue = valueType ?? 'valuable';

  DateTime now = DateTime.now();
  List<GamesRow> filteredGames = [];

  for (final game in games) {
    bool includeGame = true;

    if (filterPeriod == 'woche') {
      int weekday = now.weekday;
      DateTime startOfWeek = now.subtract(Duration(days: weekday - 1));
      startOfWeek =
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      if (game.gameDate != null) {
        includeGame =
            game.gameDate!.isAfter(startOfWeek.subtract(Duration(days: 1)));
      } else {
        includeGame = false;
      }
    } else if (filterPeriod == 'monat') {
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      if (game.gameDate != null) {
        includeGame =
            game.gameDate!.isAfter(startOfMonth.subtract(Duration(days: 1)));
      } else {
        includeGame = false;
      }
    } else if (filterPeriod == 'letzter_monat') {
      DateTime startOfLastMonth = DateTime(now.year, now.month - 1, 1);
      DateTime endOfLastMonth = DateTime(now.year, now.month, 0);
      if (game.gameDate != null) {
        includeGame = game.gameDate!
                .isAfter(startOfLastMonth.subtract(Duration(days: 1))) &&
            game.gameDate!.isBefore(endOfLastMonth.add(Duration(days: 1)));
      } else {
        includeGame = false;
      }
    } else if (filterPeriod == 'dieser_monat') {
      DateTime startOfThisMonth = DateTime(now.year, now.month, 1);
      if (game.gameDate != null) {
        includeGame = game.gameDate!
            .isAfter(startOfThisMonth.subtract(Duration(days: 1)));
      } else {
        includeGame = false;
      }
    }

    if (includeGame) {
      filteredGames.add(game);
    }
  }

  if (filterValue == 'valuable') {
    filteredGames.sort((a, b) {
      double aValue = a.lichtwatt?.toDouble() ?? 0;
      double bValue = b.lichtwatt?.toDouble() ?? 0;
      return bValue.compareTo(aValue);
    });
  } else if (filterValue == 'generous') {
    filteredGames.sort((a, b) {
      double aUserMoney = a.userMoney?.toDouble() ?? 0;
      double aTeamMoney = a.teamMoney?.toDouble() ?? 0;
      double aSiegMoney = a.siegMoney?.toDouble() ?? 0;
      double aAdditionalDonation = a.additionalDonationMoney?.toDouble() ?? 0;

      double bUserMoney = b.userMoney?.toDouble() ?? 0;
      double bTeamMoney = b.teamMoney?.toDouble() ?? 0;
      double bSiegMoney = b.siegMoney?.toDouble() ?? 0;
      double bAdditionalDonation = b.additionalDonationMoney?.toDouble() ?? 0;

      double aTotalMoney =
          aUserMoney + aTeamMoney + aSiegMoney + aAdditionalDonation;
      double bTotalMoney =
          bUserMoney + bTeamMoney + bSiegMoney + bAdditionalDonation;

      return bTotalMoney.compareTo(aTotalMoney);
    });
  } else if (filterValue == 'social') {
    filteredGames.sort((a, b) {
      double aValue = a.lichtwatt?.toDouble() ?? 0;
      double bValue = b.lichtwatt?.toDouble() ?? 0;
      return bValue.compareTo(aValue);
    });
  } else if (filterValue == 'recent') {
    filteredGames.sort((a, b) {
      DateTime aDate = a.gameDate ?? DateTime(1970);
      DateTime bDate = b.gameDate ?? DateTime(1970);
      return bDate.compareTo(aDate);
    });
  }

  int totalItems = filteredGames.length;
  int totalPages = (totalItems / itemsPerPage).ceil();

  return currentPage < totalPages;
}
