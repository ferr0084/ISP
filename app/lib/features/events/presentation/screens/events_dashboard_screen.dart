import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  State<EventsDashboardScreen> createState() => _EventsDashboardScreenState();
}

class _EventsDashboardScreenState extends State<EventsDashboardScreen> {
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
      backgroundColor: const Color(0xFF1C2128), // Dark background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2128),
        elevation: 0,
        title: const Text(
          'Events',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
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
                  color: const Color(0xFF2D333B),
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
                            color: _selectedView == 'List' ? Colors.grey[700] : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'List',
                              style: TextStyle(
                                color: _selectedView == 'List' ? Colors.white : Colors.grey[400],
                                fontWeight: FontWeight.bold,
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
                            color: _selectedView == 'Calendar' ? Colors.grey[700] : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Calendar',
                              style: TextStyle(
                                color: _selectedView == 'Calendar' ? Colors.white : Colors.grey[400],
                                fontWeight: FontWeight.bold,
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
              const Text(
                'Pending Invitations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._pendingInvitations.map((invitation) {
                return Card(
                  color: const Color(0xFF2D333B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invitation.status == EventStatus.pending ? 'Pending' : 'Accepted',
                          style: TextStyle(
                            color: invitation.status == EventStatus.pending ? Colors.orange : Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          invitation.title,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invitation.dateTimeLocation,
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Accept',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
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
                                  backgroundColor: Colors.grey[700],
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Decline',
                                  style: TextStyle(color: Colors.grey[300], fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),

              // Upcoming Events Section
              const Text(
                'Upcoming Events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._upcomingEvents.map((event) {
                return Card(
                  color: const Color(0xFF2D333B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                                event.status == EventStatus.pending ? 'Pending' : 'Accepted',
                                style: TextStyle(
                                  color: event.status == EventStatus.pending ? Colors.orange : Colors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                event.title,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${event.dateTimeLocation} • ${event.groupName}',
                                style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}