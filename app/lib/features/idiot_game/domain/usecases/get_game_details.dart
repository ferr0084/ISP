import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/idiot_game/domain/entities/game_with_details.dart';
import 'package:app/features/idiot_game/domain/repositories/idiot_game_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetGameDetails implements UseCase<GameWithDetails, GetGameDetailsParams> {
  final IdiotGameRepository repository;

  GetGameDetails(this.repository);

  @override
  Future<Either<Failure, GameWithDetails>> call(
    GetGameDetailsParams params,
  ) async {
    return await repository.getGameDetails(params.gameId);
  }
}

class GetGameDetailsParams extends Equatable {
  final String gameId;

  const GetGameDetailsParams({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}
