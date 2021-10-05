import Flutter
import UIKit
import TwilioConversationsClient

public class SwiftTwilioConversationsPlugin: NSObject, FlutterPlugin {
    public static var instance: SwiftTwilioConversationsPlugin?

    static let pluginApi: PluginMethods = PluginMethods()
    static let conversationClientApi: ConversationClientMethods = ConversationClientMethods()
    static let conversationApi: ConversationMethods = ConversationMethods()
    static let participantApi: ParticipantMethods = ParticipantMethods()
    static let messageApi: MessageMethods = MessageMethods()
    
    public static var loggingSink: FlutterEventSink?
    public static var notificationSink: FlutterEventSink?
    
    public var client: TwilioConversationsClient?
    
    public static var clientListener: ClientListener?
    public static var conversationSink: FlutterEventSink?
    public static var conversationListeners: [String: ConversationListener] = [:]
    
    public static var messenger: FlutterBinaryMessenger?

    private var clientChannel: FlutterEventChannel?
    private var conversationChannel: FlutterEventChannel?
    private var loggingChannel: FlutterEventChannel?
    private var notificationChannel: FlutterEventChannel?
    
    public static var reasonForTokenRetrieval: String?
    
    public static var nativeDebug = false
    
    public static func debug(_ msg: String) {
        if SwiftTwilioConversationsPlugin.nativeDebug {
            NSLog(msg)
            guard let loggingSink = loggingSink else {
                return
            }
            loggingSink(msg)
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        instance = SwiftTwilioConversationsPlugin()
        instance?.onRegister(registrar)
    }
    
    public func onRegister(_ registrar: FlutterPluginRegistrar) {
        SwiftTwilioConversationsPlugin.messenger = registrar.messenger()

        TWCONPluginApiSetup(registrar.messenger(),SwiftTwilioConversationsPlugin.pluginApi)
        TWCONConversationClientApiSetup(registrar.messenger(), SwiftTwilioConversationsPlugin.conversationClientApi)
        TWCONConversationApiSetup(registrar.messenger(), SwiftTwilioConversationsPlugin.conversationApi)
        TWCONParticipantApiSetup(registrar.messenger(), SwiftTwilioConversationsPlugin.participantApi)
        TWCONMessageApiSetup(registrar.messenger(), SwiftTwilioConversationsPlugin.messageApi)

        clientChannel = FlutterEventChannel(name: "twilio_conversations/client", binaryMessenger: registrar.messenger())
        clientChannel?.setStreamHandler(ClientStreamHandler())
        
        conversationChannel = FlutterEventChannel(name: "twilio_conversations/conversations", binaryMessenger: registrar.messenger())
        conversationChannel?.setStreamHandler(ConversationStreamHandler())

        loggingChannel = FlutterEventChannel(
            name: "twilio_conversations/logging", binaryMessenger: registrar.messenger())
        loggingChannel?.setStreamHandler(LoggingStreamHandler())

        notificationChannel = FlutterEventChannel(
            name: "twilio_conversations/notification", binaryMessenger: registrar.messenger())
        notificationChannel?.setStreamHandler(NotificationStreamHandler())

        registrar.addApplicationDelegate(self)
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SwiftTwilioConversationsPlugin.debug("didRegisterForRemoteNotificationsWithDeviceToken => onSuccess: \((deviceToken as NSData).description)")
                if let reason = SwiftTwilioConversationsPlugin.reasonForTokenRetrieval {
                    if reason == "register" {
                        client?.register(withNotificationToken: deviceToken, completion: { (result: TCHResult) in
                            SwiftTwilioConversationsPlugin.debug("registered for notifications: \(result.isSuccessful)")
                            SwiftTwilioConversationsPlugin.sendNotificationEvent("registered", data: ["result": result.isSuccessful], error: result.error)
                        })
                    } else {
                        client?.deregister(withNotificationToken: deviceToken, completion: { (result: TCHResult) in
                            SwiftTwilioConversationsPlugin.debug("deregistered for notifications: \(result.isSuccessful)")
                            SwiftTwilioConversationsPlugin.sendNotificationEvent("deregistered", data: ["result": result.isSuccessful], error: result.error)
                        })
                    }
                }
    }
    
    public func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError
        error: Error) {
        SwiftTwilioConversationsPlugin.debug("didFailToRegisterForRemoteNotificationsWithError => onFail")
        SwiftTwilioConversationsPlugin.sendNotificationEvent("registered", data: ["result": false], error: error)
    }

    private static func sendNotificationEvent(_ name: String, data: [String: Any]? = nil, error: Error? = nil) {
        let eventData = ["name": name, "data": data, "error": Mapper.errorToDict(error)] as [String: Any?]

        if let notificationSink = SwiftTwilioConversationsPlugin.notificationSink {
            notificationSink(eventData)
        }
    }

    class ClientStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            clientListener = ClientListener()
            SwiftTwilioConversationsPlugin.debug("ClientStreamHandler.onListen => Client eventChannel attached")
            clientListener?.events = events
            clientListener?.onListen()
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            SwiftTwilioConversationsPlugin.debug("ClientStreamHandler.onCancel => Client eventChannel detached")
            guard let clientListener = SwiftTwilioConversationsPlugin.clientListener else { return nil }
            clientListener.events = nil
            
            return nil
        }
    }

    class ConversationStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            SwiftTwilioConversationsPlugin.debug("ConversationStreamHandler.onListen => Conversation eventChannel attached")
            conversationSink = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            SwiftTwilioConversationsPlugin.debug("ConversationStreamHandler.onCancel => Conversation eventChannel detached")
            conversationSink = nil
            return nil
        }
    }

    class LoggingStreamHandler: NSObject, FlutterStreamHandler {
            func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
                SwiftTwilioConversationsPlugin.debug("LoggingStreamHandler.onListen => Logging eventChannel attached")
                SwiftTwilioConversationsPlugin.loggingSink = events
                return nil
            }

            func onCancel(withArguments arguments: Any?) -> FlutterError? {
                SwiftTwilioConversationsPlugin.debug("LoggingStreamHandler.onCancel => Logging eventChannel detached")
                SwiftTwilioConversationsPlugin.loggingSink = nil
                return nil
            }
        }
    
    class NotificationStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            SwiftTwilioConversationsPlugin.debug("NotificationStreamHandler.onListen => Notification eventChannel attached")
            SwiftTwilioConversationsPlugin.notificationSink = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            SwiftTwilioConversationsPlugin.debug("NotificationStreamHandler.onCancel => Notification eventChannel detached")
            SwiftTwilioConversationsPlugin.notificationSink = nil
            return nil
        }
    }
}
