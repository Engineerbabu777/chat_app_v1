import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, video }

enum MessageStatus { sent, read }

class ChatMessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final Timestamp timestamp;
  final List<String> readBy;

  ChatMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.timestamp,
    required this.readBy,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessageModel(
      id: doc.id,
      chatRoomId: data["chatRoomId"] ?? "",
      senderId: data["senderId"] ?? "",
      receiverId: data["receiverId"] ?? "",
      content: data["content"] ?? "",
      type: MessageType.values[data["type"] ?? 0],
      status: MessageStatus.values[data["status"] ?? 0],
      timestamp: data["timestamp"] ?? Timestamp.now(),
      readBy: List<String>.from(data["readBy"] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "chatRoomId": chatRoomId,
      "senderId": senderId,
      "receiverId": receiverId,
      "content": content,
      "type": type.index, // store enum as int
      "status": status.index, // store enum as int
      "timestamp": timestamp,
      "readBy": readBy,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    Timestamp? timestamp,
    List<String>? readBy,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
    );
  }
}
