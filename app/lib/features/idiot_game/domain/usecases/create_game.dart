import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/idiot_game/domain/entities/game.dart';
import 'package:app/features/idiot_game/domain/repositories/idiot_game_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class CreateGame implements UseCase<Game, CreateGameParams> {
  final IdiotGameRepository repository;

  CreateGame(this.repository);

  @override
  Future<Either<Failure, Game>> call(CreateGameParams params) async {
    return await repository.createGame(
      params.userIds,
      params.description,
      params.loserId,
      params.groupId,
      params.imageUrl,
    );
  }
}

class CreateGameParams extends Equatable {
  final List<String> userIds;
  final String loserId;
  final String description;
  final String? groupId;
  final String? imageUrl;

  const CreateGameParams({
    required this.userIds,
    required this.loserId,
    required this.description,
    this.groupId,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [userIds, loserId, description, groupId, imageUrl];
}
