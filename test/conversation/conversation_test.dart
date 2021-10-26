import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/src/src.dart';
import 'package:uuid/uuid.dart';

import 'conversation_test.mocks.dart';
import 'setup_stubs.dart';

@GenerateMocks([ConversationApi])
void main() {
  late TwilioConversations plugin;
  final conversationApi = MockConversationApi();

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ConversationTestStubs.invocation = null;

    plugin = TwilioConversations.mock(
      conversationApi: conversationApi,
    );
  });

  tearDown(() {});

  test('Calls API to invoke Remove Participant', () async {
    ConversationTestStubs.stubRemoveParticipant(conversationApi, true);
    final participantSid = Uuid().v4();
    final conversationSid = Uuid().v4();
    final conversation = Conversation(conversationSid);
    final participant = ConversationTestStubs.createMockParticipant(
        conversationSid, participantSid);

    await conversation.removeParticipant(participant);

    final invocation = ConversationTestStubs.invocation;
    expect(invocation?.positionalArguments[0], conversationSid);
    expect(invocation?.positionalArguments[1], participantSid);
  });

  test('Calls API to get participant by identity', () async {
    ConversationTestStubs.stubGetParticipantByIdentity(conversationApi);
    final identity = Uuid().v4();
    final conversationSid = Uuid().v4();
    final conversation = Conversation(conversationSid);

    final participant = await conversation.getParticipantByIdentity(identity);

    final invocation = ConversationTestStubs.invocation;
    expect(invocation?.positionalArguments[0], conversationSid);
    expect(invocation?.positionalArguments[1], identity);

    expect(participant?.identity, identity);
    expect(participant?.conversationSid, conversationSid);
    expect(participant?.type,
        EnumToString.fromString(Type.values, ConversationTestStubs.chatType));
  });

  test('Calls API to get participant by SID', () async {
    ConversationTestStubs.stubGetParticipantBySid(conversationApi);
    final participantSid = Uuid().v4();
    final conversationSid = Uuid().v4();
    final conversation = Conversation(conversationSid);

    final participant = await conversation.getParticipantBySid(participantSid);

    final invocation = ConversationTestStubs.invocation;
    expect(invocation?.positionalArguments[0], conversationSid);
    expect(invocation?.positionalArguments[1], participantSid);
    expect(participant?.sid, participantSid);
    expect(participant?.conversationSid, conversationSid);
    expect(participant?.type,
        EnumToString.fromString(Type.values, ConversationTestStubs.chatType));
  });

  test('Calls API to remove message', () async {
    final success = true;
    ConversationTestStubs.stubRemoveMessage(conversationApi, success);
    final conversationSid = Uuid().v4();
    final conversation = Conversation(conversationSid);
    final messageIndex = 17;
    final message =
        ConversationTestStubs.createMockMessage(conversationSid, messageIndex);

    final response = await conversation.removeMessage(message);

    final invocation = ConversationTestStubs.invocation;
    expect(invocation?.positionalArguments[0], conversationSid);
    expect(invocation?.positionalArguments[1], messageIndex);
    expect(response, success);
  });

  test('Calls API to advance last read message index', () async {
    final expectedUnreadMessageCount = 3;
    ConversationTestStubs.stubAdvanceLastReadMessageIndex(
        conversationApi, expectedUnreadMessageCount);
    final messageIndex = 17;
    final conversationSid = Uuid().v4();
    final conversation = Conversation(conversationSid);

    final updatedUnreadMessageCount =
        await conversation.advanceLastReadMessageIndex(messageIndex);

    final invocation = ConversationTestStubs.invocation;
    expect(invocation?.positionalArguments[0], conversationSid);
    expect(invocation?.positionalArguments[1], messageIndex);
    expect(updatedUnreadMessageCount, expectedUnreadMessageCount);
  });
}
