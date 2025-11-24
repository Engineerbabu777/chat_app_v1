import 'dart:developer';

import 'package:chat_app/data/models/chat_message_model.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubits/chat/chat_cubit.dart';
import 'package:chat_app/logic/cubits/chat/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
    _chatCubit.leaveChat();
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
                BlocBuilder<ChatCubit, ChatState>(
                  bloc: _chatCubit,
                  builder: (context, state) {
                    print({"state": state.isRecieverOnline});
                    if (state.isRecieverTyping) {
                      return Text(
                        "Typing...",
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      );
                    }

                    if (state.isRecieverOnline) {
                      return Text(
                        "Online",
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      );
                    }

                    if (state.recieverLastSeen != null) {
                      final lastSeen = state.recieverLastSeen!.toDate();
                      return Text(
                        "last seen at ${DateFormat("h:mm:a").format(lastSeen)}",
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      );
                    }

                    return Text(
                      "Offline",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    );
                  },
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
      body: BlocBuilder<ChatCubit, ChatState>(
        bloc: _chatCubit,
        builder: (context, state) {
          if (state.status == ChatStatus.loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.status == ChatStatus.error) {
            return Center(child: Text(state.error ?? "Something went wrong!"));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: state.messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final message = state.messages[index];
                    final isMe = message.senderId == _chatCubit.currentUserId;

                    return MessageBubble(message: message, isMe: isMe);
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
          );
        },
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
                  DateFormat('h:mm a').format(message.timestamp.toDate()),
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                ),
                if (isMe)
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(
                        Icons.done_all,
                        size: 14,
                        color: message.status == MessageStatus.read
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
