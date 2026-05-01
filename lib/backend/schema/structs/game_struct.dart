// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GameStruct extends BaseStruct {
  GameStruct({
    double? userPoints,
    double? teamPoints,
    double? siegPoints,
    double? userMoney,
    double? teamMoney,
    double? siegMoney,
    double? userMoneyRate,
    double? teamMoneyRate,
    double? siegMoneyRate,
    double? sponsorMoney,
    double? donatMoney,
    String? chosenOrgId,
    String? title,
    double? sponsorPoints,
    double? sponsorRate,
  })  : _userPoints = userPoints,
        _teamPoints = teamPoints,
        _siegPoints = siegPoints,
        _userMoney = userMoney,
        _teamMoney = teamMoney,
        _siegMoney = siegMoney,
        _userMoneyRate = userMoneyRate,
        _teamMoneyRate = teamMoneyRate,
        _siegMoneyRate = siegMoneyRate,
        _sponsorMoney = sponsorMoney,
        _donatMoney = donatMoney,
        _chosenOrgId = chosenOrgId,
        _title = title,
        _sponsorPoints = sponsorPoints,
        _sponsorRate = sponsorRate;

  // "userPoints" field.
  double? _userPoints;
  double get userPoints => _userPoints ?? 0.0;
  set userPoints(double? val) => _userPoints = val;

  void incrementUserPoints(double amount) => userPoints = userPoints + amount;

  bool hasUserPoints() => _userPoints != null;

  // "teamPoints" field.
  double? _teamPoints;
  double get teamPoints => _teamPoints ?? 0.0;
  set teamPoints(double? val) => _teamPoints = val;

  void incrementTeamPoints(double amount) => teamPoints = teamPoints + amount;

  bool hasTeamPoints() => _teamPoints != null;

  // "siegPoints" field.
  double? _siegPoints;
  double get siegPoints => _siegPoints ?? 0.0;
  set siegPoints(double? val) => _siegPoints = val;

  void incrementSiegPoints(double amount) => siegPoints = siegPoints + amount;

  bool hasSiegPoints() => _siegPoints != null;

  // "userMoney" field.
  double? _userMoney;
  double get userMoney => _userMoney ?? 0.0;
  set userMoney(double? val) => _userMoney = val;

  void incrementUserMoney(double amount) => userMoney = userMoney + amount;

  bool hasUserMoney() => _userMoney != null;

  // "teamMoney" field.
  double? _teamMoney;
  double get teamMoney => _teamMoney ?? 0.0;
  set teamMoney(double? val) => _teamMoney = val;

  void incrementTeamMoney(double amount) => teamMoney = teamMoney + amount;

  bool hasTeamMoney() => _teamMoney != null;

  // "siegMoney" field.
  double? _siegMoney;
  double get siegMoney => _siegMoney ?? 0.0;
  set siegMoney(double? val) => _siegMoney = val;

  void incrementSiegMoney(double amount) => siegMoney = siegMoney + amount;

  bool hasSiegMoney() => _siegMoney != null;

  // "userMoneyRate" field.
  double? _userMoneyRate;
  double get userMoneyRate => _userMoneyRate ?? 1.0;
  set userMoneyRate(double? val) => _userMoneyRate = val;

  void incrementUserMoneyRate(double amount) =>
      userMoneyRate = userMoneyRate + amount;

  bool hasUserMoneyRate() => _userMoneyRate != null;

  // "teamMoneyRate" field.
  double? _teamMoneyRate;
  double get teamMoneyRate => _teamMoneyRate ?? 1.0;
  set teamMoneyRate(double? val) => _teamMoneyRate = val;

  void incrementTeamMoneyRate(double amount) =>
      teamMoneyRate = teamMoneyRate + amount;

  bool hasTeamMoneyRate() => _teamMoneyRate != null;

  // "siegMoneyRate" field.
  double? _siegMoneyRate;
  double get siegMoneyRate => _siegMoneyRate ?? 1.0;
  set siegMoneyRate(double? val) => _siegMoneyRate = val;

  void incrementSiegMoneyRate(double amount) =>
      siegMoneyRate = siegMoneyRate + amount;

  bool hasSiegMoneyRate() => _siegMoneyRate != null;

  // "sponsorMoney" field.
  double? _sponsorMoney;
  double get sponsorMoney => _sponsorMoney ?? 0.0;
  set sponsorMoney(double? val) => _sponsorMoney = val;

  void incrementSponsorMoney(double amount) =>
      sponsorMoney = sponsorMoney + amount;

  bool hasSponsorMoney() => _sponsorMoney != null;

  // "donatMoney" field.
  double? _donatMoney;
  double get donatMoney => _donatMoney ?? 0.0;
  set donatMoney(double? val) => _donatMoney = val;

  void incrementDonatMoney(double amount) => donatMoney = donatMoney + amount;

  bool hasDonatMoney() => _donatMoney != null;

  // "chosenOrgId" field.
  String? _chosenOrgId;
  String get chosenOrgId => _chosenOrgId ?? '';
  set chosenOrgId(String? val) => _chosenOrgId = val;

  bool hasChosenOrgId() => _chosenOrgId != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "sponsorPoints" field.
  double? _sponsorPoints;
  double get sponsorPoints => _sponsorPoints ?? 0.0;
  set sponsorPoints(double? val) => _sponsorPoints = val;

  void incrementSponsorPoints(double amount) =>
      sponsorPoints = sponsorPoints + amount;

  bool hasSponsorPoints() => _sponsorPoints != null;

  // "sponsorRate" field.
  double? _sponsorRate;
  double get sponsorRate => _sponsorRate ?? 0.1;
  set sponsorRate(double? val) => _sponsorRate = val;

  void incrementSponsorRate(double amount) =>
      sponsorRate = sponsorRate + amount;

  bool hasSponsorRate() => _sponsorRate != null;

  static GameStruct fromMap(Map<String, dynamic> data) => GameStruct(
        userPoints: castToType<double>(data['userPoints']),
        teamPoints: castToType<double>(data['teamPoints']),
        siegPoints: castToType<double>(data['siegPoints']),
        userMoney: castToType<double>(data['userMoney']),
        teamMoney: castToType<double>(data['teamMoney']),
        siegMoney: castToType<double>(data['siegMoney']),
        userMoneyRate: castToType<double>(data['userMoneyRate']),
        teamMoneyRate: castToType<double>(data['teamMoneyRate']),
        siegMoneyRate: castToType<double>(data['siegMoneyRate']),
        sponsorMoney: castToType<double>(data['sponsorMoney']),
        donatMoney: castToType<double>(data['donatMoney']),
        chosenOrgId: data['chosenOrgId'] as String?,
        title: data['title'] as String?,
        sponsorPoints: castToType<double>(data['sponsorPoints']),
        sponsorRate: castToType<double>(data['sponsorRate']),
      );

  static GameStruct? maybeFromMap(dynamic data) =>
      data is Map ? GameStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'userPoints': _userPoints,
        'teamPoints': _teamPoints,
        'siegPoints': _siegPoints,
        'userMoney': _userMoney,
        'teamMoney': _teamMoney,
        'siegMoney': _siegMoney,
        'userMoneyRate': _userMoneyRate,
        'teamMoneyRate': _teamMoneyRate,
        'siegMoneyRate': _siegMoneyRate,
        'sponsorMoney': _sponsorMoney,
        'donatMoney': _donatMoney,
        'chosenOrgId': _chosenOrgId,
        'title': _title,
        'sponsorPoints': _sponsorPoints,
        'sponsorRate': _sponsorRate,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'userPoints': serializeParam(
          _userPoints,
          ParamType.double,
        ),
        'teamPoints': serializeParam(
          _teamPoints,
          ParamType.double,
        ),
        'siegPoints': serializeParam(
          _siegPoints,
          ParamType.double,
        ),
        'userMoney': serializeParam(
          _userMoney,
          ParamType.double,
        ),
        'teamMoney': serializeParam(
          _teamMoney,
          ParamType.double,
        ),
        'siegMoney': serializeParam(
          _siegMoney,
          ParamType.double,
        ),
        'userMoneyRate': serializeParam(
          _userMoneyRate,
          ParamType.double,
        ),
        'teamMoneyRate': serializeParam(
          _teamMoneyRate,
          ParamType.double,
        ),
        'siegMoneyRate': serializeParam(
          _siegMoneyRate,
          ParamType.double,
        ),
        'sponsorMoney': serializeParam(
          _sponsorMoney,
          ParamType.double,
        ),
        'donatMoney': serializeParam(
          _donatMoney,
          ParamType.double,
        ),
        'chosenOrgId': serializeParam(
          _chosenOrgId,
          ParamType.String,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'sponsorPoints': serializeParam(
          _sponsorPoints,
          ParamType.double,
        ),
        'sponsorRate': serializeParam(
          _sponsorRate,
          ParamType.double,
        ),
      }.withoutNulls;

  static GameStruct fromSerializableMap(Map<String, dynamic> data) =>
      GameStruct(
        userPoints: deserializeParam(
          data['userPoints'],
          ParamType.double,
          false,
        ),
        teamPoints: deserializeParam(
          data['teamPoints'],
          ParamType.double,
          false,
        ),
        siegPoints: deserializeParam(
          data['siegPoints'],
          ParamType.double,
          false,
        ),
        userMoney: deserializeParam(
          data['userMoney'],
          ParamType.double,
          false,
        ),
        teamMoney: deserializeParam(
          data['teamMoney'],
          ParamType.double,
          false,
        ),
        siegMoney: deserializeParam(
          data['siegMoney'],
          ParamType.double,
          false,
        ),
        userMoneyRate: deserializeParam(
          data['userMoneyRate'],
          ParamType.double,
          false,
        ),
        teamMoneyRate: deserializeParam(
          data['teamMoneyRate'],
          ParamType.double,
          false,
        ),
        siegMoneyRate: deserializeParam(
          data['siegMoneyRate'],
          ParamType.double,
          false,
        ),
        sponsorMoney: deserializeParam(
          data['sponsorMoney'],
          ParamType.double,
          false,
        ),
        donatMoney: deserializeParam(
          data['donatMoney'],
          ParamType.double,
          false,
        ),
        chosenOrgId: deserializeParam(
          data['chosenOrgId'],
          ParamType.String,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        sponsorPoints: deserializeParam(
          data['sponsorPoints'],
          ParamType.double,
          false,
        ),
        sponsorRate: deserializeParam(
          data['sponsorRate'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'GameStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GameStruct &&
        userPoints == other.userPoints &&
        teamPoints == other.teamPoints &&
        siegPoints == other.siegPoints &&
        userMoney == other.userMoney &&
        teamMoney == other.teamMoney &&
        siegMoney == other.siegMoney &&
        userMoneyRate == other.userMoneyRate &&
        teamMoneyRate == other.teamMoneyRate &&
        siegMoneyRate == other.siegMoneyRate &&
        sponsorMoney == other.sponsorMoney &&
        donatMoney == other.donatMoney &&
        chosenOrgId == other.chosenOrgId &&
        title == other.title &&
        sponsorPoints == other.sponsorPoints &&
        sponsorRate == other.sponsorRate;
  }

  @override
  int get hashCode => const ListEquality().hash([
        userPoints,
        teamPoints,
        siegPoints,
        userMoney,
        teamMoney,
        siegMoney,
        userMoneyRate,
        teamMoneyRate,
        siegMoneyRate,
        sponsorMoney,
        donatMoney,
        chosenOrgId,
        title,
        sponsorPoints,
        sponsorRate
      ]);
}

GameStruct createGameStruct({
  double? userPoints,
  double? teamPoints,
  double? siegPoints,
  double? userMoney,
  double? teamMoney,
  double? siegMoney,
  double? userMoneyRate,
  double? teamMoneyRate,
  double? siegMoneyRate,
  double? sponsorMoney,
  double? donatMoney,
  String? chosenOrgId,
  String? title,
  double? sponsorPoints,
  double? sponsorRate,
}) =>
    GameStruct(
      userPoints: userPoints,
      teamPoints: teamPoints,
      siegPoints: siegPoints,
      userMoney: userMoney,
      teamMoney: teamMoney,
      siegMoney: siegMoney,
      userMoneyRate: userMoneyRate,
      teamMoneyRate: teamMoneyRate,
      siegMoneyRate: siegMoneyRate,
      sponsorMoney: sponsorMoney,
      donatMoney: donatMoney,
      chosenOrgId: chosenOrgId,
      title: title,
      sponsorPoints: sponsorPoints,
      sponsorRate: sponsorRate,
    );
