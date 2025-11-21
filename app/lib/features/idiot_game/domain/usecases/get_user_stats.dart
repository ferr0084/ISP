import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/idiot_game/domain/entities/user_stats.dart';
import 'package:app/features/idiot_game/domain/repositories/idiot_game_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetUserStats implements UseCase<UserStats, GetUserStatsParams> {
  final IdiotGameRepository repository;

  GetUserStats(this.repository);

  @override
  Future<Either<Failure, UserStats>> call(GetUserStatsParams params) async {
    return await repository.getUserStats(params.userId);
  }
}

class GetUserStatsParams extends Equatable {
  final String userId;

  const GetUserStatsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
