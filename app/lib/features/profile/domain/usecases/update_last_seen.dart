import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class UpdateLastSeen {
  final ProfileRepository repository;

  UpdateLastSeen(this.repository);

  Future<Either<Failure, void>> call(String userId) async {
    return await repository.updateLastSeen(userId);
  }
}
