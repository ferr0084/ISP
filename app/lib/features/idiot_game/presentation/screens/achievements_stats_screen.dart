import 'package:app/features/idiot_game/domain/entities/achievement.dart';
import 'package:app/features/idiot_game/presentation/providers/idiot_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AchievementsStatsScreen extends StatefulWidget {
  const AchievementsStatsScreen({super.key});

  @override
  State<AchievementsStatsScreen> createState() =>
      _AchievementsStatsScreenState();
}

class _AchievementsStatsScreenState extends State<AchievementsStatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<IdiotGameProvider>(context, listen: false);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        provider.fetchUserStatsData(userId);
        provider.fetchUserAchievementsData(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats & Achievements')),
      body: Consumer<IdiotGameProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.achievements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final userId = Supabase.instance.client.auth.currentUser?.id;
          if (userId == null) {
            return const Center(child: Text('Please log in to view stats'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              provider.fetchUserStatsData(userId);
              provider.fetchUserAchievementsData(userId);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.userStats != null) ...[
                      _buildStatsHeader(provider),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'All Achievements',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (provider.achievements.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('No achievements found'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.achievements.length,
                        itemBuilder: (context, index) {
                          final achievement = provider.achievements[index];
                          return _AchievementTile(achievement: achievement);
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(IdiotGameProvider provider) {
    final stats = provider.userStats!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Games',
                  value: stats.totalGames.toString(),
                  icon: Icons.videogame_asset,
                  color: Colors.blue,
                ),
                _StatItem(
                  label: 'Win Rate',
                  value: '${(stats.winRate * 100).toStringAsFixed(1)}%',
                  icon: Icons.emoji_events,
                  color: Colors.orange,
                ),
                _StatItem(
                  label: 'Streak',
                  value: '${stats.currentStreak}',
                  icon: stats.streakType == 'win'
                      ? Icons.local_fire_department
                      : Icons.mood_bad,
                  color: stats.streakType == 'win' ? Colors.red : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: achievement.isUnlocked ? Colors.white : Colors.grey[100],
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: achievement.isUnlocked
                ? Colors.amber[100]
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconData(achievement.iconName),
            color: achievement.isUnlocked ? Colors.amber[800] : Colors.grey,
            size: 28,
          ),
        ),
        title: Text(
          achievement.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: achievement.isUnlocked ? Colors.black : Colors.grey[600],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: TextStyle(
                color: achievement.isUnlocked
                    ? Colors.grey[800]
                    : Colors.grey[500],
              ),
            ),
            if (achievement.isUnlocked && achievement.earnedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Earned on ${DateFormat.yMMMd().format(achievement.earnedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: achievement.isUnlocked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'first_win':
        return Icons.emoji_events;
      case 'streak_3':
        return Icons.local_fire_department;
      case 'streak_5':
        return Icons.whatshot;
      case 'participation':
        return Icons.group;
      default:
        return Icons.star;
    }
  }
}
