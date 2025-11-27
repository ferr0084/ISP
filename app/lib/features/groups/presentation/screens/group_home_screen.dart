import 'package:app/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../events/presentation/providers/event_provider.dart';
import '../../../idiot_game/presentation/providers/idiot_game_provider.dart';
import '../providers/group_detail_provider.dart';
import '../providers/group_provider.dart';
import '../widgets/group_avatar.dart';

class GroupHomeScreen extends StatefulWidget {
  final String groupId;

  const GroupHomeScreen({super.key, required this.groupId});

  @override
  GroupHomeScreenState createState() => GroupHomeScreenState();
}

class GroupHomeScreenState extends State<GroupHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupDetailProvider>(
      create: (_) {
        final provider = sl<GroupDetailProvider>(param1: widget.groupId);
        provider.fetchGroupDetails();
        return provider;
      },
      child: Consumer<GroupDetailProvider>(
        builder: (context, groupDetailProvider, child) {
          if (groupDetailProvider.isLoading &&
              groupDetailProvider.group == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupDetailProvider.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Text('Error: ${groupDetailProvider.errorMessage!}'),
              ),
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
                  GroupAvatar(avatarUrl: group.avatarUrl, radius: 16),
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
                          final groupProvider = context.read<GroupProvider>();
                          await groupProvider.deleteGroup(group.id);
                          if (!mounted) return;
                          if (groupProvider.hasError) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error deleting group: ${groupProvider.errorMessage}',
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
                                  backgroundImage:
                                      messageWithSender.senderAvatar != null
                                      ? NetworkImage(
                                          messageWithSender.senderAvatar!,
                                        )
                                      : null,
                                  radius: 20,
                                  child: messageWithSender.senderAvatar == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

                     // Idiot Game Section
                     Consumer<IdiotGameProvider>(
                       builder: (context, idiotGameProvider, child) {
                         final games = idiotGameProvider.groupGames;
                         final hasGames = games.isNotEmpty;
                         final lastGameDetails = idiotGameProvider.lastGroupGameDetails;
                         final loser = lastGameDetails?.loser;

                         // Fetch data if not loaded
                         if (games.isEmpty && lastGameDetails == null) {
                           WidgetsBinding.instance.addPostFrameCallback((_) {
                             idiotGameProvider.fetchGroupGamesData(widget.groupId);
                           });
                           return const Padding(
                             padding: EdgeInsets.all(16.0),
                             child: Center(child: CircularProgressIndicator()),
                           );
                         }
                        // The Game entity might not have participant details directly accessible in a simple way
                        // if it's just a Game model. Let's check Game entity.
                        // It seems Game entity doesn't have participants list in the domain entity based on previous views?
                        // Wait, the repository returns List<Game>.
                        // Let's check Game entity definition.
                        // Assuming Game entity has a way to identify the loser or we need to fetch details.
                        // For now, let's assume we can't easily get the loser name without fetching details
                        // OR we update the Game entity to include 'loserName' or similar if the query joins it.
                        // The remote data source fetches `*, idiot_game_participants(*)`.
                        // So the GameModel likely has participants.
                        // Let's assume for now we can get it. If not, we'll need to adjust.

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Idiot Game',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.push('/idiot-game');
                                  },
                                  child: Text(
                                    'View Dashboard',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withAlpha(
                                                  178,
                                                ), // 0.7 * 255 = 178.5
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                      if (loser != null)
                                        InkWell(
                                          onTap: () {
                                            context.push('/idiot-game/user/${loser.userProfile.id}');
                                          },
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: loser.userProfile.avatarUrl != null
                                                    ? NetworkImage(loser.userProfile.avatarUrl!)
                                                    : null,
                                                radius: 20,
                                                child: loser.userProfile.avatarUrl == null
                                                    ? Text((loser.userProfile.fullName ?? loser.userProfile.nickname ?? 'Unknown')[0])
                                                    : null,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                loser.userProfile.fullName ?? loser.userProfile.nickname ?? 'Unknown',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.onSurface,
                                                    ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.sentiment_dissatisfied,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                                size: 30,
                                              ),
                                            ],
                                          ),
                                        )
                                     else if (hasGames)
                                       const Text('Loading loser details...')
                                     else
                                       const Text('No games played yet.'),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.push(
                                            '/idiot-game/new',
                                            extra: widget.groupId,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Log New Game',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
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
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Upcoming Events Section
                    Consumer<EventProvider>(
                      builder: (context, eventProvider, child) {
                        final now = DateTime.now();
                        final groupEvents =
                            eventProvider.events
                                .where(
                                  (event) =>
                                      event.groupId == widget.groupId &&
                                      event.date.isAfter(now),
                                )
                                .toList()
                              ..sort((a, b) => a.date.compareTo(b.date));

                        final displayEvents = groupEvents.take(3).toList();

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Upcoming Events',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.push('/events');
                                  },
                                  child: Text(
                                    'View All',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (displayEvents.isEmpty)
                              Card(
                                color: Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text('No upcoming events'),
                                  ),
                                ),
                              )
                            else
                              Card(
                                color: Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: displayEvents.map((event) {
                                    return InkWell(
                                      onTap: () {
                                        context.push('/events/${event.id}');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 16.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withAlpha(
                                                      25,
                                                    ), // 0.1 * 255 = 25.5
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.event,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    event.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                  ),
                                                  Text(
                                                    event.location,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface
                                                                  .withAlpha(
                                                                    178,
                                                                  ),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              DateFormat.MMMd().add_jm().format(
                                                event.date,
                                              ),
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
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        );
                      },
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
                               groupDetailProvider.expenseSummary != null
                                   ? (groupDetailProvider.expenseSummary!.netAmount >= 0
                                       ? 'You are owed'
                                       : 'You owe')
                                   : 'Shared Expenses',
                               style: Theme.of(context).textTheme.bodySmall
                                   ?.copyWith(
                                     color: Theme.of(context)
                                         .colorScheme
                                         .onSurface
                                         .withAlpha(178), // 0.7 * 255 = 178.5
                                   ),
                             ),
                             const SizedBox(height: 4),
                             Row(
                               children: [
                                 Text(
                                   groupDetailProvider.expenseSummary != null
                                       ? '\$${groupDetailProvider.expenseSummary!.netAmount.abs().toStringAsFixed(2)}'
                                       : '\$0.00',
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
                                 if (groupDetailProvider.expenseSummary != null)
                                   Container(
                                     padding: const EdgeInsets.all(8.0),
                                     decoration: BoxDecoration(
                                       color: groupDetailProvider.expenseSummary!.netAmount >= 0
                                           ? Theme.of(context).colorScheme.secondary
                                           : Theme.of(context).colorScheme.error,
                                       shape: BoxShape.circle,
                                     ),
                                     child: Icon(
                                       groupDetailProvider.expenseSummary!.netAmount >= 0
                                           ? Icons.arrow_upward
                                           : Icons.arrow_downward,
                                       color: groupDetailProvider.expenseSummary!.netAmount >= 0
                                           ? Theme.of(context).colorScheme.onSecondary
                                           : Theme.of(context).colorScheme.onError,
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
                                   'Settle Up',
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
                            final groupDetailProvider = context
                                .read<GroupDetailProvider>();
                            context.push(
                              '/groups/detail/${widget.groupId}/members',
                              extra: groupDetailProvider,
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
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
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: CircleAvatar(
                                          backgroundImage:
                                              member.avatarUrl != null
                                              ? NetworkImage(member.avatarUrl!)
                                              : null,
                                          radius: 20,
                                          child: member.avatarUrl == null
                                              ? Text(member.name[0])
                                              : null,
                                        ),
                                      ),
                                    ),
                                if (groupDetailProvider.members.length > 3)
                                  CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    radius: 20,
                                    child: Text(
                                      '+${groupDetailProvider.members.length - 3}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                          ),
                                    ),
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
