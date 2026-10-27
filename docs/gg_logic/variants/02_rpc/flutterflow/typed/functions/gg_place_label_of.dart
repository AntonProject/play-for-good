import 'package:intl/intl.dart';

String ggPlaceLabelOf(int? place) {
  // Place badge text: "#12", "#1.234" (de_DE). 0 in the metric = "#0"
  // (26.10.2026, owner); no value at all -> ''.
  if (place == null) return '';
  if (place <= 0) return '#0';
  return '#${NumberFormat('#,##0', 'de_DE').format(place)}';
}
