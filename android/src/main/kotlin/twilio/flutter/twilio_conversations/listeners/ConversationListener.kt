package twilio.flutter.twilio_conversations.listeners

import com.twilio.conversations.Conversation
import com.twilio.conversations.ConversationListener
import com.twilio.conversations.Message
import com.twilio.conversations.Participant
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin

class ConversationListener(private val conversationSid: String) : ConversationListener {
    override fun onMessageAdded(message: Message) {
        TwilioConversationsPlugin.debug("ConversationListener.onMessageAdded => messageSid = ${message.sid}")
        TwilioConversationsPlugin.flutterClientApi.messageAdded(
            conversationSid,
            Mapper.messageToPigeon(message)) {}
    }

    override fun onMessageUpdated(message: Message, reason: Message.UpdateReason) {
        TwilioConversationsPlugin.debug("ConversationListener.onMessageUpdated => messageSid = ${message.sid}, reason = $reason")
        TwilioConversationsPlugin.flutterClientApi.messageUpdated(
            conversationSid,
            Mapper.messageToPigeon(message),
            reason.toString()) {}
    }

    override fun onMessageDeleted(message: Message) {
        TwilioConversationsPlugin.debug("ConversationListener.onMessageDeleted => messageSid = ${message.sid}")
        TwilioConversationsPlugin.flutterClientApi.messageDeleted(
            conversationSid,
            Mapper.messageToPigeon(message)) {}
    }

    override fun onParticipantAdded(participant: Participant) {
        TwilioConversationsPlugin.debug("ConversationListener.onParticipantAdded => participantSid = ${participant.sid}")
        TwilioConversationsPlugin.flutterClientApi.participantAdded(
            conversationSid,
            Mapper.participantToPigeon(participant)) {}
    }

    override fun onParticipantUpdated(participant: Participant, reason: Participant.UpdateReason) {
        TwilioConversationsPlugin.debug("ConversationListener.onParticipantUpdated => participantSid = ${participant.sid}, reason = $reason")
        TwilioConversationsPlugin.flutterClientApi.participantUpdated(
            conversationSid,
            Mapper.participantToPigeon(participant),
            reason.toString()) {}
    }

    override fun onParticipantDeleted(participant: Participant) {
        TwilioConversationsPlugin.debug("ConversationListener.onParticipantDeleted => participantSid = ${participant.sid}")
        TwilioConversationsPlugin.flutterClientApi.participantDeleted(
            conversationSid,
            Mapper.participantToPigeon(participant)) {}
    }

    override fun onTypingStarted(conversation: Conversation, participant: Participant) {
        TwilioConversationsPlugin.debug("ConversationListener.onTypingStarted => conversationSid = ${conversation.sid}, participantSid = ${conversation.sid}")
        TwilioConversationsPlugin.flutterClientApi.typingStarted(
            conversationSid,
            Mapper.conversationToPigeon(conversation),
            Mapper.participantToPigeon(participant)) {}
    }

    override fun onTypingEnded(conversation: Conversation, participant: Participant) {
        TwilioConversationsPlugin.debug("ConversationListener.onTypingEnded => conversationSid = ${conversation.sid}, participantSid = ${participant.sid}")
        TwilioConversationsPlugin.flutterClientApi.typingEnded(
            conversationSid,
            Mapper.conversationToPigeon(conversation),
            Mapper.participantToPigeon(participant)) {}
    }

    override fun onSynchronizationChanged(conversation: Conversation) {
        TwilioConversationsPlugin.debug("ConversationListener.onSynchronizationChanged => sid: ${conversation.sid}, status: ${conversation.synchronizationStatus}")
        TwilioConversationsPlugin.flutterClientApi.synchronizationChanged(
            conversationSid,
            Mapper.conversationToPigeon(conversation)) {}
    }
}
