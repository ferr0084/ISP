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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () {
            context.pop();
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer, // Placeholder color
              radius: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Design Team',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).appBarTheme.foregroundColor),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Theme.of(context).appBarTheme.foregroundColor),
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _announcement.content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8)),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to Idiot Game Dashboard
                    },
                    child: Text(
                      'View Dashboard',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).cardTheme.color,
                shape: Theme.of(context).cardTheme.shape,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Idiot',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
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
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
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
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Log New Game',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to Events List
                    },
                    child: Text(
                      'View All',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).cardTheme.color,
                shape: Theme.of(context).cardTheme.shape,
                child: Column(
                  children: _upcomingEvents.map((event) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(event.icon, color: Theme.of(context).colorScheme.onSurface),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                ),
                                Text(
                                  event.subtitle,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            event.time,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to Expense Details
                    },
                    child: Text(
                      'View Details',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).cardTheme.color,
                shape: Theme.of(context).cardTheme.shape,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You are owed',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '\$${_expenseSummary.amountOwed.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_upward, color: Theme.of(context).colorScheme.onPrimary),
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
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Settle Up',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Open Chat
                    },
                    child: Text(
                      'Open Chat',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).cardTheme.color,
                shape: Theme.of(context).cardTheme.shape,
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
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message.content,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}