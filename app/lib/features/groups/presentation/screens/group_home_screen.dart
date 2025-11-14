import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Data Models
class Announcement {
  final String title;
  final String content;
  final String imageUrl;

  Announcement({
    required this.title,
    required this.content,
    required this.imageUrl,
  });
}

class IdiotGameInfo {
  final String currentIdiotName;
  final String currentIdiotAvatar;

  IdiotGameInfo({
    required this.currentIdiotName,
    required this.currentIdiotAvatar,
  });
}

class Event {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  Event({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

class ExpenseSummary {
  final double amountOwed;

  ExpenseSummary({required this.amountOwed});
}

class Message {
  final String senderName;
  final String senderAvatar;
  final String content;

  Message({
    required this.senderName,
    required this.senderAvatar,
    required this.content,
  });
}

class GroupHomeScreen extends StatelessWidget {
  const GroupHomeScreen({super.key});

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

  static final ExpenseSummary _expenseSummary = ExpenseSummary(amountOwed: 15.50);

  static final List<Message> _latestMessages = [
    Message(
      senderName: 'Alex',
      senderAvatar: 'assets/images/avatar_jessica.png', // Placeholder
      content: 'Hey, I\'ve just pushed the latest designs for the onboarding flow. Can everyone take a look?',
    ),
    Message(
      senderName: 'Maria',
      senderAvatar: 'assets/images/avatar_maria.png', // Placeholder
      content: 'Looks great! I\'ll review them this afternoon. Also, reminder about our weekly sync tomorrow.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2128), // Dark background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2128),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.orange[200], // Placeholder color
              radius: 16,
            ),
            const SizedBox(width: 8),
            const Text(
              'Design Team',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: Implement group options
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
                      Colors.black.withOpacity(0.4),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _announcement.content,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
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
                  const Text(
                    'Idiot Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to Idiot Game Dashboard
                    },
                    child: const Text(
                      'View Dashboard',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFF2D333B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Idiot',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(_idiotGameInfo.currentIdiotAvatar),
                            radius: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _idiotGameInfo.currentIdiotName,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const Spacer(),
                          const Icon(Icons.sentiment_dissatisfied, color: Colors.red, size: 30),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Log New Game
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Log New Game',
                            style: TextStyle(color: Colors.white, fontSize: 16),
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
                  const Text(
                    'Upcoming Events',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to Events List
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFF2D333B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _upcomingEvents.map((event) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(event.icon, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                Text(
                                  event.subtitle,
                                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            event.time,
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                  const Text(
                    'Shared Expenses',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to Expense Details
                    },
                    child: const Text(
                      'View Details',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFF2D333B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You are owed',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '\$${_expenseSummary.amountOwed.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_upward, color: Colors.white),
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
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Settle Up',
                            style: TextStyle(color: Colors.white, fontSize: 16),
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
                  const Text(
                    'Latest Messages',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Open Chat
                    },
                    child: const Text(
                      'Open Chat',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFF2D333B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _latestMessages.map((message) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(message.senderAvatar),
                            radius: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.senderName,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message.content,
                                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new action for group
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}