// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TypeStruct extends BaseStruct {
  TypeStruct({
    String? title,
    String? type,
  })  : _title = title,
        _type = type;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  set type(String? val) => _type = val;

  bool hasType() => _type != null;

  static TypeStruct fromMap(Map<String, dynamic> data) => TypeStruct(
        title: data['title'] as String?,
        type: data['type'] as String?,
      );

  static TypeStruct? maybeFromMap(dynamic data) =>
      data is Map ? TypeStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'title': _title,
        'type': _type,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'type': serializeParam(
          _type,
          ParamType.String,
        ),
      }.withoutNulls;

  static TypeStruct fromSerializableMap(Map<String, dynamic> data) =>
      TypeStruct(
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        type: deserializeParam(
          data['type'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'TypeStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is TypeStruct && title == other.title && type == other.type;
  }

  @override
  int get hashCode => const ListEquality().hash([title, type]);
}

TypeStruct createTypeStruct({
  String? title,
  String? type,
}) =>
    TypeStruct(
      title: title,
      type: type,
    );
