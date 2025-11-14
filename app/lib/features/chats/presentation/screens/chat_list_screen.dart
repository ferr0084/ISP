import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Chat {
  final String avatarAsset;
  final String title;
  final String lastMessage;
  final String time;
  final int? unreadCount;
  final bool isGroup;

  Chat({
    required this.avatarAsset,
    required this.title,
    required this.lastMessage,
    required this.time,
    this.unreadCount,
    this.isGroup = false,
  });
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static final List<Chat> _chats = [
    Chat(
      avatarAsset: 'assets/images/avatar_jessica.png',
      title: 'Laura',
      lastMessage: 'Hey, what\'s up? Just checking in t...', // Corrected escaping for apostrophe
      time: '10:45 AM',
      unreadCount: 2,
    ),
    Chat(
      avatarAsset: 'assets/images/avatar_maria.png',
      title: 'Mom',
      lastMessage: 'See you soon!',
      time: '10:42 AM',
    ),
    Chat(
      avatarAsset: 'assets/images/group_design_team.png', // Placeholder for group avatar
      title: 'Work Group',
      lastMessage: 'John: Don\'t forget the meeting...', // Corrected escaping for apostrophe
      time: 'Yesterday',
      unreadCount: 5,
      isGroup: true,
    ),
    Chat(
      avatarAsset: 'assets/images/avatar_chris.png',
      title: 'Alex',
      lastMessage: '📷 Photo',
      time: 'Yesterday',
    ),
    Chat(
      avatarAsset: 'assets/images/avatar_david.png',
      title: 'Sarah',
      lastMessage: 'Sounds good, talk to you later!',
      time: '2d ago',
    ),
    Chat(
      avatarAsset: 'assets/images/avatar_james.png',
      title: 'Mike',
      lastMessage: 'Happy Birthday!! 🎉',
      time: '2d ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2128), // Dark background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2128), // Dark background color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // TODO: Implement drawer functionality
          },
        ),
        title: const Text(
          'Chats',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(chat.avatarAsset),
            ),
            title: Row(
              children: [
                Text(
                  chat.title,
                  style: const TextStyle(color: Colors.white),
                ),
                if (chat.isGroup)
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Icon(Icons.people, size: 16, color: Colors.grey),
                  ),
              ],
            ),
            subtitle: Text(
              chat.lastMessage,
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chat.time,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                if (chat.unreadCount != null && chat.unreadCount! > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4.0),
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            onTap: () {
              // TODO: Navigate to chat detail screen
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new chat functionality
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}