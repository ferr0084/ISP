import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/idiot_game/domain/entities/game.dart';
import 'package:app/features/idiot_game/domain/repositories/idiot_game_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetGroupGames implements UseCase<List<Game>, GetGroupGamesParams> {
  final IdiotGameRepository repository;

  GetGroupGames(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetGroupGamesParams params) async {
    return await repository.getGroupGames(params.groupId);
  }
}

class GetGroupGamesParams extends Equatable {
  final String groupId;

  const GetGroupGamesParams({required this.groupId});

  @override
  List<Object> get props => [groupId];
}
