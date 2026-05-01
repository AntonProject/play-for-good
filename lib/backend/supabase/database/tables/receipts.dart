import '../database.dart';

class ReceiptsTable extends SupabaseTable<ReceiptsRow> {
  @override
  String get tableName => 'receipts';

  @override
  ReceiptsRow createRow(Map<String, dynamic> data) => ReceiptsRow(data);
}

class ReceiptsRow extends SupabaseDataRow {
  ReceiptsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReceiptsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  double? get amount => getField<double>('amount');
  set amount(double? value) => setField<double>('amount', value);

  DateTime? get periodStart => getField<DateTime>('period_start');
  set periodStart(DateTime? value) => setField<DateTime>('period_start', value);

  DateTime? get periodEnd => getField<DateTime>('period_end');
  set periodEnd(DateTime? value) => setField<DateTime>('period_end', value);

  String? get filename => getField<String>('filename');
  set filename(String? value) => setField<String>('filename', value);
}
