import TwilioConversationsClient

public class ClientListener: NSObject, TwilioConversationsClientDelegate {
    // onAddedToConversation Notification
    public func conversationsClient(_ client: TwilioConversationsClient, notificationAddedToConversationWithSid conversationSid: String) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onAddedToConversationNotification => conversationSid is \(conversationSid)'")
        SwiftTwilioConversationsPlugin.flutterClientApi?.added(toConversationNotificationConversationSid: conversationSid, completion: { (_: Error?) in
            //TODO: consider logging an error
        })
    }
    
    // onClientSynchronizationUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onClientSynchronization => state is \(Mapper.clientSynchronizationStatusToString(status))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.clientSynchronizationSynchronizationStatus(Mapper.clientSynchronizationStatusToString(status), completion: { (_: Error?) in
            //TODO: consider logging an error
        })
    }
    
    // onConnectionStateChange
    public func conversationsClient(_ client: TwilioConversationsClient, connectionStateUpdated state: TCHClientConnectionState) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onConnectionStateChange => state is \(Mapper.clientConnectionStateToString(state))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.connectionStateChangeConnectionState(Mapper.clientConnectionStateToString(state), completion: { (_: Error?) in
            //TODO: consider logging an error
        })
    }

    // onConversationAdded
    public func conversationsClient(_ client: TwilioConversationsClient, conversationAdded conversation: TCHConversation) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onConversationAdded => conversationSid is \(String(describing: conversation.sid))'")
        SwiftTwilioConversationsPlugin.flutterClientApi?.conversationAddedConversationData(Mapper.conversationToPigeon(conversation)!, completion: { (_: Error?) in
           // TODO: consider logging an error
        })
    }
    
    // onConversationDeleted
    public func conversationsClient(_ client: TwilioConversationsClient, conversationDeleted conversation: TCHConversation) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onConversationDeleted => conversationSid is \(String(describing: conversation.sid))'")
        SwiftTwilioConversationsPlugin.flutterClientApi?.conversationDeletedConversationData(Mapper.conversationToPigeon(conversation)!, completion: { (_: Error?) in
            // TODO: consider logging an error
        })
    }
    
    // onConversationSynchronizationChanged
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, synchronizationStatusUpdated status: TCHConversationSynchronizationStatus) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onConversationSynchronizationChange => conversationSid is '\(String(describing: conversation.sid))', syncStatus: \(Mapper.conversationSynchronizationStatusToString(conversation.synchronizationStatus))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.conversationSynchronizationChange(Mapper.conversationToPigeon(conversation)!, completion: { (_: Error?) in
            // TODO: consider logging an error
        })
    }
    
    // onConversationUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, updated: TCHConversationUpdate) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.conversationUpdated => conversationSid is \(String(describing: conversation.sid)) updated, \(Mapper.conversationUpdateToString(updated))")

        let event = TWCONConversationUpdatedData()
        event.conversation = Mapper.conversationToPigeon(conversation)
        event.reason = Mapper.conversationUpdateToString(updated)
        
        SwiftTwilioConversationsPlugin.flutterClientApi?.conversationUpdatedEvent(event, completion: { (_: Error?) in
            //TODO: consider logging an error
        })
    }
    
    // onError
    public func conversationsClient(_ client: TwilioConversationsClient, errorReceived error: TCHError) {
        SwiftTwilioConversationsPlugin.flutterClientApi?.errorErrorInfoData(Mapper.errorToPigeon(error), completion: { (_: Error?) in
            //TODO: consider logging an error
        })
    }
    
    // onNewMessageNotification
    public func conversationsClient(_ client: TwilioConversationsClient, notificationNewMessageReceivedForConversationSid conversationSid: String, messageIndex: UInt) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onNewMessageNotification => conversationSid: \(conversationSid), messageIndex: \(messageIndex)")
        SwiftTwilioConversationsPlugin.flutterClientApi?.newMessageNotificationConversationSid(conversationSid, messageIndex: NSNumber(value: messageIndex), completion: { (_: Error?) in
            //TODO: consider logging an error
        })
    }

    
    // onRemovedFromConversationNotification
    public func conversationsClient(_ client: TwilioConversationsClient, notificationRemovedFromConversationWithSid conversationSid: String) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onRemovedFromConversationNotification => conversationSid: \(conversationSid)")
        SwiftTwilioConversationsPlugin.flutterClientApi?.removed(fromConversationNotificationConversationSid: conversationSid, completion: { (_: Error?) in
            //TODO: consider logging an error
        })
    }

    // onTokenExpired
    public func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onTokenExpired")
        SwiftTwilioConversationsPlugin.flutterClientApi?.tokenExpired(completion: { (_: Error?) in
            //TODO: consider logging an error
        })
    }
    
    // onTokenAboutToExpire
    public func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onTokenAboutToExpire")
        SwiftTwilioConversationsPlugin.flutterClientApi?.tokenAboutToExpire(completion: { (_: Error?) in
            //TODO: consider logging an error
        })
    }
    
    // onUserSubscribed
    public func conversationsClient(_ client: TwilioConversationsClient, userSubscribed user: TCHUser) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onUserSubscribed => user '\(String(describing: user.identity))'")
        SwiftTwilioConversationsPlugin.flutterClientApi?.userSubscribedUserData(Mapper.userToPigeon(user)!, completion: { (_: Error?) in
            //TODO: consider logging an error
        })
    }
    
    // onUserUnsubscribed
    public func conversationsClient(_ client: TwilioConversationsClient, userUnsubscribed user: TCHUser) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onUserUnsubscribed => user '\(String(describing: user.identity))'")
        SwiftTwilioConversationsPlugin.flutterClientApi?.userUnsubscribedUserData(Mapper.userToPigeon(user)!, completion: { (_: Error?) in
            //TODO: consider logging an error
        })
    }
    
    // onUserUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, user: TCHUser, updated: TCHUserUpdate) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onUserUpdated => user \(String(describing: user.identity)) updated, \(Mapper.userUpdateToString(updated))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.userUpdatedUserData(
            Mapper.userToPigeon(user)!,
            reason: Mapper.userUpdateToString(updated),
            completion: { (_: Error?) in
            //TODO: consider logging an error
        })
    }
}
