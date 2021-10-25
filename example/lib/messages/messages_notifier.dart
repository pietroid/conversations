import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class MessagesNotifier extends ChangeNotifier {
  var messageInputTextController = TextEditingController();
  var listScrollController = ScrollController();

  bool isLoading = true;
  bool isSendingMessage = false;
  bool isError = false;

  final limit = 20;
  Conversation conversation;
  ConversationClient client;
  List<Message> messages = [];
  List<Participant>? participants;
  var startingIndex = 0;
  var currentlyTyping = <String>{};
  final subscriptions = <StreamSubscription>[];
  final messageMedia = <String, Uint8List>{};

  MessagesNotifier(this.conversation, this.client) {
    messageInputTextController.addListener(notifyListeners);

    messageInputTextController.addListener(conversation.typing);

    startingIndex = conversation.lastMessageIndex ?? 0;
    subscriptions.add(conversation.onMessageAdded.listen((message) {
      messages.insert(0, message);
      final messageIndex = message.messageIndex;
      if (messageIndex != null) {
        conversation.setLastReadMessageIndex(messageIndex);
      }

      if (message.type == MessageType.MEDIA) {
        _getMedia(message);
      }
    }));
    subscriptions.add(conversation.onTypingStarted.listen((event) {
      final identity = event.participant.identity;
      if (identity != null) {
        currentlyTyping.add(identity);
        notifyListeners();
      }
    }));
    subscriptions.add(conversation.onTypingEnded.listen((event) {
      final identity = event.participant.identity;
      if (identity != null) {
        currentlyTyping.remove(identity);
        notifyListeners();
      }
    }));
    subscriptions.add(client.onConversationUpdated.listen((event) {
      notifyListeners();
    }));
  }

  void init() {
    reset();
    fetchMore();
  }

  Future addUserByIdentity(String identity) async {
    await conversation.addParticipantByIdentity(identity);
    await getParticipants();
    notifyListeners();
  }

  Future<void> getParticipants() async {
    participants = await conversation.getParticipantsList();
    if (participants?.isNotEmpty ?? false) {
      final user = await participants?.first.getUser();
      print('MessagesNotifier::getParticipants => gotUser: $user');
    }
    // artificial delay
    Timer(Duration(seconds: 3), notifyListeners);
  }

  Future<void> removeParticipant(Participant participant) async {
    await conversation.removeParticipant(participant);
    await getParticipants();
  }

  Future<void> setFriendlyName(String name) async {
    await conversation.setFriendlyName(name);
    notifyListeners();
  }

  Future<void> destroy() async {
    return conversation.destroy();
  }

  void reset() {
    messages = [];
    isLoading = false;
    startingIndex = 0;
  }

  bool hasMedia(String messageSid) {
    return messageMedia[messageSid] != null;
  }

  Uint8List? media(String messageSid) {
    return messageMedia[messageSid];
  }

  Future _getMedia(Message message) async {
    print('_getMedia => message: ${message.sid}');
    final url = await message.getMediaUrl();
    if (url != null) {
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      messageMedia[message.sid!] = response.bodyBytes;
      print('_getMedia => url: $url');
      notifyListeners();
    }
  }

  void refetchAfterError() {
    init();
  }

  void fetchMore() async {
    isLoading = true;
    notifyListeners();

    final numberOfMessages = await conversation.getMessagesCount();
    if (numberOfMessages != null) {
      final nextMessages = await conversation.getLastMessages(numberOfMessages);

      messages.addAll(nextMessages.reversed);
      for (var message in messages) {
        if (message.type == MessageType.MEDIA) {
          _getMedia(message);
        }
      }
    }

    await conversation.setAllMessagesRead();
    isLoading = false;
    notifyListeners();
  }

  void onSendMessagePressed() async {
    if (messageInputTextController.text.isEmpty) {
      return;
    }
    isSendingMessage = true;
    notifyListeners();

    Message? message;
    try {
      // set arbitrary attributes
      final attributesData = <String, dynamic>{
        'name': 'test',
        'arbitraryNumber': -13,
      };
      final attributes =
          Attributes(AttributesType.OBJECT, jsonEncode(attributesData));
      final messageOptions = MessageOptions()
        ..withBody(messageInputTextController.text)
        ..withAttributes(attributes);
      message = await conversation.sendMessage(messageOptions);
    } catch (e) {
      print('Failed to send message Error: $e');
    }

    isSendingMessage = false;

    if (message != null) {
      messageInputTextController.clear();
    }
    notifyListeners();
  }

  Future onSendMediaMessagePressed() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    final mimeType = mime(image?.path);
    if (image != null && mimeType != null) {
      final messageOptions = MessageOptions()
        ..withMedia(File(image.path), mimeType);
      await conversation.sendMessage(messageOptions);
    }
  }

  void cancelSubscriptions() {
    messageInputTextController.removeListener(notifyListeners);
    messageInputTextController.removeListener(conversation.typing);
    for (var sub in subscriptions) {
      sub.cancel();
    }
  }
}
