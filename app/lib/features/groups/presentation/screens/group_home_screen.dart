import 'package:app/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/idiot_game_info.dart';
import '../providers/group_detail_provider.dart';
import '../providers/group_provider.dart';

class GroupHomeScreen extends StatefulWidget {
  final String groupId;

  const GroupHomeScreen({super.key, required this.groupId});

  @override
  GroupHomeScreenState createState() => GroupHomeScreenState();
}

class GroupHomeScreenState extends State<GroupHomeScreen> {
  // Dummy Data
  static final Announcement _announcement = Announcement(
    title: 'Pinned Announcement',
    content: 'Project Deadline moved to Friday.',
    imageUrl: 'assets/images/group_design_team.png', // Placeholder image
  );

  static final IdiotGameInfo _idiotGameInfo = IdiotGameInfo(
    currentIdiotName: 'Ben',
    currentIdiotAvatar: 'assets/images/avatar_chris.png', // Placeholder
  );

  static final List<Event> _upcomingEvents = [
    Event(
      icon: Icons.calendar_today,
      title: 'Weekly Sync',
      subtitle: 'Team Check-in',
      time: 'Tomorrow, 10 AM',
    ),
    Event(
      icon: Icons.play_circle_outline,
      title: 'Client Pitch',
      subtitle: 'Final Presentation',
      time: 'Nov 25th, 2 PM',
    ),
  ];

  static final ExpenseSummary _expenseSummary = ExpenseSummary(
    amountOwed: 15.50,
  );



  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupDetailProvider>(
      create: (_) => sl<GroupDetailProvider>(param1: widget.groupId)..fetchGroupDetails(),
      child: Consumer<GroupDetailProvider>(
        builder: (context, groupDetailProvider, child) {
          if (groupDetailProvider.isLoading && groupDetailProvider.group == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupDetailProvider.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(child: Text('Error: ${groupDetailProvider.errorMessage!}')),
            );
          }

          final group = groupDetailProvider.group;

          if (group == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Group not found!')),
            );
          }

          final latestMessages = groupDetailProvider.latestMessages;

          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {
                  context.pop();
                },
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(group.avatarUrl),
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    final navigator = GoRouter.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    if (value == 'Edit') {
                      navigator.push('/groups/edit', extra: group.id);
                    } else if (value == 'Delete') {
                      await context.read<GroupProvider>().deleteGroup(group.id);
                      if (!mounted) return;
                      if (context.read<GroupProvider>().hasError) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error deleting group: ${context.read<GroupProvider>().errorMessage}',
                            ),
                          ),
                        );
                      } else {
                        navigator.pop();
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {'Edit', 'Delete'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pinned Announcement
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(_announcement.imageUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withAlpha(102), // 0.4 * 255 = 102
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _announcement.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _announcement.content,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimary
                                        .withAlpha(204), // 0.8 * 255 = 204
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Idiot Game Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Idiot Game',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/idiot-game');
                          },
                          child: Text(
                            'View Dashboard',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Idiot',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface
                                        .withAlpha(178), // 0.7 * 255 = 178.5
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage(
                                    _idiotGameInfo.currentIdiotAvatar,
                                  ),
                                  radius: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _idiotGameInfo.currentIdiotName,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.sentiment_dissatisfied,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 30,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement Log New Game
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Log New Game',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Upcoming Events Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Events',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/events');
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: _upcomingEvents.map((event) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onSurface
                                        .withAlpha(25), // 0.1 * 255 = 25.5
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    event.icon,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                      ),
                                      Text(
                                        event.subtitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withAlpha(
                                                    178,
                                                  ), // 0.7 * 255 = 178.5
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  event.time,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha(178), // 0.7 * 255 = 178.5
                                      ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Shared Expenses Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shared Expenses',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/expenses');
                          },
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You are owed',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface
                                        .withAlpha(178), // 0.7 * 255 = 178.5
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '\$${_expenseSummary.amountOwed.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary, // Using secondary for a different accent
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_upward,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Settle Up
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Log New Game',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Latest Messages Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Latest Messages',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (group.chatId != null) {
                              context.push(
                                '/chats/${group.chatId}',
                                extra: group.name,
                              );
                            } else {
                              // Handle case where chatId is null (shouldn't happen with triggers)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Chat not available for this group.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Open Chat',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: latestMessages.map((messageWithSender) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundImage: messageWithSender.senderAvatar != null
                                      ? NetworkImage(messageWithSender.senderAvatar!)
                                      : null,
                                  child: messageWithSender.senderAvatar == null
                                      ? const Icon(Icons.person)
                                      : null,
                                  radius: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        messageWithSender.senderName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        messageWithSender.message.content,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withAlpha(
                                                    178,
                                                  ), // 0.7 * 255 = 178.5
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Members Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Members',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push(
                              '/groups/detail/${widget.groupId}/members',
                              extra: context.read<GroupDetailProvider>(),
                            );
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Group Members',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface
                                        .withAlpha(178), // 0.7 * 255 = 178.5
                                  ),
                            ),
                            const SizedBox(height: 8),
                            // Placeholder for member avatars
                            Row(
                              children: [
                                ...groupDetailProvider.members
                                    .take(3)
                                    .map(
                                      (member) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: CircleAvatar(
                                          backgroundImage: member.avatarUrl !=
                                                  null
                                              ? NetworkImage(member.avatarUrl!)
                                              : null,
                                          child: member.avatarUrl == null
                                              ? Text(member.name[0])
                                              : null,
                                          radius: 20,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                if (groupDetailProvider.members.length > 3)
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    child: Text(
                                      '+${groupDetailProvider.members.length - 3}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                    ),
                                    radius: 20,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.push('/groups/detail/${widget.groupId}/invite');
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          );
        },
      ),
    );
  }
}