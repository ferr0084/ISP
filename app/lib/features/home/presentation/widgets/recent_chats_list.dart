import 'package:app/features/home/domain/chat.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/user_avatar.dart';

class RecentChatsList extends StatelessWidget {
  const RecentChatsList({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    final chats = [
      Chat(
        name: 'Jessica',
        lastMessage: 'Awesome, see you there!',
        avatarUrl: 'assets/images/globe.png',
        time: '10:42 AM',
        unreadCount: 5,
        isOnline: true,
      ),
      Chat(
        name: 'Maria',
        lastMessage: 'Can you send me the file?',
        avatarUrl: 'assets/images/globe.png',
        time: '9:15 AM',
        unreadCount: 2,
        isOnline: true,
      ),
      Chat(
        name: 'David',
        lastMessage: 'Sounds good, let\'s do it.',
        avatarUrl: 'assets/images/globe.png',
        time: 'Yesterday',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Chats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ListTile(
              leading: Stack(
                children: [
                   UserAvatar(
                     avatarUrl: chat.avatarUrl,
                     radius: 25,
                   ),
                  if (chat.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1A2025),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                chat.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                chat.lastMessage,
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    chat.time,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (chat.unreadCount > 0) ...[
                    const SizedBox(height: 4),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blue,
                      child: Text(
                        chat.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              onTap: () {},
            );
          },
        ),
      ],
    );
  }
}
