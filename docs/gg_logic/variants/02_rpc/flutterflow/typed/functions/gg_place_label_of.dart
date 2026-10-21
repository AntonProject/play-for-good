import 'package:intl/intl.dart';

String ggPlaceLabelOf(int? place) {
  // Place badge text: "#12", "#1.234" (de_DE). No place (not loaded) -> ''
  // and the stats row hides the badge instead of showing "#0".
  if (place == null || place <= 0) return '';
  return '#${NumberFormat('#,##0', 'de_DE').format(place)}';
}
