import 'package:app/features/home/domain/friend_status.dart';
import 'package:flutter/material.dart';

class FriendStatusList extends StatelessWidget {
  const FriendStatusList({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    final friendStatuses = [
      FriendStatus(
        name: 'Maria',
        avatarUrl: 'assets/images/globe.png',
        isOnline: true,
      ),
      FriendStatus(name: 'David', avatarUrl: 'assets/images/globe.png'),
      FriendStatus(
        name: 'Jessica',
        avatarUrl: 'assets/images/globe.png',
        isOnline: true,
      ),
      FriendStatus(name: 'Chris', avatarUrl: 'assets/images/globe.png'),
      FriendStatus(name: 'Steve', avatarUrl: 'assets/images/globe.png'),
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
                'Friend Statuses',
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
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: friendStatuses.length,
            itemBuilder: (context, index) {
              final friend = friendStatuses[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(friend.avatarUrl),
                        ),
                        if (friend.isOnline)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 15,
                              height: 15,
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
                    const SizedBox(height: 8),
                    Text(
                      friend.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
