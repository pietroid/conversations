package twilio.flutter.twilio_conversations.methods

import com.twilio.conversations.CallbackListener
import com.twilio.conversations.Conversation
import com.twilio.conversations.ErrorInfo
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_conversations.Api
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin

class ParticipantMethods: Api.ParticipantApi {
    private val TAG = "ParticipantMethods"

    override fun getUser(
        conversationSid: String,
        participantSid: String,
        result: Api.Result<Api.UserData>
    ) {
        debug("getUser => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                val participant = conversation.participantsList.firstOrNull {
                    it.sid == participantSid
                } ?: return result.error(RuntimeException("No participant found with SID: $participantSid"))

                participant.getAndSubscribeUser {
                    debug("getUser => onSuccess")
                    result.success(Mapper.userToPigeon(it))
                }
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("getUser => onError: $errorInfo")
                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    fun debug(message: String) {
        TwilioConversationsPlugin.debug("$TAG::$message")
    }
}