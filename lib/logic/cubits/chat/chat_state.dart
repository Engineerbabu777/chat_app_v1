import 'package:chat_app/data/models/chat_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final String? error;
  final String? receiverId;
  final String? chatRoomId;
  final List<ChatMessageModel> messages;

  final bool isRecieverOnline;
  final bool isRecieverTyping;
  final Timestamp? recieverLastSeen;

  final bool hasMoreMessages;
  final bool isLoadingMore;
  final bool isUserBlocked;
  final bool amIBlocked;

  const ChatState(
    this.isUserBlocked,
    this.recieverLastSeen,
    this.amIBlocked, {
    this.messages = const [],
    this.status = ChatStatus.initial,
    this.error,
    this.receiverId,
    this.chatRoomId,
    this.isRecieverOnline = false,
    this.isRecieverTyping = false,
    this.hasMoreMessages = true,
    this.isLoadingMore = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    String? error,
    String? receiverId,
    String? chatRoomId,
    List<ChatMessageModel>? messages,
    bool? isRecieverOnline,
    bool? isRecieverTyping,
    Timestamp? recieverLastSeen,
    bool? hasMoreMessages,
    bool? isLoadingMore,
    bool? isUserBlocked,
    bool? amIBlocked,
  }) {
    return ChatState(
      isUserBlocked ?? this.isUserBlocked,
      recieverLastSeen ?? this.recieverLastSeen,
      amIBlocked ?? this.amIBlocked,
      status: status ?? this.status,
      error: error ?? this.error,
      receiverId: receiverId ?? this.receiverId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      messages: messages ?? this.messages,
      isRecieverOnline: isRecieverOnline ?? this.isRecieverOnline,
      isRecieverTyping: isRecieverTyping ?? this.isRecieverTyping,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    error,
    receiverId,
    chatRoomId,
    messages,
    isRecieverOnline,
    isRecieverTyping,
    recieverLastSeen,
    hasMoreMessages,
    isLoadingMore,
    isUserBlocked,
    amIBlocked,
  ];
}
