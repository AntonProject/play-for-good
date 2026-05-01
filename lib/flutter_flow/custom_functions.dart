import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

double totalSum(List<double>? list) {
  if (list == null) return 0.0;
  return list.fold(0.0, (sum, item) => sum + item);
}

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

  // Add auth bonus (100 LW) to all users in map
  userTotalLichtwatt = userTotalLichtwatt.map(
    (key, value) => MapEntry(key, value + 100),
  );

  // Add current user with bonus if not in map
  if (userId != null && !userTotalLichtwatt.containsKey(userId)) {
    userTotalLichtwatt[userId] = 100.0;
  }

  // Return 100 if no activity data but user exists
  if (userTotalLichtwatt.isEmpty) {
    return (userId != null) ? 100.0 : 0.0;
  }

  List<double> userTotals = userTotalLichtwatt.values.toList();
  double maxTotal = userTotals.reduce((a, b) => a > b ? a : b);

  // No userId — return max as upper bound for the AVG gauge scale
  if (userId == null) {
    return maxTotal;
  }

  if (maxTotal == 0) return 0.0;

  // Calculate average excluding current user, including inactive users
  double currentUserTotal = userTotalLichtwatt[userId] ?? 100.0;
  double sum = userTotals.reduce((a, b) => a + b);
  double sumWithoutCurrent = sum - currentUserTotal;

  int activeOtherUsers = userTotalLichtwatt.length -
      (userTotalLichtwatt.containsKey(userId) ? 1 : 0);
  int totalOtherUsers = allUsersCount - 1;
  int inactiveOtherUsers = totalOtherUsers - activeOtherUsers;
  double inactiveOthersTotal = inactiveOtherUsers * 100.0;

  if (totalOtherUsers <= 0) return 0.0;

  double average = (sumWithoutCurrent + inactiveOthersTotal) / totalOtherUsers;
  return average;
}

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

double totalSumPeriodLichtwatt(
  List<GamesRow>? games,
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
    startDate = null; // No time restrictions
  } else if (filterPeriod == 'saison') {
    startDate = null; // No time restrictions
  } else {
    startDate = DateTime(now.year, now.month, 1);
  }

  double totalSum = 0.0;

  // Process games if available
  if (games != null && games.isNotEmpty) {
    for (final game in games) {
      if (game.lichtwatt != null) {
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
          totalSum += game.lichtwatt!;
        }
      }
    }
  }

  // Process invites if available
  if (invites != null && invites.isNotEmpty) {
    for (final invite in invites) {
      if (invite.lichtwatt != null && invite.wasUsed == true) {
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
          totalSum += invite.lichtwatt!;
        }
      }
    }
  }

  // + Add auth bonus
  return totalSum + 100.0;
}

double totalSumPeriodLichtwattPerGame(
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
  int gameCount = 0;

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
      if (game.lichtwatt != null) {
        totalSum += game.lichtwatt!;
      }
      gameCount++;
    }
  }

  if (gameCount == 0) return 0.0;
  return totalSum / gameCount;
}

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

double totalSumPeriodGoodPowerPerGame(
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
  int gameCount = 0;

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
      gameCount++;
    }
  }

  if (gameCount == 0) return 0.0;
  return totalSum / gameCount;
}

double totalSumPeriodGoodEnergyOrg(
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

int ratingUserGamesByGoodEnergyPerGame(
  List<GamesRow>? games,
  String userId,
  String? period,
) {
  if (games == null || games.isEmpty) {
    return 0;
  }

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
  }

  Map<String, double> userTotalGoodEnergy = {};
  Map<String, int> userGameCount = {};

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

      double userMoney = game.userMoney?.toDouble() ?? 0;
      double teamMoney = game.teamMoney?.toDouble() ?? 0;
      double siegMoney = game.siegMoney?.toDouble() ?? 0;
      double additionalDonation = game.additionalDonationMoney?.toDouble() ?? 0;

      double gameGoodEnergy =
          userMoney + teamMoney + siegMoney + additionalDonation;

      if (userTotalGoodEnergy.containsKey(creatorId)) {
        userTotalGoodEnergy[creatorId] =
            userTotalGoodEnergy[creatorId]! + gameGoodEnergy;
      } else {
        userTotalGoodEnergy[creatorId] = gameGoodEnergy;
      }

      if (userGameCount.containsKey(creatorId)) {
        userGameCount[creatorId] = userGameCount[creatorId]! + 1;
      } else {
        userGameCount[creatorId] = 1;
      }
    }
  }

  if (!userTotalGoodEnergy.containsKey(userId) ||
      !userGameCount.containsKey(userId)) {
    return 0;
  }

  Map<String, double> userAverageGoodEnergy = {};
  for (final String userKey in userTotalGoodEnergy.keys) {
    if (userGameCount.containsKey(userKey) && userGameCount[userKey]! > 0) {
      userAverageGoodEnergy[userKey] =
          userTotalGoodEnergy[userKey]! / userGameCount[userKey]!;
    }
  }

  double userScore = userAverageGoodEnergy[userId]!;
  int usersWithHigherScore = 0;

  for (final entry in userAverageGoodEnergy.entries) {
    if (entry.value > userScore) {
      usersWithHigherScore++;
    }
  }

  return usersWithHigherScore + 1;
}

int ratingUserGamesByGoodEnergy(
  List<GamesRow>? games,
  String userId,
  String? period,
) {
  if (games == null || games.isEmpty) {
    return 0;
  }

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
  }

  Map<String, double> userTotalGoodEnergy = {};

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

      double userMoney = game.userMoney?.toDouble() ?? 0;
      double teamMoney = game.teamMoney?.toDouble() ?? 0;
      double siegMoney = game.siegMoney?.toDouble() ?? 0;
      double additionalDonation = game.additionalDonationMoney?.toDouble() ?? 0;

      double gameGoodEnergy =
          userMoney + teamMoney + siegMoney + additionalDonation;

      if (userTotalGoodEnergy.containsKey(creatorId)) {
        userTotalGoodEnergy[creatorId] =
            userTotalGoodEnergy[creatorId]! + gameGoodEnergy;
      } else {
        userTotalGoodEnergy[creatorId] = gameGoodEnergy;
      }
    }
  }

  if (!userTotalGoodEnergy.containsKey(userId)) {
    return 0;
  }

  double userScore = userTotalGoodEnergy[userId]!;

  int usersWithHigherScore = 0;
  for (final entry in userTotalGoodEnergy.entries) {
    if (entry.value > userScore) {
      usersWithHigherScore++;
    }
  }

  return usersWithHigherScore + 1;
}

