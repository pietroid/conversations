import 'package:enum_to_string/enum_to_string.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

enum UpdateReason {
  /// Participant last read message index has changed.
  /// <p>
  /// This update event is fired when participant's read horizon changes. This usually
  /// indicates that some messages were read by that participant.
  LAST_READ_MESSAGE_INDEX,

  /// Participant last read message timestamp has changed.
  /// <p>
  /// This update event is fired when participant's read horizon changes (or just set to the same position again).
  /// This usually indicates that some messages were read by that participant.
  LAST_READ_TIMESTAMP,

  /// Participant attributes have changed.
  /// <p>
  /// This update event is fired when participant's attributes change.
  ATTRIBUTES
}

enum Type {
  CHAT,
  OTHER,
  SMS,
  UNSET,
  WHATSAPP,
  UNKNOWN,
}

class Participant {
  final String sid;
  final String conversationSid;
  final Type type;
  Attributes attributes;
  String? dateCreated;
  String? dateUpdated;
  String? identity;
  int? lastReadMessageIndex;
  String? lastReadTimestamp;

  User? _user;

  Participant(
    this.sid,
    this.type,
    this.conversationSid,
    this.attributes,
    this.dateCreated,
    this.dateUpdated,
    this.identity,
    this.lastReadMessageIndex,
    this.lastReadTimestamp,
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
}
