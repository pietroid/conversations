import 'package:enum_to_string/enum_to_string.dart';
import 'package:twilio_conversations/api.dart';
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
      EnumToString.fromString(Type.values, map['type']) ?? Type.UNSET,
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
    return participant;
  }

  factory Participant.fromPigeon(ParticipantData participantData) {
    return Participant.fromMap(
        Map<String, dynamic>.from(participantData.encode() as Map));
  }

  Future<User?> getUser() async {
    final result = await TwilioConversations()
        .participantApi
        .getUser(conversationSid, sid);

    return User.fromMap(Map<String, dynamic>.from(result.encode() as Map));
  }

  Future<Conversation?> getConversation() async {
    return TwilioConversations.conversationClient
        ?.getConversation(conversationSidOrUniqueName: conversationSid);
  }

  //TODO: implement setAttributes
  //TODO: implement remove
}
