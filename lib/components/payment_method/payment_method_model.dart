import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'payment_method_widget.dart' show PaymentMethodWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PaymentMethodModel extends FlutterFlowModel<PaymentMethodWidget> {
  ///  Local state fields for this component.

  String? selectedType = 'card';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
