import Flutter
import TwilioConversationsClient

public class Mapper {
    public static func conversationsClientToDict(_ client: TwilioConversationsClient?) -> [String: Any] {
        return [
            "conversations": conversationsToDict(client?.myConversations()) as Any,
            "myIdentity": client?.user?.identity as Any,
            "connectionState": clientConnectionStateToString(client?.connectionState),
            "isReachabilityEnabled": client?.isReachabilityEnabled() as Any
        ]
    }

    public static func conversationsClientToPigeon(_ client: TwilioConversationsClient?) -> TWCONConversationClientData? {
        guard let client = client else {
            return nil
        }
        let result = TWCONConversationClientData()
        result.myIdentity = client.user?.identity
        result.connectionState = clientConnectionStateToString(client.connectionState)
        result.isReachabilityEnabled = NSNumber(value: client.isReachabilityEnabled())
        return result
    }

    public static func conversationsToDict(_ conversations: [TCHConversation]?) -> [[String: Any]?]? {
        return conversations?.map { conversationToDict($0) }
    }
    
    public static func conversationsList(_ conversations: [TCHConversation]?) -> [TWCONConversationData]? {
        return conversations?.compactMap { conversationToPigeon($0) }
    }
    
    public static func conversationToDict(_ conversation: TCHConversation?) -> [String: Any]? {
        guard let conversation = conversation,
              let sid = conversation.sid else {
            return nil
        }
        
        if !SwiftTwilioConversationsPlugin.conversationListeners.keys.contains(sid) {
            SwiftTwilioConversationsPlugin.debug("Creating ConversationListener for conversation: '\(String(describing: conversation.sid))'")
            SwiftTwilioConversationsPlugin.conversationListeners[sid] = ConversationListener(sid)
            conversation.delegate = SwiftTwilioConversationsPlugin.conversationListeners[sid]
        }
        
        return [
            "attributes": attributesToDict(conversation.attributes()) as Any,
            "createdBy": conversation.createdBy as Any,
            "dateCreated": dateToString(conversation.dateCreatedAsDate) as Any,
            "dateUpdated": dateToString(conversation.dateUpdatedAsDate) as Any,
            "friendlyName": conversation.friendlyName as Any,
            "lastMessageDate": dateToString(conversation.lastMessageDate) as Any,
            "lastMessageIndex": conversation.lastMessageIndex as Any,
            "lastReadMessageIndex": conversation.lastReadMessageIndex as Any,
            "sid": sid,
            "status": conversationStatusToString(conversation.status),
            "synchronizationStatus": conversationSynchronizationStatusToString(conversation.synchronizationStatus),
            "uniqueName": conversation.uniqueName as Any
        ]
    }
    
    public static func conversationToPigeon(_ conversation: TCHConversation?) -> TWCONConversationData? {
        guard let conversation = conversation,
              let sid = conversation.sid else {
            return nil
        }
        
        if !SwiftTwilioConversationsPlugin.conversationListeners.keys.contains(sid) {
            SwiftTwilioConversationsPlugin.debug("Creating ConversationListener for conversation: '\(String(describing: conversation.sid))'")
            SwiftTwilioConversationsPlugin.conversationListeners[sid] = ConversationListener(sid)
            conversation.delegate = SwiftTwilioConversationsPlugin.conversationListeners[sid]
        }
        
        let result = TWCONConversationData()
        result.attributes = attributesToPigeon(conversation.attributes())
        result.createdBy = conversation.createdBy
        result.dateCreated = dateToString(conversation.dateCreatedAsDate)
        result.dateUpdated = dateToString(conversation.dateUpdatedAsDate)
        result.friendlyName = conversation.friendlyName
        result.lastMessageDate = dateToString(conversation.lastMessageDate)
        result.lastMessageIndex = conversation.lastMessageIndex
        result.lastReadMessageIndex = conversation.lastReadMessageIndex
        result.sid = sid
        result.status = conversationStatusToString(conversation.status)
        result.synchronizationStatus = conversationSynchronizationStatusToString(conversation.synchronizationStatus)
        result.uniqueName = conversation.uniqueName
        return result
    }

