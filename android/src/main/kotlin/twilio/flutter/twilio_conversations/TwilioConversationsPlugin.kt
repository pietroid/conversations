package twilio.flutter.twilio_conversations

import ConversationMethods
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.twilio.conversations.ConversationListener
import com.twilio.conversations.ConversationsClient
import com.twilio.conversations.ErrorInfo
import com.twilio.conversations.StatusListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_conversations.listeners.ClientListener
import twilio.flutter.twilio_conversations.methods.ConversationClientMethods
import twilio.flutter.twilio_conversations.methods.MessageMethods
import twilio.flutter.twilio_conversations.methods.ParticipantMethods
import twilio.flutter.twilio_conversations.methods.PluginMethods

/** TwilioConversationsPlugin */
class TwilioConversationsPlugin : FlutterPlugin {
    private lateinit var methodChannel: MethodChannel
    private lateinit var clientChannel: EventChannel
    private lateinit var conversationChannel: EventChannel
    private lateinit var loggingChannel: EventChannel
    private lateinit var notificationChannel: EventChannel

    companion object {
        @Suppress("unused")
        @JvmStatic
        lateinit var instance: TwilioConversationsPlugin

        @JvmStatic
        val pluginApi: Api.PluginApi = PluginMethods()

        @JvmStatic
        val conversationClientApi: Api.ConversationClientApi = ConversationClientMethods()

        @JvmStatic
        val conversationApi: Api.ConversationApi = ConversationMethods()

        @JvmStatic
        val participantApi: Api.ParticipantApi = ParticipantMethods()

        @JvmStatic
        val messageApi: Api.MessageApi = MessageMethods()

        @JvmStatic
        var client: ConversationsClient? = null

        lateinit var messenger: BinaryMessenger

        lateinit var applicationContext: Context

        lateinit var clientListener: ClientListener

        var conversationListeners: HashMap<String, ConversationListener> = hashMapOf()

        var conversationSink: EventChannel.EventSink? = null
        var loggingSink: EventChannel.EventSink? = null
        var notificationSink: EventChannel.EventSink? = null

        var handler = Handler(Looper.getMainLooper())
        var nativeDebug: Boolean = false
        val LOG_TAG = "Twilio_Conversations"

        @JvmStatic
        fun debug(msg: String) {
            if (nativeDebug) {
                Log.d(LOG_TAG, msg)
                handler.post(Runnable {
                    loggingSink?.success(msg)
                })
            }
        }
    }


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        instance = this
        messenger = flutterPluginBinding.binaryMessenger
        applicationContext = flutterPluginBinding.applicationContext

        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "twilio_conversations")

        Api.PluginApi.setup(flutterPluginBinding.binaryMessenger, pluginApi)
        Api.ConversationClientApi.setup(flutterPluginBinding.binaryMessenger, conversationClientApi)
        Api.ConversationApi.setup(flutterPluginBinding.binaryMessenger, conversationApi)
        Api.ParticipantApi.setup(flutterPluginBinding.binaryMessenger, participantApi)
        Api.MessageApi.setup(flutterPluginBinding.binaryMessenger, messageApi)

        clientChannel = EventChannel(messenger, "twilio_conversations/client")
        clientChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Client eventChannel attached")
                clientListener = ClientListener()
                clientListener.events = events
                clientListener.onListen()
            }

            override fun onCancel(arguments: Any?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Client eventChannel detached")
                clientListener.events = null
            }
        })

        conversationChannel = EventChannel(messenger, "twilio_conversations/conversations")
        conversationChannel.setStreamHandler(object: EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Conversations eventChannel attached")
                conversationSink = events
            }

            override fun onCancel(arguments: Any?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Conversations eventChannel detached")
                conversationSink = null
            }
        })

        loggingChannel = EventChannel(messenger, "twilio_conversations/logging")
        loggingChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Logging eventChannel attached")
                loggingSink = events
            }

            override fun onCancel(arguments: Any?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Logging eventChannel detached")
                loggingSink = null
            }
        })

        notificationChannel = EventChannel(messenger, "twilio_conversations/notification")
        notificationChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Notification eventChannel attached")
                notificationSink = events
            }

            override fun onCancel(arguments: Any?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Notification eventChannel detached")
                notificationSink = null
            }
        })
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        debug("TwilioConversationsPlugin.onDetachedFromEngine")
        methodChannel.setMethodCallHandler(null)
        clientChannel.setStreamHandler(null)
        loggingChannel.setStreamHandler(null)
        notificationChannel.setStreamHandler(null)
    }

    internal fun sendNotificationEvent(name: String, data: Any?, e: ErrorInfo? = null) {
        val eventData = mapOf("name" to name, "data" to data, "error" to Mapper.errorInfoToMap(e))
        notificationSink?.success(eventData)
    }
}
