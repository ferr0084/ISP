import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Group {
  final String avatarAsset;
  final String title;
  final String lastMessage;
  final String time;
  final int? unreadCount;

  Group({
    required this.avatarAsset,
    required this.title,
    required this.lastMessage,
    required this.time,
    this.unreadCount,
  });
}

class MyGroupsOverviewScreen extends StatelessWidget {
  const MyGroupsOverviewScreen({super.key});

  static final List<Group> _groups = [
    Group(
      avatarAsset: 'assets/images/group_project_phoenix.png',
      title: 'Project Phoenix',
      lastMessage: 'Alex: Sounds good, let\'s sync up tomorrow.',
      time: '10:42 AM',
      unreadCount: 2,
    ),
    Group(
      avatarAsset: 'assets/images/group_weekend_trip.png', // Placeholder
      title: 'Family Chat',
      lastMessage: 'You have a new mention',
      time: '9:15 AM',
      unreadCount: 1,
    ),
    Group(
      avatarAsset: 'assets/images/group_design_team.png', // Placeholder
      title: 'Weekend Gamers',
      lastMessage: 'Sarah: Anyone online for a match?',
      time: 'Yesterday',
    ),
    Group(
      avatarAsset: 'assets/images/globe.png', // Placeholder
      title: 'Book Club',
      lastMessage: 'Reminder: Chapter 5 discussion tonight!',
      time: 'Tuesday',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2128), // Dark background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2128),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // TODO: Implement drawer functionality
          },
        ),
        title: const Text(
          'My Groups',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search groups...', 
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFF2D333B),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(group.avatarAsset),
                  ),
                  title: Text(
                    group.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    group.lastMessage,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        group.time,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      if (group.unreadCount != null && group.unreadCount! > 0)
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
                            '${group.unreadCount}',
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
                    context.push('/groups/detail'); // Navigate to GroupHomeScreen
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement create new group functionality
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}