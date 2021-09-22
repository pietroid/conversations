import 'package:enum_to_string/enum_to_string.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class Participant {
  final String sid;
  final String conversationSid;
  final Type type;

  Attributes _attributes;
  Attributes get attributes => _attributes;

  String? _dateCreated;
  String? get dateCreated => _dateCreated;

  String? _dateUpdated;
  String? get dateUpdated => _dateUpdated;

  String? _identity;
  String? get identity => _identity;

  int? _lastReadMessageIndex;
  int? get lastReadMessageIndex => _lastReadMessageIndex;

  String? _lastReadTimestamp;
  String? get lastReadTimestamp => _lastReadTimestamp;

  User? _user;

  Participant(
    this.sid,
    this.type,
    this.conversationSid,
    this._attributes,
    this._dateCreated,
    this._dateUpdated,
    this._identity,
    this._lastReadMessageIndex,
    this._lastReadTimestamp,
  );

  /// Construct from a map.
  factory Participant.fromMap(Map<String, dynamic> map) {
    final participant = Participant(
      map['sid'],
      EnumToString.fromString(Type.values, map['type']) ?? Type.UNKNOWN,
      map['conversationSid'],
      map['attributes'] != null
          ? Attributes.fromMap(map['attributes'].cast<String, dynamic>())
          : Attributes(AttributesType.NULL, null),
      map['dateCreated'],
      map['dateUpdated'],
      map['identity'],
      map['lastReadMessageIndex'],
      map['lastReadTimestamp'],
    );
    // member._updateFromMap(map);
    return participant;
  }

  Future<User?> getUser() async {
    if (_user != null) {
      return _user;
    }

    final result = await TwilioConversations.methodChannel.invokeMethod(
        'ParticipantMethods.getUser',
        {'conversationSid': conversationSid, 'participantSid': sid});
    if (result == null) {
      return null;
    }
    return _user = User.fromMap(Map<String, dynamic>.from(result));
  }

  //TODO: implement setAttributes
  //TODO: implement updateFromMap, and use as appropriate
  //TODO: implement remove
}
