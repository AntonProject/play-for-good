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

int ratingUserLichtwattPerGame(
  List<GamesRow>? games,
  String userId,
  String? period,
  String? valueType,
) {
  if (games == null || games.isEmpty) {
    return 0;
  }

  String filterPeriod = period ?? 'gesamt';
  String filterValue = valueType ?? 'valuable';
  DateTime now = DateTime.now();
  DateTime? startDate;

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

  Map<String, double> userTotalScores = {};
  Map<String, int> userGameCounts = {};

  for (final game in games) {
    if (game.creatorUserId != null) {
      bool includeGame = true;

      if (startDate != null && game.gameDate != null) {
        if (filterPeriod == 'letzter_monat') {
          DateTime endOfLastMonth = DateTime(now.year, now.month, 0);
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

      userTotalScores[creatorId] =
          (userTotalScores[creatorId] ?? 0) + gameScore;
    }
  }

  Map<String, double> userAverageScores = {};
  for (String userKey in userTotalScores.keys) {
    if (userGameCounts.containsKey(userKey) && userGameCounts[userKey]! > 0) {
      if (filterValue == 'active') {
        userAverageScores[userKey] = userGameCounts[userKey]!.toDouble();
      } else {
        userAverageScores[userKey] =
            userTotalScores[userKey]! / userGameCounts[userKey]!;
      }
    }
  }

  if (!userAverageScores.containsKey(userId)) {
    return 0;
  }

  double userScore = userAverageScores[userId]!;

  int usersWithHigherScore = 0;
  for (final entry in userAverageScores.entries) {
    if (entry.value > userScore) {
      usersWithHigherScore++;
    }
  }

  return usersWithHigherScore + 1;
}
