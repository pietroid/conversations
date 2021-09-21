import 'dart:io';

import 'package:twilio_conversations/twilio_conversations.dart';

class MessageOptions {
  //#region Private API properties
  String? body;
  Map<String, dynamic>? attributes;
  String? mimeType;
  String? filename;
  String? inputPath;

  //TODO
  int? _mediaProgressListenerId;
  //#endregion

  //#region Public API methods
  /// Create message with given body text.
  ///
  /// If you specify [MessageOptions.withBody] then you will not be able to specify [MessageOptions.withMedia] because they are mutually exclusive message types.
  /// Created message type will be [MessageType.TEXT].
  void withBody(String body) {
    if (inputPath != null) {
      throw Exception('MessageOptions.withMedia has already been specified');
    }
    this.body = body;
  }

  /// Set new message attributes.
  void withAttributes(Map<String, dynamic> attributes) {
    this.attributes = attributes;
  }

  /// Create message with given media stream.
  ///
  /// If you specify [MessageOptions.withMedia] then you will not be able to specify [MessageOptions.withBody] because they are mutually exclusive message types. Created message type will be [MessageType.MEDIA].
  void withMedia(File input, String mimeType) {
    if (this.body != null) {
      throw Exception('MessageOptions.withBody has already been specified');
    }
    this.inputPath = input.path;
    this.mimeType = mimeType;
  }

  /// Provide optional filename for media.
  void withMediaFileName(String filename) {
    this.filename = filename;
  }

  //TODO
  void withMediaProgressListener({
    void Function()? onStarted,
    void Function(int bytes)? onProgress,
    void Function(String mediaSid)? onCompleted,
  }) {
    _mediaProgressListenerId = DateTime.now().millisecondsSinceEpoch;
    TwilioConversations.mediaProgressChannel.receiveBroadcastStream().listen((dynamic event) {
      var eventData = Map<String, dynamic>.from(event);
      if (eventData['mediaProgressListenerId'] == _mediaProgressListenerId) {
        switch (eventData['name']) {
          case 'started':
            if (onStarted != null) {
              onStarted();
            }
            break;
          case 'progress':
            if (onProgress != null) {
              onProgress(eventData['data'] as int);
            }
            break;
          case 'completed':
            if (onCompleted != null) {
              onCompleted(eventData['data'] as String);
            }
            break;
        }
      }
    });
  }
  //#endregion

  /// Create map from properties.
  Map<String, dynamic> toMap() {
    return {
      'body': body,
      'attributes': attributes,
      'input': inputPath,
      'mimeType': mimeType,
      'filename': filename,
      'mediaProgressListenerId': _mediaProgressListenerId,
    };
  }
}
