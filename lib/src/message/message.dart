import 'package:enum_to_string/enum_to_string.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class Message {
  final String? sid;
  final int? messageIndex;
  final String? author;
  final String? subject;
  final String? body;
  final MessageType type;
  final bool hasMedia;
  final MessageMedia? media;
  final String conversationSid;
  final String? participantSid;
  //TODO: review including Participant - as we are not maintaining a collection of them at the dart layer that we would want to update, simply constructing one may be sufficient. This should continue to remain the case so long as we are not distributing events via a Participant instance
  // final Participant? participant;
  final DateTime? dateCreated;
  final DateTime? dateUpdated;
  final String? lastUpdatedBy;
  final Attributes? attributes;

  const Message(
    this.sid,
    this.author,
    this.dateCreated,
    this.dateUpdated,
    this.lastUpdatedBy,
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
      DateTime.parse(map['dateUpdated']),
      map['lastUpdatedBy'],
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

  Future<Conversation?> getConversation() async {
    return TwilioConversations.conversationClient
        ?.getConversation(conversationSidOrUniqueName: conversationSid);
  }

  //TODO: implement getAggregatedDeliveryReceipt
  //TODO: implement getDetailedDeliveryReceiptList
  //TODO: implement updateMessageBody
  //TODO: implement setAttributes
}
