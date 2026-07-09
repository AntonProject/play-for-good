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
