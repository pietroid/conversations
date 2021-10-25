import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/src/src.dart';
import 'package:uuid/uuid.dart';

import 'conversation_test.mocks.dart';

@GenerateMocks([ConversationApi])
void main() {
  late TwilioConversations plugin;
  final conversationApi = MockConversationApi();
  Invocation? invocation;
  final chatType = 'CHAT';

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    invocation = null;
    when(conversationApi.removeParticipant(any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      return true;
    });
    when(conversationApi.getParticipantByIdentity(any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      final responseData = ParticipantData();
      responseData.sid = Uuid().v4();
      responseData.type = chatType;
      responseData.conversationSid = invocation?.positionalArguments[0];
      responseData.identity = invocation?.positionalArguments[1];
      return responseData;
    });

    plugin = TwilioConversations.mock(
      conversationApi: conversationApi,
    );
  });

  tearDown(() {});

  test('Calls API to invoke Remove Participant', () async {
    final participantSid = Uuid().v4();
    final conversationSid = Uuid().v4();
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

  test('Calls API to retrieve participant by identity', () async {
    final identity = Uuid().v4();
    final conversationSid = Uuid().v4();
    final conversation = Conversation(conversationSid);
    final participant = await conversation.getParticipantByIdentity(identity);
    expect(participant?.identity, identity);
    expect(participant?.conversationSid, conversationSid);
    expect(participant?.type, EnumToString.fromString(Type.values, chatType));
    expect(invocation?.positionalArguments[0], conversationSid);
    expect(invocation?.positionalArguments[1], identity);
  });
}
