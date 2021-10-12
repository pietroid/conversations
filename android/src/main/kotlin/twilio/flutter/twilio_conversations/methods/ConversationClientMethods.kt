package twilio.flutter.twilio_conversations.methods

import com.twilio.conversations.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import twilio.flutter.twilio_conversations.Api
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin

class ConversationClientMethods: Api.ConversationClientApi {
    override fun updateToken(token: String, result: Api.Result<Void>) {
        TwilioConversationsPlugin.debug("ConversationClientMethods::updateToken")
        TwilioConversationsPlugin.client?.updateToken(token, object : StatusListener {
            override fun onSuccess() {
                TwilioConversationsPlugin.debug("updateToken => onSuccess")
                result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioConversationsPlugin.debug("updateToken => onError: $errorInfo")
                result.error(RuntimeException(errorInfo.message))
            }
        })
        TwilioConversationsPlugin.debug("updateToken => END")
    }

    override fun shutdown() {
        TwilioConversationsPlugin.debug("ConversationClientMethods::shutdown")
        TwilioConversationsPlugin.client?.shutdown()
        disposeListeners()
    }

    override fun createConversation(
        friendlyName: String,
        result: Api.Result<Api.ConversationData?>
    ) {
        TwilioConversationsPlugin.debug("ConversationClientMethods::createConversation")
        try {
            TwilioConversationsPlugin.client?.createConversation(friendlyName, object :
                CallbackListener<Conversation?> {
                override fun onSuccess(conversation: Conversation?) {
                    if (conversation == null) {
                        TwilioConversationsPlugin.debug("ConversationClientMethods::createConversation => onError: Conversation null")
                        result.error(RuntimeException("Error creating conversation: Conversation null"))
                        return
                    }
                    TwilioConversationsPlugin.debug("ConversationClientMethods::createConversation => onSuccess")
                    val conversationMap = Mapper.conversationToPigeon(conversation)
                    result.success(conversationMap)
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioConversationsPlugin.debug("ConversationClientMethods::createConversation => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(IllegalArgumentException(err.message))
        }
    }

    override fun getMyConversations(result: Api.Result<MutableList<Api.ConversationData>>) {
        TwilioConversationsPlugin.debug("ConversationClientMethods::getMyConversations")
        GlobalScope.launch {
            val myConversations = TwilioConversationsPlugin.client?.myConversations
            var conversationsSynchronized = false

            while (!conversationsSynchronized) {
                conversationsSynchronized = true

                val convoStatuses = myConversations?.map { it.synchronizationStatus }
                convoStatuses?.forEach {
                    conversationsSynchronized = (conversationsSynchronized && (it == Conversation.SynchronizationStatus.ALL))
                }

                delay(100)
            }

            launch(Dispatchers.Main) {
                TwilioConversationsPlugin.debug("ConversationClientMethods::getMyConversations => onSuccess")
                val conversationsList = Mapper.conversationsListToPigeon(myConversations)
                result.success(conversationsList.toMutableList())
            }
        }
    }

    override fun getConversation(
        conversationSidOrUniqueName: String,
        result: Api.Result<Api.ConversationData>
    ) {
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        TwilioConversationsPlugin.debug("ConversationClientMethods::getConversations => conversationSidOrUniqueName: $conversationSidOrUniqueName")
        client.getConversation(conversationSidOrUniqueName, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                TwilioConversationsPlugin.debug("ConversationClientMethods::getConversations => onSuccess")
                result.success(Mapper.conversationToPigeon(conversation))
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioConversationsPlugin.debug("ConversationClientMethods::getConversations => onError: $errorInfo")
                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    override fun registerForNotification(tokenData: Api.TokenData, result: Api.Result<Void>) {
        val token: String = tokenData.token
            ?: return result.error(RuntimeException("The parameter 'token' was not provided"))

        TwilioConversationsPlugin.client?.registerFCMToken(ConversationsClient.FCMToken(token), object : StatusListener {
            override fun onSuccess() {
                TwilioConversationsPlugin.flutterClientApi.registered {  }
                result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo) {
                super.onError(errorInfo)
                TwilioConversationsPlugin.flutterClientApi.registrationFailed(Mapper.errorInfoToPigeon(errorInfo)) { }
                result.error(RuntimeException("Failed to register for FCM notifications: ${errorInfo.message}"))
            }
        })
    }

    override fun unregisterForNotification(tokenData: Api.TokenData, result: Api.Result<Void>) {
        val token: String = tokenData.token
            ?: return result.error(RuntimeException("The parameter 'token' was not provided"))

        TwilioConversationsPlugin.client?.unregisterFCMToken(ConversationsClient.FCMToken(token), object : StatusListener {
            override fun onSuccess() {
                TwilioConversationsPlugin.flutterClientApi.deregistered {  }
                result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo) {
                super.onError(errorInfo)
                TwilioConversationsPlugin.flutterClientApi.deregistrationFailed(Mapper.errorInfoToPigeon(errorInfo)) { }
                result.error(RuntimeException("Failed to register for FCM notifications: ${errorInfo.message}"))
            }
        })
    }

    private fun disposeListeners() {
        TwilioConversationsPlugin.conversationListeners.clear()
    }
}