List<GamesRow>? ratingUsers(
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

  // Return empty list if no games available
  if (games == null || games.isEmpty) {
    return [];
  }

  List<GamesRow> filteredGames = [];

  // Process games
  for (final game in games) {
    bool includeGame = true;

    if (startDate != null && game.gameDate != null) {
      if (filterPeriod == 'letzter_monat') {
        DateTime endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
        includeGame =
            game.gameDate!.isAfter(startDate.subtract(Duration(days: 1))) &&
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
  Map<String, GamesRow> userLatestGame = {};

  // Process games for scores and store latest game
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
        gameScore =
            (game.sponsorMoney != null && game.sponsorMoney! > 0) ? 1 : 0;
      } else if (filterValue == 'active') {
        gameScore = 1;
      }

      userScores[creatorId] = (userScores[creatorId] ?? 0) + gameScore;
      userLatestGame[creatorId] = game;
    }
  }

  // Add scores from invites for valuable filter only
  if (filterValue == 'valuable') {
    for (final invite in filteredInvites) {
      if (invite.inviterUserId != null) {
        String inviterId = invite.inviterUserId!;
        double inviteScore = invite.lichtwatt?.toDouble() ?? 0;
        userScores[inviterId] = (userScores[inviterId] ?? 0) + inviteScore;
        // Note: Only users with actual games will appear in results
      }
    }
  }

  // Handle 'active' filter
  if (filterValue == 'active') {
    userScores.clear();
    for (String key in userGameCounts.keys) {
      userScores[key] = userGameCounts[key]!.toDouble();
    }
  }

  // Return empty list if no users found
  if (userScores.isEmpty) {
    return [];
  }

  // Sort users by score
  List<MapEntry<String, double>> sortedUsers = userScores.entries.toList();
  sortedUsers.sort((a, b) => b.value.compareTo(a.value));

  // Build result list - only users with actual games
  List<GamesRow> result = [];
  for (final entry in sortedUsers) {
    if (userLatestGame.containsKey(entry.key)) {
      result.add(userLatestGame[entry.key]!);
    }
  }

  // Apply pagination
  int startIndex = (currentPage - 1) * itemsPerPage;
  int endIndex = startIndex + itemsPerPage;

  if (startIndex >= result.length) {
    return [];
  }

  if (endIndex > result.length) {
    endIndex = result.length;
  }

  return result.sublist(startIndex, endIndex);
}

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
    // Add auth bonus for valuable filter
    userScore += 100.0;
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

int ratingUsersPerUser(
  List<GamesRow>? games,
  String? period,
  String? valueType,
  List<InvitesRow>? invites,
  String? userId,
  int? totalUsersCount,
) {
  // Return 0 if userId is not provided
  if (userId == null || userId.isEmpty) {
    return 0;
  }

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

  Map<String, double> userScores = {};
  Map<String, int> userGameCounts = {};

  // Calculate scores from games
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
        gameScore =
            (game.sponsorMoney != null && game.sponsorMoney! > 0) ? 1 : 0;
      } else if (filterValue == 'active') {
        gameScore = 1;
      }

      userScores[creatorId] = (userScores[creatorId] ?? 0) + gameScore;
    }
  }

  // Add scores from invites for 'valuable' filter
  if (filterValue == 'valuable') {
    for (final invite in filteredInvites) {
      if (invite.inviterUserId != null) {
        String inviterId = invite.inviterUserId!;
        double inviteScore = invite.lichtwatt?.toDouble() ?? 0;
        userScores[inviterId] = (userScores[inviterId] ?? 0) + inviteScore;
      }
    }
  }

  // Handle 'active' filter separately
  if (filterValue == 'active') {
    userScores.clear();
    for (String key in userGameCounts.keys) {
      userScores[key] = userGameCounts[key]!.toDouble();
    }

    // Add invite activity for 'active' filter
    for (final invite in filteredInvites) {
      if (invite.inviterUserId != null) {
        String inviterId = invite.inviterUserId!;
        userScores[inviterId] = (userScores[inviterId] ?? 0) + 1;
      }
    }
  }

  // Return 0 if user not found in scores
  if (!userScores.containsKey(userId)) {
    return totalUsersCount ?? 0;
  }

  // Sort users by score and find position
  List<MapEntry<String, double>> sortedUsers = userScores.entries.toList();
  sortedUsers.sort((a, b) => b.value.compareTo(a.value));

  for (int i = 0; i < sortedUsers.length; i++) {
    if (sortedUsers[i].key == userId) {
      return i + 1;
    }
  }

  return totalUsersCount ?? 0;
}

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

List<GamesRow>? filterAllGames(
  List<GamesRow>? games,
  String? period,
  String? valueType,
  int? limit,
  int? page,
) {
  if (games == null || games.isEmpty) {
    return null;
  }

  String filterPeriod = period ?? 'gesamt';
  String filterValue = valueType ?? 'valuable';
  int itemsPerPage = limit ?? 10;
  int currentPage = page ?? 1;

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

  int startIndex = (currentPage - 1) * itemsPerPage;
  int endIndex = startIndex + itemsPerPage;

  if (startIndex >= filteredGames.length) {
    return [];
  }

  if (endIndex > filteredGames.length) {
    endIndex = filteredGames.length;
  }

  return filteredGames.sublist(startIndex, endIndex);
}

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

