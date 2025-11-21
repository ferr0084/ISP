import 'package:app/core/error/exceptions.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/features/idiot_game/data/datasources/idiot_game_remote_data_source.dart';
import 'package:app/features/idiot_game/domain/entities/achievement.dart';
import 'package:app/features/idiot_game/domain/entities/game.dart';
import 'package:app/features/idiot_game/domain/entities/game_with_details.dart';
import 'package:app/features/idiot_game/domain/entities/user_stats.dart';
import 'package:app/features/idiot_game/domain/repositories/idiot_game_repository.dart';
import 'package:app/features/profile/domain/entities/user_profile.dart';
import 'package:dartz/dartz.dart';

class IdiotGameRepositoryImpl implements IdiotGameRepository {
  final IdiotGameRemoteDataSource remoteDataSource;

  IdiotGameRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserProfile>>> getPotentialPlayers() async {
    try {
      final players = await remoteDataSource.getPotentialPlayers();
      return Right(players);
    } on ServerException {
      return Left(ServerFailure('Server Error'));
    }
  }

  @override
  Future<Either<Failure, Game>> createGame(
    List<String> userIds,
    String description,
    String loserId,
  ) async {
    try {
      final game = await remoteDataSource.createGame(
        userIds,
        description,
        loserId,
      );
      return Right(game);
    } on ServerException {
      return Left(ServerFailure('Server Error'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getRecentGames() async {
    try {
      final remoteGames = await remoteDataSource.getRecentGames();
      return Right(remoteGames);
    } on ServerException {
      return Left(ServerFailure('Server Error'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGameHistory() async {
    try {
      final remoteGames = await remoteDataSource.getGameHistory();
      return Right(remoteGames);
    } on ServerException {
      return Left(ServerFailure('Server Error'));
    }
  }

  @override
  Future<Either<Failure, GameWithDetails>> getGameDetails(String gameId) async {
    try {
      final gameDetails = await remoteDataSource.getGameDetails(gameId);
      return Right(gameDetails);
    } on ServerException {
      return Left(ServerFailure('Server Error'));
    }
  }

  @override
  Future<Either<Failure, UserStats>> getUserStats(String userId) async {
    try {
      final stats = await remoteDataSource.getUserStats(userId);
      return Right(stats);
    } on ServerException {
      return Left(ServerFailure('Server Error'));
    }
  }

  @override
  Future<Either<Failure, List<Achievement>>> getUserAchievements(
    String userId,
  ) async {
    try {
      final achievements = await remoteDataSource.getUserAchievements(userId);
      return Right(achievements);
    } on ServerException {
      return Left(ServerFailure('Server Error'));
    }
  }
}
