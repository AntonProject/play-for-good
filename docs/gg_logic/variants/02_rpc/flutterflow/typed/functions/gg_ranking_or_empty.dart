import '/backend/schema/structs/index.dart';

GgRankingStruct ggRankingOrEmpty(GgRankingStruct? ranking) {
  // Not loaded yet -> an empty value (0 / '' / false), so a field can be read
  // without a null check on the first frame.
  return ranking ?? GgRankingStruct();
}
