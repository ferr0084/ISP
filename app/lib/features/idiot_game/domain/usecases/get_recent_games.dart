import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/idiot_game/domain/entities/game.dart';
import 'package:app/features/idiot_game/domain/repositories/idiot_game_repository.dart';
import 'package:dartz/dartz.dart';

class GetRecentGames implements UseCase<List<Game>, NoParams> {
  final IdiotGameRepository repository;

  GetRecentGames(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(NoParams params) async {
    return await repository.getRecentGames();
  }
}
