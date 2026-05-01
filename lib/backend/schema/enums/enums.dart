import 'package:collection/collection.dart';

enum PaymentMethods {
  card,
  paypal,
  google,
  apple,
}

enum PointsType {
  user,
  team,
  sieg,
  sponsor,
}

enum Period {
  monat,
  woche,
  gesamt,
  saison,
  letzter_monat,
  dieser_monat,
}

enum RatingGamesFilter {
  valuable,
  generous,
  social,
  active,
  recent,
}

enum AdminPages {
  statistics,
  users,
  organisations,
  posts,
  receipts,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (PaymentMethods):
      return PaymentMethods.values.deserialize(value) as T?;
    case (PointsType):
      return PointsType.values.deserialize(value) as T?;
    case (Period):
      return Period.values.deserialize(value) as T?;
    case (RatingGamesFilter):
      return RatingGamesFilter.values.deserialize(value) as T?;
    case (AdminPages):
      return AdminPages.values.deserialize(value) as T?;
    default:
      return null;
  }
}
