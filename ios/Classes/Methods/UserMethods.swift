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
                        self.debug("setFriendlyName => onError: \(errorMessage)")
                        completion(
                            FlutterError(
                                code: "ERROR",
                                message: "Error setting friendlyName \(friendlyName) for user \(identity): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("setFriendlyName => onError: \(errorMessage)")
                completion(
                    FlutterError(
                    code: "ERROR",
                    message: "Error locating user \(identity): \(errorMessage)",
                    details: nil))
            }
        }
    }
    
    /// setAttributes
    func setAttributesIdentity(_ identity: String?, attributes: TWCONAttributesData?, completion: @escaping (FlutterError?) -> Void) {
        debug("setAttributes => identity: \(String(describing: identity))")
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

        guard let attributesData = attributes else {
            return completion(
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'attributes' parameter",
                    details: nil))
        }

        var userAttributes: TCHJsonAttributes? = nil
        do {
            userAttributes = try Mapper.pigeonToAttributes(attributesData)
        } catch LocalizedConversionError.invalidData {
            return completion(
                FlutterError(
                    code: "CONVERSION_ERROR",
                    message: "Could not convert \(attributes?.data) to valid TCHJsonAttributes",
                    details: nil)
            )
        } catch {
            return completion(
                FlutterError(
                    code: "TYPE_ERROR",
                    message: "\(attributes?.type) is not a valid type for TCHJsonAttributes.",
                    details: nil)
            )
        }

        client.subscribedUser(withIdentity: identity) { (result: TCHResult, user: TCHUser?) in
            if result.isSuccessful, let user = user {
                user.setAttributes(userAttributes) { (TCHResult) in
                    if result.isSuccessful {
                        self.debug("setAttributes => onSuccess")
                        completion(nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("setAttributes => onError: \(errorMessage)")
                        completion(
                            FlutterError(
                                code: "ERROR",
                                message: "Error setting attributes \(userAttributes) for user \(identity): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("setAttributes => onError: \(errorMessage)")
                completion(
                    FlutterError(
                    code: "ERROR",
                    message: "Error locating user \(identity): \(errorMessage)",
                    details: nil))
            }
        }
    }
    
    private func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}
