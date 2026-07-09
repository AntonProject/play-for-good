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

String? numFormat(String num) {
  // Check if input is null or empty
  if (num.isEmpty) return "0";

  try {
    // Parse the string to double and take absolute value
    double value = double.parse(num).abs();

    // Check if the number has decimal part
    if (value == value.roundToDouble()) {
      // No decimal part, return as integer
      return value.round().toString();
    } else {
      // Has decimal part, format with 2 decimal places and replace dot with comma
      return value.toStringAsFixed(2).replaceAll('.', ',');
    }
  } catch (e) {
    // If parsing fails, return "0"
    return "0";
  }
}
