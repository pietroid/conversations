import Flutter
import TwilioConversationsClient

class UserMethods: NSObject, TWCONUserApi {
    let TAG = "UserMethods"
    
    /// setFriendlyName
    func setFriendlyNameIdentity(_ identity: String?, friendlyName: String?, completion: @escaping (FlutterError?) -> Void) {
        debug("setFriendlyName => identity: \(String(describing: identity))")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(
                FlutterError(
                    code: "ERROR",
                    message: "Client has not been initialized.",
                    details: nil))
        }

        guard let identity = identity else {
            return completion(
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'identity' parameter",
                    details: nil))
        }

        guard let friendlyName = friendlyName else {
            return completion(
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'friendlyName' parameter",
                    details: nil))
        }

        client.subscribedUser(withIdentity: identity) { (result: TCHResult, user: TCHUser?) in
            if result.isSuccessful, let user = user {
                user.setFriendlyName(friendlyName) { (TCHResult) in
                    if result.isSuccessful {
                        self.debug("setFriendlyName => onSuccess")
                        completion(nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("join => onError: \(errorMessage)")
                        completion(
                            FlutterError(
                                code: "ERROR",
                                message: "Error setting friendlyName \(friendlyName) for user \(identity): \(errorMessage)",
                                details: nil))
                    }
                }
            }
        }
    }
    
    private func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}
