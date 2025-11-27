import 'package:app/core/di/service_locator.dart';
import 'package:app/core/widgets/user_avatar.dart';
import 'package:app/features/idiot_game/domain/entities/achievement.dart';
import 'package:app/features/idiot_game/presentation/providers/idiot_game_provider.dart';
import 'package:app/features/profile/domain/entities/profile.dart';
import 'package:app/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IdiotGameDashboardScreen extends StatefulWidget {
  final String? userId;

  const IdiotGameDashboardScreen({super.key, this.userId});

  @override
  State<IdiotGameDashboardScreen> createState() =>
      _IdiotGameDashboardScreenState();
}

class _IdiotGameDashboardScreenState extends State<IdiotGameDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProfileProvider>(
      create: (_) {
        final provider = sl<UserProfileProvider>();
        final userId =
            widget.userId ?? Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          provider.fetchProfile(userId);
        }
        return provider;
      },
      child: ChangeNotifierProvider<IdiotGameProvider>(
        create: (_) {
          final provider = sl<IdiotGameProvider>();
          final userId =
              widget.userId ?? Supabase.instance.client.auth.currentUser?.id;
          if (userId != null) {
            provider.fetchRecentGamesData(userId);
            provider.fetchUserStatsData(userId);
            provider.fetchUserAchievementsData(userId);
          }
          return provider;
        },
        child: Consumer2<IdiotGameProvider, UserProfileProvider>(
          builder: (context, idiotGameProvider, userProfileProvider, child) {
            if (idiotGameProvider.isLoading &&
                idiotGameProvider.recentGames.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (idiotGameProvider.errorMessage != null &&
                idiotGameProvider.recentGames.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(idiotGameProvider.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final userId =
                            widget.userId ??
                            Supabase.instance.client.auth.currentUser?.id;
                        if (userId != null) {
                          idiotGameProvider.fetchRecentGamesData(userId);
                          idiotGameProvider.fetchUserStatsData(userId);
                          idiotGameProvider.fetchUserAchievementsData(userId);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                title: const Text('Idiot Tracker'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: () {
                      context.push('/idiot-game/history');
                    },
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  final userId =
                      widget.userId ??
                      Supabase.instance.client.auth.currentUser?.id;
                  if (userId != null) {
                    idiotGameProvider.fetchRecentGamesData(userId);
                    idiotGameProvider.fetchUserStatsData(userId);
                    idiotGameProvider.fetchUserAchievementsData(userId);
                    userProfileProvider.fetchProfile(userId);
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Section
                        if (userProfileProvider.profile != null) ...[
                          Center(
                            child: _buildProfileSection(
                              userProfileProvider.profile!,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Stats Section
                        if (idiotGameProvider.userStats != null) ...[
                          _buildStatsSection(idiotGameProvider),
                          const SizedBox(height: 24),
                        ],
                        // Achievements Section
                        if (idiotGameProvider.achievements.isNotEmpty) ...[
                          _buildAchievementsSection(
                            idiotGameProvider.achievements,
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Recent Games Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Games',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.push('/idiot-game/history');
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (idiotGameProvider.recentGames.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.games_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No games yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap the + button to log your first game',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: idiotGameProvider.recentGames.length > 5
                                ? 5
                                : idiotGameProvider.recentGames.length,
                            itemBuilder: (context, index) {
                              final game = idiotGameProvider.recentGames[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(game.description ?? 'Game'),
                                  subtitle: Text(
                                    game.gameDate.toString().split(' ')[0],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    context.push(
                                      '/idiot-game/details/${game.id}',
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  context.push('/idiot-game/new');
                },
                child: const Icon(Icons.add),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileSection(Profile profile) {
    return Column(
      children: [
        UserAvatar(
          avatarUrl: profile.avatarUrl,
          name: profile.fullName,
          radius: 60,
          defaultAssetImage: 'assets/images/avatar_s.png',
        ),
        const SizedBox(height: 16.0),
        Text(
          profile.fullName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (profile.nickname != null) ...[
          const SizedBox(height: 8.0),
          Text(
            profile.nickname!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsSection(IdiotGameProvider provider) {
    final stats = provider.userStats!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total Games',
                value: stats.totalGames.toString(),
                icon: Icons.videogame_asset,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Win Rate',
                value: '${(stats.winRate * 100).toStringAsFixed(1)}%',
                icon: Icons.emoji_events,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: 'Current Streak',
          value: '${stats.currentStreak} ${stats.streakType}',
          icon: stats.streakType == 'Win'
              ? Icons.local_fire_department
              : Icons.mood_bad,
          color: stats.streakType == 'Win' ? Colors.red : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(List<Achievement> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                context.push('/idiot-game/stats');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _AchievementBadge(achievement: achievement),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;

  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: achievement.isUnlocked
                ? Colors.amber[100]
                : Colors.grey[200],
            shape: BoxShape.circle,
            border: Border.all(
              color: achievement.isUnlocked ? Colors.amber : Colors.grey,
              width: 2,
            ),
          ),
          child: Icon(
            // Map icon name to IconData or use a default
            _getIconData(achievement.iconName),
            color: achievement.isUnlocked ? Colors.amber[800] : Colors.grey,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            achievement.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: achievement.isUnlocked ? Colors.black : Colors.grey,
              fontWeight: achievement.isUnlocked
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
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
