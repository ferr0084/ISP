import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:dartz/dartz.dart';

import '../repositories/idiot_game_repository.dart';

class CheckAchievements implements UseCase<void, String> {
  final IdiotGameRepository repository;

  CheckAchievements(this.repository);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    return await repository.checkAndUnlockAchievements(userId);
  }
}