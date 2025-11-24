import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/friend_status.dart';

abstract class FriendStatusRepository {
  Future<Either<Failure, List<FriendStatus>>> getFriendStatuses();
}
