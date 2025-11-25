import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/event_provider.dart';
import '../../domain/entities/event_invitation.dart';
import '../../../../core/di/service_locator.dart';

class EventsDashboardScreen extends StatefulWidget {
  const EventsDashboardScreen({super.key});

  @override
  EventsDashboardScreenState createState() => EventsDashboardScreenState();
}

class EventsDashboardScreenState extends State<EventsDashboardScreen> {
  String _selectedView = 'List'; // State for segmented control

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final currentUserId = sl<SupabaseClient>().auth.currentUser!.id;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              context.go('/events/create');
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
              // Segmented Control
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedView = 'List';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedView == 'List'
                                ? Theme.of(context).colorScheme.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'List',
                              style: _selectedView == 'List'
                                  ? Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    )
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(178), // 0.7 * 255 = 178.5
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedView = 'Calendar';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedView == 'Calendar'
                                ? Theme.of(context).colorScheme.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Calendar',
                              style: _selectedView == 'Calendar'
                                  ? Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    )
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(178), // 0.7 * 255 = 178.5
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pending Invitations Section
              Text(
                'Pending Invitations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              if (eventProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (eventProvider.events.isEmpty)
                const Text('No pending invitations')
              else
                ...eventProvider.events
                    .where((event) {
                      final isCreator = event.creatorId == currentUserId;
                      final hasPendingInvitation =
                          event.invitations?.any(
                            (inv) =>
                                inv.inviteeId == currentUserId &&
                                inv.status.name == 'pending',
                          ) ??
                          false;
                      return isCreator || hasPendingInvitation;
                    })
                    .map((event) {
                      final isCreator = event.creatorId == currentUserId;
                      final myInvitation = event.invitations?.firstWhere(
                        (inv) => inv.inviteeId == currentUserId,
                        orElse: () => EventInvitation(
                          id: '',
                          eventId: event.id,
                          inviteeId: currentUserId,
                          inviterId: '',
                          status: InvitationStatus
                              .accepted, // Creator is always going
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                      final status = isCreator
                          ? 'accepted'
                          : (myInvitation?.status.name ?? 'pending');

                      return _EventCard(
                        event: event,
                        currentUserId: currentUserId,
                        status: status,
                        isCreator: isCreator,
                      );
                    }),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatefulWidget {
  final dynamic
  event; // Using dynamic to avoid import issues if Event is not exported here, but ideally should be Event
  final String currentUserId;
  final String status;
  final bool isCreator;

  const _EventCard({
    required this.event,
    required this.currentUserId,
    required this.status,
    required this.isCreator,
  });

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EventProvider>();
      provider.fetchUserName(widget.event.creatorId);
      if (widget.event.groupId != null) {
        provider.fetchGroupName(widget.event.groupId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final creatorName = eventProvider.getUserName(widget.event.creatorId);
    final groupName = widget.event.groupId != null
        ? eventProvider.getGroupName(widget.event.groupId!)
        : null;

    return Card(
      color: Theme.of(context).cardTheme.color,
      shape: Theme.of(context).cardTheme.shape,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.go('/events/${widget.event.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.isCreator
                              ? 'Host'
                              : widget.status == 'accepted'
                              ? 'Going'
                              : widget.status == 'declined'
                              ? 'Not Going'
                              : 'Pending',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: widget.isCreator
                                    ? Theme.of(context).colorScheme.primary
                                    : widget.status == 'accepted'
                                    ? Colors.green
                                    : widget.status == 'declined'
                                    ? Colors.red
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (groupName != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• $groupName',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.event.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (creatorName != null && !widget.isCreator) ...[
                      Text(
                        'Hosted by $creatorName',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      '${widget.event.date.month}/${widget.event.date.day}/${widget.event.date.year} at ${widget.event.date.hour}:${widget.event.date.minute.toString().padLeft(2, '0')} • ${widget.event.location}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(178),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.primary.withAlpha(50),
                ),
                child: const Icon(Icons.event, size: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
