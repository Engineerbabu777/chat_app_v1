import 'dart:math';

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
      type: type,
    );

    // message to sub collection!
    batch.set(messageDoc, message.toMap());

    // update chat room!
    batch.update(_chatRooms.doc(chatRoomId), {
      "lastMessage": content,
      "lastMessageTime": message.timestamp,
      "lastMessageSenderId": senderId,
    });

    // commit
    await batch.commit();
  }

  Stream<List<ChatMessageModel>> getMessages(
    String roomId, {
    DocumentSnapshot? lastDocument,
  }) {
    var query = getChatRoomMessagesCollection(
      roomId,
    ).orderBy('timestamp', descending: true).limit(20);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc))
          .toList(),
    );
  }

  Future<List<ChatMessageModel>> getMoreMessages(
    String roomId, {
    required DocumentSnapshot lastDocument,
  }) async {
    final query = getChatRoomMessagesCollection(roomId)
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDocument)
        .limit(20);

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => ChatMessageModel.fromFirestore(doc))
        .toList();
  }
}