    public static func messageToPigeon(_ message: TCHMessage, conversationSid: String?) -> TWCONMessageData {
        let result = TWCONMessageData()
        result.sid = message.sid
        result.author = message.author
        result.dateCreated = message.dateCreated
        result.dateUpdated = message.dateUpdated
        result.lastUpdatedBy = message.lastUpdatedBy
        result.messageBody = message.body
        result.conversationSid = conversationSid
        result.participantSid = message.participantSid
//        result.participant = participantToDict(message.participant, conversationSid: conversationSid)
        result.messageIndex = message.index
        result.type = messageTypeToString(message.messageType)
        result.hasMedia = NSNumber(value: message.hasMedia())
        result.media = mediaToPigeon(message, conversationSid)
        result.attributes = attributesToPigeon(message.attributes())
        return result
    }

    public static func messageToDict(_ message: TCHMessage, conversationSid: String?) -> [String: Any?] {
        return [
            "sid": message.sid,
            "author": message.author,
            "dateCreated": message.dateCreated,
            "dateUpdated": message.dateUpdated,
            "lastUpdatedBy": message.lastUpdatedBy,
            "messageBody": message.body,
            "conversationSid": conversationSid,
            "participantSid": message.participantSid,
            "participant": participantToDict(message.participant, conversationSid: conversationSid),
            "messageIndex": message.index,
            "type": messageTypeToString(message.messageType),
            "hasMedia": message.hasMedia(),
            "media": mediaToDict(message, conversationSid),
            "attributes": attributesToDict(message.attributes())
        ]
    }
    
    public static func participantToDict(_ participant: TCHParticipant?, conversationSid: String?) -> [String: Any?]? {
        guard let participant = participant else {
            return nil
        }
        return [
            "sid": participant.sid,
            "conversationSid": conversationSid,
            "lastReadMessageIndex": participant.lastReadMessageIndex,
            "lastReadTimestamp": participant.lastReadTimestamp,
            "dateCreated": participant.dateCreated,
            "dateUpdated": participant.dateUpdated,
            "identity": participant.identity,
            "type": participantTypeToString(participant.type)
        ]
    }
    
    public static func participantToPigeon(_ participant: TCHParticipant?, conversationSid: String?) -> TWCONParticipantData? {
        guard let participant = participant else {
            return nil
        }
        
        let result = TWCONParticipantData()
        result.sid = participant.sid
        result.conversationSid = conversationSid
        result.lastReadMessageIndex = participant.lastReadMessageIndex
        result.lastReadTimestamp = participant.lastReadTimestamp
        result.dateCreated = participant.dateCreated
        result.dateUpdated = participant.dateUpdated
        result.identity = participant.identity
        result.type = participantTypeToString(participant.type)
        result.attributes = attributesToPigeon(participant.attributes())
        return result
    }

    public static func userToDict(_ user: TCHUser?) -> [String: Any]? {
        guard let user = user else {
            return nil
        }
        return [
            "friendlyName": user.friendlyName as Any,
            "attributes": attributesToDict(user.attributes()) as Any,
            "identity": user.identity as Any,
            "isOnline": user.isOnline(),
            "isNotifiable": user.isNotifiable(),
            "isSubscribed": user.isSubscribed()
        ]
    }
    
    public static func userToPigeon(_ user: TCHUser?) -> TWCONUserData? {
        guard let user = user else {
            return nil
        }
        let result = TWCONUserData()
        result.friendlyName = user.friendlyName
        result.attributes = attributesToPigeon(user.attributes())
        result.identity = user.identity
        result.isOnline = NSNumber(value: user.isOnline())
        result.isNotifiable = NSNumber(value: user.isNotifiable())
        result.isSubscribed = NSNumber(value: user.isSubscribed())
        return result
    }
    
    public static func mediaToDict(_ message: TCHMessage, _ conversationSid: String?) -> [String: Any?]? {
        if !message.hasMedia() {
            return nil
        }
        return [
            "sid": message.mediaSid,
            "fileName": message.mediaFilename,
            "type": message.mediaType,
            "size": message.mediaSize,
            "conversationSid": conversationSid,
            "messageIndex": message.index,
            "messageSid": message.sid
        ]
    }
    
