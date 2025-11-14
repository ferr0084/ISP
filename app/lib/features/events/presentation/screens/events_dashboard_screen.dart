import 'package:flutter/material.dart';

// Data Models
enum EventStatus { pending, accepted }

class EventInvitation {
  final String title;
  final String dateTimeLocation;
  final EventStatus status;

  EventInvitation({
    required this.title,
    required this.dateTimeLocation,
    this.status = EventStatus.pending,
  });
}

class UpcomingEvent {
  final String title;
  final String dateTimeLocation;
  final String groupName;
  final String imageUrl;
  final EventStatus status;

  UpcomingEvent({
    required this.title,
    required this.dateTimeLocation,
    required this.groupName,
    required this.imageUrl,
    this.status = EventStatus.accepted,
  });
}

class EventsDashboardScreen extends StatefulWidget {
  const EventsDashboardScreen({super.key});

  @override
  EventsDashboardScreenState createState() => EventsDashboardScreenState();
}

class EventsDashboardScreenState extends State<EventsDashboardScreen> {
  String _selectedView = 'List'; // State for segmented control

  // Dummy Data
  static final List<EventInvitation> _pendingInvitations = [
    EventInvitation(
      title: 'Quarterly Design Review',
      dateTimeLocation: 'Fri, Nov 15, 2:00 PM • Design Team Chat',
    ),
  ];

  static final List<UpcomingEvent> _upcomingEvents = [
    UpcomingEvent(
      title: 'Team Sync & Brainstorm',
      dateTimeLocation: 'Mon, Oct 28, 10:00 AM',
      groupName: 'Product Crew',
      imageUrl: 'assets/images/group_design_team.png', // Placeholder
    ),
    UpcomingEvent(
      title: 'Project Phoenix Kick-off',
      dateTimeLocation: 'Wed, Oct 30, 9:00 AM',
      groupName: 'Engineering All-Hands',
      imageUrl: 'assets/images/group_project_phoenix.png', // Placeholder
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              // TODO: Implement add event functionality
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
              ..._pendingInvitations.map((invitation) {
                return Card(
                  color: Theme.of(context).cardTheme.color,
                  shape: Theme.of(context).cardTheme.shape,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invitation.status == EventStatus.pending
                              ? 'Pending'
                              : 'Accepted',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: invitation.status == EventStatus.pending
                                    ? Colors.orange
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          invitation.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invitation.dateTimeLocation,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface
                                    .withAlpha(178), // 0.7 * 255 = 178.5
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Accept invitation
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
                                  'Accept',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Decline invitation
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Decline',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha(
                                              178,
                                            ), // 0.7 * 255 = 178.5
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Upcoming Events Section
              Text(
                'Upcoming Events',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ..._upcomingEvents.map((event) {
                return Card(
                  color: Theme.of(context).cardTheme.color,
                  shape: Theme.of(context).cardTheme.shape,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.status == EventStatus.pending
                                    ? 'Pending'
                                    : 'Accepted',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: event.status == EventStatus.pending
                                          ? Colors.orange
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                event.title,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${event.dateTimeLocation} • ${event.groupName}',
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
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage(event.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
