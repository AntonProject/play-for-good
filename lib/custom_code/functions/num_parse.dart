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

double? numParse(String? num) {
  // Check for null or empty string
  if (num == null || num.isEmpty) {
    return 0.0;
  }

  try {
    // Remove all spaces
    String cleanNum = num.replaceAll(' ', '');

    // Remove currency symbols and other non-numeric characters, except digits, dots and commas
    // REMOVED: +- from the regex to not allow negative numbers
    cleanNum = cleanNum.replaceAll(RegExp(r'[^\d.,]'), '');

    // Replace commas with dots
    cleanNum = cleanNum.replaceAll(',', '.');

    // Handle multiple dots (take the last one as decimal separator)
    if (cleanNum.contains('.')) {
      int lastDotIndex = cleanNum.lastIndexOf('.');
      if (cleanNum.indexOf('.') != lastDotIndex) {
        // Multiple dots found, remove all except the last one
        String beforeLastDot =
            cleanNum.substring(0, lastDotIndex).replaceAll('.', '');
        String afterLastDot = cleanNum.substring(lastDotIndex);
        cleanNum = beforeLastDot + afterLastDot;
      }
    }

    // Check that string is not empty after cleaning
    if (cleanNum.isEmpty) {
      return 0.0;
    }

    // Parse to double and return absolute value
    return double.parse(cleanNum).abs();
  } catch (e) {
    // If parsing failed, return 0
    print('Error parsing number: $num, error: $e');
    return 0.0;
  }
}
