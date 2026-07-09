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
