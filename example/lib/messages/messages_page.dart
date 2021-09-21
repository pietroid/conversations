import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twilio_conversations/twilio_conversations.dart';
import 'package:twilio_conversations_example/messages/messages_notifier.dart';
import 'package:twilio_conversations_example/util.dart';

class MessagesPage extends StatefulWidget {
  final Conversation conversation;

  MessagesPage(this.conversation);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late final messagesNotifier;

  @override
  void initState() {
    super.initState();
    messagesNotifier = MessagesNotifier(widget.conversation);
    messagesNotifier.init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MessagesNotifier>.value(
      value: messagesNotifier,
      child: Consumer<MessagesNotifier>(
        builder: (BuildContext context, messagesNotifier, Widget? child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.conversation.friendlyName ?? ''),
              actions: [
                _buildInviteUser(),
              ],
            ),
            body: Center(
              child: _buildBody(messagesNotifier),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInviteUser() {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () async {
        final userName = await _getUserNameForInvite();
        if (userName != null) {
          messagesNotifier.addUserByIdentity(userName);
        }
      },
    );
  }

  Future<String?> _getUserNameForInvite() async {
    final controller = TextEditingController();

    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 30,
            ),
            child: Container(
              height: 140,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    decoration: InputDecoration(label: Text('User Identity')),
                    controller: controller,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        child: Text('Add User'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(MessagesNotifier messagesNotifier) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              color: Colors.grey[100],
              child: _buildListStates(messagesNotifier),
            ),
          )),
          _buildParticipantsTyping(messagesNotifier),
          _buildMessageInputBar(messagesNotifier),
        ],
      ),
    );
  }

  Widget _buildListStates(MessagesNotifier messagesNotifier) {
    if (messagesNotifier.isLoading && messagesNotifier.messages.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (messagesNotifier.isError) {
      return Center(
        child: IconButton(
          icon: Icon(Icons.replay),
          onPressed: () {
            messagesNotifier.refetchAfterError();
          },
        ),
      );
    }

    if (messagesNotifier.messages.isEmpty) {
      return Center(
        child: Icon(
          Icons.speaker_notes_off,
          size: 48,
        ),
      );
    }

    return _buildList(messagesNotifier);
  }

  Widget _buildList(MessagesNotifier messagesNotifier) {
    var listCount = messagesNotifier.messages.length;
    if (messagesNotifier.isLoading) {
      //Increment list count by 1
      // so that loading spinner can be shown above existing messages
      // when retrieving the next page
      listCount += 1;
    }
    return ListView.builder(
      controller: messagesNotifier.listScrollController,
      reverse: true,
      itemCount: listCount,
      itemBuilder: (_, index) {
        if (listCount == messagesNotifier.messages.length + 1 &&
            index == listCount - 1) {
          return Center(child: CircularProgressIndicator());
        }
        return _buildListItem(messagesNotifier.messages[index]);
      },
    );
  }

  Widget _buildListItem(Message message) {
    final isMyMessage =
        message.author == TwilioConversations.conversationClient?.myIdentity;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment:
            isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _buildChatBubble(message),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Message message) {
    final isMyMessage =
        message.author == TwilioConversations.conversationClient?.myIdentity;

    final textColor = isMyMessage ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment:
          isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 4.0),
          constraints: BoxConstraints(maxWidth: 250, minHeight: 35),
          decoration: BoxDecoration(
              color: isMyMessage ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 4),
            child: Column(
              crossAxisAlignment: isMyMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildAuthorName(
                    message: message,
                    isMyMessage: isMyMessage,
                    textColor: textColor),
                Text(
                  message.body ?? '',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          message.dateCreated != null
              ? ConversationsUtil.parseDateTime(message.dateCreated!)
              : '',
          textAlign: isMyMessage ? TextAlign.start : TextAlign.end,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w300,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorName({
    required bool isMyMessage,
    required Color textColor,
    required Message message,
  }) {
    // TODO: revisit logic, seems wonky
    return (isMyMessage)
        ? Container(
            width: 0,
          )
        : Column(
            crossAxisAlignment:
                isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                (!isMyMessage) ? message.author! : '',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
            ],
          );
  }

  Widget _buildParticipantsTyping(MessagesNotifier messagesNotifier) {
    final _currentlyTypingParticipants = messagesNotifier.currentlyTyping;

    return _currentlyTypingParticipants.isNotEmpty
        ? Text('${_currentlyTypingParticipants.join(', ')} is typing...')
        : Container();
  }

  Widget _buildMessageInputBar(MessagesNotifier messagesNotifier) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 8, bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: TextField(
                controller: messagesNotifier.messageInputTextController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 8,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter Message',
                  contentPadding: EdgeInsets.only(
                      left: 12.0, right: 12.0, bottom: 4, top: 0),
                ),
              ),
            ),
          ),
          _buildSendButton(messagesNotifier),
        ],
      ),
    );
  }

  Widget _buildSendButton(MessagesNotifier messagesNotifier) {
    final isEmptyInput =
        messagesNotifier.messageInputTextController.text.isEmpty;
    if (messagesNotifier.isSendingMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: isEmptyInput ? 8 : 44,
      child: isEmptyInput
          ? Container()
          : IconButton(
              color: Colors.blue,
              icon: Icon(Icons.send),
              onPressed: messagesNotifier.onSendMessagePressed,
            ),
    );
  }
}
