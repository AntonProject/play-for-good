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
