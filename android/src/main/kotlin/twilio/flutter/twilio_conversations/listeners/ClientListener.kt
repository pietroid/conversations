package twilio.flutter.twilio_conversations.listeners

import com.twilio.conversations.*
import twilio.flutter.twilio_conversations.Api
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin

class ClientListener : ConversationsClientListener {
    override fun onClientSynchronization(status: ConversationsClient.SynchronizationStatus) {
        TwilioConversationsPlugin.debug("ClientListener.onClientSynchronization => status = $status")
        TwilioConversationsPlugin.flutterClientApi.clientSynchronization(status.toString()) {}
    }

    override fun onConversationSynchronizationChange(conversation: Conversation) {
        TwilioConversationsPlugin.debug("ClientListener.onConversationSynchronizationChange => sid = ${conversation.sid}")
        TwilioConversationsPlugin.flutterClientApi.conversationSynchronizationChange(Mapper.conversationToPigeon(conversation)) {}
    }

    override fun onNotificationSubscribed() {
        TwilioConversationsPlugin.debug("ClientListener.onNotificationSubscribed")
        TwilioConversationsPlugin.flutterClientApi.notificationSubscribed {  }
    }

    override fun onUserSubscribed(user: User?) {
        user ?: return
        TwilioConversationsPlugin.debug("ClientListener.onUserSubscribed => user '${user?.identity}'")
        TwilioConversationsPlugin.flutterClientApi.userSubscribed(Mapper.userToPigeon(user)) {}
    }

    override fun onUserUnsubscribed(user: User?) {
        user ?: return
        TwilioConversationsPlugin.debug("ClientListener.onUserUnsubscribed => user '${user?.identity}'")
        TwilioConversationsPlugin.flutterClientApi.userUnsubscribed(Mapper.userToPigeon(user)) {}
    }

    override fun onUserUpdated(user: User?, reason: User.UpdateReason?) {
        user ?: return
        reason ?: return
        TwilioConversationsPlugin.debug("ClientListener.onUserUpdated => user '${user?.identity}' updated, $reason")
        TwilioConversationsPlugin.flutterClientApi.userUpdated(Mapper.userToPigeon(user), reason.toString()) {}
    }

    override fun onNotificationFailed(errorInfo: ErrorInfo?) {
        errorInfo ?: return
        TwilioConversationsPlugin.flutterClientApi.notificationFailed(Mapper.errorInfoToPigeon(errorInfo)) {}
    }

    override fun onTokenExpired() {
        TwilioConversationsPlugin.debug("ClientListener.onTokenExpired")
        TwilioConversationsPlugin.flutterClientApi.tokenExpired {  }
    }

    override fun onConversationUpdated(conversation: Conversation?, reason: Conversation.UpdateReason?) {
        TwilioConversationsPlugin.debug("ClientListener.onConversationUpdated => conversation '${conversation?.sid}' updated, $reason")
        val event = Api.ConversationUpdatedData()
        event.conversation = Mapper.conversationToPigeon(conversation)
        event.reason = reason?.toString()
        TwilioConversationsPlugin.flutterClientApi.conversationUpdated(event) {}
    }

    override fun onConversationAdded(conversation: Conversation) {
        TwilioConversationsPlugin.debug("ClientListener.onConversationAdded => sid = ${conversation.sid}")
        TwilioConversationsPlugin.flutterClientApi.conversationAdded(Mapper.conversationToPigeon(conversation)) {}
    }

    override fun onNewMessageNotification(conversationSid: String?, messageSid: String?, messageIndex: Long) {
        conversationSid ?: return
        TwilioConversationsPlugin.debug("ClientListener.onNewMessageNotification => conversationSid = $conversationSid, messageSid = $messageSid, messageIndex = $messageIndex")
        TwilioConversationsPlugin.flutterClientApi.newMessageNotification(conversationSid, messageIndex) {}
    }

    override fun onAddedToConversationNotification(conversationSid: String?) {
        conversationSid ?: return
        TwilioConversationsPlugin.debug("ClientListener.onAddedToConversationNotification => conversationSid = $conversationSid")
        TwilioConversationsPlugin.flutterClientApi.addedToConversationNotification(conversationSid) {}
    }

    override fun onConnectionStateChange(state: ConversationsClient.ConnectionState) {
        TwilioConversationsPlugin.debug("ClientListener.onConnectionStateChange => state = $state")
        TwilioConversationsPlugin.flutterClientApi.connectionStateChange(state.toString()) {}
    }

    override fun onError(errorInfo: ErrorInfo?) {
        if (errorInfo == null) {
            return
        }
        TwilioConversationsPlugin.flutterClientApi.error(Mapper.errorInfoToPigeon(errorInfo)) {}
    }

    override fun onConversationDeleted(conversation: Conversation) {
        TwilioConversationsPlugin.debug("ClientListener.onConversationDeleted => sid = ${conversation.sid}")
        TwilioConversationsPlugin.flutterClientApi.conversationDeleted(Mapper.conversationToPigeon(conversation)) {}
    }

    override fun onRemovedFromConversationNotification(conversationSid: String?) {
        TwilioConversationsPlugin.debug("ClientListener.onRemovedFromConversationNotification => conversationSid = $conversationSid")
        conversationSid ?: return
        TwilioConversationsPlugin.flutterClientApi.removedFromConversationNotification(conversationSid) {}
    }

    override fun onTokenAboutToExpire() {
        TwilioConversationsPlugin.debug("ClientListener.onTokenAboutToExpire")
        TwilioConversationsPlugin.flutterClientApi.tokenAboutToExpire {  }
    }
}