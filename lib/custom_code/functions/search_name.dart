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
