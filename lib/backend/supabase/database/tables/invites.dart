import '../database.dart';

class InvitesTable extends SupabaseTable<InvitesRow> {
  @override
  String get tableName => 'invites';

  @override
  InvitesRow createRow(Map<String, dynamic> data) => InvitesRow(data);
}

class InvitesRow extends SupabaseDataRow {
  InvitesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => InvitesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get inviterUserId => getField<String>('inviter_user_id')!;
  set inviterUserId(String value) => setField<String>('inviter_user_id', value);

  String get invitedEmail => getField<String>('invited_email')!;
  set invitedEmail(String value) => setField<String>('invited_email', value);

  bool get wasUsed => getField<bool>('was_used')!;
  set wasUsed(bool value) => setField<bool>('was_used', value);

  String? get registeredUserId => getField<String>('registered_user_id');
  set registeredUserId(String? value) =>
      setField<String>('registered_user_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get usedAt => getField<DateTime>('used_at');
  set usedAt(DateTime? value) => setField<DateTime>('used_at', value);

  double? get lichtwatt => getField<double>('lichtwatt');
  set lichtwatt(double? value) => setField<double>('lichtwatt', value);

  String? get registeredUserDisplayName =>
      getField<String>('registered_user_display_name');
  set registeredUserDisplayName(String? value) =>
      setField<String>('registered_user_display_name', value);

  String? get registeredUserFirstName =>
      getField<String>('registered_user_first_name');
  set registeredUserFirstName(String? value) =>
      setField<String>('registered_user_first_name', value);

  String? get registeredUserSurname =>
      getField<String>('registered_user_surname');
  set registeredUserSurname(String? value) =>
      setField<String>('registered_user_surname', value);
}
