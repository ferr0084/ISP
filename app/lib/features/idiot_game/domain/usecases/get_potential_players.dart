import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/idiot_game/domain/repositories/idiot_game_repository.dart';
import 'package:app/features/profile/domain/entities/user_profile.dart';
import 'package:dartz/dartz.dart';

class GetPotentialPlayers implements UseCase<List<UserProfile>, NoParams> {
  final IdiotGameRepository repository;

  GetPotentialPlayers(this.repository);

  @override
  Future<Either<Failure, List<UserProfile>>> call(NoParams params) async {
    return await repository.getPotentialPlayers();
  }
}
