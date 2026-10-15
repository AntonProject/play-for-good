import '/backend/schema/structs/index.dart';

GgProfileStatsStruct ggStatsOrEmpty(GgProfileStatsStruct? stats) {
  // Not loaded yet -> an empty value (0 / '' / false), so a field can be read
  // without a null check on the first frame.
  return stats ?? GgProfileStatsStruct();
}
