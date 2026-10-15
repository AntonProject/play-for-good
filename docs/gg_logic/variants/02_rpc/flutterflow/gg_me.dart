// Custom Action ggMe. Returns UsersRow (nullable): the signed-in user's
// profile row. Guest -> null, no request. Keep FF automatic imports above.
// Also keeps App State ggMyPhotoUrl (persisted) in sync: the header avatar
// reads it directly, so it is there on the first frame of every page.
import '/backend/supabase/supabase.dart';

Future<UsersRow?> ggMe() async {
  final uid = SupaFlow.client.auth.currentUser?.id;
  if (uid == null || uid.isEmpty) {
    FFAppState().ggMyPhotoUrl = '';
    return null;
  }
  final row = await SupaFlow.client.from('users').select().eq('id', uid).maybeSingle();
  final me = row == null ? null : UsersRow(Map<String, dynamic>.from(row));
  final photo = me?.photoUrl ?? '';
  if (FFAppState().ggMyPhotoUrl != photo) FFAppState().ggMyPhotoUrl = photo;
  return me;
}
