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
