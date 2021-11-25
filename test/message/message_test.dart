import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/twilio_conversations.dart';
import 'package:uuid/uuid.dart';

import 'message_test.mocks.dart';
import 'setup_stubs.dart';

@GenerateMocks([MessageApi])
void main() {
  final messageApi = MockMessageApi();

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TwilioConversations.mock(messageApi: messageApi);
  });

  tearDown(() {});

  test('Calls API to invoke get participant', () async {
    final participantSid = Uuid().v4();
    final conversationSid = Uuid().v4();
    final messageIndex = 9;
    final mockParticipant = MessageTestStubs.createMockParticipant(
        conversationSid, participantSid);
    MessageTestStubs.stubGetParticipant(messageApi, mockParticipant);

    final message = MessageTestStubs.createMockMessage(conversationSid, messageIndex);

    final participantResult = await message.getParticipant();

    final invocation = MessageTestStubs.invocation;
    expect(invocation?.positionalArguments[0], conversationSid);
    expect(invocation?.positionalArguments[1], messageIndex);
  });
}
