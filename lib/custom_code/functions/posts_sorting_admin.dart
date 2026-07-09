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
