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

bool validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return false;
  }

  // Min 10 characters
  if (password.length < 10) {
    return false;
  }

  // At least one number
  if (!password.contains(RegExp(r'[0-9]'))) {
    return false;
  }

  // At least one capital letter
  if (!password.contains(RegExp(r'[A-Z]'))) {
    return false;
  }

  // At least one special character (any non-alphanumeric character)
  if (!password.contains(RegExp(r'[^a-zA-Z0-9]'))) {
    return false;
  }

  return true;
}
