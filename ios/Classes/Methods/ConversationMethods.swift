// swiftlint:disable file_length type_body_length
import Flutter
import TwilioConversationsClient

class ConversationMethods: NSObject, TWCONConversationApi {
    let TAG = "ConversationMethods"

    // swiftlint:disable function_body_length
    func joinConversationSid(_ conversationSid: String?, completion: @escaping (NSNumber?, FlutterError?) -> Void) {
        debug("join => conversationSid: \(String(describing: conversationSid))")
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.join { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("join => onSuccess")
                        completion(true, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("join => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "Error joining conversation with sid \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("join => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "Error joining conversation with sid \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    func leaveConversationSid(_ conversationSid: String?, completion: @escaping (NSNumber?, FlutterError?) -> Void) {
        debug("leave => conversationSid: \(String(describing: conversationSid))")
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.leave { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("leave => onSuccess")
                        completion(true, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("leave => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "Error leaving conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("leave => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "Error leaving conversation with sid \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    func destroyConversationSid(_ conversationSid: String?, completion: @escaping (FlutterError?) -> Void) {
        debug("destroy => conversationSid: \(String(describing: conversationSid))")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(FlutterError(code: "ERROR", message: "Client has not been initialized.", details: nil))
        }

        guard let conversationSid = conversationSid else {
            return completion(
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.destroy(completion: { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("destroy => onSuccess")
                        completion(nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("destroy => onError: \(errorMessage)")
                        completion(
                            FlutterError(
                                code: "ERROR",
                                message: "Error destroying conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                })
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("destroy => onError: \(errorMessage)")
                completion(
                    FlutterError(
                        code: "ERROR",
                        message: "Error destroying conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    func typingConversationSid(_ conversationSid: String?, completion: @escaping (FlutterError?) -> Void) {
        debug("typing => conversationSid: \(String(describing: conversationSid))")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(FlutterError(code: "ERROR", message: "Client has not been initialized.", details: nil))
        }

        guard let conversationSid = conversationSid else {
            return completion(
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("typing => onSuccess")
                conversation.typing()
                completion(nil)
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("typing => onError: \(errorMessage)")
                completion(
                    FlutterError(
                        code: "ERROR",
                        message: "Error sending typing to conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    func sendMessageConversationSid(
        _ conversationSid: String?,
        options: TWCONMessageOptionsData?,
        completion: @escaping (TWCONMessageData?, FlutterError?) -> Void) {
        debug("sendMessage => conversationSid: \(String(describing: conversationSid))")
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let options = options else {
            return completion(
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'options' parameter",
                    details: nil))
        }

        let messageOptions = TCHMessageOptions()

        if let messageBody = options.body {
            messageOptions.withBody(messageBody)
        }
        if let input = options.inputPath {
            guard let mimeType = options.mimeType else {
                return completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "Missing 'mimeType' in MessageOptions",
                        details: nil))
            }

            if let inputStream = InputStream(fileAtPath: input) {
                messageOptions.withMediaStream(inputStream, contentType: mimeType, defaultFilename: options.filename,
                                               onStarted: nil,
                                               onProgress: nil,
                                               onCompleted: nil)
//                                               ,
//                                               onStarted: {
//                    // implement media stream progress listener
//
//                },
//                                               onProgress: { (bytes: UInt) in
//                    // implement media stream progress listener
//
//                },
//                                               onCompleted: { (mediaSid: String) in
//                    // implement media stream progress listener
//
//                }
//                )
            } else {
                return completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "Error retrieving file for upload from `\(input)`",
                        details: nil))
            }
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.sendMessage(
                    with: messageOptions,
                    completion: { (result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful,
                       let message = message {
                        self.debug("sendMessage => onSuccess")
                        completion(Mapper.messageToPigeon(message, conversationSid: conversationSid), nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("sendMessage => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "Error sending message in conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                })
            }
        })
    }

    func addParticipant(
        byIdentityConversationSid conversationSid: String?,
        identity: String?, completion: @escaping (NSNumber?, FlutterError?) -> Void) {
        debug("addParticipantByIdentity => conversationSid: \(String(describing: conversationSid))")
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let identity = identity else {
            return completion(
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'identity' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.addParticipant(byIdentity: identity,
                                            attributes: nil) { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("addParticipantByIdentity => onSuccess")
                        completion(true, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("addParticipantByIdentity => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "Error adding participant to conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                self.debug("addParticipantByIdentity => onError: \(String(describing: result.error))")
                completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "Error retrieving conversation with sid '\(conversationSid)'",
                        details: nil))
            }
        })
    }

    // removeParticipant
    func removeParticipantConversationSid(_ conversationSid: String?, participantSid: String?, completion: @escaping (NSNumber?, FlutterError?) -> Void) {
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let participantSid = participantSid else {
            return completion(
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'sid' parameter",
                    details: nil))
        }

        debug("removeParticipant => conversationSid: \(conversationSid) participantSid: \(participantSid)")
        
        client.conversation(withSidOrUniqueName: conversationSid) { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                guard let participant = conversation.participant(withSid: participantSid) else {
                    return completion(
                        nil,
                        FlutterError(
                            code: "ERROR",
                            message: "Error retrieving participant \(participantSid)",
                            details: nil))
                }
                conversation.removeParticipant(participant) { (result: TCHResult) in
                    if result.isSuccessful {
                        return completion(true, nil)
                    } else {
                        return completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "Error removing participant \(participantSid)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("removeParticipant => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "Error retrieving conversation \(conversationSid)",
                        details: nil))
            }
        }
    }
    
    // removeParticipantByIdentity
    func removeParticipant(
        byIdentityConversationSid conversationSid: String?,
        identity: String?, completion: @escaping (NSNumber?, FlutterError?) -> Void) {
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let identity = identity else {
            return completion(
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'identity' parameter",
                    details: nil))
        }

        debug("removeParticipantByIdentity => conversationSid: \(conversationSid) identity: \(identity)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.removeParticipant(byIdentity: identity) { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("removeParticipantByIdentity => onSuccess")
                        completion(true, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("removeParticipantByIdentity => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "Error removing participant from "
                                    + "conversation \(conversationSid): Error: \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("removeParticipantByIdentity => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "Error retrieving conversation \(conversationSid)",
                        details: nil))
            }
        })
    }

    func getParticipantsListConversationSid(
        _ conversationSid: String?,
        completion: @escaping ([TWCONParticipantData]?, FlutterError?) -> Void) {
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        debug("getParticipantsList => conversationSid: \(conversationSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("getParticipantsList => onSuccess")
                let participantsList = conversation.participants().compactMap {
                    Mapper.participantToPigeon($0, conversationSid: conversationSid)
                }
                completion(participantsList, nil)
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("getParticipantsList => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "Error getting conversation \(conversationSid)",
                        details: nil))
            }
        })
    }

    func getMessagesCountConversationSid(
        _ conversationSid: String?,
        completion: @escaping (TWCONMessageCount?, FlutterError?) -> Void) {
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        debug("getMessagesCount => conversationSid: \(conversationSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getMessagesCount(completion: { (result: TCHResult, count: UInt) in
                    if result.isSuccessful {
                        self.debug("getMessagesCount => onSuccess")
                        let result = TWCONMessageCount()
                        result.count = NSNumber(value: count)
                        completion(result, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("getMessagesCount => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "getMessagesCount => Error getting message count "
                                    + "for conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                })
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("getMessagesCount => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "getMessagesCount => Error getting conversation "
                            + "\(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    func getUnreadMessagesCountConversationSid(
        _ conversationSid: String?,
        completion: @escaping (TWCONMessageCount?, FlutterError?) -> Void) {
        debug("getUnreadMessagesCount => conversationSid: \(String(describing: conversationSid))")
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getUnreadMessagesCount { (result: TCHResult, count: NSNumber?) in
                    if result.isSuccessful {
                        self.debug("getUnreadMessagesCount => onSuccess: \(String(describing: count))")
                        let result = TWCONMessageCount()
                        result.count = count
                        completion(result, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("getUnreadMessagesCount => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "Error retrieving unread messages count "
                                    + "for conversation \(conversationSid): Error: \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("getUnreadMessagesCount => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "Error retrieving conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    func setLastReadMessageIndexConversationSid(
        _ conversationSid: String?,
        lastReadMessageIndex: NSNumber?,
        completion: @escaping (TWCONMessageIndex?, FlutterError?) -> Void) {
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let lastReadMessageIndex = lastReadMessageIndex else {
            return completion(
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'lastReadMessageIndex' parameter",
                    details: nil))
        }

        debug("setLastReadMessageIndex => conversationSid: \(conversationSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.setLastReadMessageIndex(
                    lastReadMessageIndex,
                    completion: { (result: TCHResult, count: UInt) in
                    if result.isSuccessful {
                        self.debug("setLastReadMessageIndex => onSuccess")
                        let result = TWCONMessageIndex()
                        result.index = NSNumber(value: count)
                        completion(result, nil)
                    } else {
                        self.debug("setLastReadMessageIndex => onError: \(result.error.debugDescription))")
                        completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "Error setting last consumed message index \(lastReadMessageIndex) "
                                    + "for conversation \(conversationSid)",
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

    func setAllMessagesReadConversationSid(
        _ conversationSid: String?,
        completion: @escaping (TWCONMessageIndex?, FlutterError?) -> Void) {
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        debug("setAllMessagesRead => conversationSid: \(conversationSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.setAllMessagesReadWithCompletion({ (result: TCHResult, count: UInt) in
                    if result.isSuccessful {
                        self.debug("setAllMessagesRead => onSuccess")
                        let result = TWCONMessageIndex()
                        result.index = NSNumber(value: count)
                        completion(result, nil)
                    } else {
                        self.debug("setAllMessagesRead => onError: \(String(describing: result.error))")
                        completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "Error setting all messages read for conversation \(conversationSid)",
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

    func getMessagesBeforeConversationSid(
        _ conversationSid: String?,
        index: NSNumber?,
        count: NSNumber?,
        completion: @escaping ([TWCONMessageData]?, FlutterError?) -> Void) {
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let index = index else {
            return completion(
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'index' parameter",
                    details: nil))
        }

        guard let count = count else {
            return completion(
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'count' parameter",
                    details: nil))
        }

        debug("getMessagesBefore => conversationSid: \(conversationSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getMessagesBefore(
                    index.uintValue,
                    withCount: count.uintValue,
                    completion: { (result: TCHResult, messages: [TCHMessage]?) in
                    if result.isSuccessful, let messages = messages {
                        self.debug("getMessagesBefore => onSuccess")
                        let messagesMap = messages.map { message in
                            Mapper.messageToPigeon(message, conversationSid: conversationSid)
                        }
                        completion(messagesMap, nil)
                    } else {
                        self.debug("getMessagesBefore => onError: \(String(describing: result.error))")
                        completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "Error retrieving \(count) messages before "
                                    + "message index: \(index) from conversation \(conversationSid)",
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

    func getLastMessagesConversationSid(
        _ conversationSid: String?,
        count: NSNumber?,
        completion: @escaping ([TWCONMessageData]?, FlutterError?) -> Void) {
        debug("getLastMessages => conversationSid: \(String(describing: conversationSid))")
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let count = count else {
            return completion(
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'count' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getLastMessages(
                    withCount: count.uintValue,
                    completion: { (result: TCHResult, messages: [TCHMessage]?) in
                    if result.isSuccessful, let messages = messages {
                        self.debug("getLastMessages => onSuccess")
                        let messagesMap = messages.map { message in
                            Mapper.messageToPigeon(message, conversationSid: conversationSid)
                        }
                        completion(messagesMap, nil)
                    } else {
                        self.debug("getLastMessages => onError: \(String(describing: result.error))")
                        completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "Error retrieving last \(count) messages for conversation \(conversationSid)",
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

    func setFriendlyNameConversationSid(
        _ conversationSid: String?,
        friendlyName: String?,
        completion: @escaping (String?, FlutterError?) -> Void) {
        debug("setFriendlyName => conversationSid: \(String(describing: conversationSid))")
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
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let friendlyName = friendlyName else {
            return completion(
                nil,
                FlutterError(
                    code: "MISSING_PARAMS",
                    message: "Missing 'friendlyName' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("setFriendlyName => onSuccess")
                conversation.setFriendlyName(friendlyName) { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("setFriendlyName => onSuccess")
                        completion(conversation.friendlyName, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("setFriendlyName => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "ERROR",
                                message: "setFriendlyName => Error setting friendly name "
                                    + "for conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("setFriendlyName => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "ERROR",
                        message: "setFriendlyName => Error retrieving conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    private func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}
