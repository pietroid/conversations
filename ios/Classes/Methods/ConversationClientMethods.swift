import Flutter
import TwilioConversationsClient

class ConversationClientMethods: NSObject, TWCONConversationClientApi {
    func getConversationConversationSidOrUniqueName(_ conversationSidOrUniqueName: String?, completion: @escaping (TWCONConversationData?, FlutterError?) -> Void) {
        SwiftTwilioConversationsPlugin.debug("ConversationClientMethods::getConversation => conversationSidOrUniqueName: \(conversationSidOrUniqueName)")
        
        guard let conversationSidOrUniqueName = conversationSidOrUniqueName else {
            return completion(nil, FlutterError(code: "MISSING_PARAMS", message: "Missing 'conversationSidOrUniqueName' parameter", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSidOrUniqueName, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                SwiftTwilioConversationsPlugin.debug("ConversationClientMethods::getConversation => onSuccess")
                completion(Mapper.conversationToPigeon(conversation), nil)
            } else {
                SwiftTwilioConversationsPlugin.debug("ConversationClientMethods::getConversation => onError: \(String(describing: result.error))")
                completion(nil, FlutterError(code: "ERROR", message: "Error retrieving conversation with sid or uniqueName '\(conversationSidOrUniqueName)'", details: nil))
            }
        })
    }
    
    func getMyConversations(completion: @escaping ([TWCONConversationData]?, FlutterError?) -> Void) {
        SwiftTwilioConversationsPlugin.debug("ConversationClientMethods::getMyConversations")
        let myConversations =  SwiftTwilioConversationsPlugin.instance?.client?.myConversations()
        let result = Mapper.conversationsList(myConversations)
        completion(result, nil)
    }
    
    public func updateTokenToken(_ token: String?, completion: @escaping (FlutterError?) -> Void) {
        SwiftTwilioConversationsPlugin.debug("ConversationClientMethods::updateToken")
        let flutterResult = completion

        guard let token = token else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing 'token' parameter", details: nil))
        }

        SwiftTwilioConversationsPlugin.instance?.client?.updateToken(token, completion: {(result: TCHResult) -> Void in
            if result.isSuccessful {
                SwiftTwilioConversationsPlugin.debug("ConversationClientMethods::updateToken => onSuccess")
                flutterResult(nil)
            } else {
                if let error = result.error as NSError? {
                    SwiftTwilioConversationsPlugin.debug("ConversationClientMethods::updateToken => onError: \(error)")
                    flutterResult(FlutterError(code: "\(error.code)", message: "\(error.description)", details: nil))
                }
            }
        } as TCHCompletion)
    }

    public func shutdownWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        SwiftTwilioConversationsPlugin.debug("ConversationClientMethods::shutdown")
        SwiftTwilioConversationsPlugin.instance?.client?.shutdown()
        disposeListeners()
    }
    
    public func createConversationFriendlyName(_ friendlyName: String?, completion: @escaping (TWCONConversationData?, FlutterError?) -> Void) {
        SwiftTwilioConversationsPlugin.debug("ConversationClientMethods::createConversation => friendlyName: \(friendlyName)")
        let flutterResult = completion
        
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return flutterResult(nil, FlutterError(code: "ERROR", message: "Client has not been initialized.", details: nil))
        }

        let conversationOptions: [String: Any] = [
            TCHConversationOptionFriendlyName: friendlyName
        ]

        client.createConversation(options: conversationOptions, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                SwiftTwilioConversationsPlugin.debug("ConversationClientMethods::createConversation => onSuccess")
                let conversationDict = Mapper.conversationToPigeon(conversation)
                flutterResult(conversationDict, nil)
            } else {
                SwiftTwilioConversationsPlugin.debug("ConversationClientMethods::createConversation => onError: \(String(describing: result.error))")
                flutterResult(nil, FlutterError(code: "ERROR", message: "Error creating conversation with friendlyName '\(friendlyName)': \(String(describing: result.error))", details: nil))
            }
        })
    }
    
    public func register(forNotificationTokenData tokenData: TWCONTokenData?, completion: @escaping (FlutterError?) -> Void) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted: Bool, _: Error?) in
                SwiftTwilioConversationsPlugin.debug("User responded to permissions request: \(granted)")
                if granted {
                    DispatchQueue.main.async {
                        SwiftTwilioConversationsPlugin.debug("Requesting APNS token")
                        SwiftTwilioConversationsPlugin.reasonForTokenRetrieval = "register"
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
        completion(nil)
    }
    
    public func unregister(forNotificationTokenData tokenData: TWCONTokenData?, completion: @escaping (FlutterError?) -> Void) {
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
                SwiftTwilioConversationsPlugin.debug("Requesting APNS token")
                SwiftTwilioConversationsPlugin.reasonForTokenRetrieval = "deregister"
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        completion(nil)
    }

    private func disposeListeners() {
        SwiftTwilioConversationsPlugin.clientListener = nil
        SwiftTwilioConversationsPlugin.conversationListeners.removeAll()
    }
}