List<GamesRow>? lastGamesOrg(List<GamesRow>? games) {
  if (games == null || games.isEmpty) {
    return null;
  }

  // Calculate total scores per organization and find latest game
  Map<String, double> orgTotalLichtwatt = {};
  Map<String, GamesRow> orgLatestGame = {};

  for (final game in games) {
    if (game.organizationId != null && game.lichtwatt != null) {
      String orgId = game.organizationId!;

      // Sum up lichtwatt for organization
      orgTotalLichtwatt[orgId] =
          (orgTotalLichtwatt[orgId] ?? 0) + game.lichtwatt!;

      // Keep the latest game for this organization (by date)
      if (!orgLatestGame.containsKey(orgId)) {
        orgLatestGame[orgId] = game;
      } else {
        // Compare dates and keep the latest one
        if (game.gameDate != null && orgLatestGame[orgId]!.gameDate != null) {
          if (game.gameDate!.isAfter(orgLatestGame[orgId]!.gameDate!)) {
            orgLatestGame[orgId] = game;
          }
        } else if (game.gameDate != null &&
            orgLatestGame[orgId]!.gameDate == null) {
          // If current game has date but stored doesn't, prefer current
          orgLatestGame[orgId] = game;
        }
        // If neither has date or stored game has date but current doesn't,
        // keep the stored one (no change needed)
      }
    }
  }

  // Sort organizations by total score (descending - highest first)
  List<MapEntry<String, double>> sortedOrgs =
      orgTotalLichtwatt.entries.toList();
  sortedOrgs.sort((a, b) => b.value.compareTo(a.value));

  // Create result list with UNIQUE organizations (maximum 5)
  List<GamesRow> result = [];
  Set<String> addedOrganizations =
      {}; // Track added organizations to ensure uniqueness

  int maxOrgs = math.min(5, sortedOrgs.length);

  for (int i = 0; i < maxOrgs; i++) {
    String orgId = sortedOrgs[i].key;

    // Only add if organization hasn't been added yet (ensures uniqueness)
    if (orgLatestGame.containsKey(orgId) &&
        !addedOrganizations.contains(orgId)) {
      result.add(orgLatestGame[orgId]!);
      addedOrganizations.add(orgId); // Mark this organization as added
    }
  }

  return result.isEmpty ? null : result;
}

List<GamesRow>? gamesForPeriod(
  String? period,
  List<GamesRow>? games,
  String? userId,
) {
  if (games == null || games.isEmpty) {
    return null;
  }

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
  }

  List<GamesRow> filteredGames = [];

  for (final game in games) {
    bool includeGame = true;

    if (userId != null && game.creatorUserId != userId) {
      continue;
    }

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
      filteredGames.add(game);
    }
  }

  return filteredGames;
}

double? numParse(String? num) {
  // Check for null or empty string
  if (num == null || num.isEmpty) {
    return 0.0;
  }

  try {
    // Remove all spaces
    String cleanNum = num.replaceAll(' ', '');

    // Remove currency symbols and other non-numeric characters, except digits, dots and commas
    // REMOVED: +- from the regex to not allow negative numbers
    cleanNum = cleanNum.replaceAll(RegExp(r'[^\d.,]'), '');

    // Replace commas with dots
    cleanNum = cleanNum.replaceAll(',', '.');

    // Handle multiple dots (take the last one as decimal separator)
    if (cleanNum.contains('.')) {
      int lastDotIndex = cleanNum.lastIndexOf('.');
      if (cleanNum.indexOf('.') != lastDotIndex) {
        // Multiple dots found, remove all except the last one
        String beforeLastDot =
            cleanNum.substring(0, lastDotIndex).replaceAll('.', '');
        String afterLastDot = cleanNum.substring(lastDotIndex);
        cleanNum = beforeLastDot + afterLastDot;
      }
    }

    // Check that string is not empty after cleaning
    if (cleanNum.isEmpty) {
      return 0.0;
    }

    // Parse to double and return absolute value
    return double.parse(cleanNum).abs();
  } catch (e) {
    // If parsing failed, return 0
    print('Error parsing number: $num, error: $e');
    return 0.0;
  }
}

String? numFormat(String num) {
  // Check if input is null or empty
  if (num.isEmpty) return "0";

  try {
    // Parse the string to double and take absolute value
    double value = double.parse(num).abs();

    // Check if the number has decimal part
    if (value == value.roundToDouble()) {
      // No decimal part, return as integer
      return value.round().toString();
    } else {
      // Has decimal part, format with 2 decimal places and replace dot with comma
      return value.toStringAsFixed(2).replaceAll('.', ',');
    }
  } catch (e) {
    // If parsing fails, return "0"
    return "0";
  }
}

String? formatCompactWithComma(double value) {
  if (value == null) return '0';

  double val = value.abs();
  String sign = value < 0 ? '-' : '';

  if (val >= 1000000000) {
    double billions = val / 1000000000;
    return '$sign${_formatDecimal(billions)}B';
  } else if (val >= 1000000) {
    double millions = val / 1000000;
    return '$sign${_formatDecimal(millions)}M';
  } else if (val >= 1000) {
    double thousands = val / 1000;
    return '$sign${_formatDecimal(thousands)}K';
  } else {
    return '$sign${val.toInt()}';
  }
}

String _formatDecimal(double value) {
  if (value == value.toInt()) {
    return value.toInt().toString();
  } else {
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }
}

