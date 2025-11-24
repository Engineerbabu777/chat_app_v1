import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/logic/cubits/chat/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final String currentUserId;

  ChatCubit({
    required ChatRepository chatRepository,
    required this.currentUserId,
  }) : _chatRepository = chatRepository,
       super(const ChatState());

  void enterChat(String receiverId) async {
    emit(state.copyWith(status: ChatStatus.loading));

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
    } catch (e) {
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
    print(state.chatRoomId!);

    if (state.chatRoomId == null) return;

    try {
      await _chatRepository.sendMessage(
        state.chatRoomId!,
        currentUserId,
        receiverId,
        content,
      );
    } catch (e) {
      print(e.toString());

      emit(state.copyWith(error: "Failed to send message $e"));
    }
  }
}
