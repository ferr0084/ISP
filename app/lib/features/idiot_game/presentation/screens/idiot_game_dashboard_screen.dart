import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Data Models
class CurrentIdiot {
  final String name;
  final String avatarAsset;
  final int losses;
  final String lastLostDate;

  CurrentIdiot({
    required this.name,
    required this.avatarAsset,
    required this.losses,
    required this.lastLostDate,
  });
}

class RecentGame {
  final String loserAvatarAsset;
  final String description;
  final String date;

  RecentGame({
    required this.loserAvatarAsset,
    required this.description,
    required this.date,
  });
}

class IdiotGameDashboardScreen extends StatelessWidget {
  const IdiotGameDashboardScreen({super.key});

  // Dummy Data
  static final CurrentIdiot _currentIdiot = CurrentIdiot(
    name: 'Alex Johnson',
    avatarAsset: 'assets/images/avatar_chris.png', // Placeholder
    losses: 5,
    lastLostDate: 'July 23, 2024',
  );

  static final List<RecentGame> _recentGames = [
    RecentGame(
      loserAvatarAsset: 'assets/images/avatar_jessica.png', // Placeholder
      description: 'Alex Johnson lost a game with Sarah L. and Mike P.',
      date: 'Jul 23',
    ),
    RecentGame(
      loserAvatarAsset: 'assets/images/avatar_maria.png', // Placeholder
      description: 'Sarah Lee lost a game with Alex J. and Mike P.',
      date: 'Jul 21',
    ),
    RecentGame(
      loserAvatarAsset: 'assets/images/avatar_david.png', // Placeholder
      description: 'Mike Perez lost a game with Sarah L. and Alex J.',
      date: 'Jul 19',
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
          'Idiot Tracker',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              // TODO: Implement view stats functionality
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
              const Text(
                'Current Idiot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            _currentIdiot.avatarAsset,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loser ${_currentIdiot.losses} times',
                        style: const TextStyle(color: Colors.orange, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentIdiot.name,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Is the Current Idiot',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                      Text(
                        'Lost on ${_currentIdiot.lastLostDate}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: View All Players
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View All Players',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Games',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: View All Recent Games
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._recentGames.map((game) {
                return Card(
                  color: const Color(0xFF2D333B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(game.loserAvatarAsset),
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            game.description,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Text(
                          game.date,
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement log new game functionality
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}