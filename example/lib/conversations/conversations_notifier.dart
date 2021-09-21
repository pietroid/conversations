import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class ConversationsNotifier extends ChangeNotifier {
  final plugin = TwilioConversations();
  bool isClientInitialized = false;
  TextEditingController identityController = TextEditingController();
  String identity = '';

  List<Conversation> conversations = [];

  void updateIdentity(String identity) {
    this.identity = identity;
    notifyListeners();
  }

  Future<void> create({required String jwtToken}) async {
    await TwilioConversations.debug(dart: true, native: true);

    final client = await plugin.create(jwtToken: jwtToken);

    print('Client initialized');
    print('Your Identity: ${client?.myIdentity}');

    isClientInitialized = true;
    notifyListeners();

    client?.onConversationAdded.listen((event) {
      conversations.add(event);
      notifyListeners();
    });
  }

  Future<void> shutdown() async {
    final client = TwilioConversations.conversationClient;
    if (client != null) {
      await client.shutdown();
      isClientInitialized = false;
      notifyListeners();
    }
  }

  Future<void> join(Conversation conversation) async {
    await conversation.join();
    notifyListeners();
  }

  Future<void> leave(Conversation conversation) async {
    await conversation.leave();
    notifyListeners();
  }

  Future<Conversation?> createConversation(
      {String friendlyName = 'Test Conversation'}) async {
    var result = await TwilioConversations.conversationClient
        ?.createConversation(friendlyName: friendlyName);
    print('Conversation successfully created: ${result?.friendlyName}');
    return result;
  }

  Future<void> getMyConversations() async {
    final myConversations =
        await TwilioConversations.conversationClient?.getMyConversations();

    if (myConversations != null) {
      conversations = myConversations;
      notifyListeners();
    }
  }
}