    public static func mediaToPigeon(_ message: TCHMessage, _ conversationSid: String?) -> TWCONMessageMediaData? {
        if !message.hasMedia() {
            return nil
        }
        
        let result = TWCONMessageMediaData()
        result.sid = message.mediaSid
        result.fileName = message.mediaFilename
        result.type = message.mediaType
        result.size = NSNumber(value: message.mediaSize)
        result.conversationSid = conversationSid
        result.messageIndex = message.index
        result.messageSid = message.sid
        return result
    }
    
    public static func attributesToDict(_ attributes: TCHJsonAttributes?) -> [String: Any?]? {
        if let attr = attributes as TCHJsonAttributes? {
            if attr.isNull {
                return [
                    "type": "NULL",
                    "data": nil
                ]
            } else if attr.isNumber {
                return [
                    "type": "NUMBER",
                    "data": attr.number?.stringValue
                ]
            } else if attr.isArray {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: attr.array as Any) else {
                    return nil
                }
                return [
                    "type": "ARRAY",
                    "data": String(data: jsonData, encoding: String.Encoding.utf8)
                ]
            } else if attr.isString {
                return [
                    "type": "STRING",
                    "data": attr.string
                ]
            } else if attr.isDictionary {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: attr.dictionary as Any) else {
                    return nil
                }
                return [
                    "type": "OBJECT",
                    "data": String(data: jsonData, encoding: String.Encoding.utf8)
                ]
            }
        }
        return nil
    }
    
    public static func attributesToPigeon(_ attributes: TCHJsonAttributes?) -> TWCONAttributesData? {
        let result = TWCONAttributesData()
        result.type = "NULL"
        result.data = nil
        
        if let attr = attributes as TCHJsonAttributes? {
            if attr.isNumber {
                result.type = "NUMBER"
                result.data = attr.number?.stringValue
            } else if attr.isArray {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: attr.array as Any) else {
                    return result
                }
                result.type = "ARRAY"
                result.data = String(data: jsonData, encoding: String.Encoding.utf8)
            } else if attr.isString {
                result.type = "STRING"
                result.data = attr.string
            } else if attr.isDictionary {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: attr.dictionary as Any) else {
                    return result
                }
                result.type = "OBJECT"
                result.data = String(data: jsonData, encoding: String.Encoding.utf8)
            }
        }
        return result
    }
    
    public static func dictToAttributes(_ dict: [String: Any?]) -> TCHJsonAttributes {
        return TCHJsonAttributes.init(dictionary: dict as [AnyHashable: Any])
    }
    
    public static func errorToDict(_ error: Error?) -> [String: Any?]? {
        if let error = error as NSError? {
            return [
                "code": error.code,
                "message": error.description
            ]
        }
        
        return nil
    }

    public static func errorToPigeon(_ error: TCHError) -> TWCONErrorInfoData {
        let errorInfoData = TWCONErrorInfoData()
        errorInfoData.code = NSNumber(value: error.code)
        errorInfoData.message = error.description
        return errorInfoData
    }

    public static func conversationStatusToString(_ conversationStatus: TCHConversationStatus) -> String {
        let conversationStatusString: String
        
        switch conversationStatus {
        case .joined:
            conversationStatusString = "JOINED"
        case .notParticipating:
            conversationStatusString = "NOT_PARTICIPATING"
        @unknown default:
            conversationStatusString = "UNKNOWN"
        }
        
        return conversationStatusString
    }
    
    public static func clientConnectionStateToString(_ connectionState: TCHClientConnectionState?) -> String {
        var connectionStateString: String = "UNKNOWN"
        if let connectionState = connectionState {
            switch connectionState {
            case .unknown:
                connectionStateString = "UNKNOWN"
            case .disconnected:
                connectionStateString = "DISCONNECTED"
            case .connected:
                connectionStateString = "CONNECTED"
            case .connecting:
                connectionStateString = "CONNECTING"
            case .denied:
                connectionStateString = "DENIED"
            case .error:
                connectionStateString = "ERROR"
            case .fatalError:
                connectionStateString = "FATAL_ERROR"
            default:
                connectionStateString = "UNKNOWN"
            }
        }
        
        return connectionStateString
    }
    
    public static func clientSynchronizationStatusToString(_ syncStatus: TCHClientSynchronizationStatus?) -> String {
        var syncStateString: String = "UNKNOWN"
        if let syncStatus = syncStatus {
            switch syncStatus {
            case .started:
                syncStateString = "STARTED"
            case .completed:
                syncStateString = "COMPLETED"
            case .conversationsListCompleted:
                syncStateString = "CONVERSATIONS_COMPLETED"
            case .failed:
                syncStateString = "FAILED"
            @unknown default:
                syncStateString = "UNKNOWN"
            }
        }
        
        return syncStateString
    }
    
    public static func conversationSynchronizationStatusToString(_ syncStatus: TCHConversationSynchronizationStatus) -> String {
        let syncStatusString: String
        
        switch syncStatus {
        case .none:
            syncStatusString = "NONE"
        case .identifier:
            syncStatusString = "IDENTIFIER"
        case .metadata:
            syncStatusString = "METADATA"
        case .all:
            syncStatusString = "ALL"
        case .failed:
            syncStatusString = "FAILED"
        @unknown default:
            syncStatusString = "UNKNOWN"
        }
        
        return syncStatusString
    }
    
    public static func conversationUpdateToString(_ update: TCHConversationUpdate) -> String {
        switch update {
        case .attributes:
            return "ATTRIBUTES"
        case .friendlyName:
            return "FRIENDLY_NAME"
        case .lastMessage:
            return "LAST_MESSAGE"
        case .lastReadMessageIndex:
            return "LAST_READ_MESSAGE_INDEX"
        case .state:
            return "STATE"
        case .status:
            return "STATUS"
        case .uniqueName:
            return "UNIQUE_NAME"
        case .userNotificationLevel:
            return "NOTIFICATION_LEVEL"
        @unknown default:
            return "UNKNOWN"
        }
    }
    
    public static func participantTypeToString(_ participantType: TCHParticipantType) -> String {
        let participantTypeString: String
        
        switch participantType {
        case .chat:
            participantTypeString = "CHAT"
        case .other:
            participantTypeString = "OTHER"
        case .sms:
            participantTypeString = "SMS"
        case .unset:
            participantTypeString = "UNSET"
        case .whatsapp:
            participantTypeString = "WHATSAPP"
        @unknown default:
            participantTypeString = "UNKNOWN"
        }
        
        return participantTypeString
    }
    
    public static func messageTypeToString(_ messageType: TCHMessageType) -> String {
        let messageTypeString: String
        
        switch messageType {
        case .media:
            messageTypeString = "MEDIA"
        case .text:
            messageTypeString = "TEXT"
        @unknown default:
            messageTypeString = "UNKNOWN"
        }
        
        return messageTypeString
    }
    
    public static func messageUpdateToString(_ update: TCHMessageUpdate) -> String {
        let updateString: String
        
        switch update {
        case .attributes:
            updateString = "ATTRIBUTES"
        case .body:
            updateString = "BODY"
        case .deliveryReceipt:
            updateString = "DELIVERY_RECEIPT"
        case .subject:
            updateString = "SUBJECT"
        @unknown default:
            updateString = "UNKNOWN"
        }
        
        return updateString
    }
    
    public static func participantUpdateToString(_ update: TCHParticipantUpdate) -> String {
        let updateString: String
        
        switch update {
        case .attributes:
            updateString = "ATTRIBUTES"
        case .lastReadMessageIndex:
            updateString = "LAST_READ_MESSAGE_INDEX"
        case .lastReadTimestamp:
            updateString = "LAST_READ_TIMESTAMP"
        @unknown default:
            updateString = "UNKNOWN"
        }
        
        return updateString
    }
    
    public static func userUpdateToString(_ update: TCHUserUpdate) -> String {
        switch update {
        case .friendlyName:
            return "FRIENDLY_NAME"
        case .attributes:
            return "ATTRIBUTES"
        case .reachabilityOnline:
            return "REACHABILITY_ONLINE"
        case .reachabilityNotifiable:
            return "REACHABILITY_NOTIFIABLE"
        @unknown default:
            return "UNKNOWN"
        }
    }
    
    public static func dateToString(_ date: Date?) -> String? {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            return formatter.string(from: date)
        }
        return nil
    }
}
