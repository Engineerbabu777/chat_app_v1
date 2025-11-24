import 'dart:async';
import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/logic/cubits/chat/chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final String currentUserId;

  bool _isInChat = false;

  StreamSubscription? _messagesSubscription;
  StreamSubscription? _onlineUsersSubscription;
  StreamSubscription? _typingSubscription;

  ChatCubit({
    required ChatRepository chatRepository,
    required this.currentUserId,
  }) : _chatRepository = chatRepository,
       super(const ChatState()); // ✅ works with default messages list

  void enterChat(String receiverId) async {
    emit(state.copyWith(status: ChatStatus.loading));
    _isInChat = true;

    try {
      final chatRoom = await _chatRepository.getOrCreateChatRoom(
        currentUserId,
        receiverId,
      );

      emit(
        state.copyWith(
          status: ChatStatus.loaded,
          receiverId: receiverId,
          chatRoomId: chatRoom.id,
        ),
      );

      _subscribeToMessages(chatRoom.id);
      _subscribeToOnlineUsers(receiverId);
      _subscribeToTypingStatus(chatRoom.id);
    } catch (e) {
      print(e.toString());
      emit(
        state.copyWith(
          error: "Failed to create or init chat $e",
          status: ChatStatus.error,
        ),
      );
    }
  }

  Future<void> sendMessage({
    required String content,
    required String receiverId,
  }) async {
    if (state.chatRoomId == null) return;

    try {
      await _chatRepository.sendMessage(
        state.chatRoomId!,
        currentUserId,
        receiverId,
        content,
      );
    } catch (e) {
      emit(state.copyWith(error: "Failed to send message $e"));
    }
  }

  void _subscribeToMessages(String chatRoomId) {
    print("Helo");
    _messagesSubscription?.cancel();

    _messagesSubscription = _chatRepository
        .getMessages(chatRoomId)
        .listen(
          (messages) {
            if (_isInChat) {
              _markMessagesAsRead(chatRoomId);
            }
            emit(state.copyWith(messages: messages ?? [], error: null));
          },
          onError: (error) {
            emit(
              state.copyWith(
                messages: [],
                error: "Failed to load messages $error",
                status: ChatStatus.error,
              ),
            );
          },
        );
  }

  Future<void> _markMessagesAsRead(String chatRoomId) async {
    try {
      await _chatRepository.markMessagesAsRead(chatRoomId, currentUserId);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> leaveChat() async {
    _isInChat = false;
  }

  void _subscribeToOnlineUsers(String userId) async {
    _onlineUsersSubscription?.cancel();

    _onlineUsersSubscription = _chatRepository
        .getUserOnlineStatus(userId)
        .listen(
          (status) {
            final isOnline = status["isOnline"] as bool;
            final lastSeen = status["lastSeen"] as Timestamp?;

            emit(
              state.copyWith(
                isRecieverOnline: isOnline,
                recieverLastSeen: lastSeen,
              ),
            );
          },
          onError: (error) {
            print("error getting online status!");
          },
        );
  }

  void _subscribeToTypingStatus(String chatRoomId) async {
    _onlineUsersSubscription?.cancel();

    _onlineUsersSubscription = _chatRepository
        .getTypingStatus(chatRoomId)
        .listen(
          (status) {
            final isTyping = status["isTyping"] as bool;
            final typingUserId = status["typingUserId"] as Timestamp?;

            emit(
              state.copyWith(
                isRecieverTyping: isTyping && typingUserId != currentUserId,
              ),
            );
          },
          onError: (error) {
            print("error getting online status!");
          },
        );
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
