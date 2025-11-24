import 'package:chat_app/data/models/chat_room_model.dart';
import 'package:flutter/material.dart';

class ChatListTile extends StatelessWidget {
  final ChatRoomModel chat;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  String _getOtherUsername() {
    final otherUserId = chat.participants.firstWhere(
      (id) => id != currentUserId,
    );
    return chat.participantsName[otherUserId] ?? "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Text(_getOtherUsername()[0].toUpperCase()),
      ),
      title: Text(
        _getOtherUsername(),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
      trailing: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        width: 20,
        height: 20,
        child: Align(
          child: Text("1", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
