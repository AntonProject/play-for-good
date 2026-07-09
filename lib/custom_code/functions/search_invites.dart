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
