import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/src/conversation_client/properties.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class TwilioConversations extends FlutterLoggingApi {
  factory TwilioConversations() {
    _instance ??= TwilioConversations._();
    return _instance!;
  }
  static TwilioConversations? _instance;

  TwilioConversations._({
    PluginApi? pluginApi,
    ConversationApi? conversationApi,
  }) {
    _pluginApi = pluginApi ?? PluginApi();
    _conversationApi = conversationApi ?? ConversationApi();
    FlutterLoggingApi.setup(this);
  }

  @visibleForTesting
  factory TwilioConversations.mock({
    PluginApi? pluginApi,
    ConversationApi? conversationApi,
  }) {
    _instance = TwilioConversations._(
      pluginApi: pluginApi,
      conversationApi: conversationApi,
    );
    return _instance!;
  }

  late PluginApi _pluginApi;
  PluginApi get pluginApi => _pluginApi;

  final _conversationsClientApi = ConversationClientApi();
  ConversationClientApi get conversationsClientApi => _conversationsClientApi;

  late ConversationApi _conversationApi;
  ConversationApi get conversationApi => _conversationApi;

  final _participantApi = ParticipantApi();
  ParticipantApi get participantApi => _participantApi;

  final _messageApi = MessageApi();
  MessageApi get messageApi => _messageApi;

  // TODO: deprecate media progress channel and use pigeon instead
  static const EventChannel mediaProgressChannel =
      EventChannel('twilio_programmable_chat/media_progress');

  static bool _dartDebug = false;
  static ConversationClient? conversationClient;

  /// Create a [ConversationClient].
  Future<ConversationClient?> create({
    required String jwtToken,
    Properties properties = const Properties(),
  }) async {
    assert(jwtToken.isNotEmpty);

    conversationClient = ConversationClient();

    //TODO Needs to throw a better error when trying
    // to create with a bad jwtToken. The current error is "Client timeout reached"
    // (happens in iOS, not sure about Android)
    final ConversationClientData result;
    try {
      result = await pluginApi.create(jwtToken, properties.toPigeon());

      conversationClient
          ?.updateFromMap(Map<String, dynamic>.from(result.encode() as Map));
    } catch (e) {
      conversationClient = null;
      log('create => onError: $e');
      rethrow;
    }

    return conversationClient;
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

  /// Host to Flutter logging API
  @override
  void logFromHost(String msg) {
    print('[  NATIVE  ] $msg');
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
      await TwilioConversations().pluginApi.debug(native, sdk);
    } catch (e) {
      TwilioConversations.log(
          'TwilioConversations::debug => Caught Exception: $e');
    }
  }
}
