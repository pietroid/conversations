import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
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
    final result = await TwilioConversations.methodChannel.invokeMethod<bool>(
        'ParticipantsMethods.addParticipantByIdentity',
        {'identity': identity, 'conversationSid': sid});

    return result;
  }

  // TODO: implement addParticipantByAddress
  // TODO: implement removeParticipant
  // TODO: implement getParticipantByIdentity
  // TODO: implement getParticipantBySid

  Future<bool?> removeParticipantByIdentity(String identity) async {
    final result = await TwilioConversations.methodChannel.invokeMethod<bool>(
        'ParticipantsMethods.removeParticipantByIdentity',
        {'identity': identity, 'conversationSid': sid});

    return result;
  }

  Future<List<Participant>> getParticipantsList() async {
    final result = await TwilioConversations.methodChannel.invokeMethod(
        'ParticipantsMethods.getParticipantsList', {'conversationSid': sid});

    var participants = List.from(result)
        .map((e) => Participant.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return participants;
  }
  //#endregion

  // TODO: `getUsers` not a part of the Conversations SDK, either deprecate, or ensure consistent behaviour across platforms
  Future<List<User>> getUsers() async {
    final result = await TwilioConversations.methodChannel
        .invokeMethod('ParticipantsMethods.getUsers', {'conversationSid': sid});

    var users = result
        .map<User>((e) => User.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return users;
  }

  //#region Counts
  Future<int?> getUnreadMessagesCount() async {
    final result = await TwilioConversations.methodChannel.invokeMethod<int>(
        'ConversationMethods.getUnreadMessagesCount', {'conversationSid': sid});

    return result;
  }

  //TODO: implement getMessagesCount
  //TODO: implement getParticipantsCount
  //#endregion

  //#region Actions
  Future<bool?> join() async {
    final result = await TwilioConversations.methodChannel.invokeMethod<bool>(
        'ConversationMethods.join', {'conversationSid': sid});

    return result;
  }

  Future<bool?> leave() async {
    final result = await TwilioConversations.methodChannel.invokeMethod<bool>(
        'ConversationMethods.leave', {'conversationSid': sid});

    return result;
  }

  // TODO: implement `destroy`

  /// Indicate that Participant is typing in this conversation.
  ///
  /// You should call this method to indicate that a local user is entering a message into current conversation. The typing state is forwarded to users subscribed to this conversation through [Conversation.onTypingStarted] and [Conversation.onTypingEnded] callbacks.
  /// After approximately 5 seconds after the last [Conversation.typing] call the SDK will emit [Conversation.onTypingEnded] signal.
  /// One common way to implement this indicator is to call [Conversation.typing] repeatedly in response to key input events.
  Future<void> typing() async {
    try {
      return await TwilioConversations.methodChannel
          .invokeMethod('ConversationMethods.typing', {'conversationSid': sid});
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }
  //#endregion

  //#region Messages
  Future<Message> sendMessage(MessageOptions options) async {
    try {
      final result = await TwilioConversations.methodChannel
          .invokeMethod('MessagesMethods.sendMessage', {
        'options': options.toMap(),
        'conversationSid': sid,
      });

      return Message.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  //TODO: implement removeMessage

  Future<int> setLastReadMessageIndex(int lastReadMessageIndex) async {
    try {
      return await TwilioConversations.methodChannel.invokeMethod(
          'MessagesMethods.setLastReadMessageIndex', {
        'conversationSid': sid,
        'lastReadMessageIndex': lastReadMessageIndex
      }) as int;
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
      return await TwilioConversations.methodChannel
          .invokeMethod('MessagesMethods.setAllMessagesRead', {
        'conversationSid': sid,
      }) as int;
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
      final result = await TwilioConversations.methodChannel
          .invokeMethod('MessagesMethods.getMessagesBefore', {
        'index': index,
        'count': count,
        'conversationSid': sid,
      });

      final messages = result
          .map<Message>((i) => Message.fromMap(Map<String, dynamic>.from(i)))
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
    final result = await TwilioConversations.methodChannel
        .invokeMethod('MessagesMethods.getLastMessages', {
      'count': count,
      'conversationSid': sid,
    });

    var messages = result
        .map((e) => Message.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return messages;
  }

  //TODO: implement getMessageByIndex
  //#endregion

  //#region Setters
  Future<String> setFriendlyName(String friendlyName) async {
    final result = await TwilioConversations.methodChannel
        .invokeMethod('ConversationMethods.setFriendlyName', {
      'conversationSid': sid,
      'friendlyName': friendlyName,
    });

    this.friendlyName = result.toString();
    return friendlyName;
  }

  //TODO: implement setUniqueName
  //TODO: implement setAttributes
  //TODO: implement setNotificationLevel
  //#endregion

  /// Parse native channel events to the right event streams.
  void parseEvents(dynamic event) {
    final eventName = event['name'] as String;
    final data = Map<String, dynamic>.from(event['data'] as Map);
    if (data['conversation'] != null) {
      final conversationMap =
          Map<String, dynamic>.from(data['conversation'] as Map);
      updateFromMap(conversationMap);
    }

    Message? message;
    if (data['message'] != null) {
      final messageMap = Map<String, dynamic>.from(data['message'] as Map);
      message = Message.fromMap(messageMap);
    }

    Participant? participant;
    if (data['participant'] != null) {
      final memberMap = Map<String, dynamic>.from(data['participant'] as Map);
      participant = Participant.fromMap(memberMap);
    }

    dynamic reason;
    if (data['reason'] != null) {
      final reasonMap =
          Map<String, dynamic>.from(data['reason'] as Map<dynamic, dynamic>);
      switch (reasonMap['type'] as String) {
        case 'message':
          reason = EnumToString.fromString(
              MessageUpdateReason.values, reasonMap['value'] as String);
          break;
        case 'participant':
          reason = EnumToString.fromString(
              ParticipantUpdateReason.values, reasonMap['value'] as String);
          break;
      }
    }

    switch (eventName) {
      case 'messageAdded':
        if (message != null) {
          _onMessageAddedCtrl.add(message);
        }
        break;
      case 'messageUpdated':
        if (message != null && reason != null) {
          _onMessageUpdatedCtrl
              .add(MessageUpdatedEvent(message, reason as MessageUpdateReason));
        }
        break;
      case 'messageDeleted':
        if (message != null) {
          _onMessageDeletedCtrl.add(message);
        }
        break;
      case 'participantAdded':
        if (participant != null) {
          _onParticipantAddedCtrl.add(participant);
        }
        break;
      case 'participantUpdated':
        if (participant != null && reason != null) {
          _onParticipantUpdatedCtrl.add(ParticipantUpdatedEvent(
              participant, reason as ParticipantUpdateReason));
        }
        break;
      case 'participantDeleted':
        if (participant != null) {
          _onParticipantDeletedCtrl.add(participant);
        }
        break;
      case 'typingStarted':
        if (participant != null) {
          _onTypingStartedCtrl.add(TypingEvent(this, participant));
        }
        break;
      case 'typingEnded':
        if (participant != null) {
          _onTypingEndedCtrl.add(TypingEvent(this, participant));
        }
        break;
      case 'synchronizationChanged':
        _onSynchronizationChangedCtrl.add(this);
        break;
      default:
        TwilioConversations.log("Event '$eventName' not yet implemented");
        break;
    }
  }
}
