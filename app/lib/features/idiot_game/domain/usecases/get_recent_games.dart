import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/idiot_game/domain/entities/game.dart';
import 'package:app/features/idiot_game/domain/repositories/idiot_game_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetRecentGames implements UseCase<List<Game>, GetRecentGamesParams> {
  final IdiotGameRepository repository;

  GetRecentGames(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetRecentGamesParams params) async {
    return await repository.getRecentGames(params.userId);
  }
}

class GetRecentGamesParams extends Equatable {
  final String? userId;

  const GetRecentGamesParams({this.userId});

  @override
  List<Object?> get props => [userId];
}
