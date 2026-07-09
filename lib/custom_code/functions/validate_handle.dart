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

bool validateHandle(String? handle) {
  if (handle == null || handle.isEmpty) {
    return false;
  }

  // Length: 1-20 characters
  if (handle.length < 1 || handle.length > 20) {
    return false;
  }

  // Allowed characters: a-z, 0-9, "." (dot), "_" (underscore) - lowercase only
  final handleRegex = RegExp(r'^[a-z0-9._]+$');

  return handleRegex.hasMatch(handle);
}
