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
      lastMessage: 'Hey, what\'s up? Just checking in t...',
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
      avatarAsset:
          'assets/images/group_design_team.png', // Placeholder for group avatar
      title: 'Work Group',
      lastMessage: 'John: Don\'t forget the meeting...',
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Chats',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (chat.isGroup)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.people,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153), // 0.6 * 255 = 153
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              chat.lastMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withAlpha(178), // 0.7 * 255 = 178.5
              ),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chat.time,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(178), // 0.7 * 255 = 178.5
                  ),
                ),
                if (chat.unreadCount != null && chat.unreadCount! > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4.0),
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
