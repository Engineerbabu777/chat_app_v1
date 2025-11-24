import 'dart:developer';

import 'package:chat_app/data/models/chat_message_model.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubits/chat/chat_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  const ChatMessageScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final TextEditingController _sendMessageController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  late final ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(() {
      setState(() {}); // rebuild when focus changes
    });
    _chatCubit = getIt<ChatCubit>();
    _chatCubit.enterChat(widget.receiverId);
  }

  Future<void> _handleSendMessage() async {
    final messageText = _sendMessageController.text.trim();

    log("Hello");
    await _chatCubit.sendMessage(
      content: messageText,
      receiverId: widget.receiverId,
    );
    _sendMessageController.clear();
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _sendMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(widget.receiverName[0].toUpperCase()),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.receiverName),
                Text(
                  "Online",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.only(right: 15.0),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return MessageBubble(
                  message: ChatMessageModel(
                    id: "8888",
                    chatRoomId: "XXXX",
                    senderId: "VVXVXVVX",
                    receiverId: "XJHGXJHG",
                    content: "Hello this is my first message",
                    timestamp: Timestamp.now(),
                    readBy: [],
                  ),
                  isMe: false,
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                ),

                // TextField (CENTER)
                Expanded(
                  child: TextField(
                    controller: _sendMessageController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    _handleSendMessage();
                  },
                  icon: Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.only(
          left: isMe ? 64 : 8,
          right: isMe ? 8 : 64,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "4:34 AM",
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                ),
                if (isMe)
                  Icon(
                    Icons.done_all,
                    size: 20,
                    color: message.status == MessageStatus.read
                        ? Colors.green
                        : Colors.red,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
