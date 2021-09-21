import 'package:enum_to_string/enum_to_string.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class Message {
  final String? sid;
  final String? author;
  final DateTime? dateCreated;
  final String? subject;
  final String? body;
  final String conversationSid;
  final String? participantSid;
  // final Participant? participant;
  final int? messageIndex;
  final MessageType type;
  final bool hasMedia;
  final MessageMedia? media;
  //TODO Does not serialize currently
  final Attributes? attributes;

  Message(
    this.sid,
    this.author,
    this.dateCreated,
    this.conversationSid,
    this.subject,
    this.body,
    this.participantSid,
    // this.participant, // TODO: maybe include
    this.messageIndex,
    this.type,
    this.hasMedia,
    this.media,
    this.attributes,
  );

  /// Construct from a map.
  factory Message.fromMap(Map<String, dynamic> map) {
    final message = Message(
      map['sid'],
      map['author'],
      DateTime.parse(map['dateCreated']),
      map['conversationSid'],
      map['subject'],
      map['messageBody'],
      map['participantSid'],
      map['messageIndex'],
      EnumToString.fromString(MessageType.values, map['type']) ??
          MessageType.TEXT,
      map['hasMedia'],
      map['media'] != null
          ? MessageMedia.fromMap(map['media'].cast<String, dynamic>())
          : null,
      map['attributes'] != null
          ? Attributes.fromMap(map['attributes'].cast<String, dynamic>())
          : Attributes(AttributesType.NULL, null),
    );

    return message;
  }
}
