import 'package:pigeon/pigeon.dart';

class ConversationClientData {
  String? myIdentity;
  String? connectionState;
  bool? isReachabilityEnabled;
}

class ConversationData {
  String? sid;
  AttributesData? attributes;
  String? uniqueName;
  String? friendlyName;
  String? status;
  String? synchronizationStatus;
  String? dateCreated;
  String? createdBy;
  String? dateUpdated;
  String? lastMessageDate;
  int? lastReadMessageIndex;
  int? lastMessageIndex;
}

class AttributesData {
  String? type;
  String? data;
}

class TokenData {
  String? token;
}

class MessageMediaData {
  String? sid;
  String? fileName;
  String? type;
  int? size;
  String? conversationSid;
  String? messageSid;
  int? messageIndex;
}

class MessageData {
  String? sid;
  int? messageIndex;
  String? author;
  String? subject;
  String? messageBody;
  String? type;
  bool? hasMedia;
  MessageMediaData? media;
  String? conversationSid;
  String? participantSid;
  String? dateCreated;
  String? dateUpdated;
  String? lastUpdatedBy;
  AttributesData? attributes;
}

class MessageOptionsData {
  String? body;
  AttributesData? attributes;
  String? mimeType;
  String? filename;
  String? inputPath;
  int? mediaProgressListenerId;
}

class ParticipantData {
  String? sid;
  String? conversationSid;
  String? type;
  AttributesData? attributes;
  String? dateCreated;
  String? dateUpdated;
  String? identity;
  int? lastReadMessageIndex;
  String? lastReadTimestamp;
}

class UserData {
  String? identity;
  AttributesData? attributes;
  String? friendlyName;
  bool? isNotifiable;
  bool? isOnline;
  bool? isSubscribed;
}

class MessageCount {
  int? count;
}

class MessageIndex {
  int? index;
}

@HostApi()
abstract class PluginApi {
  void debug(bool enableNative, bool enableSdk);

  @async
  ConversationClientData create(String jwtToken);
}

@HostApi()
abstract class ConversationClientApi {
  @async
  void updateToken(String token);

  void shutdown();

  @async
  ConversationData createConversation(String friendlyName);

  @async
  List<ConversationData> getMyConversations();

  @async
  ConversationData getConversation(String conversationSidOrUniqueName);

  @async
  void registerForNotification(TokenData tokenData);

  @async
  void unregisterForNotification(TokenData tokenData);
}

@HostApi()
abstract class ConversationApi {
  @async
  bool join(String conversationSid);

  @async
  bool leave(String conversationSid);

  @async
  void destroy(String conversationSid);

  @async
  void typing(String conversationSid);

  @async
  MessageData sendMessage(String conversationSid, MessageOptionsData options);

  @async
  bool addParticipantByIdentity(String conversationSid, String identity);

  @async
  bool removeParticipantByIdentity(String conversationSid, String identity);

  @async
  List<ParticipantData> getParticipantsList(String conversationSid);

  @async
  MessageCount getMessagesCount(String conversationSid);

  @async
  MessageCount getUnreadMessagesCount(String conversationSid);

  @async
  MessageIndex setLastReadMessageIndex(
      String conversationSid, int lastReadMessageIndex);

  @async
  MessageIndex setAllMessagesRead(String conversationSid);

  @async
  List<MessageData> getMessagesBefore(
      String conversationSid, int index, int count);

  @async
  List<MessageData> getLastMessages(String conversationSid, int count);

  @async
  String setFriendlyName(String conversationSid, String friendlyName);
}

@HostApi()
abstract class ParticipantApi {
  @async
  UserData getUser(String conversationSid, String participantSid);
}

@HostApi()
abstract class MessageApi {
  @async
  String getMediaContentTemporaryUrl(String conversationSid, int messageIndex);
}
