// part of twilio_conversations;

import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';

enum AttributesType {
  OBJECT,
  ARRAY,
  STRING,
  NUMBER,
  BOOLEAN,
  NULL,
}

class Attributes {
  //#region Private API properties
  final AttributesType _type;

  final String? _json;
  //#endregion

  /// Returns attributes type
  AttributesType get type => _type;

  String? get data => _json;

  // In the Android SDK, Twilio uses JSONObject.NULL as the data for NULL Attributes
  // Which stringifies to "null"
  // TODO: once fully converted to Pigeon, review whether we can resume expecting `_json` to be `null`
  Attributes(this._type, this._json)
      : assert((_type == AttributesType.NULL) ||
            (_type != AttributesType.NULL && _json != null));
  // : assert((_type == AttributesType.NULL && _json == null) ||
  //       (_type != AttributesType.NULL && _json != null));

  factory Attributes.fromMap(Map<String, dynamic> map) {
    final type = EnumToString.fromString(AttributesType.values, map['type']) ??
        AttributesType.NULL;
    final json = map['data'];
    return Attributes(type, json);
  }

  Map<String, dynamic>? getJSONObject() {
    final json = _json;
    if (type != AttributesType.OBJECT || json == null) {
      return null;
    } else {
      return jsonDecode(json);
    }
  }

  List<Map<String, dynamic>>? getJSONArray() {
    final json = _json;
    if (type != AttributesType.ARRAY || json == null) {
      return null;
    } else {
      return List<Map<String, dynamic>>.from(jsonDecode(json));
    }
  }

  String? getString() {
    if (type != AttributesType.STRING) {
      return null;
    } else {
      return _json;
    }
  }

  num? getNumber() {
    final json = _json;
    if (type != AttributesType.NUMBER || json == null) {
      return null;
    } else {
      return num.tryParse(json);
    }
  }

  bool? getBoolean() {
    if (type != AttributesType.BOOLEAN) {
      return null;
    } else {
      return _json == 'true';
    }
  }
}
