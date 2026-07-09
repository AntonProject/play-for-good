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
