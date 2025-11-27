import 'package:app/core/error/failures.dart';
import 'package:app/features/idiot_game/domain/entities/achievement.dart';
import 'package:app/features/idiot_game/domain/entities/game.dart';
import 'package:app/features/idiot_game/domain/entities/game_with_details.dart';
import 'package:app/features/idiot_game/domain/entities/user_stats.dart';
import 'package:app/features/profile/domain/entities/user_profile.dart';
import 'package:dartz/dartz.dart';

abstract class IdiotGameRepository {
  Future<Either<Failure, List<UserProfile>>> getPotentialPlayers();
  Future<Either<Failure, Game>> createGame(
    List<String> userIds,
    String description,
    String loserId,
    String? groupId,
    String? imageUrl,
  );
  Future<Either<Failure, String>> uploadImage(String filePath);
  Future<Either<Failure, List<Game>>> getRecentGames();
  Future<Either<Failure, List<Game>>> getGroupGames(String groupId);
  Future<Either<Failure, List<Game>>> getGameHistory();
  Future<Either<Failure, GameWithDetails>> getGameDetails(String gameId);
  Future<Either<Failure, UserStats>> getUserStats(String userId);
  Future<Either<Failure, List<Achievement>>> getUserAchievements(String userId);
  Future<Either<Failure, void>> checkAndUnlockAchievements(String userId);
}
