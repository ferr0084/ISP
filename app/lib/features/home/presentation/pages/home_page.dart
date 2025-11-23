import 'package:app/core/widgets/main_drawer.dart';
import 'package:app/features/events/presentation/providers/event_provider.dart';
import 'package:app/features/home/domain/entities/expense.dart';
import 'package:app/features/home/domain/entities/friend_status.dart';
import 'package:app/features/home/presentation/providers/recent_chats_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../groups/presentation/providers/group_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../widgets/my_groups_list.dart';

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
      // EventProvider loads events in its constructor, but we can trigger a refresh if needed.
      // Ideally, we should rely on the stream or initial load.
      // If we want to be sure, we can't easily trigger a reload without exposing a public method.
      // But since it's a singleton/provider, it should be alive.
      // Let's just rely on the provider's state for now.
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

    // Real Events Logic
    final eventProvider = context.watch<EventProvider>();
    final now = DateTime.now();
    final upcomingEvents =
        eventProvider.events.where((event) => event.date.isAfter(now)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final displayEvents = upcomingEvents.take(3).toList();

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
            const MyGroupsList(),
            const SizedBox(height: 24.0),
            _buildSectionHeader(context, 'Recent Chats', () {
              context.go('/chats');
            }),
            const SizedBox(height: 16.0),
            Consumer<RecentChatsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text('Error: ${provider.error}'));
                }

                if (provider.recentChats.isEmpty) {
                  return const Center(child: Text('No recent chats.'));
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.recentChats.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 24.0),
                  itemBuilder: (context, index) {
                    final chat = provider.recentChats[index];
                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundImage: _getImageProvider(
                              chat.senderAvatarUrl,
                            ),
                            child: chat.senderAvatarUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          if (chat.unreadCount > 0)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
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
                        chat.chatName ?? chat.senderName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        chat.lastMessageContent,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Text(
                        DateFormat.jm().format(chat.lastMessageCreatedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        context.go('/chats/${chat.chatId}');
                      },
                    );
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
              itemCount: displayEvents.length,
              separatorBuilder: (context, index) => const Divider(height: 24.0),
              itemBuilder: (context, index) {
                final event = displayEvents[index];
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
                          DateFormat.MMM().format(event.date).toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                        Text(
                          event.date.day.toString(),
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
                    event.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    '${DateFormat.jm().format(event.date)} - ${event.location}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    context.go('/events/${event.id}');
                  },
                );
              },
            ),
            if (displayEvents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No upcoming events'),
                ),
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

  ImageProvider? _getImageProvider(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) {
      return NetworkImage(url);
    }
    return AssetImage(url);
  }
}
