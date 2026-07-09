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

List<OrganizationRow>? searchOrg(
  List<OrganizationRow>? orgList,
  String? searchText,
  String? selectedId,
  String? initialId,
) {
  // If no organizations list provided, return null
  if (orgList == null || orgList.isEmpty) {
    return null;
  }

  // Move ONLY the initial (saved) organization to the top.
  // selectedId (the live selection) is ignored for ordering, so the list
  // does not jump around when the user picks different items.
  List<OrganizationRow> prioritizeInitialOrg(
      List<OrganizationRow> list, String id) {
    if (list.isEmpty) return list;

    OrganizationRow? initialOrg;
    List<OrganizationRow> otherOrgs = [];

    for (final org in list) {
      if (org.id == id) {
        initialOrg = org;
      } else {
        otherOrgs.add(org);
      }
    }

    // If the initial organization is present, put it first
    if (initialOrg != null) {
      return [initialOrg, ...otherOrgs];
    }

    // If not found, return the list unchanged
    return list;
  }

  // Clean up inputs
  final cleanSearchText = searchText?.trim();
  final cleanInitialId = initialId?.trim();

  // No search text -> return all organizations, with the initial one on top
  if (cleanSearchText == null || cleanSearchText.isEmpty) {
    if (cleanInitialId != null && cleanInitialId.isNotEmpty) {
      return prioritizeInitialOrg(orgList, cleanInitialId);
    }
    return orgList;
  }

  // Case-insensitive search
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

  // Pin the initial organization on top of the filtered results
  if (cleanInitialId != null && cleanInitialId.isNotEmpty) {
    filteredOrgs = prioritizeInitialOrg(filteredOrgs, cleanInitialId);
  }

  // Return filtered list (empty list if no matches, not null)
  return filteredOrgs;
}
