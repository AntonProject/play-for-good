import '../database.dart';

class UserOtpCodesTable extends SupabaseTable<UserOtpCodesRow> {
  @override
  String get tableName => 'user_otp_codes';

  @override
  UserOtpCodesRow createRow(Map<String, dynamic> data) => UserOtpCodesRow(data);
}

class UserOtpCodesRow extends SupabaseDataRow {
  UserOtpCodesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserOtpCodesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get code => getField<String>('code');
  set code(String? value) => setField<String>('code', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  bool? get isUsed => getField<bool>('is_used');
  set isUsed(bool? value) => setField<bool>('is_used', value);

  String? get otpType => getField<String>('otp_type');
  set otpType(String? value) => setField<String>('otp_type', value);
}
