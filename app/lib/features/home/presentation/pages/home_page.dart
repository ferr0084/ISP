import 'package:app/core/widgets/main_drawer.dart';
import 'package:app/features/home/domain/entities/chat.dart';
import 'package:app/features/home/domain/entities/event.dart';
import 'package:app/features/home/domain/entities/expense.dart';
import 'package:app/features/home/domain/entities/friend_status.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../groups/presentation/providers/group_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<SupabaseClient>(
        context,
        listen: false,
      ).auth.currentUser?.id;
      if (userId != null) {
        Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).fetchNotifications(userId);
      }
      Provider.of<GroupProvider>(context, listen: false).fetchGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dummy Data (will be replaced by actual data from domain layer)
    final List<FriendStatus> friendStatuses = [
      FriendStatus(
        name: 'Maria',
        avatarUrl: 'assets/images/avatar_maria.png',
        isOnline: true,
      ),
      FriendStatus(name: 'David', avatarUrl: 'assets/images/avatar_david.png'),
      FriendStatus(
        name: 'Jessica',
        avatarUrl: 'assets/images/avatar_jessica.png',
        isOnline: true,
      ),
      FriendStatus(name: 'Chris', avatarUrl: 'assets/images/avatar_chris.png'),
      FriendStatus(name: 'S', avatarUrl: 'assets/images/avatar_s.png'),
    ];

    final List<Chat> recentChats = [
      Chat(
        senderName: 'Jessica',
        avatarUrl: 'assets/images/avatar_jessica.png',
        message: 'Awesome, see you there!',
        time: '10:42 AM',
        unreadCount: 5,
      ),
      Chat(
        senderName: 'Maria',
        avatarUrl: 'assets/images/avatar_maria.png',
        message: 'Can you send me the file?',
        time: '9:15 AM',
        unreadCount: 2,
      ),
      Chat(
        senderName: 'David',
        avatarUrl: 'assets/images/avatar_david.png',
        message: 'Sounds good, let\'s do it.',
        time: 'Yesterday',
      ),
    ];

    final List<Event> upcomingEvents = [
      Event(
        month: 'SEP',
        day: '28',
        title: 'Design Team Sync',
        timeLocation: '10:00 AM - Conference Room',
      ),
      Event(
        month: 'OCT',
        day: '02',
        title: 'Project Phoenix Kickoff',
        timeLocation: '2:30 PM - Main Office',
      ),
    ];

    final List<Expense> pendingExpenses = [
      Expense(
        type: ExpenseType.owedByYou,
        description: 'You owe Maria',
        forWhat: 'For "Team Lunch"',
        amount: 15.50,
      ),
      Expense(
        type: ExpenseType.owedToYou,
        description: 'David owes you',
        forWhat: 'For "Movie Tickets"',
        amount: 25.00,
      ),
      Expense(
        type: ExpenseType.owedByYou,
        description: 'You owe Chris',
        forWhat: 'For "Coffee Run"',
        amount: 8.75,
      ),
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
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      context.push('/notifications');
                    },
                  ),
                  if (provider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${provider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
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
              context.go('/contacts');
            }),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 100,
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
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).scaffoldBackgroundColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          status.name,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24.0),
            _buildSectionHeader(context, 'My Groups', () {
              context.go('/groups');
            }),
            const SizedBox(height: 16.0),
            Consumer<GroupProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text('Error: ${provider.error}'));
                }

                final myGroups = provider.groups;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: myGroups.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 24.0),
                  itemBuilder: (context, index) {
                    final group = myGroups[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (group.avatarUrl.isNotEmpty)
                            ? NetworkImage(group.avatarUrl)
                            : null,
                        child: (group.avatarUrl.isEmpty)
                            ? const Icon(Icons.group)
                            : null,
                      ),
                      title: Text(
                        group.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        group.lastMessage,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                      onTap: () {},
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24.0),
            _buildSectionHeader(context, 'Recent Chats', () {
              context.go('/chats');
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
                      CircleAvatar(backgroundImage: AssetImage(chat.avatarUrl)),
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
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    chat.senderName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    chat.message,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        chat.time,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  onTap: () {
                    context.go('/chats');
                  },
                );
              },
            ),
            const SizedBox(height: 24.0),
            _buildSectionHeader(context, 'Upcoming Events', () {
              context.go('/events');
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
                        Text(
                          event.month,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                        Text(
                          event.day,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    event.timeLocation,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    context.go('/events');
                  },
                );
              },
            ),
            const SizedBox(height: 24.0),
            _buildSectionHeader(context, 'Pending Expenses', () {
              context.go('/expenses');
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
                    backgroundColor: expense.type == ExpenseType.owedByYou
                        ? Colors.orange
                        : Colors.blue,
                    child: Icon(
                      expense.type == ExpenseType.owedByYou
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    expense.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    expense.forWhat,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: expense.type == ExpenseType.owedByYou
                          ? Colors.orange.shade700
                          : Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      '\$${expense.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    context.go('/expenses');
                  },
                );
              },
            ),
            const SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.go('/profile');
                },
                child: const Text('View Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onViewAll,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Text(
            'View All',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
