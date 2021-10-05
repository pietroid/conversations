import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class ConversationClient {
  Map<String, Conversation> conversations = <String, Conversation>{};

  String? myIdentity;
  ConnectionState connectionState = ConnectionState.UNKNOWN;

  bool _isReachabilityEnabled = false;
  bool get isReachabilityEnabled => _isReachabilityEnabled;

  /// Stream for the native client events.
  late StreamSubscription<dynamic> _clientStream;

  /// Stream for the native conversation events.
  late StreamSubscription<dynamic> _conversationStream;

  /// Stream for the notification events.
  late StreamSubscription<dynamic> _notificationStream;

  final StreamController<bool> _onClientListenerAttachedCtrl =
      StreamController<bool>.broadcast();

  /// Called when client listener is listening and ready for client creation.
  late Stream<bool> onClientListenerAttached;

  final StreamController<String> _onAddedToConversationNotificationCtrl =
      StreamController<String>.broadcast();

  /// Called when client receives a push notification for added to Conversation event.
  late Stream<String> onAddedToConversationNotification;

  final StreamController<Conversation> _onConversationAddedCtrl =
      StreamController<Conversation>.broadcast();

  /// Called when the current user has a conversation added to their conversation list, conversation status is not specified.
  late Stream<Conversation> onConversationAdded;

  final StreamController<Conversation> _onConversationDeletedCtrl =
      StreamController<Conversation>.broadcast();

  /// Called when one of the conversation of the current user is deleted.
  late Stream<Conversation> onConversationDeleted;

  final StreamController<ConnectionState> _onConnectionStateCtrl =
      StreamController<ConnectionState>.broadcast();

  /// Called when client connnection state has changed.
  late Stream<ConnectionState> onConnectionState;

  final StreamController<ClientSynchronizationStatus>
      _onClientSynchronizationCtrl =
      StreamController<ClientSynchronizationStatus>.broadcast();

  /// Called when client synchronization status changes.
  late Stream<ClientSynchronizationStatus> onClientSynchronization;

  final StreamController<Conversation>
      _onConversationSynchronizationChangeCtrl =
      StreamController<Conversation>.broadcast();

  /// Called when conversation synchronization status changed.
  ///
  /// Use [Conversation.synchronizationStatus] to obtain new conversation status.
  late Stream<Conversation> onConversationSynchronizationChange;

  final StreamController<ConversationUpdatedEvent> _onConversationUpdatedCtrl =
      StreamController<ConversationUpdatedEvent>.broadcast();

  /// Called when the conversation is updated.
  ///
  /// [Conversation] synchronization updates are delivered via different callback.
  late Stream<ConversationUpdatedEvent> onConversationUpdated;

  final StreamController<ErrorInfo> _onErrorCtrl =
      StreamController<ErrorInfo>.broadcast();

  /// Called when an error condition occurs.
  late Stream<ErrorInfo> onError;

  final StreamController<NewMessageNotificationEvent>
      _onNewMessageNotificationCtrl =
      StreamController<NewMessageNotificationEvent>.broadcast();

  /// Called when client receives a push notification for new message.
  late Stream<NewMessageNotificationEvent> onNewMessageNotification;

  final StreamController<NotificationRegistrationEvent>
      _onNotificationRegisteredCtrl =
      StreamController<NotificationRegistrationEvent>.broadcast();

  /// Called when attempt to register device for notifications has completed.
  late Stream<NotificationRegistrationEvent> onNotificationRegistered;

  final StreamController<String> _onRemovedFromConversationNotificationCtrl =
      StreamController<String>.broadcast();

  /// Called when client receives a push notification for removed from conversation event.
  late Stream<String> onRemovedFromConversationNotification;

  final StreamController<NotificationRegistrationEvent>
      _onNotificationDeregisteredCtrl =
      StreamController<NotificationRegistrationEvent>.broadcast();

  /// Called when attempt to register device for notifications has completed.
  late Stream<NotificationRegistrationEvent> onNotificationDeregistered;

  final StreamController<ErrorInfo> _onNotificationFailedCtrl =
      StreamController<ErrorInfo>.broadcast();

  /// Called when registering for push notifications fails.
  late Stream<ErrorInfo> onNotificationFailed;

  //#region Token events
  final StreamController<void> _onTokenAboutToExpireCtrl =
      StreamController<void>.broadcast();

  /// Called when token is about to expire soon.
  ///
  /// In response, [ConversationClient] should generate a new token and call [ConversationClient.updateToken] as soon as possible.
  late Stream<void> onTokenAboutToExpire;

  final StreamController<void> _onTokenExpiredCtrl =
      StreamController<void>.broadcast();

  /// Called when token has expired.
  ///
  /// In response, [ConversationClient] should generate a new token and call [ConversationClient.updateToken] as soon as possible.
  late Stream<void> onTokenExpired;

  final StreamController<User> _onUserSubscribedCtrl =
      StreamController<User>.broadcast();

  /// Called when a user is subscribed to and will receive realtime state updates.
  late Stream<User> onUserSubscribed;

  final StreamController<User> _onUserUnsubscribedCtrl =
      StreamController<User>.broadcast();

  /// Called when a user is unsubscribed from and will not receive realtime state updates anymore.
  late Stream<User> onUserUnsubscribed;

  final StreamController<UserUpdatedEvent> _onUserUpdatedCtrl =
      StreamController<UserUpdatedEvent>.broadcast();

  /// Called when user info is updated for currently loaded users.
  late Stream<UserUpdatedEvent> onUserUpdated;

  ConversationClient() {
    // TODO: Only used to ensure initialization completion, should not be exposed publicly
    onClientListenerAttached = _onClientListenerAttachedCtrl.stream;

    // Conversation events
    onConversationAdded = _onConversationAddedCtrl.stream;
    onConversationDeleted = _onConversationDeletedCtrl.stream;
    onConversationSynchronizationChange =
        _onConversationSynchronizationChangeCtrl.stream;
    onConversationUpdated = _onConversationUpdatedCtrl.stream;

    // Conversation client events
    onError = _onErrorCtrl.stream;
    onClientSynchronization = _onClientSynchronizationCtrl.stream;
    onConnectionState = _onConnectionStateCtrl.stream;
    onTokenExpired = _onTokenExpiredCtrl.stream;
    onTokenAboutToExpire = _onTokenAboutToExpireCtrl.stream;

    // User Events
    onUserSubscribed = _onUserSubscribedCtrl.stream;
    onUserUnsubscribed = _onUserUnsubscribedCtrl.stream;
    onUserUpdated = _onUserUpdatedCtrl.stream;

    // Push notification events
    onNewMessageNotification = _onNewMessageNotificationCtrl.stream;
    onAddedToConversationNotification =
        _onAddedToConversationNotificationCtrl.stream;
    onRemovedFromConversationNotification =
        _onRemovedFromConversationNotificationCtrl.stream;
    onNotificationDeregistered = _onNotificationDeregisteredCtrl.stream;
    onNotificationFailed = _onNotificationFailedCtrl.stream;
    onNotificationRegistered = _onNotificationRegisteredCtrl.stream;

    _clientStream = TwilioConversations.clientChannel
        .receiveBroadcastStream(0)
        .listen(_parseEvents);
    _conversationStream = TwilioConversations.conversationChannel
        .receiveBroadcastStream(0)
        .listen(_parseConversationEvents);
    _notificationStream = TwilioConversations.notificationChannel
        .receiveBroadcastStream(0)
        .listen(_parseNotificationEvents);
  }

  void updateFromMap(Map<String, dynamic> json) {
    myIdentity = json['myIdentity'] as String;
    connectionState = EnumToString.fromString(
            ConnectionState.values, json['connectionState']) ??
        ConnectionState.UNKNOWN;
    _isReachabilityEnabled = json['isReachabilityEnabled'] ?? false;
  }

  /// Updates the authentication token for this client.
  Future<void> updateToken(String token) async {
    try {
      return TwilioConversations.conversationsClientApi.updateToken(token);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  /// Shuts down the conversation client.
  ///
  /// This will dispose() the client after shutdown, so the client cannot be used after this call.
  Future<void> shutdown() async {
    try {
      await _clientStream.cancel();
      await _conversationStream.cancel();
      await _notificationStream.cancel();
      TwilioConversations.conversationClient = null;
      await TwilioConversations.conversationsClientApi.shutdown();
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  // TODO: test push notification registration/deregistration and delivery
  /// Registers for push notifications. Uses APNs on iOS and FCM on Android.
  ///
  /// Twilio iOS SDK handles receiving messages when app is in the background and displaying
  /// notifications.
  Future<void> registerForNotification(String? token) async {
    try {
      final tokenData = TokenData()..token = token;
      await TwilioConversations.conversationsClientApi
          .registerForNotification(tokenData);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  /// Unregisters for push notifications.  Uses APNs on iOS and FCM on Android.
  Future<void> unregisterForNotification(String? token) async {
    try {
      final tokenData = TokenData()..token = token;
      await TwilioConversations.conversationsClientApi
          .unregisterForNotification(tokenData);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  //#region Conversations
  Future<Conversation?> createConversation(
      {required String friendlyName}) async {
    final result = await TwilioConversations.conversationsClientApi
        .createConversation(friendlyName);
    if (result.sid == null) {
      return null;
    }

    updateConversationFromMap(
        Map<String, dynamic>.from(result.encode() as Map));
    return conversations[result.sid];
  }

  Future<Conversation?> getConversation(
      {required String conversationSidOrUniqueName}) async {
    final result = await TwilioConversations.conversationsClientApi
        .getConversation(conversationSidOrUniqueName);
    final conversationMap = Map<String, dynamic>.from(result.encode() as Map);
    updateConversationFromMap(conversationMap);
    return conversations[result.sid];
  }

  Future<List<Conversation>> getMyConversations() async {
    final result =
        await TwilioConversations.conversationsClientApi.getMyConversations();

    final conversationsMapList = result
        .whereType<
            ConversationData>() // converts list contents type to non-nullable
        .map((ConversationData c) =>
            Map<String, dynamic>.from(c.encode() as Map))
        .toList();

    conversationsMapList.forEach((element) {
      updateConversationFromMap(element);
    });

    return conversations.values.toList();
  }

  // // TODO: Should not be publicly accessible
  void updateConversationFromMap(Map<String, dynamic> map) {
    var sid = map['sid'] as String;
    if (conversations[sid] == null) {
      conversations[sid] = Conversation.fromMap(map);
    } else {
      conversations[sid]?.updateFromMap(map);
    }
  }
  //#endregion

  /// Parse native conversation client events to the right event streams.
  void _parseEvents(dynamic event) {
    TwilioConversations.log(
        'ConversationClient::parseEvents => received event: $event');
    final eventName = event['name'] as String;

    if (event['data'] == null) {
      return;
    }
    final data = Map<String, dynamic>.from(event['data']);

    if (data['conversationClient'] != null) {
      final conversationClientMap =
          data['conversationClient'] as Map<String, dynamic>;
      updateFromMap(conversationClientMap);
    }

    ErrorInfo? exception;
    if (event['error'] != null) {
      final errorMap =
          Map<String, dynamic>.from(event['error'] as Map<dynamic, dynamic>);
      exception = ErrorInfo(errorMap['code'] as int,
          errorMap['message'] as String, errorMap['status'] as int);
    }

    var conversationSid = data['conversationSid'] as String?;

    Map<String, dynamic>? conversationMap;
    if (data['conversation'] != null) {
      conversationMap = Map<String, dynamic>.from(
          data['conversation'] as Map<dynamic, dynamic>);
      conversationSid = conversationMap['sid'] as String;
    }

    Map<String, dynamic>? userMap;
    if (data['user'] != null) {
      userMap =
          Map<String, dynamic>.from(data['user'] as Map<dynamic, dynamic>);
    }
    dynamic reason;
    if (data['reason'] != null) {
      final reasonMap =
          Map<String, dynamic>.from(data['reason'] as Map<dynamic, dynamic>);
      if (reasonMap['type'] == 'conversation') {
        reason = EnumToString.fromString(
            ConversationUpdateReason.values, reasonMap['value'] as String);
      } else if (reasonMap['type'] == 'user') {
        reason = EnumToString.fromString(
            UserUpdateReason.values, reasonMap['value'] as String);
      }
    }

    switch (eventName) {
      case 'clientListenerAttached':
        _onClientListenerAttachedCtrl.add(true);
        break;
      case 'addedToConversationNotification':
        if (conversationSid != null) {
          _onAddedToConversationNotificationCtrl.add(conversationSid);
        }
        break;
      case 'conversationAdded':
        if (conversationMap != null && conversationSid != null) {
          updateConversationFromMap(conversationMap);
          final conversation = conversations[conversationSid];
          if (conversation != null) {
            _onConversationAddedCtrl.add(conversation);
          }
        }
        break;
      case 'conversationDeleted':
        if (conversationMap != null && conversationSid != null) {
          final conversation = conversations[conversationSid];
          conversations.remove(conversationSid);
          if (conversation != null) {
            _onConversationDeletedCtrl.add(conversation);
          }
        }
        break;
      case 'conversationSynchronizationChange':
        if (conversationMap != null && conversationSid != null) {
          updateConversationFromMap(conversationMap);
          final conversation = conversations[conversationSid];
          if (conversation != null) {
            _onConversationSynchronizationChangeCtrl.add(conversation);
          }
        }
        break;
      case 'conversationUpdated':
        if (conversationMap != null &&
            reason != null &&
            conversationSid != null) {
          final conversation = conversations[conversationSid];
          if (conversation != null) {
            updateConversationFromMap(conversationMap);
            _onConversationUpdatedCtrl.add(ConversationUpdatedEvent(
              conversation,
              reason as ConversationUpdateReason,
            ));
          }
        }
        break;
      case 'clientSynchronization':
        var synchronizationStatus = EnumToString.fromString(
                ClientSynchronizationStatus.values,
                data['synchronizationStatus'] as String) ??
            ClientSynchronizationStatus.UNKNOWN;
        _onClientSynchronizationCtrl.add(synchronizationStatus);
        break;
      case 'connectionStateChange':
        var newConnectionState = EnumToString.fromString(
            ConnectionState.values, data['connectionState'] as String);
        if (newConnectionState != null) {
          connectionState = newConnectionState;
          _onConnectionStateCtrl.add(newConnectionState);
        } else {
          TwilioConversations.log(
              "ConversationClient => case 'connectionStateChange' => Attempting to operate on NULL.");
        }
        break;
      case 'error':
        if (exception != null) {
          _onErrorCtrl.add(exception);
        }
        break;
      case 'newMessageNotification':
        var messageSid = data['messageSid'] as String?;
        var messageIndex = data['messageIndex'] as int?;
        if (conversationSid != null &&
            messageSid != null &&
            messageIndex != null) {
          _onNewMessageNotificationCtrl.add(NewMessageNotificationEvent(
              conversationSid, messageSid, messageIndex));
        }
        break;
      case 'notificationFailed':
        if (exception != null) {
          _onNotificationFailedCtrl.add(exception);
        }
        break;
      case 'removedFromConversationNotification':
        if (conversationSid != null) {
          _onRemovedFromConversationNotificationCtrl.add(conversationSid);
        }
        break;
      case 'tokenAboutToExpire':
        _onTokenAboutToExpireCtrl.add(null);
        break;
      case 'tokenExpired':
        _onTokenExpiredCtrl.add(null);
        break;
      case 'userSubscribed':
        //TODO: handle userSubscribed event
        //assert(userMap != null);
        // users._updateFromMap({
        //   'subscribedUsers': [userMap]
        // });
        //_onUserSubscribedCtrl.add(User.fromJson(userMap));
        break;
      case 'userUnsubscribed':
        //TODO: review handling of userUnsubscribed event
        if (userMap == null) {
          TwilioConversations.log(
              'ConversationClient => case \'userUnsubscribed\' => userMap is NULL.');
          return;
        }
        // var user = users.getUserById(userMap['identity']);
        // user._updateFromMap(userMap);
        // users.subscribedUsers.removeWhere((u) => u.identity == userMap['identity']);
        _onUserUnsubscribedCtrl.add(User.fromMap(userMap));
        break;
      case 'userUpdated':
        if (userMap != null && reason != null) {
          // users._updateFromMap({
          //   'subscribedUsers': [userMap]
          // });
          _onUserUpdatedCtrl.add(UserUpdatedEvent(
              User.fromMap(userMap), reason as UserUpdateReason));
        }
        break;
      default:
        TwilioConversations.log('Event \'$eventName\' not yet implemented');
        break;
    }
  }

  void _parseConversationEvents(dynamic event) {
    final data = Map<String, dynamic>.from(event['data']);
    final String? conversationSid = data['conversationSid'];
    if (conversationSid != null) {
      conversations[conversationSid]?.parseEvents(event);
    }
  }

  /// Parse notification events to the right event streams.
  void _parseNotificationEvents(dynamic event) {
    final eventMap = Map<String, dynamic>.from(event);
    final eventName = eventMap['name'] as String;
    TwilioConversations.log(
        'ConversationClient => Event \'$eventName\' => ${eventMap['data']}, error: ${eventMap['error']}');

    final data = Map<String, dynamic>.from(eventMap['data']);

    ErrorInfo? exception;
    if (eventMap['error'] != null) {
      final errorMap = Map<String, dynamic>.from(eventMap['error']);
      exception = ErrorInfo(errorMap['code'] as int,
          errorMap['message'] as String, errorMap['status'] as int);
    }

    switch (eventName) {
      case 'registered':
        _onNotificationRegisteredCtrl.add(
            NotificationRegistrationEvent(data['result'] as bool, exception));
        break;
      case 'deregistered':
        _onNotificationDeregisteredCtrl.add(
            NotificationRegistrationEvent(data['result'] as bool, exception));
        break;
      default:
        TwilioConversations.log(
            'Notification event \'$eventName\' not yet implemented');
        break;
    }
  }
}
