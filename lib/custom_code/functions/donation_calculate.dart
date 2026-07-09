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

DonationStruct donationCalculate(double? userMoney) {
  // Check if userMoney is null or invalid
  if (userMoney == null || userMoney < 0) {
    return DonationStruct(
        userMoney: 0, maxDonat: 20, suggestDonat: 0, step: 1, sliderNumber: 21);
  }

  // Define donation ranges with new boundaries
  final List<Map<String, dynamic>> ranges = [
    {
      "min": 1.0,
      "max": 11.0,
      "donation_suggestion": 1,
    },
    {
      "min": 11.01,
      "max": 19.0,
      "donation_suggestion": 3,
    },
    {
      "min": 19.01,
      "max": 49.0,
      "donation_suggestion": 5,
    },
    {
      "min": 49.01,
      "max": 99.0,
      "donation_suggestion": 10,
    },
    {
      "min": 99.01,
      "max": double.infinity,
      "donation_suggestion": 20,
    },
  ];

  // Fixed values for all ranges
  final double maxDonat = 20.0; // Maximum donation is always 20€
  final double step = 1.0; // Step is always 1€
  final int sliderNumber = 21; // 0 to 20€ = 21 divisions (0,1,2,...,20)

  // Find the appropriate suggestion for the user's money
  double suggestDonat = 0;

  if (userMoney < 1.0) {
    // For amounts less than 1.0€, suggest 0€
    suggestDonat = 0;
  } else {
    // Find the appropriate range for the user's money
    for (final range in ranges) {
      if (userMoney >= range["min"] && userMoney <= range["max"]) {
        suggestDonat = range["donation_suggestion"].toDouble();
        break;
      }
    }
  }

  // Debug output for testing
  print('Debug donationCalculate:');
  print('  Input userMoney: $userMoney');
  print('  suggestDonat: $suggestDonat');
  print('  maxDonat: $maxDonat (fixed)');
  print('  step: $step (fixed)');
  print('  sliderNumber: $sliderNumber (fixed)');

  // Create and return DonationStruct
  return DonationStruct(
    userMoney: userMoney,
    maxDonat: maxDonat,
    suggestDonat: suggestDonat,
    step: step,
    sliderNumber: sliderNumber,
  );
}
