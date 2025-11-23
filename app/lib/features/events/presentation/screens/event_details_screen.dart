import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/event_invitation.dart';
import '../providers/event_provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../contacts/domain/repositories/contact_repository.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Map<String, String> _attendeeNames = {};

  @override
  void initState() {
    super.initState();
    // Load event details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEventDetails(widget.eventId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchAttendeeNames();
  }

  Future<void> _fetchAttendeeNames() async {
    final eventProvider = context.watch<EventProvider>();
    final invitations = eventProvider.currentEventInvitations;

    if (invitations.isEmpty) return;

    final contactRepo = sl<ContactRepository>();
    final newNames = <String, String>{};

    for (final invitation in invitations) {
      if (!_attendeeNames.containsKey(invitation.inviteeId)) {
        try {
          final contact = await contactRepo.getContact(invitation.inviteeId);
          newNames[invitation.inviteeId] = contact.name;
        } catch (e) {
          // Ignore error, keep ID or default
        }
      }
    }

    if (newNames.isNotEmpty && mounted) {
      setState(() {
        _attendeeNames.addAll(newNames);
      });
    }

    // Also fetch creator name
    if (eventProvider.currentEvent != null) {
      final creatorId = eventProvider.currentEvent!.creatorId;
      if (!_attendeeNames.containsKey(creatorId)) {
        try {
          final contact = await contactRepo.getContact(creatorId);
          if (mounted) {
            setState(() {
              _attendeeNames[creatorId] = contact.name;
            });
          }
        } catch (e) {
          // Ignore
        }
      }
    }

    // Fetch group name
    if (eventProvider.currentEvent != null &&
        eventProvider.currentEvent!.groupId != null) {
      final groupId = eventProvider.currentEvent!.groupId!;
      if (!_attendeeNames.containsKey(groupId)) {
        // Reusing map for group name for simplicity, or add new state var
        // Actually better to use provider's method or add a local state var
        // Let's use the provider's method since we added it
        eventProvider.fetchGroupName(groupId);
      }
    }
  }

  Future<void> _respondToInvitation(
    BuildContext context,
    String invitationId,
    InvitationStatus status, {
    DateTime? suggestedDate,
  }) async {
    final success = await context
        .read<EventProvider>()
        .respondToEventInvitation(
          invitationId,
          status,
          suggestedDate: suggestedDate,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Response recorded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<EventProvider>().error ??
                'Failed to respond to invitation',
          ),
        ),
      );
    }
  }

  Future<void> _suggestNewTime(
    BuildContext context,
    String invitationId,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null && mounted) {
        final suggestedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        await _respondToInvitation(
          context,
          invitationId,
          InvitationStatus.declined,
          suggestedDate: suggestedDateTime,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final event = eventProvider.currentEvent;
    final invitations = eventProvider.currentEventInvitations;

    // Find current user's invitation
    final currentUserId = sl<SupabaseClient>().auth.currentUser!.id;

    final myInvitation = invitations
        .where((inv) => inv.inviteeId == currentUserId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (event?.creatorId == currentUserId)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navigate to edit event screen
              },
            ),
        ],
      ),
      body: eventProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : event == null
          ? const Center(child: Text('Event not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    event.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),

                  // Group Name
                  if (event.groupId != null) ...[
                    Builder(
                      builder: (context) {
                        final groupName = eventProvider.getGroupName(
                          event.groupId!,
                        );
                        if (groupName != null) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              'Group: $groupName',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Date and Time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${event.date.month}/${event.date.day}/${event.date.year} at ${event.date.hour}:${event.date.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  if (event.location.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          event.location,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  if (event.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Attendees Section
                  Text(
                    'Attendees',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Accepted (and Creator)
                  Builder(
                    builder: (context) {
                      final accepted = invitations
                          .where(
                            (inv) => inv.status == InvitationStatus.accepted,
                          )
                          .toList();

                      // Add creator to the list if not already there (though they shouldn't have an invitation usually)
                      // We'll manually create a widget for the creator
                      final creatorId = event.creatorId;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Going',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          // Creator Card
                          Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  _attendeeNames[creatorId]
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      '?',
                                ),
                              ),
                              title: Text(
                                '${_attendeeNames[creatorId] ?? 'User $creatorId'} (Host)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          ...accepted.map(
                            (invitation) => Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    _attendeeNames[invitation.inviteeId]
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        '?',
                                  ),
                                ),
                                title: Text(
                                  _attendeeNames[invitation.inviteeId] ??
                                      'User ${invitation.inviteeId}',
                                ),
                                subtitle: invitation.suggestedDate != null
                                    ? Text(
                                        'Suggested: ${invitation.suggestedDate!.month}/${invitation.suggestedDate!.day}/${invitation.suggestedDate!.year}',
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),

                  // Pending
                  ..._buildAttendeeSection(
                    'Pending',
                    invitations.where(
                      (inv) => inv.status == InvitationStatus.pending,
                    ),
                  ),

                  // Declined
                  ..._buildAttendeeSection(
                    'Not Going',
                    invitations.where(
                      (inv) => inv.status == InvitationStatus.declined,
                    ),
                  ),

                  // Host Message (if user is creator)
                  if (event.creatorId == currentUserId) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Your Response',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 16),
                            Text(
                              'You are hosting this event',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Response Section (only show if user has an invitation)
                  if (myInvitation != null) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Your Response',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Status: ${myInvitation.status.name.toUpperCase()}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (myInvitation.suggestedDate != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Suggested time: ${myInvitation.suggestedDate!.month}/${myInvitation.suggestedDate!.day}/${myInvitation.suggestedDate!.year} at ${myInvitation.suggestedDate!.hour}:${myInvitation.suggestedDate!.minute.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        myInvitation.status ==
                                            InvitationStatus.accepted
                                        ? null
                                        : () => _respondToInvitation(
                                            context,
                                            myInvitation.id,
                                            InvitationStatus.accepted,
                                          ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Accept'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        myInvitation.status ==
                                            InvitationStatus.declined
                                        ? null
                                        : () => _suggestNewTime(
                                            context,
                                            myInvitation.id,
                                          ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                    ),
                                    child: const Text('Suggest Time'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        myInvitation.status ==
                                            InvitationStatus.declined
                                        ? null
                                        : () => _respondToInvitation(
                                            context,
                                            myInvitation.id,
                                            InvitationStatus.declined,
                                          ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  List<Widget> _buildAttendeeSection(
    String title,
    Iterable<EventInvitation> attendees,
  ) {
    if (attendees.isEmpty) return [];

    return [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      ...attendees.map(
        (invitation) => Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                _attendeeNames[invitation.inviteeId]
                        ?.substring(0, 1)
                        .toUpperCase() ??
                    '?',
              ),
            ),
            title: Text(
              _attendeeNames[invitation.inviteeId] ??
                  'User ${invitation.inviteeId}',
            ),
            subtitle: invitation.suggestedDate != null
                ? Text(
                    'Suggested: ${invitation.suggestedDate!.month}/${invitation.suggestedDate!.day}/${invitation.suggestedDate!.year}',
                  )
                : null,
          ),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }
}