DonationStruct donationCalculate(double? userMoney) {
  // Check if userMoney is null or invalid
  if (userMoney == null || userMoney < 0) {
    return DonationStruct(
        userMoney: 0, maxDonat: 20, suggestDonat: 0, step: 1, sliderNumber: 21);
  }

  // Define donation ranges with new boundaries
  final List<Map<String, dynamic>> ranges = [
    {
      "min": 1.0,
      "max": 11.0,
      "donation_suggestion": 1,
    },
    {
      "min": 11.01,
      "max": 19.0,
      "donation_suggestion": 3,
    },
    {
      "min": 19.01,
      "max": 49.0,
      "donation_suggestion": 5,
    },
    {
      "min": 49.01,
      "max": 99.0,
      "donation_suggestion": 10,
    },
    {
      "min": 99.01,
      "max": double.infinity,
      "donation_suggestion": 20,
    },
  ];

  // Fixed values for all ranges
  final double maxDonat = 20.0; // Maximum donation is always 20€
  final double step = 1.0; // Step is always 1€
  final int sliderNumber = 21; // 0 to 20€ = 21 divisions (0,1,2,...,20)

  // Find the appropriate suggestion for the user's money
  double suggestDonat = 0;

  if (userMoney < 1.0) {
    // For amounts less than 1.0€, suggest 0€
    suggestDonat = 0;
  } else {
    // Find the appropriate range for the user's money
    for (final range in ranges) {
      if (userMoney >= range["min"] && userMoney <= range["max"]) {
        suggestDonat = range["donation_suggestion"].toDouble();
        break;
      }
    }
  }

  // Debug output for testing
  print('Debug donationCalculate:');
  print('  Input userMoney: $userMoney');
  print('  suggestDonat: $suggestDonat');
  print('  maxDonat: $maxDonat (fixed)');
  print('  step: $step (fixed)');
  print('  sliderNumber: $sliderNumber (fixed)');

  // Create and return DonationStruct
  return DonationStruct(
    userMoney: userMoney,
    maxDonat: maxDonat,
    suggestDonat: suggestDonat,
    step: step,
    sliderNumber: sliderNumber,
  );
}

List<OrganizationRow>? searchOrg(
  List<OrganizationRow>? orgList,
  String? searchText,
  String? selectedId,
) {
  // If no organizations list provided, return null
  if (orgList == null || orgList.isEmpty) {
    return null;
  }

  // Helper function to move selected organization to the top
  List<OrganizationRow> prioritizeSelectedOrg(
      List<OrganizationRow> list, String id) {
    if (list.isEmpty) return list;

    // Find the organization with selectedId
    OrganizationRow? selectedOrg;
    List<OrganizationRow> otherOrgs = [];

    for (final org in list) {
      if (org.id == id) {
        selectedOrg = org;
      } else {
        otherOrgs.add(org);
      }
    }

    // If selected organization found, put it at the beginning
    if (selectedOrg != null) {
      return [selectedOrg, ...otherOrgs];
    }

    // If not found, return original list
    return list;
  }

  // Clean up search text and selectedId
  final cleanSearchText = searchText?.trim();
  final cleanSelectedId = selectedId?.trim();

  // If no search text provided or empty, return all organizations
  if (cleanSearchText == null || cleanSearchText.isEmpty) {
    // If we have selectedId, prioritize it at the top
    if (cleanSelectedId != null && cleanSelectedId.isNotEmpty) {
      return prioritizeSelectedOrg(orgList, cleanSelectedId);
    }
    return orgList;
  }

  // Convert search text to lowercase for case-insensitive search
  String query = cleanSearchText.toLowerCase();

  // Filter organizations based on search criteria
  List<OrganizationRow> filteredOrgs = [];

  for (final org in orgList) {
    bool matchFound = false;

    // Search in title/display_name
    if (org.title != null && org.title!.toLowerCase().contains(query)) {
      matchFound = true;
    } else if (org.displayName != null &&
        org.displayName!.toLowerCase().contains(query)) {
      matchFound = true;
    }

    // Search in description
    if (!matchFound &&
        org.description != null &&
        org.description!.toLowerCase().contains(query)) {
      matchFound = true;
    }

    // Search in city
    if (!matchFound &&
        org.city != null &&
        org.city!.toLowerCase().contains(query)) {
      matchFound = true;
    }

    // Search in email
    if (!matchFound &&
        org.email != null &&
        org.email!.toLowerCase().contains(query)) {
      matchFound = true;
    }

    // Add organization to filtered list if match found
    if (matchFound) {
      filteredOrgs.add(org);
    }
  }

  // If we have selectedId, prioritize it at the top of filtered results
  if (cleanSelectedId != null && cleanSelectedId.isNotEmpty) {
    filteredOrgs = prioritizeSelectedOrg(filteredOrgs, cleanSelectedId);
  }

  // Return filtered list (return empty list if no matches, not null)
  return filteredOrgs;
}

List<FollowersRow>? searchFollowers(
  List<FollowersRow>? followList,
  String? searchText,
) {
  // If no follow list provided, return null
  if (followList == null || followList.isEmpty) {
    return null;
  }

  // Filter out inactive follows and those with neither user nor organization
  List<FollowersRow> activeFollows = followList.where((follow) {
    return follow.isActive == true &&
        (follow.followingUserId != null ||
            follow.followingOrganizationId != null);
  }).toList();

  // If no active follows, return empty list
  if (activeFollows.isEmpty) {
    return [];
  }

  List<FollowersRow> filteredFollows = [];

  // If no search text provided or empty, return all active follows
  if (searchText == null || searchText.trim().isEmpty) {
    filteredFollows = activeFollows;
  } else {
    // Convert search text to lowercase for case-insensitive search
    String query = searchText.trim().toLowerCase();

    // Filter follows based on search criteria
    for (final follow in activeFollows) {
      bool matchFound = false;

      // Search in user name (following_user_name)
      if (follow.followingUserName != null &&
          follow.followingUserName!.toLowerCase().contains(query)) {
        matchFound = true;
      }

      // Search in organization name (following_organization_name)
      if (!matchFound &&
          follow.followingOrganizationName != null &&
          follow.followingOrganizationName!.toLowerCase().contains(query)) {
        matchFound = true;
      }

      // Add to filtered list if match found
      if (matchFound) {
        filteredFollows.add(follow);
      }
    }
  }

  // Sort by name (users first, then organizations, both alphabetically)
  filteredFollows.sort((a, b) {
    String nameA = '';
    String nameB = '';
    bool aIsUser = a.followingUserId != null;
    bool bIsUser = b.followingUserId != null;

    // Get names for comparison
    if (aIsUser) {
      nameA = a.followingUserName?.toLowerCase() ?? '';
    } else {
      nameA = a.followingOrganizationName?.toLowerCase() ?? '';
    }

    if (bIsUser) {
      nameB = b.followingUserName?.toLowerCase() ?? '';
    } else {
      nameB = b.followingOrganizationName?.toLowerCase() ?? '';
    }

    // First sort by type (users first), then by name
    if (aIsUser && !bIsUser) {
      return -1; // a is user, b is organization - a comes first
    } else if (!aIsUser && bIsUser) {
      return 1; // a is organization, b is user - b comes first
    } else {
      // Both are same type, sort alphabetically by name
      return nameA.compareTo(nameB);
    }
  });

  return filteredFollows;
}

