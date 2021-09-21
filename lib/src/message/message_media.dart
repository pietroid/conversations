import 'package:twilio_conversations/twilio_conversations.dart';

class MessageMedia {
  final String _sid;
  final String? _fileName;
  final String _type;
  final int _size;
  final String? _conversationSid;
  final int _messageIndex;

  //#region Public API properties
  /// Get SID of media stream.
  String get sid {
    return _sid;
  }

  /// Get file name of media stream.
  String? get fileName {
    return _fileName;
  }

  /// Get mime-type of media stream.
  String get type {
    return _type;
  }

  /// Get size of media stream.
  int get size {
    return _size;
  }
  //#endregion

  MessageMedia(
    this._sid,
    this._fileName,
    this._type,
    this._size,
    this._conversationSid,
    this._messageIndex,
  );

  /// Construct from a map.
  factory MessageMedia.fromMap(Map<String, dynamic> map) {
    return MessageMedia(map['sid'], map['fileName'], map['type'], map['size'], map['conversationSid'], map['messageIndex']);
  }

  //#region Public API methods
  /// Save media content stream that could be streamed or downloaded by client.
  ///
  /// Provided file could be an existing file and a none existing file.
  Future<String> getMediaUrl() async {
    final response = await TwilioConversations.methodChannel
        .invokeMethod('MessageMethods.getMediaContentTemporaryUrl', {
      'conversationSid': _conversationSid,
      'messageIndex': _messageIndex,
    });
    return response as String;
  }
}
