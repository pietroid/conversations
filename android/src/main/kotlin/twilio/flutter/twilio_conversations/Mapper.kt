package twilio.flutter.twilio_conversations

import com.twilio.conversations.*
import org.json.JSONArray
import org.json.JSONObject
import twilio.flutter.twilio_conversations.listeners.ConversationListener
import java.text.SimpleDateFormat
import java.util.*

object Mapper {
    //TODO go through all of the mappers in iOS, Android, and Dart, to make sure
    // they are consistent
    fun conversationsClientToPigeon(client: ConversationsClient): Api.ConversationClientData {
        val result = Api.ConversationClientData()
        result.myIdentity = client.myIdentity
        result.connectionState = client.connectionState.toString()
        result.isReachabilityEnabled = client.isReachabilityEnabled
        return result
    }

    fun attributesToMap(attributes: Attributes): Map<String, Any> {
        return mapOf(
                "type" to attributes.type.toString(),
                "data" to attributes.toString()
        )
    }

    fun listToJSONArray(list: List<Any>): JSONArray {
        val result = JSONArray()
        list.forEach {
            if (it is Map<*, *>) {
                result.put(mapToJSONObject(it as Map<String, Any>))
            } else if (it is List<*>) {
                result.put(listToJSONArray(it as List<Any>))
            } else {
                result.put(it)
            }
        }
        return result
    }

    fun mapToJSONObject(map: Map<String, Any>?): JSONObject? {
        if (map == null) {
            return null
        }
        val result = JSONObject()
        map.keys.forEach {
            if (map[it] == null) {
                result.put(it, null)
            } else if (map[it] is Map<*, *>) {
                result.put(it, mapToJSONObject(map[it] as Map<String, Any>))
            } else if (map[it] is List<*>) {
                result.put(it, listToJSONArray(map[it] as List<Any>))
            } else {
                result.put(it, map[it])
            }
        }
        return result
    }

    fun attributesToPigeon(attributes: Attributes): Api.AttributesData {
        val result = Api.AttributesData()
        result.type = attributes.type.toString()
        result.data = attributes.toString()
        return result
    }

    fun pigeonToAttributes(pigeon: Api.AttributesData): Attributes {
        var result = Attributes()
        when (pigeon.type) {
            "NULL" ->
                result = Attributes()
            "BOOLEAN" ->
                result = Attributes(pigeon.data.toBoolean())
            "NUMBER" -> {
                val number: Number =
                    if (pigeon.data.contains('.')) pigeon.data.toFloat()
                    else pigeon.data.toInt()
                result = Attributes(number)
            }
            "STRING" ->
                result = Attributes(pigeon.data)
            "OBJECT" ->
                result = Attributes(JSONObject(pigeon.data))
            "ARRAY" ->
                result = Attributes(JSONArray(pigeon.data))
        }
        return result
    }

    fun conversationsListToPigeon(conversations: MutableList<Conversation>?): List<Api.ConversationData> {
        if (conversations == null) {
            return listOf()
        }
        return conversations.mapNotNull { conversationToPigeon(it) }
    }

    fun conversationToPigeon(conversation: Conversation?): Api.ConversationData? {
        if (conversation == null) return null

        // Setting flutter event listener for the given channel if one does not yet exist.
        if (conversation.sid != null && !TwilioConversationsPlugin.conversationListeners.containsKey(conversation.sid)) {
            TwilioConversationsPlugin.debug("Creating ConversationListener for conversation: '${conversation.sid}'")
            TwilioConversationsPlugin.conversationListeners[conversation.sid] = ConversationListener(conversation.sid)
            conversation.addListener(TwilioConversationsPlugin.conversationListeners[conversation.sid])
        }

        val result = Api.ConversationData()
        result.createdBy = conversation.createdBy
        result.dateCreated = dateToString(conversation.dateCreatedAsDate)
        result.dateUpdated = dateToString(conversation.dateUpdatedAsDate)
        result.friendlyName = conversation.friendlyName
        result.lastMessageDate = dateToString(conversation.lastMessageDate)
        result.lastReadMessageIndex =
            if (conversation.synchronizationStatus.isAtLeast(Conversation.SynchronizationStatus.METADATA))
                conversation.lastReadMessageIndex else null
        result.lastMessageIndex = conversation.lastMessageIndex
        result.sid = conversation.sid
        result.status = conversation.status.toString()
        result.synchronizationStatus = conversation.synchronizationStatus.toString()
        result.uniqueName = conversation.uniqueName

        result.attributes = attributesToPigeon(conversation.attributes)

        return result
    }

    fun messageToPigeon(message: Message): Api.MessageData {
        val result = Api.MessageData()

        result.sid = message.sid
        result.author = message.author
        result.dateCreated= dateToString(message.dateCreatedAsDate)
        result.dateUpdated = dateToString(message.dateUpdatedAsDate)
        result.lastUpdatedBy = message.lastUpdatedBy
        result.subject = message.subject
        result.messageBody = message.messageBody
        result.conversationSid = message.conversation.sid
        result.participantSid = message.participantSid
//        result.participant = participantToMap(message.participant)
        result.messageIndex = message.messageIndex
        result.type = message.type.toString()
        result.media = mediaToPigeon(message)
        result.hasMedia = message.hasMedia()
        result.attributes = attributesToPigeon(message.attributes)
        return result
    }