List<InvitesRow>? searchInvites(
  List<InvitesRow>? inviteList,
  String? searchText,
) {
  // If no invite list provided, return null
  if (inviteList == null || inviteList.isEmpty) {
    return null;
  }

  // Filter out only used invites with registered users
  List<InvitesRow> activeInvites = inviteList.where((invites) {
    return invites.wasUsed == true && (invites.registeredUserId != null);
  }).toList();

  // If no active invites, return empty list
  if (activeInvites.isEmpty) {
    return [];
  }

  List<InvitesRow> filteredInvites = [];

  // If no search text provided or empty, return all active invites
  if (searchText == null || searchText.trim().isEmpty) {
    filteredInvites = activeInvites;
  } else {
    // Convert search text to lowercase for case-insensitive search
    String query = searchText.trim().toLowerCase();

    // Filter invites based on search criteria
    for (final invites in activeInvites) {
      bool matchFound = false;

      // Search in registered user display name
      if (invites.registeredUserDisplayName != null &&
          invites.registeredUserDisplayName!.toLowerCase().contains(query)) {
        matchFound = true;
      }

      // Search in registered user first name
      if (!matchFound &&
          invites.registeredUserFirstName != null &&
          invites.registeredUserFirstName!.toLowerCase().contains(query)) {
        matchFound = true;
      }

      // Search in registered user surname
      if (!matchFound &&
          invites.registeredUserSurname != null &&
          invites.registeredUserSurname!.toLowerCase().contains(query)) {
        matchFound = true;
      }

      // Add to filtered list if match found
      if (matchFound) {
        filteredInvites.add(invites);
      }
    }
  }

  // Sort by date used (most recent first - descending order)
  filteredInvites.sort((a, b) {
    DateTime? dateA = a.usedAt;
    DateTime? dateB = b.usedAt;

    // Handle null dates (put them at the end)
    if (dateA == null && dateB == null) {
      return 0;
    } else if (dateA == null) {
      return 1; // a goes after b
    } else if (dateB == null) {
      return -1; // a goes before b
    }

    // Sort by date descending (most recent first)
    return dateB.compareTo(dateA);
  });

  return filteredInvites;
}

bool searchName(
  String? name,
  String? searchText,
) {
  if (name == null || name.isEmpty) {
    return false;
  }

  // If no search text provided or empty, return true (show all)
  if (searchText == null || searchText.trim().isEmpty) {
    return true;
  }

  // Convert both to lowercase for case-insensitive search
  String nameToSearch = name.toLowerCase();
  String query = searchText.trim().toLowerCase();

  // Return true if name contains the search text
  return nameToSearch.contains(query);
}

int uniqSupporters(
  List<GamesRow>? games,
  String orgId,
) {
// Check if games list is null or empty
  if (games == null || games.isEmpty) {
    return 0;
  }

  // Check if orgId is null or empty
  if (orgId.isEmpty) {
    return 0;
  }

  // Set to store unique user IDs
  Set<String> uniqueUsers = <String>{};

  // Iterate through all games
  for (final game in games) {
    // Check if game belongs to the specified organization
    if (game.organizationId == orgId) {
      // Check if creator user ID exists and is not null
      if (game.creatorUserId != null && game.creatorUserId!.isNotEmpty) {
        // Add user ID to set (duplicates will be automatically ignored)
        uniqueUsers.add(game.creatorUserId!);
      }
    }
  }

  // Return the count of unique supporters
  return uniqueUsers.length;
}

List<UsersRow>? usersSortingAdmin(
  List<UsersRow>? users,
  String? searchText,
  bool isAsc,
  int? sortingIndex,
) {
  if (users == null || users.isEmpty) {
    return users;
  }

  List<UsersRow> filteredUsers = List.from(users);

  // Search functionality
  if (searchText != null && searchText.trim().isNotEmpty) {
    String searchLower = searchText.toLowerCase().trim();

    filteredUsers = filteredUsers.where((user) {
      // Search in username (display_name)
      bool matchesUsername =
          user.displayName?.toLowerCase().contains(searchLower) ?? false;

      // Search in first name
      bool matchesFirstName =
          user.firstName?.toLowerCase().contains(searchLower) ?? false;

      // Search in last name
      bool matchesLastName =
          user.surname?.toLowerCase().contains(searchLower) ?? false;

      // Search in email
      bool matchesEmail =
          user.email?.toLowerCase().contains(searchLower) ?? false;

      return matchesUsername ||
          matchesFirstName ||
          matchesLastName ||
          matchesEmail;
    }).toList();
  }

  // Sorting functionality
  if (sortingIndex != null) {
    filteredUsers.sort((a, b) {
      int comparison = 0;

      switch (sortingIndex) {
        case 1: // User name (display_name)
          String aValue = a.displayName ?? '';
          String bValue = b.displayName ?? '';
          comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
          break;

        case 2: // First name
          String aValue = a.firstName ?? '';
          String bValue = b.firstName ?? '';
          comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
          break;

        case 3: // Last name
          String aValue = a.surname ?? '';
          String bValue = b.surname ?? '';
          comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
          break;

        case 5: // Good Power
          double aValue = a.goodPower ?? 0.0;
          double bValue = b.goodPower ?? 0.0;
          comparison = aValue.compareTo(bValue);
          break;

        case 6: // Games count
          int aValue = a.gamesCount ?? 0;
          int bValue = b.gamesCount ?? 0;
          comparison = aValue.compareTo(bValue);
          break;

        case 7: // Registration date (created_at)
          DateTime? aDate = a.createdAt;
          DateTime? bDate = b.createdAt;

          if (aDate == null && bDate == null) {
            comparison = 0;
          } else if (aDate == null) {
            comparison = 1; // Put null dates at the end
          } else if (bDate == null) {
            comparison = -1; // Put null dates at the end
          } else {
            comparison = aDate.compareTo(bDate);
          }
          break;

        default:
          comparison = 0;
      }

      // Apply ascending/descending order
      return isAsc ? comparison : -comparison;
    });
  }

  return filteredUsers;
}

