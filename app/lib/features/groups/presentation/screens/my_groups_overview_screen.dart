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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () {
            // TODO: Implement drawer functionality
          },
        ),
        title: Text(
          'My Groups',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).appBarTheme.foregroundColor),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search groups...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    group.lastMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        group.time,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      if (group.unreadCount != null && group.unreadCount! > 0)
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
                            '${group.unreadCount}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}