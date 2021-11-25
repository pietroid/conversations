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

    /// getParticipant
    func getParticipantConversationSid(_ conversationSid: String?, messageIndex: NSNumber?, completion: @escaping (TWCONParticipantData?, FlutterError?) -> Void) {
        debug("getParticipant => conversationSid: \(String(describing: conversationSid)), "
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
                            guard let participant = message.participant else {
                                return completion(
                                    nil,
                                    FlutterError(
                                        code: "ERROR",
                                        message: "Participant not found for message: \(messageIndex).",
                                        details: nil))
                            }
                            
                            self.debug("getParticipant => onSuccess")
                            let participantData = Mapper.participantToPigeon(participant, conversationSid: conversationSid)
                            return completion(participantData, nil)
                        } else {
                            self.debug("getParticipant => onError: \(String(describing: result.error))")
                            completion(
                                nil,
                                FlutterError(
                                    code: "ERROR",
                                    message: "Error getting message at index \(messageIndex) "
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
    
    /// updateMessageBody
    func updateMessageBodyConversationSid(_ conversationSid: String?, messageIndex: NSNumber?, messageBody: String?, completion: @escaping (FlutterError?) -> Void) {
        debug("updateMessageBody => conversationSid: \(String(describing: conversationSid)), "
                + "messageIndex: \(String(describing: messageIndex))")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(
                FlutterError(
                    code: "ERROR",
                    message: "Client has not been initialized.",
                    details: nil))
        }

        guard let conversationSid = conversationSid else {
            return completion(
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing conversationSid",
                    details: nil))
        }

        guard let messageIndex = messageIndex else {
            return completion(
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing messageIndex",
                    details: nil))
        }

        guard let messageBody = messageBody else {
            return completion(
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing messageBody",
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
                            message.updateBody(messageBody) { (result: TCHResult) in
                                if result.isSuccessful {
                                    self.debug("updateMessageBody => onSuccess")
                                    return completion(nil)
                                } else {
                                    self.debug("updateMessageBody => onError: \(String(describing: result.error))")
                                    return completion(
                                        FlutterError(
                                            code: "ERROR",
                                            message: "Error updating message at index \(messageIndex) "
                                                + "in conversation \(conversationSid)",
                                            details: nil))
                                }
                            }
                        } else {
                            self.debug("updateMessageBody => onError: \(String(describing: result.error))")
                            completion(
                                FlutterError(
                                    code: "ERROR",
                                    message: "Error getting message at index \(messageIndex) "
                                        + "in conversation \(conversationSid)",
                                    details: nil))
                        }
                    })
                } else {
                    completion(
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