List<OrganizationRow>? orgSortingAdmin(
  List<OrganizationRow>? orgs,
  String? searchText,
  bool isAsc,
  int? sortingIndex,
  List<GamesRow>? games,
  String? stripeStatus,
) {
  if (orgs == null || orgs.isEmpty) {
    return orgs;
  }

  List<OrganizationRow> filteredOrgs = List.from(orgs);

  // Filter Stripe status
  if (stripeStatus != null && stripeStatus.trim().isNotEmpty) {
    filteredOrgs = filteredOrgs.where((org) {
      return org.stripeAccountStatus == stripeStatus.trim().toLowerCase();
    }).toList();
  }

  // Search functionality
  if (searchText != null && searchText.trim().isNotEmpty) {
    String searchLower = searchText.toLowerCase().trim();

    filteredOrgs = filteredOrgs.where((org) {
      // Search in handle (display_name)
      bool matchesHandle =
          org.displayName?.toLowerCase().contains(searchLower) ?? false;

      // Search in organization name (title)
      bool matchesOrgName =
          org.title?.toLowerCase().contains(searchLower) ?? false;

      // Search in contact email
      bool matchesEmail =
          org.contactEmail?.toLowerCase().contains(searchLower) ?? false;

      return matchesHandle || matchesOrgName || matchesEmail;
    }).toList();
  }

  // Helper function to calculate Good Energy for organization
  double calculateGoodEnergy(String orgId) {
    if (games == null || games.isEmpty) return 0.0;

    double totalSum = 0.0;
    for (final game in games) {
      if (game.organizationId == orgId) {
        double userMoney = game.userMoney?.toDouble() ?? 0;
        double teamMoney = game.teamMoney?.toDouble() ?? 0;
        double siegMoney = game.siegMoney?.toDouble() ?? 0;
        double additionalDonation =
            game.additionalDonationMoney?.toDouble() ?? 0;

        totalSum += userMoney + teamMoney + siegMoney + additionalDonation;
      }
    }
    return totalSum;
  }

  // Helper function to calculate unique supporters for organization
  int calculateSupporters(String orgId) {
    if (games == null || games.isEmpty) return 0;

    Set<String> uniqueUsers = <String>{};
    for (final game in games) {
      if (game.organizationId == orgId &&
          game.creatorUserId != null &&
          game.creatorUserId!.isNotEmpty) {
        uniqueUsers.add(game.creatorUserId!);
      }
    }
    return uniqueUsers.length;
  }

  // Sorting functionality
  if (sortingIndex != null) {
    filteredOrgs.sort((a, b) {
      int comparison = 0;

      switch (sortingIndex) {
        case 1: // Handle (display_name)
          String aValue = a.displayName ?? '';
          String bValue = b.displayName ?? '';
          comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
          break;

        case 2: // Organization name (title)
          String aValue = a.title ?? '';
          String bValue = b.title ?? '';
          comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
          break;

        case 3: // Contact Email address (contact_email)
          String aValue = a.contactEmail ?? '';
          String bValue = b.contactEmail ?? '';
          comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
          break;

        case 4: // Good Energy (calculated dynamically)
          double aValue = calculateGoodEnergy(a.id);
          double bValue = calculateGoodEnergy(b.id);
          comparison = aValue.compareTo(bValue);
          break;

        case 5: // Supporters (calculated dynamically)
          int aValue = calculateSupporters(a.id);
          int bValue = calculateSupporters(b.id);
          comparison = aValue.compareTo(bValue);
          break;

        case 6: // Registration date (created_at)
          DateTime? aDate = a.createdAt;
          DateTime? bDate = b.createdAt;
          if (aDate == null && bDate == null) {
            comparison = 0;
          } else if (aDate == null) {
            comparison = 1;
          } else if (bDate == null) {
            comparison = -1;
          } else {
            comparison = aDate.compareTo(bDate);
          }
          break;

        // case 7 is skipped - это несортируемая колонка Organization ID

        case 8: // Environment (test boolean) - было 7
          // test: true = Test environment, false = Production
          bool aValue = a.test ?? false;
          bool bValue = b.test ?? false;

          // When ascending: Production (false) first, then Test (true)
          comparison = (aValue ? 1 : 0).compareTo(bValue ? 1 : 0);
          break;

        case 9: // Visibility (hide boolean) - было 8
          // hide: false = Live/Visible, true = Hidden
          bool aValue = a.hide ?? false;
          bool bValue = b.hide ?? false;

          // When ascending: Live/Visible (false) first, then Hidden (true)
          comparison = (aValue ? 1 : 0).compareTo(bValue ? 1 : 0);
          break;

        default:
          comparison = 0;
      }

      // Apply ascending/descending order
      return isAsc ? comparison : -comparison;
    });
  }

  return filteredOrgs;
}

