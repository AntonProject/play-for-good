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

String? urlParse(String? url) {
  if (url == null || url.trim().isEmpty) {
    return null;
  }

  // Trim whitespace
  String trimmedUrl = url.trim();

  // If URL already has a protocol (http:// or https://), return as is
  if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
    return trimmedUrl;
  }

  // If URL starts with //, add https: prefix
  if (trimmedUrl.startsWith('//')) {
    return 'https:$trimmedUrl';
  }

  // For URLs without protocol, add https://
  // This handles cases like:
  // - www.instagram.com
  // - instagram.com
  // - www.example.com/path
  return 'https://$trimmedUrl';
}
