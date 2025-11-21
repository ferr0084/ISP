import 'package:app/features/idiot_game/data/models/achievement_model.dart';
import 'package:app/features/idiot_game/data/models/game_model.dart';
import 'package:app/features/idiot_game/data/models/game_with_details_model.dart';
import 'package:app/features/idiot_game/data/models/user_stats_model.dart';
import 'package:app/features/profile/domain/entities/user_profile.dart';

abstract class IdiotGameRemoteDataSource {
  Future<List<UserProfile>> getPotentialPlayers();
  Future<GameModel> createGame(
    List<String> userIds,
    String description,
    String loserId,
  );
  Future<List<GameModel>> getRecentGames();
  Future<List<GameModel>> getGameHistory();
  Future<GameWithDetailsModel> getGameDetails(String gameId);
  Future<UserStatsModel> getUserStats(String userId);
  Future<List<AchievementModel>> getUserAchievements(String userId);
}
