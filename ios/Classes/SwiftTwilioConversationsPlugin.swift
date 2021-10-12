import Flutter
import UIKit
import TwilioConversationsClient

public class SwiftTwilioConversationsPlugin: NSObject, FlutterPlugin {
    public static var instance: SwiftTwilioConversationsPlugin?

    // Flutter > Host APIs
    static let pluginApi: PluginMethods = PluginMethods()
    static let conversationClientApi: ConversationClientMethods = ConversationClientMethods()
    static let conversationApi: ConversationMethods = ConversationMethods()
    static let participantApi: ParticipantMethods = ParticipantMethods()
    static let messageApi: MessageMethods = MessageMethods()

    // Host > Flutter APIs
    static var flutterClientApi: TWCONFlutterConversationClientApi?
    static var flutterLoggingApi: TWCONFlutterLoggingApi?
    
    public var client: TwilioConversationsClient?
    
    public static var clientListener: ClientListener?
    public static var conversationListeners: [String: ConversationListener] = [:]
    
    public static var messenger: FlutterBinaryMessenger?
    
    public static var reasonForTokenRetrieval: String?
    
    public static var nativeDebug = false
    
    public static func debug(_ msg: String) {
        if SwiftTwilioConversationsPlugin.nativeDebug {
            NSLog(msg)
            guard let loggingApi = SwiftTwilioConversationsPlugin.flutterLoggingApi else {
                return
            }
            loggingApi.log(fromHostMsg: msg) { (_: Error?) in
                //TODO: consider doing something
            }
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        instance = SwiftTwilioConversationsPlugin()
        instance?.onRegister(registrar)
    }
    
    public func onRegister(_ registrar: FlutterPluginRegistrar) {
        SwiftTwilioConversationsPlugin.messenger = registrar.messenger()

        SwiftTwilioConversationsPlugin.flutterClientApi = TWCONFlutterConversationClientApi(binaryMessenger: registrar.messenger())
        SwiftTwilioConversationsPlugin.flutterLoggingApi = TWCONFlutterLoggingApi(binaryMessenger: registrar.messenger())
        
        TWCONPluginApiSetup(registrar.messenger(),SwiftTwilioConversationsPlugin.pluginApi)
        TWCONConversationClientApiSetup(registrar.messenger(), SwiftTwilioConversationsPlugin.conversationClientApi)
        TWCONConversationApiSetup(registrar.messenger(), SwiftTwilioConversationsPlugin.conversationApi)
        TWCONParticipantApiSetup(registrar.messenger(), SwiftTwilioConversationsPlugin.participantApi)
        TWCONMessageApiSetup(registrar.messenger(), SwiftTwilioConversationsPlugin.messageApi)

        registrar.addApplicationDelegate(self)
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SwiftTwilioConversationsPlugin.debug("didRegisterForRemoteNotificationsWithDeviceToken => onSuccess: \((deviceToken as NSData).description)")
        if let reason = SwiftTwilioConversationsPlugin.reasonForTokenRetrieval {
            if reason == "register" {
                client?.register(withNotificationToken: deviceToken, completion: { (result: TCHResult) in
                    SwiftTwilioConversationsPlugin.debug("registered for notifications: \(result.isSuccessful)")
                    if result.isSuccessful {
                        SwiftTwilioConversationsPlugin.flutterClientApi?.registered(completion: { (_: Error?) in
                            // TODO: consider doing something
                        })
                    } else if let error = result.error {
                        SwiftTwilioConversationsPlugin.flutterClientApi?.registrationFailedErrorInfoData(Mapper.errorToPigeon(error), completion: { (_: Error?) in
                            // TODO: consider doing something
                        })
                    } else {
                        let error = TWCONErrorInfoData()
                        error.code = 0
                        error.message = "Unknown error during registration."
                        SwiftTwilioConversationsPlugin.flutterClientApi?.registrationFailedErrorInfoData(error, completion: { (_: Error?) in
                            // TODO: consider doing something
                        })
                    }
                })
            } else {
                client?.deregister(withNotificationToken: deviceToken, completion: { (result: TCHResult) in
                    SwiftTwilioConversationsPlugin.debug("deregistered for notifications: \(result.isSuccessful)")
                    if result.isSuccessful {
                        SwiftTwilioConversationsPlugin.flutterClientApi?.deregistered(completion: { (_: Error?) in
                            // TODO: consider doing something
                        })
                    } else if let error = result.error {
                        SwiftTwilioConversationsPlugin.flutterClientApi?.deregistrationFailedErrorInfoData(Mapper.errorToPigeon(error), completion: { (_: Error?) in
                            // TODO: consider doing something
                        })
                    } else {
                        let error = TWCONErrorInfoData()
                        error.code = 0
                        error.message = "Unknown error during deregistration."
                        SwiftTwilioConversationsPlugin.flutterClientApi?.deregistrationFailedErrorInfoData(error, completion: { (_: Error?) in
                            // TODO: consider doing something
                        })
                    }
                })
            }
        }
    }
    
    public func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError
        error: Error) {
        SwiftTwilioConversationsPlugin.debug("didFailToRegisterForRemoteNotificationsWithError => onFail")
        let error = error as NSError
        let exception = TWCONErrorInfoData()
        exception.code = NSNumber(value: error.code)
        exception.message = error.localizedDescription
        SwiftTwilioConversationsPlugin.flutterClientApi?.registrationFailedErrorInfoData(exception, completion: { (_: Error?) in
            // TODO: consider doing something
        })
    }
}
