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

String? formatCompactWithComma(double value) {
  if (value == null) return '0';

  double val = value.abs();
  String sign = value < 0 ? '-' : '';

  if (val >= 1000000000) {
    double billions = val / 1000000000;
    return '$sign${_formatDecimal(billions)}B';
  } else if (val >= 1000000) {
    double millions = val / 1000000;
    return '$sign${_formatDecimal(millions)}M';
  } else if (val >= 1000) {
    double thousands = val / 1000;
    return '$sign${_formatDecimal(thousands)}K';
  } else {
    return '$sign${val.toInt()}';
  }
}

String _formatDecimal(double value) {
  if (value == value.toInt()) {
    return value.toInt().toString();
  } else {
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }
}
