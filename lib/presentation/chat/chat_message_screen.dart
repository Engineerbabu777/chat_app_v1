import 'dart:developer';
import 'dart:io';

import 'package:chat_app/data/models/chat_message_model.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubits/chat/chat_cubit.dart';
import 'package:chat_app/logic/cubits/chat/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

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
  final _scrollController = ScrollController();

  List<ChatMessageModel> _previousMessages = [];
  bool _isEmojiOpen = false;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();

    _sendMessageController.addListener(_onTextChanged);
    _scrollController.addListener(_onScroll);

    _chatCubit = getIt<ChatCubit>();
    _chatCubit.enterChat(widget.receiverId);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _chatCubit.loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _hasNewMessages(List<ChatMessageModel> messages) {
    if (messages.length != _previousMessages.length) {
      _scrollToBottom();
      _previousMessages = List.from(messages);
    }
  }

  Future<void> _handleSendMessage() async {
    final messageText = _sendMessageController.text.trim();
    if (messageText.isEmpty) return;

    await _chatCubit.sendMessage(
      content: messageText,
      receiverId: widget.receiverId,
    );

    _sendMessageController.clear();
  }

  void _onTextChanged() {
    final isComposing = _sendMessageController.text.isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() => _isComposing = isComposing);
    }
    if (isComposing) _chatCubit.startTyping();
  }

  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiOpen = !_isEmojiOpen;
    });

    if (_isEmojiOpen) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _sendMessageController.dispose();
    _scrollController.dispose();
    _chatCubit.leaveChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatCubit, ChatState>(
        bloc: _chatCubit,
        listener: (context, state) => _hasNewMessages(state.messages),
        builder: (context, state) {
          if (state.status == ChatStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(child: _buildMessageList(state)),
              _buildInputArea(state),
              if (_isEmojiOpen) _buildEmojiPicker(),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------
  //      APP BAR
  // ---------------------------
  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(widget.receiverName[0].toUpperCase()),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.receiverName),
              BlocBuilder<ChatCubit, ChatState>(
                bloc: _chatCubit,
                builder: (context, state) {
                  if (state.isRecieverTyping) {
                    return const Text(
                      "Typing...",
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    );
                  }

                  if (state.isRecieverOnline) {
                    return const Text(
                      "Online",
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    );
                  }

                  if (state.recieverLastSeen != null) {
                    final lastSeen = state.recieverLastSeen!.toDate();
                    return Text(
                      "last seen at ${DateFormat("h:mm:a").format(lastSeen)}",
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    );
                  }

                  return const Text(
                    "Offline",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // 👇 THIS PART WAS MISSING — the popup menu
      actions: [
        BlocBuilder<ChatCubit, ChatState>(
          bloc: _chatCubit,
          builder: (context, state) {
            return PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case "block":
                    _chatCubit.blockUser(widget.receiverId);
                    break;
                  case "unblock":
                    _chatCubit.unBlockUser(widget.receiverId);
                    break;
                }
              },
              itemBuilder: (context) {
                return [
                  if (!state.isUserBlocked)
                    const PopupMenuItem(
                      value: "block",
                      child: Text("Block User"),
                    ),
                  if (state.isUserBlocked)
                    const PopupMenuItem(
                      value: "unblock",
                      child: Text("Unblock User"),
                    ),
                ];
              },
            );
          },
        ),
      ],
    );
  }

  // ---------------------------
  //      MESSAGE LIST
  // ---------------------------
  Widget _buildMessageList(ChatState state) {
    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isMe = message.senderId == _chatCubit.currentUserId;
        return MessageBubble(message: message, isMe: isMe);
      },
    );
  }

  // ---------------------------
  //      INPUT AREA
  // ---------------------------
  Widget _buildInputArea(ChatState state) {
    if (state.amIBlocked) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          "You are blocked by this user.",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    if (state.isUserBlocked) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          "You have blocked this user.",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            onPressed: _toggleEmojiPicker,
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),

          Expanded(
            child: TextField(
              controller: _sendMessageController,
              maxLines: null,
              onTap: () {
                if (_isEmojiOpen) {
                  setState(() => _isEmojiOpen = false);
                }
              },
              decoration: InputDecoration(
                hintText: "Type a message",
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: _isComposing ? _handleSendMessage : null,
            icon: const Icon(Icons.send),
            color: _isComposing ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ],
      ),
    );
  }

  // ---------------------------
  //      EMOJI PICKER
  // ---------------------------
  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 260,
      child: EmojiPicker(
        textEditingController: _sendMessageController,
        onEmojiSelected: (category, emoji) {
          _sendMessageController
            ..text += emoji.emoji
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: _sendMessageController.text.length),
            );
          setState(() => _isComposing = true);
        },
        config: Config(
          height: 260,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax: 28 * (Platform.isIOS ? 1.2 : 1.0),
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            enabled: true,
            buttonColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
//   MESSAGE BUBBLE (unchanged)
// ------------------------------------------------------
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
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
