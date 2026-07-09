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

double totalSumPeriodGoodPower(
  List<GamesRow>? games,
  String? period,
) {
  if (games == null || games.isEmpty) return 0.0;

  String filterPeriod = period ?? 'gesamt';
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
  } else {
    startDate = DateTime(now.year, now.month, 1);
  }

  double totalSum = 0.0;

  for (final game in games) {
    bool includeGame = true;

    if (startDate != null && game.gameDate != null) {
      if (filterPeriod == 'letzter_monat') {
        DateTime endOfLastMonth = DateTime(now.year, now.month, 0);
        includeGame =
            game.gameDate!.isAfter(startDate.subtract(Duration(days: 1))) &&
                game.gameDate!.isBefore(endOfLastMonth.add(Duration(days: 1)));
      } else {
        includeGame =
            game.gameDate!.isAfter(startDate.subtract(Duration(days: 1)));
      }
    }

    if (includeGame) {
      double userMoney = game.userMoney?.toDouble() ?? 0;
      double teamMoney = game.teamMoney?.toDouble() ?? 0;
      double siegMoney = game.siegMoney?.toDouble() ?? 0;
      double additionalDonation = game.additionalDonationMoney?.toDouble() ?? 0;

      double gameGoodEnergy =
          userMoney + teamMoney + siegMoney + additionalDonation;
      totalSum += gameGoodEnergy;
    }
  }

  return totalSum;
}
