import Flutter
import TwilioConversationsClient

class ParticipantMethods: NSObject, TWCONParticipantApi {
    let TAG = "ParticipantMethods"

    func getUserConversationSid(_ conversationSid: String?, participantSid: String?, completion: @escaping (TWCONUserData?, FlutterError?) -> Void) {
        debug("getUser => conversationSid: \(String(describing: conversationSid))")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(nil, FlutterError(code: "ERROR", message: "Client has not been initialized.", details: nil))
        }

        guard let conversationSid = conversationSid else {
            return completion(nil, FlutterError(code: "MISSING_PARAMS", message: "Missing conversationSid", details: nil))
        }

        guard let participantSid = participantSid else {
            return completion(nil, FlutterError(code: "MISSING_PARAMS", message: "Missing participantSid", details: nil))
        }
        
        client.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("getUser => onSuccess")
                let participant = conversation.participants().first(where: {$0.sid == participantSid})
                participant?.subscribedUser() { result, user in
                    if result.isSuccessful {
                        completion(Mapper.userToPigeon(user), nil)
                    } else {
                        completion(nil, FlutterError(code: "NOT_FOUND", message: "No participant found with sid: \(participantSid)", details: nil))
                    }
                }
            } else {
                self.debug("getUser => onError: \(String(describing: result.error))")
                completion(nil, FlutterError(code: "ERROR", message: "Error retrieving conversation with sid '\(conversationSid)'", details: nil))
            }
        })
    }

    private func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}
