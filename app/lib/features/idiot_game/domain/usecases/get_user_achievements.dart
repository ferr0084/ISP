import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/idiot_game/domain/entities/achievement.dart';
import 'package:app/features/idiot_game/domain/repositories/idiot_game_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetUserAchievements
    implements UseCase<List<Achievement>, GetUserAchievementsParams> {
  final IdiotGameRepository repository;

  GetUserAchievements(this.repository);

  @override
  Future<Either<Failure, List<Achievement>>> call(
    GetUserAchievementsParams params,
  ) async {
    return await repository.getUserAchievements(params.userId);
  }
}

class GetUserAchievementsParams extends Equatable {
  final String userId;

  const GetUserAchievementsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
