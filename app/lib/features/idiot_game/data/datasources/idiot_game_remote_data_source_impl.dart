import 'dart:io';

import 'package:app/core/error/exceptions.dart';
import 'package:app/features/idiot_game/data/datasources/idiot_game_remote_data_source.dart';
import 'package:app/features/idiot_game/data/models/achievement_model.dart';
import 'package:app/features/idiot_game/data/models/game_model.dart';
import 'package:app/features/idiot_game/data/models/game_with_details_model.dart';
import 'package:app/features/idiot_game/data/models/participant_details_model.dart';

import 'package:app/features/idiot_game/data/models/user_stats_model.dart';
import 'package:app/features/profile/domain/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IdiotGameRemoteDataSourceImpl implements IdiotGameRemoteDataSource {
  final SupabaseClient supabaseClient;

  IdiotGameRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<UserProfile>> getPotentialPlayers() async {
    try {
      final response = await supabaseClient.from('profiles').select();
      return (response as List)
          .map((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<GameModel> createGame(
    List<String> userIds,
    String description,
    String loserId,
    String? groupId,
    String? imageUrl,
  ) async {
    try {
      // 1. Create the game
      final gameResponse = await supabaseClient
          .from('idiot_games')
          .insert({
            'description': description,
            'created_by': supabaseClient.auth.currentUser!.id,
            'group_id': groupId,
            'image_url': imageUrl,
          })
          .select()
          .single();

      final gameId = gameResponse['id'] as String;

      // 2. Create Participants
      final participantsData = userIds.map((userId) {
        return {
          'game_id': gameId,
          'user_id': userId,
          'is_loser': userId == loserId,
        };
      }).toList();

      await supabaseClient
          .from('idiot_game_participants')
          .insert(participantsData);

      // 3. Fetch full game details (simplified for now, just returning the game model)
      // In a real app, we might want to fetch the game with participants expanded
      return GameModel.fromJson(gameResponse);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> uploadImage(String filePath) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabaseClient.storage
          .from('idiot-pics')
          .upload(fileName, File(filePath));
      final publicUrl = supabaseClient.storage
          .from('idiot-pics')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<GameModel>> getRecentGames([String? userId]) async {
    try {
      final targetUserId = userId ?? supabaseClient.auth.currentUser!.id;
      final response = await supabaseClient
          .from('idiot_games')
          .select('*, idiot_game_participants(*)')
          .eq('idiot_game_participants.user_id', targetUserId)
          .order('game_date', ascending: false)
          .limit(10);

      // Note: This assumes GameModel.fromJson can handle the nested participants
      // If not, we might need to adjust GameModel or manual parsing
      return (response as List)
          .map((game) => GameModel.fromJson(game))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<GameModel>> getGroupGames(String groupId) async {
    try {
      final response = await supabaseClient
          .from('idiot_games')
          .select('*, idiot_game_participants(*)')
          .eq('group_id', groupId)
          .order('game_date', ascending: false)
          .limit(10);

      return (response as List)
          .map((game) => GameModel.fromJson(game))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<GameModel>> getGameHistory() async {
    try {
      final response = await supabaseClient
          .from('idiot_games')
          .select('*, idiot_game_participants(*)')
          .order('game_date', ascending: false)
          .limit(50); // Fetch more games for history

      return (response as List)
          .map((game) => GameModel.fromJson(game))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<GameWithDetailsModel> getGameDetails(String gameId) async {
    try {
      final response = await supabaseClient
          .from('idiot_games')
          .select('*, idiot_game_participants(*, profiles!user_id(*))')
          .eq('id', gameId)
          .single();

      // Parse the response
      final gameData = response;
      final participantsData =
          gameData['idiot_game_participants'] as List<dynamic>;

      // Convert to models
      final game = GameModel.fromJson(gameData);
      final participants = participantsData
          .map(
            (p) => ParticipantDetailsModel.fromJson(p as Map<String, dynamic>),
          )
          .toList();

      return GameWithDetailsModel(game: game, participants: participants);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<UserStatsModel> getUserStats(String userId) async {
    try {
      // Fetch all games participated by the user, ordered by date descending
      final response = await supabaseClient
          .from('idiot_game_participants')
          .select('is_loser, idiot_games!inner(game_date)')
          .eq('user_id', userId)
          .order('idiot_games(game_date)', ascending: false);

      final List<dynamic> games = response as List<dynamic>;
      final int totalGames = games.length;
      final int losses = games.where((g) => g['is_loser'] as bool).length;
      final int wins = totalGames - losses;
      final double winRate = totalGames > 0 ? wins / totalGames : 0.0;

      // Calculate streak
      int currentStreak = 0;
      String streakType = 'none';

      if (games.isNotEmpty) {
        final firstGameLoser = games.first['is_loser'] as bool;
        streakType = firstGameLoser ? 'loss' : 'win';

        for (var game in games) {
          if ((game['is_loser'] as bool) == firstGameLoser) {
            currentStreak++;
          } else {
            break;
          }
        }
      }

      return UserStatsModel(
        totalGames: totalGames,
        winRate: winRate,
        currentStreak: currentStreak,
        streakType: streakType,
      );
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<AchievementModel>> getUserAchievements(String userId) async {
    try {
      // Fetch all achievements
      final achievementsResponse = await supabaseClient
          .from('idiot_achievements')
          .select();

      // Fetch user's unlocked achievements
      final userAchievementsResponse = await supabaseClient
          .from('idiot_user_achievements')
          .select('achievement_id, earned_at')
          .eq('user_id', userId);

      final userAchievementsMap = {
        for (var ua in (userAchievementsResponse as List<dynamic>))
          ua['achievement_id'] as String: DateTime.parse(
            ua['earned_at'] as String,
          ),
      };

      return (achievementsResponse as List<dynamic>).map((json) {
        final id = json['id'] as String;
        final earnedAt = userAchievementsMap[id];

        return AchievementModel.fromJson({
          ...json,
          'earned_at': earnedAt?.toIso8601String(),
          'is_unlocked': earnedAt != null,
        });
      }).toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> checkAndUnlockAchievements(String userId) async {
    try {
      // Get user's current achievements
      final currentAchievements = await supabaseClient
          .from('idiot_user_achievements')
          .select('achievement_id')
          .eq('user_id', userId);

      final unlockedIds = currentAchievements
          .map((a) => a['achievement_id'] as int)
          .toSet();

      // Get all achievements
      final allAchievements = await supabaseClient
          .from('idiot_achievements')
          .select('*');

      // Get user's game stats
      final userGames = await supabaseClient
          .from('idiot_game_participants')
          .select('is_loser, idiot_games!inner(game_date)')
          .eq('user_id', userId)
          .order('idiot_games(game_date)', ascending: false);

      final totalGames = userGames.length;

      // Get recent games for streak
      final recentGames = userGames.take(10).toList();
      final currentStreak = _calculateCurrentStreak(recentGames);

      // Check each achievement
      for (final achievement in allAchievements) {
        final id = achievement['id'] as int;
        final name = achievement['name'] as String;

        if (unlockedIds.contains(id)) continue;

        bool shouldUnlock = false;

        switch (name) {
          case 'Century Club':
            shouldUnlock = totalGames >= 100;
            break;
          case 'Idiot King':
            // TODO: Implement check for highest losses
            shouldUnlock = false; // Placeholder
            break;
          case 'Survivor':
            shouldUnlock = currentStreak >= 10;
            break;
          case 'Comeback Kid':
            // Check if last game was loser and this game is not
            if (recentGames.length >= 2) {
              final lastGame = recentGames[0];
              final secondLastGame = recentGames[1];
              shouldUnlock =
                  (secondLastGame['is_loser'] as bool) &&
                  !(lastGame['is_loser'] as bool);
            }
            break;
          case 'Pat Trick':
            // Check if last 5 games were all losses
            if (recentGames.length >= 5) {
              shouldUnlock = recentGames
                  .take(5)
                  .every((g) => g['is_loser'] as bool);
            }
            break;
          // Other achievements not implemented yet
        }

        if (shouldUnlock) {
          await supabaseClient.from('idiot_user_achievements').insert({
            'user_id': userId,
            'achievement_id': id,
          });
        }
      }
    } catch (e) {
      throw ServerException();
    }
  }

  int _calculateCurrentStreak(List<dynamic> games) {
    int streak = 0;
    for (final game in games) {
      if (!(game['is_loser'] as bool)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
