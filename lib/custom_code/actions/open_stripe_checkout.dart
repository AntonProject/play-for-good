// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:url_launcher/url_launcher.dart';

Future<String?> openStripeCheckout(String checkoutUrl) async {
  try {
    final result = await FlutterWebAuth2.authenticate(
      url: checkoutUrl,
      callbackUrlScheme: "playforgoodcallback",
      options: const FlutterWebAuth2Options(
        preferEphemeral: true,
      ),
    );
    final uri = Uri.parse(result);
    final gameId = uri.queryParameters['gameId'];

    if (gameId != null) {
      await launchUrl(
        Uri.parse('playforgood://playforgood.com/finishPage?gameId=$gameId'),
        mode: LaunchMode.externalApplication,
      );
    }

    return gameId;
  } catch (e) {
    return null;
  }
}
