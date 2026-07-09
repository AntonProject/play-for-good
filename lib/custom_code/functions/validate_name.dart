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

bool validateName(String? name) {
  if (name == null || name.trim().isEmpty) {
    return false;
  }

  // Allowed characters: Latin letters (a-z, A-Z), space, hyphen (-), apostrophes ('')
  // Forbidden: ! @ # $ % ^ & * ( ) _ = §, digits, any other symbols
  // Apostrophes: regular apostrophe (') and curly quotes ('')
  final firstNameRegex = RegExp(r"^[a-zA-Z\s\-'\u2018\u2019]+$");

  return firstNameRegex.hasMatch(name);
}
