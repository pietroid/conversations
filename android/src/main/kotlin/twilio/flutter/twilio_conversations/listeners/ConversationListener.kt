package twilio.flutter.twilio_conversations.listeners

import com.twilio.conversations.*
import com.twilio.conversations.ConversationListener
import io.flutter.plugin.common.EventChannel
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin

class ConversationListener(private val conversationSid: String) : ConversationListener {
    override fun onMessageAdded(message: Message) {
        TwilioConversationsPlugin.debug("ConversationListener.onMessageAdded => messageSid = ${message.sid}")
        sendEvent("messageAdded", mapOf(
            "conversationSid" to conversationSid,
            "message" to Mapper.messageToMap(message))
        )
    }

    override fun onMessageUpdated(message: Message, reason: Message.UpdateReason) {
        TwilioConversationsPlugin.debug("ConversationListener.onMessageUpdated => messageSid = ${message.sid}, reason = $reason")
        sendEvent("messageUpdated", mapOf(
            "conversationSid" to conversationSid,
            "message" to Mapper.messageToMap(message),
            "reason" to mapOf(
                    "type" to "message",
                    "value" to reason.toString()
            )
        ))
    }

    override fun onMessageDeleted(message: Message) {
        TwilioConversationsPlugin.debug("ConversationListener.onMessageDeleted => messageSid = ${message.sid}")
        sendEvent("messageDeleted", mapOf(
            "conversationSid" to conversationSid,
            "message" to Mapper.messageToMap(message))
        )
    }


    override fun onParticipantAdded(participant: Participant) {
        TwilioConversationsPlugin.debug("ConversationListener.onParticipantAdded => participantSid = ${participant.sid}")
        sendEvent("participantAdded", mapOf(
            "conversationSid" to conversationSid,
            "participant" to Mapper.participantToMap(participant))
        )
    }

    override fun onParticipantUpdated(participant: Participant, reason: Participant.UpdateReason) {
        TwilioConversationsPlugin.debug("ConversationListener.onParticipantUpdated => participantSid = ${participant.sid}, reason = $reason")
        sendEvent("participantUpdated", mapOf(
            "conversationSid" to conversationSid,
            "participant" to Mapper.participantToMap(participant),
            "reason" to mapOf(
                    "type" to "participant",
                    "value" to reason.toString()
            )
        ))
    }

    override fun onParticipantDeleted(participant: Participant) {
        TwilioConversationsPlugin.debug("ConversationListener.onParticipantDeleted => participantSid = ${participant.sid}")
        sendEvent("participantDeleted", mapOf(
            "conversationSid" to conversationSid,
            "participant" to Mapper.participantToMap(participant))
        )
    }

    override fun onTypingStarted(conversation: Conversation, participant: Participant) {
        TwilioConversationsPlugin.debug("ConversationListener.onTypingStarted => conversationSid = ${conversation.sid}, participantSid = ${conversation.sid}")
        sendEvent("typingStarted", mapOf(
            "conversationSid" to conversationSid,
            "conversation" to Mapper.conversationToMap(conversation),
            "participant" to Mapper.participantToMap(participant))
        )
    }

    override fun onTypingEnded(conversation: Conversation, participant: Participant) {
        TwilioConversationsPlugin.debug("ConversationListener.onTypingEnded => conversationSid = ${conversation.sid}, participantSid = ${participant.sid}")
        sendEvent("typingEnded", mapOf(
            "conversationSid" to conversationSid,
            "conversation" to Mapper.conversationToMap(conversation),
            "participant" to Mapper.participantToMap(participant)))
    }

    override fun onSynchronizationChanged(conversation: Conversation) {
        TwilioConversationsPlugin.debug("ConversationListener.onSynchronizationChanged => sid: ${conversation.sid}, status: ${conversation.synchronizationStatus}")
        sendEvent("synchronizationChanged", mapOf(
            "conversationSid" to conversationSid,
            "conversation" to Mapper.conversationToMap(conversation)))
    }
    
    private fun sendEvent(name: String, data: Any?, e: ErrorInfo? = null) {
        val eventData = mapOf("name" to name, "data" to data, "error" to Mapper.errorInfoToMap(e))
        TwilioConversationsPlugin.conversationSink?.success(eventData)
    }
}