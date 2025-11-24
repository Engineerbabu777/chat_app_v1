import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final Timestamp? lastMessageTime;
  final Timestamp? lastRead;
  final Map<String, Timestamp> lastReadTime;
  final Map<String, String> participantsName;
  final bool isTyping;
  final String? isTypingUserId;
  final bool isCallActive;

  ChatRoomModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageTime,
    this.lastRead,
    Map<String, Timestamp>? lastReadTime,
    Map<String, String>? participantsName,
    this.isTyping = false,
    this.isTypingUserId,
    this.isCallActive = false,
  }) : lastReadTime = lastReadTime ?? {},
       participantsName = participantsName ?? {};

  ChatRoomModel copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    String? lastMessageSenderId,
    Timestamp? lastMessageTime,
    Timestamp? lastRead,
    Map<String, Timestamp>? lastReadTime,
    Map<String, String>? participantsName,
    bool? isTyping,
    String? isTypingUserId,
    bool? isCallActive,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastRead: lastRead ?? this.lastRead,
      lastReadTime: lastReadTime ?? this.lastReadTime,
      participantsName: participantsName ?? this.participantsName,
      isTyping: isTyping ?? this.isTyping,
      isTypingUserId: isTypingUserId ?? this.isTypingUserId,
      isCallActive: isCallActive ?? this.isCallActive,
    );
  }

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ChatRoomModel(
      id: data["id"] as String? ?? doc.id,
      participants:
          (data["participants"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lastMessage: data["lastMessage"] as String?,
      lastMessageSenderId: data["lastMessageSenderId"] as String?,
      lastMessageTime: data["lastMessageTime"] is Timestamp
          ? data["lastMessageTime"] as Timestamp
          : null,
      lastRead: data["lastRead"] is Timestamp
          ? data["lastRead"] as Timestamp
          : null,
      lastReadTime:
          (data["lastReadTime"] as Map<String, dynamic>?)?.map(
            (key, value) =>
                MapEntry(key, value is Timestamp ? value : Timestamp.now()),
          ) ??
          {},
      participantsName:
          (data["participantsName"] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toString()),
          ) ??
          {},
      isTyping: data["isTyping"] as bool? ?? false,
      isTypingUserId: data["isTypingUserId"] as String?,
      isCallActive: data["isCallActive"] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "participants": participants,
      "lastMessage": lastMessage,
      "lastMessageSenderId": lastMessageSenderId,
      "lastMessageTime": lastMessageTime,
      "lastRead": lastRead,
      "lastReadTime": lastReadTime.map(
        (key, value) => MapEntry(key, value),
      ), // Timestamp stays Timestamp
      "participantsName": participantsName,
      "isTyping": isTyping,
      "isTypingUserId": isTypingUserId,
      "isCallActive": isCallActive,
    };
  }
}
