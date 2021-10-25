import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/src/src.dart';

import 'conversation_test.mocks.dart';

@GenerateMocks([ConversationApi])
void main() {
  late TwilioConversations plugin;
  final conversationApi = MockConversationApi();
  Invocation? invocation;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    when(conversationApi.removeParticipant(any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      return true;
    });
    plugin = TwilioConversations.mock(
      conversationApi: conversationApi,
    );
  });

  tearDown(() {});

  test('Calls API to invoke Remove Participant', () async {
    final participantSid = 'participantSid';
    final conversationSid = 'conversationSid';
    final conversation = Conversation(conversationSid);
    final participant = Participant(
      participantSid,
      Type.CHAT,
      conversationSid,
      Attributes(AttributesType.NULL, null),
      null,
      null,
      null,
      null,
      null,
    );
    await conversation.removeParticipant(participant);
    expect(invocation?.positionalArguments[0], conversationSid);
    expect(invocation?.positionalArguments[1], participantSid);
  });
}
