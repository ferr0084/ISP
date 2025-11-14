import 'package:flutter/material.dart';
import 'package:app/features/home/domain/entities/chat.dart';
import 'package:app/features/home/domain/entities/event.dart';
import 'package:app/features/home/domain/entities/expense.dart';
import 'package:app/features/home/domain/entities/friend_status.dart';
import 'package:app/features/home/domain/entities/group.dart';
import 'package:app/core/widgets/main_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data (will be replaced by actual data from domain layer)
    final List<FriendStatus> friendStatuses = [
      FriendStatus(name: 'Maria', avatarUrl: 'assets/images/avatar_maria.png', isOnline: true),
      FriendStatus(name: 'David', avatarUrl: 'assets/images/avatar_david.png'),
      FriendStatus(name: 'Jessica', avatarUrl: 'assets/images/avatar_jessica.png', isOnline: true),
      FriendStatus(name: 'Chris', avatarUrl: 'assets/images/avatar_chris.png'),
      FriendStatus(name: 'S', avatarUrl: 'assets/images/avatar_s.png'),
    ];

    final List<Group> myGroups = [
      Group(name: 'Design Team', avatarUrl: 'assets/images/group_design_team.png', description: '5 new messages'),
      Group(name: 'Project Phoenix', avatarUrl: 'assets/images/group_project_phoenix.png', description: 'Kickoff meeting today @ 2:30 PM'),
      Group(name: 'Weekend Trip', avatarUrl: 'assets/images/group_weekend_trip.png', description: 'You owe \u002445 for gas'),
    ];

    final List<Chat> recentChats = [
      Chat(senderName: 'Jessica', avatarUrl: 'assets/images/avatar_jessica.png', message: 'Awesome, see you there!', time: '10:42 AM', unreadCount: 5),
      Chat(senderName: 'Maria', avatarUrl: 'assets/images/avatar_maria.png', message: 'Can you send me the file?', time: '9:15 AM', unreadCount: 2),
      Chat(senderName: 'David', avatarUrl: 'assets/images/avatar_david.png', message: 'Sounds good, let\'s do it.', time: 'Yesterday'),
    ];

    final List<Event> upcomingEvents = [
      Event(month: 'SEP', day: '28', title: 'Design Team Sync', timeLocation: '10:00 AM - Conference Room'),
      Event(month: 'OCT', day: '02', title: 'Project Phoenix Kickoff', timeLocation: '2:30 PM - Main Office'),
    ];

    final List<Expense> pendingExpenses = [
      Expense(type: ExpenseType.owedByYou, description: 'You owe Maria', forWhat: 'For "Team Lunch"', amount: 15.50),
      Expense(type: ExpenseType.owedToYou, description: 'David owes you', forWhat: 'For "Movie Tickets"', amount: 25.00),
      Expense(type: ExpenseType.owedByYou, description: 'You owe Chris', forWhat: 'For "Coffee Run"', amount: 8.75),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search button press
            },
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Friend Statuses', () {
              // Handle View All for Friend Statuses
            }),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 100, // Adjust height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: friendStatuses.length,
                itemBuilder: (context, index) {
                  final status = friendStatuses[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(status.avatarUrl),
                            ),
                            if (status.isOnline)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(status.name, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24.0),
            _buildSectionHeader(context, 'My Groups', () {
              // Handle View All for My Groups
            }),
            const SizedBox(height: 16.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myGroups.length,
              separatorBuilder: (context, index) => const Divider(height: 24.0),
              itemBuilder: (context, index) {
                final group = myGroups[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: group.avatarUrl != null ? AssetImage(group.avatarUrl!) : null,
                    child: group.avatarUrl == null ? const Icon(Icons.group) : null,
                  ),
                  title: Text(group.name, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(group.description, style: Theme.of(context).textTheme.bodySmall),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                  onTap: () {
                    // Handle group tap
                  },
                );
              },
            ),
            const SizedBox(height: 24.0),
            _buildSectionHeader(context, 'Recent Chats', () {
              // Handle View All for Recent Chats
            }),
            const SizedBox(height: 16.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentChats.length,
              separatorBuilder: (context, index) => const Divider(height: 24.0),
              itemBuilder: (context, index) {
                final chat = recentChats[index];
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(chat.avatarUrl),
                      ),
                      if (chat.unreadCount != null && chat.unreadCount! > 0)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              chat.unreadCount.toString(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(chat.senderName, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(chat.message, style: Theme.of(context).textTheme.bodySmall),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(chat.time, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  onTap: () {
                    // Handle chat tap
                  },
                );
              },
            ),
            const SizedBox(height: 24.0),
            _buildSectionHeader(context, 'Upcoming Events', () {
              // Handle View All for Upcoming Events
            }),
            const SizedBox(height: 16.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingEvents.length,
              separatorBuilder: (context, index) => const Divider(height: 24.0),
              itemBuilder: (context, index) {
                final event = upcomingEvents[index];
                return ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(event.month, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                        Text(event.day, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                      ],
                    ),
                  ),
                  title: Text(event.title, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(event.timeLocation, style: Theme.of(context).textTheme.bodySmall),
                  onTap: () {
                    // Handle event tap
                  },
                );
              },
            ),
            const SizedBox(height: 24.0),
            _buildSectionHeader(context, 'Pending Expenses', () {
              // Handle View All for Pending Expenses
            }),
            const SizedBox(height: 16.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingExpenses.length,
              separatorBuilder: (context, index) => const Divider(height: 24.0),
              itemBuilder: (context, index) {
                final expense = pendingExpenses[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: expense.type == ExpenseType.owedByYou ? Colors.orange : Colors.blue,
                    child: Icon(
                      expense.type == ExpenseType.owedByYou ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(expense.description, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(expense.forWhat, style: Theme.of(context).textTheme.bodySmall),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: expense.type == ExpenseType.owedByYou ? Colors.orange.shade700 : Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      '\$${expense.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    // Handle expense tap
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Text(
            'View All',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}