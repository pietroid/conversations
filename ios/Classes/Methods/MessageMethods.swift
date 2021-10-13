import Flutter
import TwilioConversationsClient

class MessageMethods: NSObject, TWCONMessageApi {
    let TAG = "MessageMethods"

    // swiftlint:disable function_body_length
    public func getMediaContentTemporaryUrlConversationSid(
        _ conversationSid: String?,
        messageIndex: NSNumber?,
        completion: @escaping (String?, FlutterError?) -> Void) {
        debug("getMediaContentTemporaryUrl => conversationSid: \(String(describing: conversationSid)), "
                + "messageIndex: \(String(describing: messageIndex))")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(
                nil,
                FlutterError(
                    code: "ERROR",
                    message: "Client has not been initialized.",
                    details: nil))
        }

        guard let conversationSid = conversationSid else {
            return completion(
                nil, FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing conversationSid",
                    details: nil))
        }

        guard let messageIndex = messageIndex else {
            return completion(
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing messageIndex",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
                if result.isSuccessful, let conversation = conversation {
                    conversation.message(
                        withIndex: messageIndex,
                        completion: { (result: TCHResult, message: TCHMessage?) in
                        if result.isSuccessful, let message = message {
                            message.getMediaContentTemporaryUrl(completion: { (result: TCHResult, url: String?) in
                                if result.isSuccessful, let url = url {
                                    self.debug("getMediaContentTemporaryUrl => onSuccess: \(url)")
                                    completion(url, nil)
                                } else {
                                    let errorMessage = String(describing: result.error)
                                    self.debug("getMediaContentTemporaryUrl => onError: \(errorMessage)")
                                    completion(
                                        nil,
                                        FlutterError(
                                            code: "ERROR",
                                            message: "Error getting mediaContentTemporaryUrl: \(errorMessage)",
                                            details: nil))
                                }
                            })
                        } else {
                            self.debug("getMediaContentTemporaryUrl => onError: \(String(describing: result.error))")
                            completion(
                                nil,
                                FlutterError(
                                    code: "ERROR",
                                    message: "Error getting messages at index \(messageIndex) "
                                        + "in conversation \(conversationSid)",
                                    details: nil))
                        }
                    })
                } else {
                    completion(
                        nil,
                        FlutterError(
                            code: "ERROR",
                            message: "Error retrieving conversation \(conversationSid)",
                            details: nil))
                }
        })
    }

    private func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}
