import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class Conversation {
  final String sid;
  Attributes? attributes;
  String? uniqueName;
  String? friendlyName;
  ConversationStatus status = ConversationStatus.UNKNOWN;
  ConversationSynchronizationStatus synchronizationStatus =
      ConversationSynchronizationStatus.NONE;
  DateTime? dateCreated;
  String? createdBy;
  DateTime? dateUpdated;

  //#region Message properties
  DateTime? _lastMessageDate;
  int? _lastMessageIndex;
  int? _lastReadMessageIndex;

  DateTime? get lastMessageDate => _lastMessageDate;
  int? get lastMessageIndex => _lastMessageIndex;
  int? get lastReadMessageIndex => _lastReadMessageIndex;
  //#endregion

  bool get hasMessages => lastMessageIndex != null;

  bool get hasSynchronized =>
      (status == ConversationStatus.JOINED &&
          synchronizationStatus == ConversationSynchronizationStatus.ALL) ||
      (status == ConversationStatus.NOT_PARTICIPATING &&
          synchronizationStatus == ConversationSynchronizationStatus.METADATA);

  /// Local caching event stream so each instance will use the same stream.
  final StreamController<Message> _onMessageAddedCtrl =
      StreamController<Message>.broadcast();

  /// Called when a [Message] is added to the conversation the current user is subscribed to.
  late Stream<Message> onMessageAdded;

  final StreamController<MessageUpdatedEvent> _onMessageUpdatedCtrl =
      StreamController<MessageUpdatedEvent>.broadcast();

  /// Called when a [Message] is changed in the conversation the current user is subscribed to.
  ///
  /// You could obtain the [Conversation] where it was updated by using [Message.getConversation] or [Message.conversationSid].
  /// [Message] change events include body updates and attribute updates.
  late Stream<MessageUpdatedEvent> onMessageUpdated;

  final StreamController<Message> _onMessageDeletedCtrl =
      StreamController<Message>.broadcast();

  /// Called when a [Message] is deleted from the conversation the current user is subscribed to.
  ///
  /// You could obtain the [Conversation] where it was deleted by using [Message.getConversation] or [Message.conversationSid].
  late Stream<Message> onMessageDeleted;

  final StreamController<Participant> _onParticipantAddedCtrl =
      StreamController<Participant>.broadcast();

  /// Called when a [Participant] is added to the conversation the current user is subscribed to.
  ///
  /// You could obtain the [Conversation] where it was added by using [Participant.getConversation].
  late Stream<Participant> onParticipantAdded;

  final StreamController<ParticipantUpdatedEvent> _onParticipantUpdatedCtrl =
      StreamController<ParticipantUpdatedEvent>.broadcast();

  /// Called when a [Participant] is changed in the conversation the current user is subscribed to.
  ///
  /// You could obtain the [Conversation] where it was updated by using [Participant.getConversation].
  /// [Participant] change events include body updates and attribute updates.
  late Stream<ParticipantUpdatedEvent> onParticipantUpdated;

  final StreamController<Participant> _onParticipantDeletedCtrl =
      StreamController<Participant>.broadcast();

  /// Called when a [Participant] is deleted from the conversation the current user is subscribed to.
  ///
  /// You could obtain the [Conversation] where it was deleted by using [Participant.getConversation].
  late Stream<Participant> onParticipantDeleted;

  //#region Typing events
  final StreamController<TypingEvent> _onTypingStartedCtrl =
      StreamController<TypingEvent>.broadcast();

  /// Called when an [Participant] starts typing in a [Conversation].
  late Stream<TypingEvent> onTypingStarted;

  final StreamController<TypingEvent> _onTypingEndedCtrl =
      StreamController<TypingEvent>.broadcast();

  /// Called when an [Participant] stops typing in a [Conversation].
  ///
  /// Typing indicator has a timeout after user stops typing to avoid triggering it too often. Expect about 5 seconds delay between stopping typing and receiving typing ended event.
  late Stream<TypingEvent> onTypingEnded;

  final StreamController<Conversation> _onSynchronizationChangedCtrl =
      StreamController<Conversation>.broadcast();
  //#endregion

  /// Called when conversation synchronization status changed.
  late Stream<Conversation> onSynchronizationChanged;

  Conversation(this.sid) {
    // Message events
    onMessageAdded = _onMessageAddedCtrl.stream;
    onMessageUpdated = _onMessageUpdatedCtrl.stream;
    onMessageDeleted = _onMessageDeletedCtrl.stream;

    // Participant events
    onParticipantAdded = _onParticipantAddedCtrl.stream;
    onParticipantUpdated = _onParticipantUpdatedCtrl.stream;
    onParticipantDeleted = _onParticipantDeletedCtrl.stream;

    // Typing events
    onTypingStarted = _onTypingStartedCtrl.stream;
    onTypingEnded = _onTypingEndedCtrl.stream;

    // Conversation status events
    onSynchronizationChanged = _onSynchronizationChangedCtrl.stream;
  }

  // TODO: should be private, but needs to be accessed from ConversationClient
  void updateFromMap(Map<String, dynamic> map) {
    attributes = map['attributes'] == null
        ? null
        : Attributes.fromMap(Map<String, dynamic>.from(map['attributes']));
    uniqueName = map['uniqueName'] as String?;
    friendlyName = map['friendlyName'] as String?;

    status =
        EnumToString.fromString(ConversationStatus.values, map['status']) ??
            ConversationStatus.UNKNOWN;

    synchronizationStatus = EnumToString.fromString(
            ConversationSynchronizationStatus.values,
            map['synchronizationStatus']) ??
        ConversationSynchronizationStatus.NONE;

    dateCreated = map['dateCreated'] == null
        ? null
        : DateTime.parse(map['dateCreated'] as String);
    createdBy = map['createdBy'] as String?;
    dateUpdated = map['dateUpdated'] == null
        ? null
        : DateTime.parse(map['dateUpdated'] as String);
    _lastMessageDate = map['lastMessageDate'] == null
        ? null
        : DateTime.parse(map['lastMessageDate'] as String);
    _lastReadMessageIndex = map['lastReadMessageIndex'] as int?;
    _lastMessageIndex = map['lastMessageIndex'] as int?;
  }

  void updateFromPigeon(ConversationData conversationData) {
    updateFromMap(Map<String, dynamic>.from(conversationData.encode() as Map));
  }

  /// Construct from a map.
  factory Conversation.fromMap(Map<String, dynamic> map) {
    var conversation = Conversation(
      map['sid'] as String,
    );
    conversation.updateFromMap(map);
    return conversation;
  }

  //#region Participants
  Future<bool?> addParticipantByIdentity(String identity) async {
    final result = await TwilioConversations()
        .conversationApi
        .addParticipantByIdentity(sid, identity);

    return result;
  }

  // TODO: implement addParticipantByAddress
  // TODO: implement getParticipantByIdentity
  // TODO: implement getParticipantBySid

  Future<bool?> removeParticipant(Participant participant) async {
    final result = await TwilioConversations()
        .conversationApi
        .removeParticipant(sid, participant.sid);
    return result;
  }

  Future<bool?> removeParticipantByIdentity(String identity) async {
    final result = await TwilioConversations()
        .conversationApi
        .removeParticipantByIdentity(sid, identity);

    return result;
  }

  Future<Participant?> getParticipantByIdentity(String identity) async {
    final result = await TwilioConversations()
        .conversationApi
        .getParticipantByIdentity(sid, identity);

    final participant =
        Participant.fromMap(Map<String, dynamic>.from(result.encode() as Map));

    return participant;
  }

  Future<List<Participant>> getParticipantsList() async {
    final result =
        await TwilioConversations().conversationApi.getParticipantsList(sid);

    var participants = List.from(result)
        .map((e) =>
            Participant.fromMap(Map<String, dynamic>.from(e.encode() as Map)))
        .toList();
    return participants;
  }
  //#endregion

  //#region Counts
  Future<int?> getMessagesCount() async {
    final result =
        await TwilioConversations().conversationApi.getMessagesCount(sid);

    return result.count;
  }

  Future<int?> getUnreadMessagesCount() async {
    final result =
        await TwilioConversations().conversationApi.getUnreadMessagesCount(sid);

    return result.count;
  }

  //TODO: implement getParticipantsCount
  //#endregion

  //#region Actions
  Future<bool?> join() async {
    final result = await TwilioConversations().conversationApi.join(sid);

    return result;
  }

  Future<bool?> leave() async {
    final result = await TwilioConversations().conversationApi.leave(sid);

    return result;
  }

  Future<void> destroy() async {
    return TwilioConversations().conversationApi.destroy(sid);
  }

  /// Indicate that Participant is typing in this conversation.
  ///
  /// You should call this method to indicate that a local user is entering a message into current conversation. The typing state is forwarded to users subscribed to this conversation through [Conversation.onTypingStarted] and [Conversation.onTypingEnded] callbacks.
  /// After approximately 5 seconds after the last [Conversation.typing] call the SDK will emit [Conversation.onTypingEnded] signal.
  /// One common way to implement this indicator is to call [Conversation.typing] repeatedly in response to key input events.
  Future<void> typing() async {
    try {
      return TwilioConversations().conversationApi.typing(sid);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }
  //#endregion

  //#region Messages
  Future<Message> sendMessage(MessageOptions options) async {
    try {
      final optionsData = options.toPigeon();
      final result = await TwilioConversations()
          .conversationApi
          .sendMessage(sid, optionsData);

      return Message.fromMap(Map<String, dynamic>.from(result.encode() as Map));
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  //TODO: implement removeMessage

  Future<int> setLastReadMessageIndex(int lastReadMessageIndex) async {
    try {
      final result = await TwilioConversations()
          .conversationApi
          .setLastReadMessageIndex(sid, lastReadMessageIndex);
// TODO: decide if defaulting to 0 makes sense as `null` could indicate action that needs to be taken
      return result.index ?? 0;
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  //TODO: implement advanceLastReadMessageIndex

  Future<int> setAllMessagesRead() async {
    if (!hasMessages) {
      return 0;
    }
    try {
      final result =
          await TwilioConversations().conversationApi.setAllMessagesRead(sid);
      return result.index ?? 0;
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  //TODO: implement setAllMessagesUnread

  /// Fetch at most count messages including and prior to the specified index.
  Future<List<Message>> getMessagesBefore({
    required int index,
    required int count,
  }) async {
    if (!hasMessages) {
      return [];
    }
    try {
      final result = await TwilioConversations()
          .conversationApi
          .getMessagesBefore(sid, index, count);

      final messages = result
          .whereNotNull()
          .map<Message>((i) =>
              Message.fromMap(Map<String, dynamic>.from(i.encode() as Map)))
          .toList();

      return messages;
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  //TODO: implement getMessagesAfter

  Future<List<Message>> getLastMessages(int count) async {
    if (!hasMessages) {
      return [];
    }
    final result =
        await TwilioConversations().conversationApi.getLastMessages(sid, count);

    final messages = result
        .whereNotNull()
        .map<Message>((i) =>
            Message.fromMap(Map<String, dynamic>.from(i.encode() as Map)))
        .toList();

    return messages;
  }

  Future<Message?> getMessageByIndex(int messageIndex) async {
    //TODO: implement getMessageByIndex
  }
  //#endregion

  //#region Setters
  Future<String> setFriendlyName(String friendlyName) async {
    final result = await TwilioConversations()
        .conversationApi
        .setFriendlyName(sid, friendlyName);

    this.friendlyName = result.toString();
    return friendlyName;
  }

  //TODO: implement setUniqueName
  //TODO: implement setAttributes
  //TODO: implement setNotificationLevel
  //#endregion

  void messageAdded(MessageData messageData) {
    final message = Message.fromPigeon(messageData);
    _onMessageAddedCtrl.add(message);
  }

  void messageDeleted(MessageData messageData) {
    final message = Message.fromPigeon(messageData);
    _onMessageDeletedCtrl.add(message);
  }

  void messageUpdated(MessageData messageData, String reasonString) {
    final message = Message.fromPigeon(messageData);
    final reason =
        EnumToString.fromString(MessageUpdateReason.values, reasonString);
    if (reason == null) {
      return;
    }
    _onMessageUpdatedCtrl.add(MessageUpdatedEvent(message, reason));
  }

  void participantAdded(ParticipantData participantData) {
    final participant = Participant.fromPigeon(participantData);
    _onParticipantAddedCtrl.add(participant);
  }

  void participantDeleted(ParticipantData participantData) {
    final participant = Participant.fromPigeon(participantData);
    _onParticipantDeletedCtrl.add(participant);
  }

  void participantUpdated(
      ParticipantData participantData, String reasonString) {
    final participant = Participant.fromPigeon(participantData);
    final reason =
        EnumToString.fromString(ParticipantUpdateReason.values, reasonString);
    if (reason == null) {
      return;
    }
    _onParticipantUpdatedCtrl.add(ParticipantUpdatedEvent(participant, reason));
  }

  void synchronizationChanged(ConversationData conversationData) {
    updateFromPigeon(conversationData);
    _onSynchronizationChangedCtrl.add(this);
  }

  void typingEnded(
      ConversationData conversationData, ParticipantData participantData) {
    updateFromPigeon(conversationData);
    final participant = Participant.fromPigeon(participantData);
    _onTypingEndedCtrl.add(TypingEvent(this, participant));
  }

  void typingStarted(
      ConversationData conversationData, ParticipantData participantData) {
    updateFromPigeon(conversationData);
    final participant = Participant.fromPigeon(participantData);
    _onTypingStartedCtrl.add(TypingEvent(this, participant));
  }
}
