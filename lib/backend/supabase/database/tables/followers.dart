import '../database.dart';

class FollowersTable extends SupabaseTable<FollowersRow> {
  @override
  String get tableName => 'followers';

  @override
  FollowersRow createRow(Map<String, dynamic> data) => FollowersRow(data);
}

class FollowersRow extends SupabaseDataRow {
  FollowersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FollowersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get followerUserId => getField<String>('follower_user_id');
  set followerUserId(String? value) =>
      setField<String>('follower_user_id', value);

  String? get followingUserId => getField<String>('following_user_id');
  set followingUserId(String? value) =>
      setField<String>('following_user_id', value);

  String? get followingOrganizationId =>
      getField<String>('following_organization_id');
  set followingOrganizationId(String? value) =>
      setField<String>('following_organization_id', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  String? get followingUserName => getField<String>('following_user_name');
  set followingUserName(String? value) =>
      setField<String>('following_user_name', value);

  String? get followingOrganizationName =>
      getField<String>('following_organization_name');
  set followingOrganizationName(String? value) =>
      setField<String>('following_organization_name', value);
}
