import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/event_invitation.dart';
import '../providers/event_provider.dart';
import 'edit_event_screen.dart';
import 'event_expenses_screen.dart';
import '../providers/event_expense_provider.dart';
import 'add_expense_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load event details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEventDetails(widget.eventId);
    });
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

  Future<void> _confirmDelete(BuildContext context, String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<EventProvider>().deleteExistingEvent(
        eventId,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );
        context.pop(); // Go back to previous screen
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<EventProvider>().error ?? 'Failed to delete',
            ),
          ),
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
          IconButton(
            icon: const Icon(Icons.attach_money),
            tooltip: 'Expenses',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EventExpensesScreen(eventId: widget.eventId),
                ),
              );
            },
          ),
          if (event?.creatorId == currentUserId) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditEventScreen(event: event!),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context, event!.id),
            ),
          ],
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
                                  eventProvider
                                          .getUserName(creatorId)
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      '?',
                                ),
                              ),
                              title: Text(
                                '${eventProvider.getUserName(creatorId) ?? 'User $creatorId'} (Host)',
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
                                    eventProvider
                                            .getUserName(invitation.inviteeId)
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        '?',
                                  ),
                                ),
                                title: Text(
                                  eventProvider.getUserName(
                                        invitation.inviteeId,
                                      ) ??
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
                    eventProvider,
                  ),

                  // Declined
                  ..._buildAttendeeSection(
                    'Not Going',
                    invitations.where(
                      (inv) => inv.status == InvitationStatus.declined,
                    ),
                    eventProvider,
                  ),

                  // Expenses Section
                  const SizedBox(height: 32),
                  Text(
                    'Expenses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ChangeNotifierProvider(
                    create: (_) =>
                        sl<EventExpenseProvider>()
                          ..loadExpenses(widget.eventId),
                    child: Consumer<EventExpenseProvider>(
                      builder: (context, expenseProvider, child) {
                        if (expenseProvider.isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final expenses = expenseProvider.expenses;
                        final hasExpenses = expenses.isNotEmpty;

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!hasExpenses)
                                  const Text('No expenses yet')
                                else ...[
                                  ...expenses.take(3).map((expense) {
                                    // Check if current user owes money on this expense
                                    final userParticipant = expense.participants
                                        ?.where(
                                          (p) => p.userId == currentUserId,
                                        )
                                        .firstOrNull;
                                    final userOwes = userParticipant != null;
                                    final userIsPayer =
                                        expense.payerId == currentUserId;

                                    return Card(
                                      margin: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    expense.description,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                                Text(
                                                  '\$${expense.amount.toStringAsFixed(2)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            if (userOwes && !userIsPayer) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                'You owe: \$${userParticipant.amountOwed.toStringAsFixed(2)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Colors.orange,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: OutlinedButton.icon(
                                                      onPressed: () async {
                                                        // Create settlement for this user's share
                                                        try {
                                                          await expenseProvider.settleUp(
                                                            eventId:
                                                                widget.eventId,
                                                            payerId:
                                                                currentUserId,
                                                            payeeId:
                                                                expense.payerId,
                                                            amount:
                                                                userParticipant
                                                                    .amountOwed,
                                                          );
                                                          if (context.mounted) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'Payment recorded!',
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        } catch (e) {
                                                          if (context.mounted) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Error: $e',
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      },
                                                      icon: const Icon(
                                                        Icons.payment,
                                                        size: 16,
                                                      ),
                                                      label: const Text(
                                                        'Pay My Share',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      style: OutlinedButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  OutlinedButton.icon(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text(
                                                            'Report Issue',
                                                          ),
                                                          content: const Text(
                                                            'This feature is coming soon. You\'ll be able to report issues with expenses.',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                              child: const Text(
                                                                'OK',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.flag,
                                                      size: 16,
                                                    ),
                                                    label: const Text(
                                                      'Dispute',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  if (expenses.length > 3) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '+ ${expenses.length - 3} more',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangeNotifierProvider.value(
                                                    value: expenseProvider,
                                                    child: AddExpenseScreen(
                                                      eventId: widget.eventId,
                                                    ),
                                                  ),
                                            ),
                                          );
                                        },
                                        child: const Text('Add Expense'),
                                      ),
                                    ),
                                    if (hasExpenses) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EventExpensesScreen(
                                                      eventId: widget.eventId,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: const Text('View All'),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
    EventProvider eventProvider,
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
                eventProvider
                        .getUserName(invitation.inviteeId)
                        ?.substring(0, 1)
                        .toUpperCase() ??
                    '?',
              ),
            ),
            title: Text(
              eventProvider.getUserName(invitation.inviteeId) ??
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