    fun conversationToMap(conversation: Conversation?): Map<String, Any?>? {
        if (conversation == null) return null

        // Setting flutter event listener for the given channel if one does not yet exist.
        if (conversation.sid != null && !TwilioConversationsPlugin.conversationListeners.containsKey(conversation.sid)) {
            TwilioConversationsPlugin.debug("Creating ConversationListener for conversation: '${conversation.sid}'")
            TwilioConversationsPlugin.conversationListeners[conversation.sid] = ConversationListener(conversation.sid)
            conversation.addListener(TwilioConversationsPlugin.conversationListeners[conversation.sid])
        }

        return mapOf(
            "attributes" to attributesToMap(conversation.attributes),
            "createdBy" to conversation.createdBy,
            "dateCreated" to dateToString(conversation.dateCreatedAsDate),
            "dateUpdated" to dateToString(conversation.dateUpdatedAsDate),
            "friendlyName" to conversation.friendlyName,
            "lastMessageDate" to dateToString(conversation.lastMessageDate),
            "lastReadMessageIndex" to
                    if (conversation.synchronizationStatus.isAtLeast(Conversation.SynchronizationStatus.METADATA))
                        conversation.lastReadMessageIndex else null,
            "lastMessageIndex" to conversation.lastMessageIndex,
            "sid" to conversation.sid,
            "status" to conversation.status.toString(),
            "synchronizationStatus" to conversation.synchronizationStatus.toString(),
            "uniqueName" to conversation.uniqueName
        )
    }

    fun messageToMap(message: Message): Map<String, Any?> {
        return mapOf(
                "sid" to message.sid,
                "author" to message.author,
                "dateCreated" to dateToString(message.dateCreatedAsDate),
                "dateUpdated" to dateToString(message.dateUpdatedAsDate),
                "lastUpdatedBy" to message.lastUpdatedBy,
                "subject" to message.subject,
                "messageBody" to message.messageBody,
                "conversationSid" to message.conversation.sid,
                "participantSid" to message.participantSid,
                "participant" to participantToMap(message.participant),
                "messageIndex" to message.messageIndex,
                "type" to message.type.toString(),
                "media" to mapMedia(message),
                "hasMedia" to message.hasMedia(),
                "attributes" to attributesToMap(message.attributes)
        )
    }

    fun participantListToPigeon(participants: List<Participant>?): List<Api.ParticipantData> {
        if (participants == null) {
            return listOf()
        }
        return participants.mapNotNull { participantToPigeon(it) }
    }

    fun participantToMap(participant: Participant?): Map<String, Any?>? {
        if (participant == null) {
            return null
        }
        return mapOf(
                "sid" to participant.sid,
                "conversationSid" to participant.conversation.sid,
                "lastReadMessageIndex" to participant.lastReadMessageIndex,
                "lastReadTimestamp" to participant.lastReadTimestamp,
                "dateCreated" to participant.dateCreated,
                "dateUpdated" to participant.dateUpdated,
                "identity" to participant.identity,
                "type" to participant.type.toString()
        )
    }

    fun participantToPigeon(participant: Participant?): Api.ParticipantData? {
        if (participant == null) {
            return null
        }
        val result = Api.ParticipantData()
                result.sid = participant.sid
        result.conversationSid = participant.conversation.sid
        result.lastReadMessageIndex = participant.lastReadMessageIndex
        result.lastReadTimestamp = participant.lastReadTimestamp
        result.dateCreated = participant.dateCreated
        result.dateUpdated = participant.dateUpdated
        result.identity = participant.identity
        result.type = participant.type.toString()
        return result
    }

    fun userToMap(user: User?): Map<String, Any>? {
        if (user == null) return null
        return mapOf(
                "friendlyName" to user.friendlyName,
                "attributes" to attributesToMap(user.attributes),
                "identity" to user.identity,
                "isOnline" to user.isOnline,
                "isNotifiable" to user.isNotifiable,
                "isSubscribed" to user.isSubscribed
        )
    }

    fun userToPigeon(user: User?): Api.UserData? {
        if (user == null) return null
        val result = Api.UserData()

        result.friendlyName = user.friendlyName
        result.attributes = attributesToPigeon(user.attributes)
        result.identity = user.identity
        result.isOnline = user.isOnline
        result.isNotifiable = user.isNotifiable
        result.isSubscribed = user.isSubscribed
        return result
    }

    private fun dateToString(date: Date?): String? {
        if (date == null) return null
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss ZZZ")
        return dateFormat.format(date)
    }

    private fun mapMedia(message: Message): Map<String, Any?>? {
        if (!message.hasMedia()) {
            return null
        }

        return mapOf(
                "sid" to message.mediaSid,
                "fileName" to message.mediaFileName,
                "type" to message.mediaType,
                "size" to message.mediaSize,
                "conversationSid" to message.conversationSid,
                "messageIndex" to message.messageIndex,
                "messageSid" to message.sid
        )
    }

    fun mediaToPigeon(message: Message): Api.MessageMediaData? {
        if (!message.hasMedia()) {
            return null
        }

        val result = Api.MessageMediaData()
        result.sid = message.mediaSid
        result.fileName = message.mediaFileName
        result.type = message.mediaType
        result.size = message.mediaSize
        result.conversationSid = message.conversationSid
        result.messageIndex = message.messageIndex
        result.messageSid = message.sid
        return result
    }

    fun errorInfoToMap(errorInfo: ErrorInfo?): Map<String, Any?>? {
        errorInfo ?: return null

        return mapOf(
                "code" to errorInfo.code,
                "message" to errorInfo.message,
                "status" to errorInfo.status
        )
    }

    fun errorInfoToPigeon(errorInfo: ErrorInfo): Api.ErrorInfoData {
        val errorData = Api.ErrorInfoData()
        errorData.status = errorInfo.status.toLong()
        errorData.message = errorInfo.message
        errorData.code = errorInfo.code.toLong()
        return errorData
    }
}
