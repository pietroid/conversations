import 'dart:async';

import 'package:flutter/services.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class TwilioConversations {
  factory TwilioConversations() => _instance;
  static final TwilioConversations _instance = TwilioConversations._();

  static final _pluginApi = PluginApi();
  static PluginApi get pluginApi => _pluginApi;

  static final _conversationsClientApi = ConversationClientApi();
  static ConversationClientApi get conversationsClientApi =>
      _conversationsClientApi;

  static final _conversationApi = ConversationApi();
  static ConversationApi get conversationApi => _conversationApi;

  static final _participantApi = ParticipantApi();
  static ParticipantApi get participantApi => _participantApi;

  static final _messageApi = MessageApi();
  static MessageApi get messageApi => _messageApi;

  TwilioConversations._();

  static const EventChannel clientChannel =
      EventChannel('twilio_conversations/client');
  static const EventChannel conversationChannel =
      EventChannel('twilio_conversations/conversations');
  static const EventChannel notificationChannel =
      EventChannel('twilio_conversations/notification');
  static const EventChannel loggingChannel =
      EventChannel('twilio_conversations/logging');
  static const EventChannel mediaProgressChannel =
      EventChannel('twilio_programmable_chat/media_progress');

  static bool _dartDebug = false;
  static StreamSubscription<bool>? _clientListener;
  static StreamSubscription? loggingStream;
  static ConversationClient? conversationClient;

  /// Create a [ConversationClient].
  Future<ConversationClient?> create({
    required String jwtToken,
  }) async {
    assert(jwtToken.isNotEmpty);

    conversationClient = ConversationClient();
    final completer = Completer<ConversationClient?>();

    await _clientListener?.cancel();
    _clientListener =
        conversationClient?.onClientListenerAttached.listen((event) async {
      //TODO Needs to throw a better error when trying
      // to create with a bad jwtToken. The current error is "Client timeout reached"
      // (happens in iOS, not sure about Android)
      await _clientListener?.cancel();
      final result;
      try {
        result = await pluginApi.create(jwtToken);

        if (result == null) {
          conversationClient = null;
          return completer.completeError(
              Exception('Unknown error creating ConversationClient'));
        }

        conversationClient?.updateFromMap(Map<String, dynamic>.from(result.encode() as Map));
        completer.complete(conversationClient);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  //TODO: review error throwing/parsing from the native layer to this one
  static Exception convertException(PlatformException err) {
    var code = int.tryParse(err.code);
    // If code is an integer, then it is a Twilio ErrorInfo exception.
    if (code != null) {
      return ErrorInfo(int.parse(err.code), err.message, err.details as int);
    }

    // For now just rethrow the PlatformException. But we could make custom ones based on the code value.
    // code can be:
    // - "ERROR" Something went wrong in the custom native code.
    // - "IllegalArgumentException" Something went wrong calling the twilio SDK.
    // - "JSONException" Something went wrong parsing a JSON string.
    // - "MISSING_PARAMS" Missing params, only the native debug method uses this at the moment.
    return err;
  }

  /// Internal logging method for dart.
  static void log(dynamic msg) {
    if (_dartDebug) {
      print('[   DART   ] $msg');
    }
  }

  /// Enable debug logging.
  ///
  /// For native logging set [native] to `true` and for dart set [dart] to `true`.
  static Future<void> debug({
    bool dart = false,
    bool native = false,
    bool sdk = false,
  }) async {
    _dartDebug = dart;
    try {
      await pluginApi.debug(native, sdk);
    } catch (e) {
      TwilioConversations.log(
          'TwilioConversations::debug => Caught Exception: $e');
    }
    if (native && loggingStream == null) {
      loggingStream =
          loggingChannel.receiveBroadcastStream().listen((dynamic event) {
        if (native) {
          print('[  NATIVE  ] $event');
        }
      });
    } else if (!native && loggingStream != null) {
      await loggingStream?.cancel();
      loggingStream = null;
    }
  }
}
