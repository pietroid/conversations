import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class MessagesNotifier extends ChangeNotifier {
  var messageInputTextController = TextEditingController();
  var listScrollController = ScrollController();

  bool isLoading = true;
  bool isSendingMessage = false;
  bool isError = false;

  final limit = 20;
  Conversation conversation;
  List<Message> messages = [];
  bool _areAllMessagesRetrieved = false;
  var startingIndex = 0;
  var currentlyTyping = Set<String>();

  MessagesNotifier(this.conversation) {
    messageInputTextController.addListener(notifyListeners);
    listScrollController.addListener(onListScrolled);

    messageInputTextController.addListener(conversation.typing);

    startingIndex = conversation.lastMessageIndex ?? 0;
    conversation.onMessageAdded.listen((message) {
      messages.insert(0, message);
    });
    conversation.onTypingStarted.listen((event) {
      final identity = event.participant.identity;
      if (identity != null) {
        currentlyTyping.add(identity);
        notifyListeners();
      }
    });
    conversation.onTypingEnded.listen((event) {
      final identity = event.participant.identity;
      if (identity != null) {
        currentlyTyping.remove(identity);
        notifyListeners();
      }
    });
  }

  void init() {
    reset();
    fetchMore();
  }

  Future addUserByIdentity(String identity) async {
    await conversation.addParticipantByIdentity(identity);
    notifyListeners();
  }

  void reset() {
    messages = [];
    isLoading = false;
    _areAllMessagesRetrieved = false;
    startingIndex = 0;
  }

  void refetchAfterError() {
    init();
  }

  void onListScrolled() {
    if (listScrollController.offset >
        listScrollController.position.maxScrollExtent - 100) {
      if (!isLoading && !_areAllMessagesRetrieved) {
        fetchMore();
      }
    }
  }

  void fetchMore() async {
    isLoading = true;
    notifyListeners();

    final index = startingIndex - messages.length;
    final nextMessages =
        await conversation.getMessagesBefore(index: index, count: limit);

    _areAllMessagesRetrieved = nextMessages.length < limit;
    messages.addAll(nextMessages.reversed);

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
      message = await conversation.sendMessage(
        messageInputTextController.text,
      );
    } catch (e) {
      print('Failed to send message Error: $e');
    }

    isSendingMessage = false;

    if (message != null) {
      messageInputTextController.clear();
    }
    notifyListeners();
  }
}
