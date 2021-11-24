package twilio.flutter.twilio_conversations.methods

import com.twilio.conversations.CallbackListener
import com.twilio.conversations.ErrorInfo
import com.twilio.conversations.StatusListener
import com.twilio.conversations.User
import twilio.flutter.twilio_conversations.Api
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin

class UserMethods : Api.UserApi {
    private val TAG = "UserMethods"

    override fun setFriendlyName(
        identity: String,
        friendlyName: String,
        result: Api.Result<Void>
    ) {
        debug("setFriendlyName => identity: $String")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        client.getAndSubscribeUser(identity, object: CallbackListener<User> {
            override fun onSuccess(user: User) {
                user.setFriendlyName(friendlyName, object: StatusListener {
                    override fun onSuccess() {
                        debug("setFriendlyName => onSuccess")
                        result.success(null)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("setFriendlyName => onError: $errorInfo")
                        result.error(RuntimeException(errorInfo.message))
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("setFriendlyName => onError: $errorInfo")
                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    fun debug(message: String) {
        TwilioConversationsPlugin.debug("$TAG::$message")
    }
}