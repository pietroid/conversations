import Flutter
import TwilioConversationsClient

public class ConversationListener: NSObject, TCHConversationDelegate {
    let conversationSid: String
    
    init(_ conversationSid: String) {
        self.conversationSid = conversationSid
    }

    // onMessageAdded
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageAdded message: TCHMessage) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onMessageAdded => messageSid = \(String(describing: message.sid))")
        sendEvent("messageAdded", data: [
            "conversationSid": conversationSid,
            "message": Mapper.messageToDict(message, conversationSid: conversation.sid)
        ])
    }

    // onMessageUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, message: TCHMessage, updated: TCHMessageUpdate) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onMessageUpdated => messageSid = \(String(describing: message.sid)), " +
                "updated = \(String(describing: updated))")
        sendEvent("messageUpdated", data: [
            "conversationSid": conversationSid,
            "message": Mapper.messageToDict(message, conversationSid: conversation.sid),
            "reason": [
                "type": "message",
                "value": Mapper.messageUpdateToString(updated)
            ]
        ])
    }

    // onMessageDeleted
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageDeleted message: TCHMessage) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onMessageDeleted => messageSid = \(String(describing: message.sid))")
        sendEvent("messageDeleted", data: [
            "conversationSid": conversationSid,
            "message": Mapper.messageToDict(message, conversationSid: conversation.sid)
        ])
    }

    // onParticipantAdded
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantJoined participant: TCHParticipant) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onParticipantAdded => participantSid = \(String(describing: participant.sid))")
        sendEvent("participantAdded", data: [
            "conversationSid": conversationSid,
            "participant": Mapper.participantToDict(participant, conversationSid: conversation.sid) as Any
        ])
    }

    // onParticipantUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participant: TCHParticipant, updated: TCHParticipantUpdate) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onParticipantUpdated => participantSid = \(String(describing: participant.sid)), " +
                "updated = \(String(describing: updated))")
        sendEvent("participantUpdated", data: [
            "conversationSid": conversationSid,
            "participant": Mapper.participantToDict(participant, conversationSid: conversation.sid) as Any,
            "reason": [
                "type": "participant",
                "value": Mapper.participantUpdateToString(updated)
            ]
        ])
    }

    // onParticipantDeleted
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantLeft participant: TCHParticipant) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onParticipantDeleted => participantSid = \(String(describing: participant.sid))")
        sendEvent("participantDeleted", data: [
            "conversationSid": conversationSid,
            "participant": Mapper.participantToDict(participant, conversationSid: conversation.sid) as Any
        ])
    }

    // onTypingStarted
    public func conversationsClient(_ client: TwilioConversationsClient, typingStartedOn conversation: TCHConversation, participant: TCHParticipant) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onTypingStarted => conversationSid = \(String(describing: conversation.sid)), " +
                "participantSid = \(String(describing: participant.sid))")
        sendEvent("typingStarted", data: [
            "conversationSid": conversationSid,
            "conversation": Mapper.conversationToDict(conversation) as Any,
            "participant": Mapper.participantToDict(participant, conversationSid: conversation.sid) as Any
        ])
    }

    // onTypingEnded
    public func conversationsClient(_ client: TwilioConversationsClient, typingEndedOn conversation: TCHConversation, participant: TCHParticipant) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onTypingEnded => conversationSid = \(String(describing: conversation.sid)), " +
                "participantSid = \(String(describing: participant.sid))")
        sendEvent("typingEnded", data: [
            "conversationSid": conversationSid,
            "conversation": Mapper.conversationToDict(conversation) as Any,
            "participant": Mapper.participantToDict(participant, conversationSid: conversation.sid) as Any
        ])
    }

    // onSynchronizationChanged
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, synchronizationStatusUpdated status: TCHConversationSynchronizationStatus) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onSynchronizationChanged => sid: \(String(describing: conversation.sid)), status: \(Mapper.conversationSynchronizationStatusToString(conversation.synchronizationStatus))")
        sendEvent("synchronizationChanged", data: [
            "conversationSid": conversationSid,
            "conversation": Mapper.conversationToDict(conversation) as Any
        ])
    }

    private func sendEvent(_ name: String, data: [String: Any]? = nil, error: Error? = nil) {
        let eventData =
            [
                "name": name,
                "data": data,
                "error": Mapper.errorToDict(error)
            ] as [String: Any?]
        
        if let events = SwiftTwilioConversationsPlugin.conversationSink {
            events(eventData)
        }
    }

    // The ConversationListener Protocol for iOS duplicates some of the events
    // that are provided via the ClientListener protocol on both Android and iOS.
    // In the interest of functional parity and avoid duplicate notifications,
    // we will not notify the dart layer of such event from the ConversationListener.
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participant: TCHParticipant, userSubscribed user: TCHUser) {
        // userSubscribed
    }

    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participant: TCHParticipant, userUnsubscribed user: TCHUser) {
        // userUnsubscribed
    }

    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participant: TCHParticipant, user: TCHUser, updated: TCHUserUpdate) {
        // userUpdated
    }

    public func conversationsClient(_ client: TwilioConversationsClient, conversationDeleted conversation: TCHConversation) {
        // onConversationDeleted
    }

    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, updated: TCHConversationUpdate) {
        // onConversationUpdated
    }
}
