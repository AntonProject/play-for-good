import '../database.dart';

class GamesTable extends SupabaseTable<GamesRow> {
  @override
  String get tableName => 'games';

  @override
  GamesRow createRow(Map<String, dynamic> data) => GamesRow(data);
}

class GamesRow extends SupabaseDataRow {
  GamesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GamesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  DateTime? get gameDate => getField<DateTime>('game_date');
  set gameDate(DateTime? value) => setField<DateTime>('game_date', value);

  String? get creatorUserId => getField<String>('creator_user_id');
  set creatorUserId(String? value) =>
      setField<String>('creator_user_id', value);

  String? get organizationId => getField<String>('organization_id');
  set organizationId(String? value) =>
      setField<String>('organization_id', value);

  String? get sponsorId => getField<String>('sponsor_id');
  set sponsorId(String? value) => setField<String>('sponsor_id', value);

  double? get userMoney => getField<double>('user_money');
  set userMoney(double? value) => setField<double>('user_money', value);

  double? get userPoints => getField<double>('user_points');
  set userPoints(double? value) => setField<double>('user_points', value);

  double? get teamMoney => getField<double>('team_money');
  set teamMoney(double? value) => setField<double>('team_money', value);

  double? get teamPoints => getField<double>('team_points');
  set teamPoints(double? value) => setField<double>('team_points', value);

  double? get siegMoney => getField<double>('sieg_money');
  set siegMoney(double? value) => setField<double>('sieg_money', value);

  double? get siegPoints => getField<double>('sieg_points');
  set siegPoints(double? value) => setField<double>('sieg_points', value);

  double? get sponsorMoney => getField<double>('sponsor_money');
  set sponsorMoney(double? value) => setField<double>('sponsor_money', value);

  double? get additionalDonationMoney =>
      getField<double>('additional_donation_money');
  set additionalDonationMoney(double? value) =>
      setField<double>('additional_donation_money', value);

  double? get userPointsToEuroRate =>
      getField<double>('user_points_to_euro_rate');
  set userPointsToEuroRate(double? value) =>
      setField<double>('user_points_to_euro_rate', value);

  double? get totalUserAmount => getField<double>('total_user_amount');
  set totalUserAmount(double? value) =>
      setField<double>('total_user_amount', value);

  double? get lichtwatt => getField<double>('lichtwatt');
  set lichtwatt(double? value) => setField<double>('lichtwatt', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get stripePaymentIntentId =>
      getField<String>('stripe_payment_intent_id');
  set stripePaymentIntentId(String? value) =>
      setField<String>('stripe_payment_intent_id', value);

  DateTime? get paymentCompletedAt =>
      getField<DateTime>('payment_completed_at');
  set paymentCompletedAt(DateTime? value) =>
      setField<DateTime>('payment_completed_at', value);

  double? get teamPointsToEuroRate =>
      getField<double>('team_points_to_euro_rate');
  set teamPointsToEuroRate(double? value) =>
      setField<double>('team_points_to_euro_rate', value);

  double? get siegPointsToEuroRate =>
      getField<double>('sieg_points_to_euro_rate');
  set siegPointsToEuroRate(double? value) =>
      setField<double>('sieg_points_to_euro_rate', value);

  double? get sponsorPointsToEuroRate =>
      getField<double>('sponsor_points_to_euro_rate');
  set sponsorPointsToEuroRate(double? value) =>
      setField<double>('sponsor_points_to_euro_rate', value);

  double? get sponsorPoints => getField<double>('sponsor_points');
  set sponsorPoints(double? value) => setField<double>('sponsor_points', value);

  double? get totalPoints => getField<double>('total_points');
  set totalPoints(double? value) => setField<double>('total_points', value);

  double? get additionalDonationPoints =>
      getField<double>('additional_donation_points');
  set additionalDonationPoints(double? value) =>
      setField<double>('additional_donation_points', value);

  String? get userName => getField<String>('user_name');
  set userName(String? value) => setField<String>('user_name', value);

  String? get userDisplayName => getField<String>('user_display_name');
  set userDisplayName(String? value) =>
      setField<String>('user_display_name', value);

  String? get orgName => getField<String>('org_name');
  set orgName(String? value) => setField<String>('org_name', value);

  String? get orgDisplayName => getField<String>('org_display_name');
  set orgDisplayName(String? value) =>
      setField<String>('org_display_name', value);
}