List<PostsRow>? postsSortingAdmin(
  List<PostsRow>? posts,
  String? searchText,
  bool isAsc,
  int? sortingIndex,
) {
  if (posts == null || posts.isEmpty) {
    return posts;
  }

  List<PostsRow> filteredPosts = List.from(posts);

  // Search functionality
  if (searchText != null && searchText.trim().isNotEmpty) {
    String searchLower = searchText.toLowerCase().trim();

    filteredPosts = filteredPosts.where((post) {
      // Search in user display_name (handle)
      bool matchesUserDisplayName =
          post.userName?.toLowerCase().contains(searchLower) ?? false;

      // Search in user first_name
      bool matchesUserFirstName =
          post.userDisplayName?.toLowerCase().contains(searchLower) ?? false;

      // Search in organization title (name)
      bool matchesOrgTitle =
          post.orgName?.toLowerCase().contains(searchLower) ?? false;

      // Search in organization display_name (handle)
      bool matchesOrgDisplayName =
          post.orgDisplayName?.toLowerCase().contains(searchLower) ?? false;

      return matchesUserDisplayName ||
          matchesUserFirstName ||
          matchesOrgTitle ||
          matchesOrgDisplayName;
    }).toList();
  }

  // Sorting functionality
  if (sortingIndex != null) {
    filteredPosts.sort((a, b) {
      int comparison = 0;

      switch (sortingIndex) {
        case 1: // User name/handle (user_name)
          String aValue = a.userName ?? '';
          String bValue = b.userName ?? '';
          comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
          break;

        case 2: // Organization name (org_name)
          String aValue = a.orgName ?? '';
          String bValue = b.orgName ?? '';
          comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
          break;

        case 3: // Good Power (lichtwatt_amount)
          int aValue = a.lichtwattAmount ?? 0;
          int bValue = b.lichtwattAmount ?? 0;
          comparison = aValue.compareTo(bValue);
          break;

        case 4: // Created at
          DateTime? aDate = a.createdAt;
          DateTime? bDate = b.createdAt;

          if (aDate == null && bDate == null) {
            comparison = 0;
          } else if (aDate == null) {
            comparison = 1; // Put null dates at the end
          } else if (bDate == null) {
            comparison = -1; // Put null dates at the end
          } else {
            comparison = aDate.compareTo(bDate);
          }
          break;

        default:
          comparison = 0;
      }

      // Apply ascending/descending order
      return isAsc ? comparison : -comparison;
    });
  }

  return filteredPosts;
}

String? imageToString(String? photo) {
  // image path to string url
  if (photo == null) return null; // Check if photo is null
  return Uri.encodeFull(photo); // Encode the photo path to a string URL
}

String? businessTypeConverter(String? input) {
  if (input == null || input.trim().isEmpty) {
    return null;
  }

  // Map: Title <-> Type
  const Map<String, String> titleToType = {
    'Kapitalgesellschaft': 'company',
    'Verein / Genossenschaft': 'non_profit',
  };

  const Map<String, String> typeToTitle = {
    'company': 'Kapitalgesellschaft',
    'non_profit': 'Verein / Genossenschaft',
  };

  String trimmedInput = input.trim();

  // Try to find in title -> type map
  if (titleToType.containsKey(trimmedInput)) {
    return titleToType[trimmedInput];
  }

  // Try to find in type -> title map
  if (typeToTitle.containsKey(trimmedInput)) {
    return typeToTitle[trimmedInput];
  }

  // If not found, return null
  return null;
}

List<String> businessTypes() {
  return [
    'Kapitalgesellschaft',
    'Verein / Genossenschaft',
  ];
}

List<String> categories() {
  return [
    'Alten- und Seniorenhilfe',
    'Behinderten- und Krankenhilfe',
    'Bildung und Erziehung',
    'Entwicklungshilfe',
    'Wissenschaft & Forschung',
    'Gesundheitswesen',
    'Katastrophenhilfe',
    'Kinder und Jugend',
    'Umwelt & Naturschutz',
    'Kunst & Kultur',
    'Menschenrechte',
    'Politische Arbeit',
    'Rettung aus Lebensgefahr',
    'Sportförderung',
    'Tierschutz',
    'Wohlfahrtspflege',
  ];
}

String? businessStructureConverter(String? input) {
  if (input == null || input.trim().isEmpty) {
    return null;
  }

  // Map: Title <-> Structure
  const Map<String, String> titleToStructure = {
    // For company
    'GmbH / UG': 'private_corporation',
    // For non_profit
    // DE whitelist: map e.V./e.G. to incorporated_non_profit
    'e.V. / e.G.': 'incorporated_non_profit',
    'gGmbh': 'incorporated_non_profit',
    'nicht eingetragener Verein': 'unincorporated_non_profit',
    // Other option -> no structure will be sent
    'Sonstiges': '',
  };

  const Map<String, String> structureToTitle = {
    // For company
    'private_corporation': 'GmbH / UG',
    // For non_profit
    'incorporated_non_profit': 'gGmbh',
    'unincorporated_non_profit': 'nicht eingetragener Verein',
  };

  String trimmedInput = input.trim();

  // Try to find in title -> structure map
  if (titleToStructure.containsKey(trimmedInput)) {
    final value = titleToStructure[trimmedInput]!;
    // Treat 'Sonstiges' as no explicit structure (return null)
    return value.isEmpty ? null : value;
  }

  // Try to find in structure -> title map
  if (structureToTitle.containsKey(trimmedInput)) {
    return structureToTitle[trimmedInput];
  }

  // If not found, return null
  return null;
}

List<String> businessStructures(String? businessType) {
  if (businessType == null || businessType.trim().isEmpty) {
    return [];
  }

  // Convert display name to type value if needed
  String typeValue = businessType.trim();

  // Map display names to type values
  const Map<String, String> titleToType = {
    'Kapitalgesellschaft': 'company',
    'Verein / Genossenschaft': 'non_profit',
  };

  if (titleToType.containsKey(typeValue)) {
    typeValue = titleToType[typeValue]!;
  }

  // Return structures based on business type
  if (typeValue == 'company') {
    return [
      'GmbH / UG',
      'Sonstiges',
    ];
  } else if (typeValue == 'non_profit') {
    return [
      'e.V. / e.G.',
      'nicht eingetragener Verein',
      'Sonstiges',
    ];
  }

  // Default fallback - empty list
  return [];
}

