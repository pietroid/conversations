import Flutter
import TwilioConversationsClient

class ConversationClientMethods: NSObject, TWCONConversationClientApi {
    let TAG = "ConversationClientMethods"

    func getConversationConversationSidOrUniqueName(
        _ conversationSidOrUniqueName: String?,
        completion: @escaping (TWCONConversationData?, FlutterError?) -> Void) {
        self.debug("getConversation => conversationSidOrUniqueName: \(String(describing: conversationSidOrUniqueName))")

        guard let conversationSidOrUniqueName = conversationSidOrUniqueName else {
            return completion(
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSidOrUniqueName' parameter",
                    details: nil))
        }

        SwiftTwilioConversationsPlugin.instance?.client?.conversation(
            withSidOrUniqueName: conversationSidOrUniqueName,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("getConversation => onSuccess")
                completion(Mapper.conversationToPigeon(conversation), nil)
            } else {
                self.debug("getConversation => onError: \(String(describing: result.error))")
                completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "Error getting conversation with sid or uniqueName '\(conversationSidOrUniqueName)'",
                        details: nil))
            }
        })
    }

    func getMyConversations(completion: @escaping ([TWCONConversationData]?, FlutterError?) -> Void) {
        self.debug("getMyConversations")
        let myConversations =  SwiftTwilioConversationsPlugin.instance?.client?.myConversations()
        let result = Mapper.conversationsList(myConversations)
        completion(result, nil)
    }

    public func updateTokenToken(_ token: String?, completion: @escaping (FlutterError?) -> Void) {
        self.debug("updateToken")
        let flutterResult = completion

        guard let token = token else {
            return flutterResult(
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'token' parameter",
                    details: nil))
        }

        SwiftTwilioConversationsPlugin.instance?.client?.updateToken(token, completion: {(result: TCHResult) -> Void in
            if result.isSuccessful {
                self.debug("updateToken => onSuccess")
                flutterResult(nil)
            } else {
                if let error = result.error as NSError? {
                    self.debug("updateToken => onError: \(error)")
                    flutterResult(FlutterError(code: "\(error.code)", message: "\(error.description)", details: nil))
                }
            }
        } as TCHCompletion)
    }

    public func shutdownWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        self.debug("shutdown")
        SwiftTwilioConversationsPlugin.instance?.client?.shutdown()
        disposeListeners()
    }

    public func createConversationFriendlyName(
        _ friendlyName: String?,
        completion: @escaping (TWCONConversationData?, FlutterError?) -> Void) {
        guard let friendlyName = friendlyName else {
            return completion(
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'friendlyName' parameter",
                    details: nil))
        }

        self.debug("createConversation => friendlyName: \(friendlyName)")
        let flutterResult = completion

        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return flutterResult(
                nil,
                FlutterError(
                    code: "ERROR",
                    message: "Client has not been initialized.",
                    details: nil))
        }

        let conversationOptions: [String: Any] = [
            TCHConversationOptionFriendlyName: friendlyName
        ]

        client.createConversation(
            options: conversationOptions,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("createConversation => onSuccess")
                let conversationDict = Mapper.conversationToPigeon(conversation)
                completion(conversationDict, nil)
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("createConversation => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "Error creating conversation with friendlyName '\(friendlyName)': \(errorMessage)",
                        details: nil))
            }
        })
    }

    public func register(
        forNotificationTokenData tokenData: TWCONTokenData?,
        completion: @escaping (FlutterError?) -> Void) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]) { (granted: Bool, _: Error?) in
                self.debug("register => User responded to permissions request: \(granted)")
                if granted {
                    DispatchQueue.main.async {
                        self.debug("register => Requesting APNS token")
                        SwiftTwilioConversationsPlugin.reasonForTokenRetrieval = "register"
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
        completion(nil)
    }

    public func unregister(
        forNotificationTokenData tokenData: TWCONTokenData?,
        completion: @escaping (FlutterError?) -> Void) {
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
                self.debug("unregister => Requesting APNS token")
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

    private func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}
