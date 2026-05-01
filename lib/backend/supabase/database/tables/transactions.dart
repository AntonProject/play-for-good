import '../database.dart';

class TransactionsTable extends SupabaseTable<TransactionsRow> {
  @override
  String get tableName => 'transactions';

  @override
  TransactionsRow createRow(Map<String, dynamic> data) => TransactionsRow(data);
}

class TransactionsRow extends SupabaseDataRow {
  TransactionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TransactionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get fromUserId => getField<String>('from_user_id');
  set fromUserId(String? value) => setField<String>('from_user_id', value);

  String? get toOrganizationId => getField<String>('to_organization_id');
  set toOrganizationId(String? value) =>
      setField<String>('to_organization_id', value);

  double? get amountPoints => getField<double>('amount_points');
  set amountPoints(double? value) => setField<double>('amount_points', value);

  double? get amountMoney => getField<double>('amount_money');
  set amountMoney(double? value) => setField<double>('amount_money', value);

  String? get transactionType => getField<String>('transaction_type');
  set transactionType(String? value) =>
      setField<String>('transaction_type', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  double? get conversionRate => getField<double>('conversion_rate');
  set conversionRate(double? value) =>
      setField<double>('conversion_rate', value);

  String? get gameId => getField<String>('game_id');
  set gameId(String? value) => setField<String>('game_id', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String? get stripePaymentIntentId =>
      getField<String>('stripe_payment_intent_id');
  set stripePaymentIntentId(String? value) =>
      setField<String>('stripe_payment_intent_id', value);

  String? get stripePaymentIntentStatus =>
      getField<String>('stripe_payment_intent_status');
  set stripePaymentIntentStatus(String? value) =>
      setField<String>('stripe_payment_intent_status', value);

  String? get stripeChargeId => getField<String>('stripe_charge_id');
  set stripeChargeId(String? value) =>
      setField<String>('stripe_charge_id', value);

  String? get stripeChargeStatus => getField<String>('stripe_charge_status');
  set stripeChargeStatus(String? value) =>
      setField<String>('stripe_charge_status', value);

  String? get stripeTransferId => getField<String>('stripe_transfer_id');
  set stripeTransferId(String? value) =>
      setField<String>('stripe_transfer_id', value);

  String? get stripeConnectAccountId =>
      getField<String>('stripe_connect_account_id');
  set stripeConnectAccountId(String? value) =>
      setField<String>('stripe_connect_account_id', value);

  double? get stripeGrossAmount => getField<double>('stripe_gross_amount');
  set stripeGrossAmount(double? value) =>
      setField<double>('stripe_gross_amount', value);

  double? get stripeFeeAmount => getField<double>('stripe_fee_amount');
  set stripeFeeAmount(double? value) =>
      setField<double>('stripe_fee_amount', value);

  double? get stripeApplicationFeeAmount =>
      getField<double>('stripe_application_fee_amount');
  set stripeApplicationFeeAmount(double? value) =>
      setField<double>('stripe_application_fee_amount', value);

  double? get stripeNetAmount => getField<double>('stripe_net_amount');
  set stripeNetAmount(double? value) =>
      setField<double>('stripe_net_amount', value);

  DateTime? get stripeCreatedAt => getField<DateTime>('stripe_created_at');
  set stripeCreatedAt(DateTime? value) =>
      setField<DateTime>('stripe_created_at', value);

  DateTime? get stripeUpdatedAt => getField<DateTime>('stripe_updated_at');
  set stripeUpdatedAt(DateTime? value) =>
      setField<DateTime>('stripe_updated_at', value);

  String? get paymentMethodType => getField<String>('payment_method_type');
  set paymentMethodType(String? value) =>
      setField<String>('payment_method_type', value);

  String? get paymentMethodLast4 => getField<String>('payment_method_last4');
  set paymentMethodLast4(String? value) =>
      setField<String>('payment_method_last4', value);

  String? get paymentMethodBrand => getField<String>('payment_method_brand');
  set paymentMethodBrand(String? value) =>
      setField<String>('payment_method_brand', value);

  String? get receiptUrl => getField<String>('receipt_url');
  set receiptUrl(String? value) => setField<String>('receipt_url', value);

  String? get receiptEmail => getField<String>('receipt_email');
  set receiptEmail(String? value) => setField<String>('receipt_email', value);

  dynamic? get metadata => getField<dynamic>('metadata');
  set metadata(dynamic? value) => setField<dynamic>('metadata', value);

  double? get additionalDonationAmount =>
      getField<double>('additional_donation_amount');
  set additionalDonationAmount(double? value) =>
      setField<double>('additional_donation_amount', value);

  double? get userMoney => getField<double>('user_money');
  set userMoney(double? value) => setField<double>('user_money', value);

  double? get teamMoney => getField<double>('team_money');
  set teamMoney(double? value) => setField<double>('team_money', value);

  double? get sponsorMoney => getField<double>('sponsor_money');
  set sponsorMoney(double? value) => setField<double>('sponsor_money', value);

  String? get stripePaymentIntentClientSecret =>
      getField<String>('stripe_payment_intent_client_secret');
  set stripePaymentIntentClientSecret(String? value) =>
      setField<String>('stripe_payment_intent_client_secret', value);

  String? get stripeSponsorTransferId =>
      getField<String>('stripe_sponsor_transfer_id');
  set stripeSponsorTransferId(String? value) =>
      setField<String>('stripe_sponsor_transfer_id', value);

  DateTime? get sponsorTransferCompletedAt =>
      getField<DateTime>('sponsor_transfer_completed_at');
  set sponsorTransferCompletedAt(DateTime? value) =>
      setField<DateTime>('sponsor_transfer_completed_at', value);

  String? get sponsorTransferError =>
      getField<String>('sponsor_transfer_error');
  set sponsorTransferError(String? value) =>
      setField<String>('sponsor_transfer_error', value);

  DateTime? get sponsorTransferFailedAt =>
      getField<DateTime>('sponsor_transfer_failed_at');
  set sponsorTransferFailedAt(DateTime? value) =>
      setField<DateTime>('sponsor_transfer_failed_at', value);

  double? get estimatedStripeFee => getField<double>('estimated_stripe_fee');
  set estimatedStripeFee(double? value) =>
      setField<double>('estimated_stripe_fee', value);

  double? get plannedTransferToNgo =>
      getField<double>('planned_transfer_to_ngo');
  set plannedTransferToNgo(double? value) =>
      setField<double>('planned_transfer_to_ngo', value);

  double? get plannedApplicationFee =>
      getField<double>('planned_application_fee');
  set plannedApplicationFee(double? value) =>
      setField<double>('planned_application_fee', value);

  double? get actualStripeFee => getField<double>('actual_stripe_fee');
  set actualStripeFee(double? value) =>
      setField<double>('actual_stripe_fee', value);

  double? get actualNetAmount => getField<double>('actual_net_amount');
  set actualNetAmount(double? value) =>
      setField<double>('actual_net_amount', value);

  double? get actualApplicationFee =>
      getField<double>('actual_application_fee');
  set actualApplicationFee(double? value) =>
      setField<double>('actual_application_fee', value);

  double? get exactStripeFeeCalculated =>
      getField<double>('exact_stripe_fee_calculated');
  set exactStripeFeeCalculated(double? value) =>
      setField<double>('exact_stripe_fee_calculated', value);

  bool? get receiptSent => getField<bool>('receipt_sent');
  set receiptSent(bool? value) => setField<bool>('receipt_sent', value);

  DateTime? get receiptSentAt => getField<DateTime>('receipt_sent_at');
  set receiptSentAt(DateTime? value) =>
      setField<DateTime>('receipt_sent_at', value);

  String? get receiptError => getField<String>('receipt_error');
  set receiptError(String? value) => setField<String>('receipt_error', value);

  DateTime? get receiptFailedAt => getField<DateTime>('receipt_failed_at');
  set receiptFailedAt(DateTime? value) =>
      setField<DateTime>('receipt_failed_at', value);

  String? get stripeReceiptUrl => getField<String>('stripe_receipt_url');
  set stripeReceiptUrl(String? value) =>
      setField<String>('stripe_receipt_url', value);
}
