import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/friend_status.dart';
import '../repositories/friend_status_repository.dart';

class GetFriendStatuses {
  final FriendStatusRepository repository;

  GetFriendStatuses(this.repository);

  Future<Either<Failure, List<FriendStatus>>> call() async {
    return await repository.getFriendStatuses();
  }
}
