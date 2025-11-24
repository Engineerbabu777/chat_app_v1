import 'package:chat_app/data/models/chat_message_model.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final String? error;
  final String? receiverId;
  final String? chatRoomId;
  final List<ChatMessageModel> messages;

  const ChatState({
    this.messages = const [], // ✅ default empty list
    this.status = ChatStatus.initial,
    this.error,
    this.receiverId,
    this.chatRoomId,
  });

  ChatState copyWith({
    ChatStatus? status,
    String? error,
    String? receiverId,
    String? chatRoomId,
    List<ChatMessageModel>? messages,
  }) {
    return ChatState(
      messages: messages ?? this.messages, // ✅ never null
      status: status ?? this.status,
      error: error ?? this.error,
      receiverId: receiverId ?? this.receiverId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
    );
  }

  @override
  List<Object?> get props => [status, error, receiverId, chatRoomId, messages];
}
