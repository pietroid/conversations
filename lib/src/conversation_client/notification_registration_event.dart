import 'package:twilio_conversations/twilio_conversations.dart';

class NotificationRegistrationEvent {
  final bool isSuccessful;
  final ErrorInfo? error;

  NotificationRegistrationEvent(this.isSuccessful, this.error);

  @override
  String toString() {
    return 'NotificationRegistrationEvent: isSuccessful: $isSuccessful, error: $error';
  }
}
