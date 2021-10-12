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
        SwiftTwilioConversationsPlugin.flutterClientApi?.messageAddedConversationSid(
            conversationSid,
            messageData: Mapper.messageToPigeon(message, conversationSid: conversationSid),
            completion: { (_: Error?) in
                //TODO: consider logging an error
            })
    }

    // onMessageUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, message: TCHMessage, updated: TCHMessageUpdate) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onMessageUpdated => messageSid = \(String(describing: message.sid)), " +
                "updated = \(String(describing: updated))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.messageUpdatedConversationSid(
            conversationSid,
            messageData: Mapper.messageToPigeon(message, conversationSid: conversationSid),
            reason: Mapper.messageUpdateToString(updated),
            completion: { (_: Error?) in
                //TODO: consider logging an error
            })
    }

    // onMessageDeleted
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageDeleted message: TCHMessage) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onMessageDeleted => messageSid = \(String(describing: message.sid))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.messageDeletedConversationSid(
            conversationSid,
            messageData: Mapper.messageToPigeon(message, conversationSid: conversationSid),
            completion: { (_: Error?) in
                //TODO: consider logging an error
            })
    }

    // onParticipantAdded
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantJoined participant: TCHParticipant) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onParticipantAdded => participantSid = \(String(describing: participant.sid))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.participantAddedConversationSid(
            conversationSid,
            participantData: Mapper.participantToPigeon(participant, conversationSid: conversationSid)!,
            completion: { (_: Error?) in
                //TODO: consider logging an error
            })
    }

    // onParticipantUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participant: TCHParticipant, updated: TCHParticipantUpdate) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onParticipantUpdated => participantSid = \(String(describing: participant.sid)), " +
                "updated = \(String(describing: updated))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.participantUpdatedConversationSid(
            conversationSid,
            participantData: Mapper.participantToPigeon(participant, conversationSid: conversationSid)!,
            reason: Mapper.participantUpdateToString(updated),
            completion: { (_: Error?) in
                //TODO: consider logging an error
            })
    }

    // onParticipantDeleted
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantLeft participant: TCHParticipant) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onParticipantDeleted => participantSid = \(String(describing: participant.sid))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.participantDeletedConversationSid(
            conversationSid,
            participantData: Mapper.participantToPigeon(participant, conversationSid: conversationSid)!,
            completion: { (_: Error?) in
                //TODO: consider logging an error
            })
    }

    // onTypingStarted
    public func conversationsClient(_ client: TwilioConversationsClient, typingStartedOn conversation: TCHConversation, participant: TCHParticipant) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onTypingStarted => conversationSid = \(String(describing: conversation.sid)), " +
                "participantSid = \(String(describing: participant.sid))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.typingStartedConversationSid(
            conversationSid,
            conversationData: Mapper.conversationToPigeon(conversation)!,
            participantData: Mapper.participantToPigeon(participant, conversationSid: conversationSid)!,
            completion: { (_: Error?) in
                //TODO: consider logging an error
            })
    }

    // onTypingEnded
    public func conversationsClient(_ client: TwilioConversationsClient, typingEndedOn conversation: TCHConversation, participant: TCHParticipant) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onTypingEnded => conversationSid = \(String(describing: conversation.sid)), " +
                "participantSid = \(String(describing: participant.sid))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.typingEndedConversationSid(
            conversationSid,
            conversationData: Mapper.conversationToPigeon(conversation)!,
            participantData: Mapper.participantToPigeon(participant, conversationSid: conversationSid)!,
            completion: { (_: Error?) in
                //TODO: consider logging an error
            })

    }

    // onSynchronizationChanged
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, synchronizationStatusUpdated status: TCHConversationSynchronizationStatus) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onSynchronizationChanged => sid: \(String(describing: conversation.sid)), status: \(Mapper.conversationSynchronizationStatusToString(conversation.synchronizationStatus))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.synchronizationChangedConversationSid(
            conversationSid,
            conversationData: Mapper.conversationToPigeon(conversation)!,
            completion: { (_: Error?) in
                //TODO: consider logging an error
            })
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
