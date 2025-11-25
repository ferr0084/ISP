import 'package:app/core/error/exceptions.dart';
import 'package:app/features/idiot_game/data/datasources/idiot_game_remote_data_source.dart';
import 'package:app/features/idiot_game/data/models/achievement_model.dart';
import 'package:app/features/idiot_game/data/models/game_model.dart';
import 'package:app/features/idiot_game/data/models/game_with_details_model.dart';

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
  ) async {
    try {
      // 1. Create the game
      final gameResponse = await supabaseClient
          .from('idiot_games')
          .insert({
            'description': description,
            'created_by': supabaseClient.auth.currentUser!.id,
            'group_id': groupId,
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
  Future<List<GameModel>> getRecentGames() async {
    try {
      final response = await supabaseClient
          .from('idiot_games')
          .select('*, idiot_game_participants(*)')
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
          .select('*, idiot_game_participants(*, profiles(*))')
          .eq('id', gameId)
          .single();

      return GameWithDetailsModel.fromJson(response);
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
}
