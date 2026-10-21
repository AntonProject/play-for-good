String? ggUuidOrNone(String? value) {
  // Filter value for a uuid column. null stays null (FF skips the filter);
  // a real uuid passes; '' / 'guest' / anything else becomes the nil uuid, so
  // the query finds nothing instead of failing with 22P02
  // (invalid input syntax for type uuid).
  if (value == null) return null;
  final v = value.trim();
  final uuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
  return uuid.hasMatch(v) ? v : '00000000-0000-0000-0000-000000000000';
}
