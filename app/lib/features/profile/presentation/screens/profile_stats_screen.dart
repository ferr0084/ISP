import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/user_provider.dart';

class ProfileStatsScreen extends StatelessWidget {
  const ProfileStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Stats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final profile = userProvider.profile;
          final stats = profile?.stats;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  'Game Statistics',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                _buildStatCard(
                  'Games Played',
                  stats?['gamesPlayed']?.toString() ?? '0',
                ),
                _buildStatCard(
                  'Games Won',
                  stats?['gamesWon']?.toString() ?? '0',
                ),
                _buildStatCard(
                  'Games Lost',
                  stats?['gamesLost']?.toString() ?? '0',
                ),
                _buildStatCard(
                  'Current Streak',
                  stats?['currentStreak']?.toString() ?? '0',
                ),
                _buildStatCard(
                  'Longest Winning Streak',
                  stats?['longestStreak']?.toString() ?? '0',
                ),
                const SizedBox(height: 32.0),
                const Text(
                  'Achievements',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                if (profile?.badges != null && profile!.badges!.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: profile.badges!
                        .map(
                          (badge) => Chip(
                            label: Text(badge),
                            backgroundColor: Colors.amber,
                          ),
                        )
                        .toList(),
                  )
                else
                  const Text('No achievements yet.'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
