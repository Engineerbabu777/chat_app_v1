import 'package:chat_app/data/models/chat_message_model.dart';
import 'package:chat_app/data/models/chat_room_model.dart';
import 'package:chat_app/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository extends BaseRepository {
  CollectionReference get _chatRooms => firestore.collection("chatRooms");

  CollectionReference getChatRoomMessagesCollection(String chatRoomId) {
    return _chatRooms.doc(chatRoomId).collection("messages");
  }

  Future<ChatRoomModel> getOrCreateChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    final users = [currentUserId, otherUserId]..sort();

    final roomId = users.join("_");

    final roomDoc = await _chatRooms.doc(roomId).get();

    if (roomDoc.exists) {
      return ChatRoomModel.fromFirestore(roomDoc);
    }

    final currentUserData =
        (await firestore.collection("users").doc(currentUserId).get()).data();

    final otherUserData =
        (await firestore.collection("users").doc(otherUserId).get()).data();

    final participantsName = <String, String>{
      currentUserId: currentUserData?["fullName"]?.toString() ?? "",
      otherUserId: otherUserData?["fullName"]?.toString() ?? "",
    };

    final newRoom = ChatRoomModel(
      id: roomId,
      participants: users,
      participantsName: participantsName,
      lastReadTime: {
        currentUserId: Timestamp.now(),
        otherUserId: Timestamp.now(),
      },
    );

    await _chatRooms.doc(roomId).set(newRoom.toMap());
    return newRoom;
  }

  Future<void> sendMessage(
    String chatRoomId,
    String senderId,
    String receiverId,
    String content, {
    MessageType type = MessageType.text,
  }) async {
    // batch!
    final batch = firestore.batch();

    // get message sub collection!
    final messageRef = getChatRoomMessagesCollection(chatRoomId);
    final messageDoc = messageRef.doc();

    // message!
    final message = ChatMessageModel(
      id: messageRef.id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: Timestamp.now(),
      readBy: [senderId],
    );

    // message to sub collection!
    batch.set(messageDoc, message);

    // update chat room!
    batch.update(_chatRooms.doc(chatRoomId), {
      "lastMessage": content,
      "lastMessageTime": message.timestamp,
      "lastMessageSenderId": senderId,
    });

    // commit
    await batch.commit();
  }
}
