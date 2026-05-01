import '../database.dart';

class OrganizationTable extends SupabaseTable<OrganizationRow> {
  @override
  String get tableName => 'organization';

  @override
  OrganizationRow createRow(Map<String, dynamic> data) => OrganizationRow(data);
}

class OrganizationRow extends SupabaseDataRow {
  OrganizationRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => OrganizationTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get displayName => getField<String>('display_name');
  set displayName(String? value) => setField<String>('display_name', value);

  int? get supporters => getField<int>('supporters');
  set supporters(int? value) => setField<int>('supporters', value);

  int? get energy => getField<int>('energy');
  set energy(int? value) => setField<int>('energy', value);

  int? get socialScore => getField<int>('social_score');
  set socialScore(int? value) => setField<int>('social_score', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get city => getField<String>('city');
  set city(String? value) => setField<String>('city', value);

  String? get registration => getField<String>('registration');
  set registration(String? value) => setField<String>('registration', value);

  String? get websiteUrl => getField<String>('website_url');
  set websiteUrl(String? value) => setField<String>('website_url', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  bool? get sponsor => getField<bool>('sponsor');
  set sponsor(bool? value) => setField<bool>('sponsor', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get stripeAccountId => getField<String>('stripe_account_id');
  set stripeAccountId(String? value) =>
      setField<String>('stripe_account_id', value);

  String? get stripeAccountStatus => getField<String>('stripe_account_status');
  set stripeAccountStatus(String? value) =>
      setField<String>('stripe_account_status', value);

  bool? get stripeChargesEnabled => getField<bool>('stripe_charges_enabled');
  set stripeChargesEnabled(bool? value) =>
      setField<bool>('stripe_charges_enabled', value);

  bool? get stripePayoutsEnabled => getField<bool>('stripe_payouts_enabled');
  set stripePayoutsEnabled(bool? value) =>
      setField<bool>('stripe_payouts_enabled', value);

  String? get stripeOnboardingUrl => getField<String>('stripe_onboarding_url');
  set stripeOnboardingUrl(String? value) =>
      setField<String>('stripe_onboarding_url', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get stripeAccountIdLive => getField<String>('stripe_account_id_live');
  set stripeAccountIdLive(String? value) =>
      setField<String>('stripe_account_id_live', value);

  String? get contactEmail => getField<String>('contact_email');
  set contactEmail(String? value) => setField<String>('contact_email', value);

  String? get contactName => getField<String>('contact_name');
  set contactName(String? value) => setField<String>('contact_name', value);

  String? get contactSurname => getField<String>('contact_surname');
  set contactSurname(String? value) =>
      setField<String>('contact_surname', value);

  String? get land => getField<String>('land');
  set land(String? value) => setField<String>('land', value);

  String? get postalCode => getField<String>('postal_code');
  set postalCode(String? value) => setField<String>('postal_code', value);

  bool? get test => getField<bool>('test');
  set test(bool? value) => setField<bool>('test', value);

  bool? get hide => getField<bool>('hide');
  set hide(bool? value) => setField<bool>('hide', value);

  String? get file => getField<String>('file');
  set file(String? value) => setField<String>('file', value);

  String? get businessType => getField<String>('business_type');
  set businessType(String? value) => setField<String>('business_type', value);

  String? get businessStructure => getField<String>('business_structure');
  set businessStructure(String? value) =>
      setField<String>('business_structure', value);

  List<String> get category => getListField<String>('category');
  set category(List<String>? value) => setListField<String>('category', value);

  String? get strae => getField<String>('strae');
  set strae(String? value) => setField<String>('strae', value);

  String? get hausNr => getField<String>('haus_nr');
  set hausNr(String? value) => setField<String>('haus_nr', value);
}
