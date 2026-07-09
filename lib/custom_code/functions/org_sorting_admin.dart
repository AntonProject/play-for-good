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