String? listStringToString(List<String>? list) {
  // list string to list with ", "
  if (list == null || list.isEmpty) {
    return "-";
  }
  return list.join(', ');
}

bool validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return false;
  }

  // Email validation regex pattern
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegex.hasMatch(email);
}

bool validateHandle(String? handle) {
  if (handle == null || handle.isEmpty) {
    return false;
  }

  // Length: 1-20 characters
  if (handle.length < 1 || handle.length > 20) {
    return false;
  }

  // Allowed characters: a-z, 0-9, "." (dot), "_" (underscore) - lowercase only
  final handleRegex = RegExp(r'^[a-z0-9._]+$');

  return handleRegex.hasMatch(handle);
}

bool validateName(String? name) {
  if (name == null || name.trim().isEmpty) {
    return false;
  }

  // Allowed characters: Latin letters (a-z, A-Z), space, hyphen (-), apostrophes ('')
  // Forbidden: ! @ # $ % ^ & * ( ) _ = §, digits, any other symbols
  // Apostrophes: regular apostrophe (') and curly quotes ('')
  final firstNameRegex = RegExp(r"^[a-zA-Z\s\-'\u2018\u2019]+$");

  return firstNameRegex.hasMatch(name);
}

bool validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return false;
  }

  // Min 10 characters
  if (password.length < 10) {
    return false;
  }

  // At least one number
  if (!password.contains(RegExp(r'[0-9]'))) {
    return false;
  }

  // At least one capital letter
  if (!password.contains(RegExp(r'[A-Z]'))) {
    return false;
  }

  // At least one special character (any non-alphanumeric character)
  if (!password.contains(RegExp(r'[^a-zA-Z0-9]'))) {
    return false;
  }

  return true;
}

String? urlParse(String? url) {
  if (url == null || url.trim().isEmpty) {
    return null;
  }

  // Trim whitespace
  String trimmedUrl = url.trim();

  // If URL already has a protocol (http:// or https://), return as is
  if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
    return trimmedUrl;
  }

  // If URL starts with //, add https: prefix
  if (trimmedUrl.startsWith('//')) {
    return 'https:$trimmedUrl';
  }

  // For URLs without protocol, add https://
  // This handles cases like:
  // - www.instagram.com
  // - instagram.com
  // - www.example.com/path
  return 'https://$trimmedUrl';
}

String? instagramUrlParse(String? url) {
  if (url == null || url.trim().isEmpty) {
    return null;
  }

  // Trim whitespace and remove leading/trailing slashes
  String trimmedUrl = url.trim().replaceAll(RegExp(r'^/+|/+$'), '');

  // If URL already has a protocol (http:// or https://), return as is
  if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
    return trimmedUrl;
  }

  // If URL starts with //, add https: prefix
  if (trimmedUrl.startsWith('//')) {
    return 'https:$trimmedUrl';
  }

  // If URL contains instagram.com domain, add https:// if needed
  if (trimmedUrl.contains('instagram.com')) {
    return 'https://$trimmedUrl';
  }

  // If it's just a username (no domain), construct full Instagram URL
  // Remove @ symbol if present
  String username = trimmedUrl.replaceAll('@', '');
  // Remove any leading/trailing slashes
  username = username.replaceAll(RegExp(r'^/+|/+$'), '');

  return 'https://www.instagram.com/$username/';
}

String? facebookUrlParse(String? url) {
  if (url == null || url.trim().isEmpty) {
    return null;
  }

  // Trim whitespace and remove leading/trailing slashes
  String trimmedUrl = url.trim().replaceAll(RegExp(r'^/+|/+$'), '');

  // If URL already has a protocol (http:// or https://), return as is
  if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
    return trimmedUrl;
  }

  // If URL starts with //, add https: prefix
  if (trimmedUrl.startsWith('//')) {
    return 'https:$trimmedUrl';
  }

  // If URL contains facebook.com domain, add https:// if needed
  if (trimmedUrl.contains('facebook.com')) {
    return 'https://$trimmedUrl';
  }

  // If it's just a username (no domain), construct full Facebook URL
  // Remove @ symbol if present
  String username = trimmedUrl.replaceAll('@', '');
  // Remove any leading/trailing slashes
  username = username.replaceAll(RegExp(r'^/+|/+$'), '');

  return 'https://www.facebook.com/$username';
}

String? youtubeUrlParse(String? url) {
  if (url == null || url.trim().isEmpty) {
    return null;
  }

  // Trim whitespace and remove leading/trailing slashes
  String trimmedUrl = url.trim().replaceAll(RegExp(r'^/+|/+$'), '');

  // If URL already has a protocol (http:// or https://), return as is
  if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
    return trimmedUrl;
  }

  // If URL starts with //, add https: prefix
  if (trimmedUrl.startsWith('//')) {
    return 'https:$trimmedUrl';
  }

  // If URL contains youtube.com domain, add https:// if needed
  if (trimmedUrl.contains('youtube.com')) {
    return 'https://$trimmedUrl';
  }

  // If it's just a username/channel name (no domain), construct full YouTube URL
  // Remove @ symbol if present (we'll add it back)
  String username = trimmedUrl.replaceAll('@', '');
  // Remove any leading/trailing slashes
  username = username.replaceAll(RegExp(r'^/+|/+$'), '');

  // Use modern @username format for YouTube
  return 'https://www.youtube.com/@$username';
}

int getRandomGuestNumber() {
  return math.Random().nextInt(9999 - 200) + 200;
}

List<InvitesRow> getEmptyInvitesList() {
  return [];
}

List<String> getOrgIdsSortedByGamesCount(List<GamesRow> games) {
  final Map<String, int> countMap = {};
  for (final game in games) {
    final orgId = game.organizationId;
    if (orgId != null && orgId.isNotEmpty) {
      countMap[orgId] = (countMap[orgId] ?? 0) + 1;
    }
  }
  final sorted = countMap.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.map((e) => e.key).toList();
}
