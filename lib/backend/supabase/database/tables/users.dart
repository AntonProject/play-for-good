import '../database.dart';

class UsersTable extends SupabaseTable<UsersRow> {
  @override
  String get tableName => 'users';

  @override
  UsersRow createRow(Map<String, dynamic> data) => UsersRow(data);
}

class UsersRow extends SupabaseDataRow {
  UsersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UsersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get displayName => getField<String>('display_name');
  set displayName(String? value) => setField<String>('display_name', value);

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get surname => getField<String>('surname');
  set surname(String? value) => setField<String>('surname', value);

  String? get instagramUrl => getField<String>('instagram_url');
  set instagramUrl(String? value) => setField<String>('instagram_url', value);

  String? get facebookUrl => getField<String>('facebook_url');
  set facebookUrl(String? value) => setField<String>('facebook_url', value);

  String? get youtubeUrl => getField<String>('youtube_url');
  set youtubeUrl(String? value) => setField<String>('youtube_url', value);

  String? get land => getField<String>('land');
  set land(String? value) => setField<String>('land', value);

  String? get plz => getField<String>('plz');
  set plz(String? value) => setField<String>('plz', value);

  String? get stadt => getField<String>('stadt');
  set stadt(String? value) => setField<String>('stadt', value);

  String? get strae => getField<String>('strae');
  set strae(String? value) => setField<String>('strae', value);

  String? get hausNr => getField<String>('haus_nr');
  set hausNr(String? value) => setField<String>('haus_nr', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);

  String? get info => getField<String>('info');
  set info(String? value) => setField<String>('info', value);

  int? get followersCount => getField<int>('followers_count');
  set followersCount(int? value) => setField<int>('followers_count', value);

  int? get followingCount => getField<int>('following_count');
  set followingCount(int? value) => setField<int>('following_count', value);

  double? get balanceEnergy => getField<double>('balance_energy');
  set balanceEnergy(double? value) => setField<double>('balance_energy', value);

  double? get balanceMoney => getField<double>('balance_money');
  set balanceMoney(double? value) => setField<double>('balance_money', value);

  double? get goodPower => getField<double>('good_power');
  set goodPower(double? value) => setField<double>('good_power', value);

  int? get gamesCount => getField<int>('games_count');
  set gamesCount(int? value) => setField<int>('games_count', value);

  double? get gpRingPercentage => getField<double>('gp_ring_percentage');
  set gpRingPercentage(double? value) =>
      setField<double>('gp_ring_percentage', value);

  double? get avgRingPercentage => getField<double>('avg_ring_percentage');
  set avgRingPercentage(double? value) =>
      setField<double>('avg_ring_percentage', value);

  bool? get showUsername => getField<bool>('show_username');
  set showUsername(bool? value) => setField<bool>('show_username', value);

  String? get paymentMethod => getField<String>('payment_method');
  set paymentMethod(String? value) => setField<String>('payment_method', value);

  String? get chosenOrg => getField<String>('chosen_org');
  set chosenOrg(String? value) => setField<String>('chosen_org', value);

  String? get gender => getField<String>('gender');
  set gender(String? value) => setField<String>('gender', value);

  String? get stripeCustomerId => getField<String>('stripe_customer_id');
  set stripeCustomerId(String? value) =>
      setField<String>('stripe_customer_id', value);

  bool? get emails => getField<bool>('emails');
  set emails(bool? value) => setField<bool>('emails', value);

  int? get invites => getField<int>('invites');
  set invites(int? value) => setField<int>('invites', value);

  String? get stripeCustomerIdLive =>
      getField<String>('stripe_customer_id_live');
  set stripeCustomerIdLive(String? value) =>
      setField<String>('stripe_customer_id_live', value);

  String? get role => getField<String>('role');
  set role(String? value) => setField<String>('role', value);

  bool? get receipt => getField<bool>('receipt');
  set receipt(bool? value) => setField<bool>('receipt', value);
}
