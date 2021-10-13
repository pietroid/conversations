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
          return WillPopScope(
            onWillPop: () async {
              conversationsNotifier.cancelSubscriptions();
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text('Conversations'),
                actions: [
                  _buildCreateConversation(),
                  _buildRegisterForNotifications(),
                  _buildUnregisterForNotifications(),
                ],
              ),
              body: Center(
                child: _buildBody(),
              ),
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
          print(
              'Successfully created conversation: ${conversation?.friendlyName}');
        } else {
          print('Create conversation cancelled');
        }
      },
    );
  }

  Widget _buildRegisterForNotifications() {
    return IconButton(
      icon: Icon(Icons.cloud),
      onPressed: () async {
        await widget.conversationsNotifier.registerForNotification();
      },
    );
  }

  Widget _buildUnregisterForNotifications() {
    return IconButton(
      icon: Icon(Icons.cloud_off),
      onPressed: () async {
        await widget.conversationsNotifier.unregisterForNotification();
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
        var r = await widget.conversationsNotifier.client
            ?.getConversation(conversationSidOrUniqueName: conversation.sid);
        print('Conversation details: $r');
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagesPage(
                conversation, widget.conversationsNotifier.client!),
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
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text('Conversation: ${conversation.friendlyName}'),
                          Text(
                              'Unread Messages: ${widget.conversationsNotifier.unreadMessageCounts[conversation.sid]}'),
                        ],
                      ),
                    ),
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
