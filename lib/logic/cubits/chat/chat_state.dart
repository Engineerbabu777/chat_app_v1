import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final String? error;
  final String? receiverId;
  final String? chatRoomId;

  const ChatState({
    this.status = ChatStatus.initial,
    this.error,
    this.receiverId,
    this.chatRoomId,
  });

  ChatState copyWith({
    ChatStatus? status,
    ValueGetter<String?>? error,
    String? receiverId,
    String? chatRoomId,
  }) {
    return ChatState(
      status: status ?? this.status,
      error: error != null ? error() : this.error,
      receiverId: receiverId ?? this.receiverId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
    );
  }

  @override
  List<Object?> get props => [status, error, receiverId];
}
