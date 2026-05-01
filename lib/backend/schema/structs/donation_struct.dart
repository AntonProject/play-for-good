// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DonationStruct extends BaseStruct {
  DonationStruct({
    double? userMoney,
    double? maxDonat,
    double? suggestDonat,
    double? step,
    int? sliderNumber,
  })  : _userMoney = userMoney,
        _maxDonat = maxDonat,
        _suggestDonat = suggestDonat,
        _step = step,
        _sliderNumber = sliderNumber;

  // "userMoney" field.
  double? _userMoney;
  double get userMoney => _userMoney ?? 0.0;
  set userMoney(double? val) => _userMoney = val;

  void incrementUserMoney(double amount) => userMoney = userMoney + amount;

  bool hasUserMoney() => _userMoney != null;

  // "maxDonat" field.
  double? _maxDonat;
  double get maxDonat => _maxDonat ?? 0.0;
  set maxDonat(double? val) => _maxDonat = val;

  void incrementMaxDonat(double amount) => maxDonat = maxDonat + amount;

  bool hasMaxDonat() => _maxDonat != null;

  // "suggestDonat" field.
  double? _suggestDonat;
  double get suggestDonat => _suggestDonat ?? 0.0;
  set suggestDonat(double? val) => _suggestDonat = val;

  void incrementSuggestDonat(double amount) =>
      suggestDonat = suggestDonat + amount;

  bool hasSuggestDonat() => _suggestDonat != null;

  // "step" field.
  double? _step;
  double get step => _step ?? 0.0;
  set step(double? val) => _step = val;

  void incrementStep(double amount) => step = step + amount;

  bool hasStep() => _step != null;

  // "sliderNumber" field.
  int? _sliderNumber;
  int get sliderNumber => _sliderNumber ?? 0;
  set sliderNumber(int? val) => _sliderNumber = val;

  void incrementSliderNumber(int amount) =>
      sliderNumber = sliderNumber + amount;

  bool hasSliderNumber() => _sliderNumber != null;

  static DonationStruct fromMap(Map<String, dynamic> data) => DonationStruct(
        userMoney: castToType<double>(data['userMoney']),
        maxDonat: castToType<double>(data['maxDonat']),
        suggestDonat: castToType<double>(data['suggestDonat']),
        step: castToType<double>(data['step']),
        sliderNumber: castToType<int>(data['sliderNumber']),
      );

  static DonationStruct? maybeFromMap(dynamic data) =>
      data is Map ? DonationStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'userMoney': _userMoney,
        'maxDonat': _maxDonat,
        'suggestDonat': _suggestDonat,
        'step': _step,
        'sliderNumber': _sliderNumber,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'userMoney': serializeParam(
          _userMoney,
          ParamType.double,
        ),
        'maxDonat': serializeParam(
          _maxDonat,
          ParamType.double,
        ),
        'suggestDonat': serializeParam(
          _suggestDonat,
          ParamType.double,
        ),
        'step': serializeParam(
          _step,
          ParamType.double,
        ),
        'sliderNumber': serializeParam(
          _sliderNumber,
          ParamType.int,
        ),
      }.withoutNulls;

  static DonationStruct fromSerializableMap(Map<String, dynamic> data) =>
      DonationStruct(
        userMoney: deserializeParam(
          data['userMoney'],
          ParamType.double,
          false,
        ),
        maxDonat: deserializeParam(
          data['maxDonat'],
          ParamType.double,
          false,
        ),
        suggestDonat: deserializeParam(
          data['suggestDonat'],
          ParamType.double,
          false,
        ),
        step: deserializeParam(
          data['step'],
          ParamType.double,
          false,
        ),
        sliderNumber: deserializeParam(
          data['sliderNumber'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'DonationStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is DonationStruct &&
        userMoney == other.userMoney &&
        maxDonat == other.maxDonat &&
        suggestDonat == other.suggestDonat &&
        step == other.step &&
        sliderNumber == other.sliderNumber;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([userMoney, maxDonat, suggestDonat, step, sliderNumber]);
}

DonationStruct createDonationStruct({
  double? userMoney,
  double? maxDonat,
  double? suggestDonat,
  double? step,
  int? sliderNumber,
}) =>
    DonationStruct(
      userMoney: userMoney,
      maxDonat: maxDonat,
      suggestDonat: suggestDonat,
      step: step,
      sliderNumber: sliderNumber,
    );
