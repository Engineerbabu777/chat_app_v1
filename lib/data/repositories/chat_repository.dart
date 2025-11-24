import 'dart:developer';

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

  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    return _chatRooms
        .where("participants", arrayContains: userId)
        .orderBy("lastMessageTime", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatRoomModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<int> getUnreadCount(String chatRoomId, String userId) {
    return getChatRoomMessagesCollection(chatRoomId)
        .where("receiverId", isEqualTo: userId)
        .where("status", isEqualTo: MessageStatus.sent.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      final batch = firestore.batch();

      final unreadMessages = await getChatRoomMessagesCollection(chatRoomId)
          .where("receiverId", isEqualTo: userId)
          .where("status", isEqualTo: MessageStatus.sent.toString())
          .get();

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          "readBy": FieldValue.arrayUnion([userId]),
          "status": MessageStatus.read.toString(),
        });
      }

      batch.commit();
    } catch (e) {
      print(e.toString());
      log(e.toString());
    }
  }

  Stream<Map<String, dynamic>> getUserOnlineStatus(String userId) {
    return firestore.collection("users").doc(userId).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();

      return {
        'isOnline': data?['isOnline'] ?? false,
        'lastSeen': data?['lastSeen'] ?? false,
      };
    });
  }

  Stream<Map<String, dynamic>> getTypingStatus(String chatRoomId) {
    return _chatRooms.doc(chatRoomId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return {'isTyping': false, 'isTypingUserId': null};
      }

      final data = snapshot.data() as Map<String, dynamic>;

      return {
        'isTyping': data['isTyping'] ?? false,
        'typingUserId': data['typingUserId'],
      };
    });
  }

  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await firestore.collection("users").doc(userId).update({
      "isOnline": isOnline,
      'lastSeen': Timestamp.now(),
    });
  }

  Future<void> updateTypingStatus(
    String chatRoomId,
    String userId,
    bool isTyping,
  ) async {
    final chatRoom = await _chatRooms.doc(chatRoomId).get();

    if (!chatRoom.exists) {
      print("Unable to find the chat room with this is;");
      return;
    }

    await _chatRooms.doc(chatRoomId).update({
      "isTyping": isTyping,
      "typingUserId": userId,
    });
  }

  Future<void> blockUser(String currentUserId, String blockedUserId) async {
    final userRef = firestore.collection("users").doc(currentUserId);

    await userRef.update({
      "blockedUsers": FieldValue.arrayUnion([blockedUserId]),
    });
  }

  Future<void> unBlockUser(String currentUserId, String unblockUserId) async {
    final userRef = firestore.collection("users").doc(currentUserId);

    await userRef.update({
      "blockedUsers": FieldValue.arrayRemove([unblockUserId]),
    });
  }

  Future<bool> amIBlockedFrom(String currentUser, String otherUserId){}
}
