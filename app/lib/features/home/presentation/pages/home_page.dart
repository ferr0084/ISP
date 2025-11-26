import 'package:app/core/widgets/main_drawer.dart';
import 'package:app/features/events/presentation/providers/event_provider.dart';
import 'package:app/features/events/presentation/providers/expense_summary_provider.dart';
import 'package:app/features/home/domain/entities/expense.dart';

import 'package:app/features/home/presentation/providers/recent_chats_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/user_avatar.dart';
import '../../../groups/presentation/providers/group_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../widgets/my_groups_list.dart';
import '../widgets/friend_status_list.dart';
import '../providers/friend_status_provider.dart';

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
        Provider.of<ExpenseSummaryProvider>(
          context,
          listen: false,
        ).fetchUserPendingExpenses(userId);
      }
      Provider.of<GroupProvider>(context, listen: false).fetchGroups();
      // EventProvider loads events in its constructor, but we can trigger a refresh if needed.
      // Ideally, we should rely on the stream or initial load.
      // If we want to be sure, we can't easily trigger a reload without exposing a public method.
      // But since it's a singleton/provider, it should be alive.
      // Let's just rely on the provider's state for now.
      Provider.of<FriendStatusProvider>(
        context,
        listen: false,
      ).fetchFriendStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dummy Data (will be replaced by actual data from domain layer)
    // Dummy Data removed - using FriendStatusList widget which uses provider

    // Real Events Logic
    final eventProvider = context.watch<EventProvider>();
    final now = DateTime.now();
    final upcomingEvents =
        eventProvider.events.where((event) => event.date.isAfter(now)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final displayEvents = upcomingEvents.take(3).toList();

    // Get pending expenses from provider
    final expenseProvider = context.watch<ExpenseSummaryProvider>();
    final pendingExpenses = expenseProvider.isLoading
        ? [] // Show empty while loading
        : expenseProvider.pendingExpenses.map((summary) {
            return Expense(
              type: summary.netAmount > 0 ? ExpenseType.owedToYou : ExpenseType.owedByYou,
              description: summary.netAmount > 0
                  ? '${summary.otherUserName} owes you'
                  : 'You owe ${summary.otherUserName}',
              forWhat: 'For "${summary.expenseDescription}" in ${summary.eventName}',
              amount: summary.netAmount.abs(),
            );
          }).toList();

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
            const FriendStatusList(),
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
                           UserAvatar(
                             avatarUrl: chat.senderAvatarUrl,
                             name: chat.senderName,
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
                final group = event.groupId != null
                    ? Provider.of<GroupProvider>(
                        context,
                        listen: false,
                      ).getGroup(event.groupId!)
                    : null;

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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormat.jm().format(event.date)} - ${event.location}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (group != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              group.name,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer,
                                  ),
                            ),
                          ),
                        ),
                    ],
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
            if (expenseProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (pendingExpenses.isEmpty)
              Card(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No pending expenses'),
                  ),
                ),
              )
            else
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
