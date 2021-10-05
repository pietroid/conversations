package twilio.flutter.twilio_conversations.methods

import com.twilio.conversations.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_conversations.Api
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin
import java.io.File

class PluginMethods: Api.PluginApi {
    private val TAG = "PluginMethods"

    override fun debug(enableNative: Boolean, enableSdk: Boolean) {
        if (enableSdk) {
            ConversationsClient.setLogLevel(ConversationsClient.LogLevel.DEBUG)
        } else {
            ConversationsClient.setLogLevel(ConversationsClient.LogLevel.ERROR)
        }

        TwilioConversationsPlugin.nativeDebug = enableNative
        return Unit
    }

    override fun create(jwtToken: String, result: Api.Result<Api.ConversationClientData>) {
        debug("create => jwtToken: $jwtToken")
        val props = ConversationsClient.Properties.newBuilder().createProperties()

        ConversationsClient.create(TwilioConversationsPlugin.applicationContext, jwtToken, props, object : CallbackListener<ConversationsClient> {
            override fun onSuccess(conversationsClient: ConversationsClient) {
                TwilioConversationsPlugin.client = conversationsClient
                conversationsClient.addListener(TwilioConversationsPlugin.clientListener)
                val clientMap = Mapper.conversationsClientToPigeon(conversationsClient)
                result.success(clientMap)
            }

            override fun onError(errorInfo: ErrorInfo) {
                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    fun debug(message: String) {
        TwilioConversationsPlugin.debug("$TAG::$message")
    }
}