import com.twilio.conversations.Attributes
import com.twilio.conversations.CallbackListener
import com.twilio.conversations.Conversation
import com.twilio.conversations.ErrorInfo
import com.twilio.conversations.Message
import com.twilio.conversations.StatusListener
import java.io.FileInputStream
import twilio.flutter.twilio_conversations.Api
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin

class ConversationMethods : Api.ConversationApi {
    private val TAG = "ConversationMethods"

    override fun join(conversationSid: String, result: Api.Result<Boolean>) {
        debug("join => conversationSid: $conversationSid")
        try {
            TwilioConversationsPlugin.client?.getConversation(conversationSid, object :
                CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.join(object : StatusListener {
                        override fun onSuccess() {
                            debug("join => onSuccess")
                            result.success(true)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("join => onError: $errorInfo")
                            result.error(RuntimeException(errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("join => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(err)
        }
    }

    override fun leave(conversationSid: String, result: Api.Result<Boolean>) {
        debug("leave => conversationSid: $conversationSid")
        try {
            TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.leave(object : StatusListener {
                        override fun onSuccess() {
                            debug("leave => onSuccess")
                            result.success(true)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("leave => onError: $errorInfo")
                            result.error(RuntimeException(errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("leave => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(err)
        }
    }

    override fun destroy(conversationSid: String, result: Api.Result<Void>) {
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.destroy(object : StatusListener {
                        override fun onSuccess() {
                            debug("destroy => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("destroy => onError: $errorInfo")
                            result.error(RuntimeException(errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("destroy => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(err)
        }
    }

    override fun typing(conversationSid: String, result: Api.Result<Void>) {
        debug("typing => conversationSid: $conversationSid")
        try {
            TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    debug("typing => onSuccess")
                    conversation.typing()
                    result.success(null)
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("typing => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(err)
        }
    }

    override fun sendMessage(
        conversationSid: String,
        options: Api.MessageOptionsData,
        result: Api.Result<Api.MessageData>
    ) {
        debug("sendMessage => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        val messageOptions = Message.options()
        if (options.body != null) {
            messageOptions.withBody(options.body as String)
        }

        if (options.attributes != null) {
            messageOptions.withAttributes(
                Mapper.pigeonToAttributes(options.attributes))
        }

        if (options.inputPath != null) {
            val input = options.inputPath as String
            val mimeType = options.mimeType as String?
                ?: return result.error(Exception("Missing 'mimeType' in MessageOptions"))

            messageOptions.withMedia(FileInputStream(input), mimeType)
            if (options.filename != null) {
                messageOptions.withMediaFileName(options.filename as String)
            }

            // TODO: implement MediaProgressListener
//            if (options.mediaProgressListenerId != null) {
//                messageOptions.withMediaProgressListener(object : ProgressListener() {
//                    override fun onStarted() {
//                        TwilioConversationsPlugin.mediaProgressSink?.success({
//                            "mediaProgressListenerId" to options["mediaProgressListenerId"]
//                            "name" to "started"
//                        })
//                    }
//
//                    override fun onProgress(bytes: Long) {
//                        TwilioConversationsPlugin.mediaProgressSink?.success({
//                            "mediaProgressListenerId" to options["mediaProgressListenerId"]
//                            "name" to "progress"
//                            "data" to bytes
//                        })
//                    }
//
//                    override fun onCompleted(mediaSid: String) {
//                        TwilioConversationsPlugin.mediaProgressSink?.success({
//                            "mediaProgressListenerId" to options["mediaProgressListenerId"]
//                            "name" to "completed"
//                            "data" to mediaSid
//                        })
//                    }
//                })
//            }
        }

        try {
            client.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.sendMessage(messageOptions, object : CallbackListener<Message> {
                        override fun onSuccess(message: Message?) {
                            debug("sendMessage => onSuccess")
                            if (message != null) {
                                val messageData = Mapper.messageToPigeon(message)
                                result.success(messageData)
                            } else {
                                // TODO: error if message is null?
                                result.success(null)
                            }
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("sendMessage => onError: $errorInfo")
                            result.error(RuntimeException(errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("sendMessage => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(err)
        }
    }

    override fun addParticipantByIdentity(
        conversationSid: String,
        identity: String,
        result: Api.Result<Boolean>
    ) {
        debug("addParticipantByIdentity => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.addParticipantByIdentity(identity, Attributes(), object : StatusListener {
                        override fun onSuccess() {
                            debug("addParticipantByIdentity => onSuccess")
                            result.success(true)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("addParticipantByIdentity => onError: $errorInfo")
                            result.error(RuntimeException(errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("addParticipantByIdentity => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(err)
        }
    }

    override fun removeParticipant(
        conversationSid: String,
        participantSid: String,
        result: Api.Result<Boolean>
    ) {
        debug("removeParticipant => conversationSid: $conversationSid participantSid: $participantSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    val participant = conversation.getParticipantBySid(participantSid)
                        ?: return result.error(RuntimeException("Participant $participantSid not found."))

                    conversation.removeParticipant(participant, object : StatusListener {
                        override fun onSuccess() {
                            debug("removeParticipant => onSuccess")
                            result.success(true)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("removeParticipant => onError: $errorInfo")
                            result.error(RuntimeException(errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("removeParticipant => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(err)
        }
    }

    override fun removeParticipantByIdentity(
        conversationSid: String,
        identity: String,
        result: Api.Result<Boolean>
    ) {
        debug("removeParticipantByIdentity => conversationSid: $conversationSid identity: $identity")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.removeParticipantByIdentity(identity, object : StatusListener {
                        override fun onSuccess() {
                            debug("removeParticipantByIdentity => onSuccess")
                            result.success(true)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("removeParticipantByIdentity => onError: $errorInfo")
                            result.error(RuntimeException(errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("removeParticipantByIdentity => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(err)
        }
    }

    override fun getParticipantByIdentity(
        conversationSid: String,
        identity: String,
        result: Api.Result<Api.ParticipantData>
    ) {
        debug("getParticipantByIdentity => conversationSid: $conversationSid identity: $identity")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                val participant = conversation.getParticipantByIdentity(identity)
                    ?: return result.error(RuntimeException("No participant found with identity $identity"))
                debug("getParticipantByIdentity => onSuccess")
                val participantData = Mapper.participantToPigeon(participant)
                result.success(participantData)
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("getParticipantByIdentity => onError: $errorInfo")
                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    override fun getParticipantBySid(
        conversationSid: String,
        participantSid: String,
        result: Api.Result<Api.ParticipantData>
    ) {
        debug("getParticipantBySid => conversationSid: $conversationSid participantSid: $participantSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                val participant = conversation.getParticipantBySid(participantSid)
                    ?: return result.error(RuntimeException("No participant found with sid $participantSid"))
                debug("getParticipantBySid => onSuccess")
                val participantData = Mapper.participantToPigeon(participant)
                result.success(participantData)
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("getParticipantBySid => onError: $errorInfo")
                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    override fun getParticipantsList(
        conversationSid: String,
        result: Api.Result<MutableList<Api.ParticipantData>>
    ) {
        debug("getParticipantsList => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                debug("getParticipantsList => onSuccess")
                val participantsListData = Mapper.participantListToPigeon(conversation.participantsList)
                result.success(participantsListData.toMutableList())
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("getParticipantsList => onError: $errorInfo")
                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    override fun getMessagesCount(conversationSid: String, result: Api.Result<Api.MessageCount>) {
        debug("getMessagesCount => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    debug("getMessagesCount => onSuccess")
                    conversation.getMessagesCount(object : CallbackListener<Long> {
                        override fun onSuccess(messageCount: Long) {
                            debug("getMessagesCount => onSuccess: $messageCount")
                            val count = Api.MessageCount()
                            count.count = messageCount
                            result.success(count)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("getMessagesCount => onError: $errorInfo")
                            result.error(RuntimeException(errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getMessagesCount => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(err)
        }
    }

    override fun getUnreadMessagesCount(conversationSid: String, result: Api.Result<Api.MessageCount>) {
        debug("getUnreadMessagesCount => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.getUnreadMessagesCount(object : CallbackListener<Long?> {
                        override fun onSuccess(count: Long?) {
                            debug("getUnreadMessagesCount => onSuccess: $count")
                            val unreadMessages = Api.MessageCount()
                            unreadMessages.count = count
                            result.success(unreadMessages)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("getUnreadMessagesCount => onError: $errorInfo")
                            result.error(RuntimeException(errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getUnreadMessagesCount => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(err)
        }
    }

    override fun advanceLastReadMessageIndex(
        conversationSid: String,
        lastReadMessageIndex: Long,
        result: Api.Result<Api.MessageCount>
    ) {
        debug("advanceLastReadMessageIndex => conversationSid: $conversationSid index: $lastReadMessageIndex")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.advanceLastReadMessageIndex(lastReadMessageIndex, object : CallbackListener<Long> {
                    override fun onSuccess(count: Long) {
                        debug("advanceLastReadMessageIndex => onSuccess")
                        val unreadMessages = Api.MessageCount()
                        unreadMessages.count = count
                        result.success(unreadMessages)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("advanceLastReadMessageIndex => onError: $errorInfo")
                        result.error(RuntimeException(errorInfo.message))
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("advanceLastReadMessageIndex => onError: $errorInfo")
                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    override fun setLastReadMessageIndex(
        conversationSid: String,
        lastReadMessageIndex: Long,
        result: Api.Result<Api.MessageCount>
    ) {
        debug("setLastReadMessageIndex => conversationSid: $conversationSid index: $lastReadMessageIndex")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.setLastReadMessageIndex(lastReadMessageIndex, object : CallbackListener<Long> {
                    override fun onSuccess(count: Long) {
                        debug("setLastReadMessageIndex => onSuccess")
                        val unreadMessages = Api.MessageCount()
                        unreadMessages.count = count
                        result.success(unreadMessages)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("setLastReadMessageIndex => onError: $errorInfo")
                        result.error(RuntimeException(errorInfo.message))
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("setLastReadMessageIndex => onError: $errorInfo")
                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    override fun setAllMessagesRead(
        conversationSid: String,
        result: Api.Result<Api.MessageCount>
    ) {
        debug("setAllMessagesRead => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.setAllMessagesRead(object : CallbackListener<Long> {
                    override fun onSuccess(count: Long) {
                        debug("setAllMessagesRead => onSuccess")
                        val unreadMessages = Api.MessageCount()
                        unreadMessages.count = count
                        result.success(unreadMessages)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("setAllMessagesRead => onError: $errorInfo")
                        result.error(RuntimeException(errorInfo.message))
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("setAllMessagesRead => onError: $errorInfo")
                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    override fun setAllMessagesUnread(
        conversationSid: String,
        result: Api.Result<Api.MessageCount>
    ) {
        debug("setAllMessagesUnread => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.setAllMessagesUnread(object : CallbackListener<Long> {
                    override fun onSuccess(count: Long?) {
                        debug("setAllMessagesUnread => onSuccess: $count")
                        val unreadMessages = Api.MessageCount()
                        unreadMessages.count = count
                        result.success(unreadMessages)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("setAllMessagesUnread => onError: $errorInfo")
                        result.error(RuntimeException(errorInfo.message))
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("setAllMessagesUnread => onError: $errorInfo")
                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    override fun removeMessage(
        conversationSid: String,
        messageIndex: Long,
        result: Api.Result<Boolean>
    ) {
        debug("removeMessage => conversationSid: $conversationSid messageSid: $messageIndex")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.getMessageByIndex(messageIndex, object : CallbackListener<Message> {
                    override fun onSuccess(message: Message) {
                        conversation.removeMessage(message, object: StatusListener {
                            override fun onSuccess() {
                                debug("removeMessage => onSuccess")
                                result.success(true)
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                debug("removeMessage => onError: $errorInfo")
                                result.error(RuntimeException(errorInfo.message))
                            }
                        })
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("removeMessage => onError: $errorInfo")
                        result.error(RuntimeException(errorInfo.message))
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("removeMessage => onError: $errorInfo")
                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    override fun getMessagesAfter(
        conversationSid: String,
        index: Long,
        count: Long,
        result: Api.Result<MutableList<Api.MessageData>>
    ) {
        debug("getMessagesAfter => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.getMessagesAfter(index, count.toInt(), object : CallbackListener<List<Message>> {
                    override fun onSuccess(messages: List<Message>) {
                        debug("getMessagesAfter => onSuccess")
                        val messagesMap = messages.map { Mapper.messageToPigeon(it) }
                        result.success(messagesMap.toMutableList())
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("getMessagesAfter => onError: $errorInfo")
                        result.error(RuntimeException(errorInfo.message))
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("getMessagesAfter => onError: $errorInfo")

                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    override fun getMessagesBefore(
        conversationSid: String,
        index: Long,
        count: Long,
        result: Api.Result<MutableList<Api.MessageData>>
    ) {
        debug("getMessagesBefore => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.getMessagesBefore(index, count.toInt(), object : CallbackListener<List<Message>> {
                    override fun onSuccess(messages: List<Message>) {
                        debug("getMessagesBefore => onSuccess")
                        val messagesMap = messages.map { Mapper.messageToPigeon(it) }
                        result.success(messagesMap.toMutableList())
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("getMessagesBefore => onError: $errorInfo")
                        result.error(RuntimeException(errorInfo.message))
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("getMessagesBefore => onError: $errorInfo")

                result.error(RuntimeException(errorInfo.message))
            }
        })
    }

    override fun getLastMessages(
        conversationSid: String,
        count: Long,
        result: Api.Result<MutableList<Api.MessageData>>
    ) {
        debug("getLastMessages => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation?) {
                    conversation?.getLastMessages(count.toInt(), object : CallbackListener<List<Message>> {
                        override fun
                                onSuccess(messages: List<Message>) {
                            debug("getLastMessages => onSuccess")

                            val messagesMap = messages.map { Mapper.messageToPigeon(it) }
                            result.success(messagesMap.toMutableList())
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("getLastMessages => onError: $errorInfo")
                            result.error(RuntimeException(errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getLastMessages => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(err)
        } catch (err: IllegalStateException) {
            return result.error(err)
        }
    }

    override fun setFriendlyName(
        conversationSid: String,
        friendlyName: String,
        result: Api.Result<String>
    ) {
        debug("setFriendlyName => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(RuntimeException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.setFriendlyName(friendlyName, object : StatusListener {
                        override fun onSuccess() {
                            debug("setFriendlyName => onSuccess")
                            result.success(conversation.friendlyName)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("setFriendlyName => onError: $errorInfo")
                            result.error(RuntimeException(errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("setFriendlyName => onError: $errorInfo")
                    result.error(RuntimeException(errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(err)
        }
    }

    fun debug(message: String) {
        TwilioConversationsPlugin.debug("$TAG::$message")
    }
}
