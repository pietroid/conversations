import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twilio_conversations/twilio_conversations.dart';
import 'package:twilio_conversations_example/conversations/conversations_notifier.dart';
import 'package:twilio_conversations_example/messages/messages_page.dart';

class ConversationsPage extends StatefulWidget {
  final ConversationsNotifier conversationsNotifier;

  const ConversationsPage({
    required this.conversationsNotifier,
  });

  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    widget.conversationsNotifier.getMyConversations();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConversationsNotifier>.value(
      value: widget.conversationsNotifier,
      child: Consumer<ConversationsNotifier>(
        builder: (BuildContext context, conversationsNotifier, Widget? child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Conversations'),
              actions: [
                _buildCreateConversation(),
              ],
            ),
            body: Center(
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateConversation() {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () async {
        var conversationName = await _getFriendlyNameForCreateConversation();
        if (conversationName != null) {
          final conversation = await widget.conversationsNotifier
              .createConversation(friendlyName: conversationName);
          // var joined = await conversation?.join();
          print(
              'Successfully created conversation: ${conversation?.friendlyName}');
        } else {
          print('Create conversation cancelled');
        }
      },
    );
  }

  Future<String?> _getFriendlyNameForCreateConversation() async {
    final controller = TextEditingController();

    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  decoration: InputDecoration(label: Text('Conversation Name')),
                  controller: controller,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(controller.text);
                      },
                      child: Text('Create'),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
            child: Text('Refresh Conversations'),
            onPressed: () {
              widget.conversationsNotifier.getMyConversations();
            }),
        Flexible(
          child: _buildConversationList(),
        ),
      ],
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.conversationsNotifier.conversations.length,
      itemBuilder: (_, index) {
        return _buildConversationListItem(
            widget.conversationsNotifier.conversations[index]);
      },
    );
  }

  Widget _buildConversationListItem(Conversation conversation) {
    return InkWell(
      onLongPress: () async {
        var a = await conversation.addParticipantByIdentity('+17175555555');
        print('User added: $a');
        // var newMessage = await conversation.messages.sendMessage("Test texts");
        // print('New Message text is: ${newMessage.messageBody}');
      },
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagesPage(conversation),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    Text(conversation.friendlyName ?? ''),
                    InkWell(
                      onTap: () async {
                        if (conversation.status != ConversationStatus.JOINED) {
                          await widget.conversationsNotifier.join(conversation);
                        } else {
                          await widget.conversationsNotifier
                              .leave(conversation);
                        }
                      },
                      child: Icon(
                          conversation.status == ConversationStatus.JOINED
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_outlined),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
