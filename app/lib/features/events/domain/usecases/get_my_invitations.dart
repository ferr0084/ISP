import 'package:app/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/event_invitation.dart';
import '../repositories/event_repository.dart';

class GetMyInvitations {
  final EventRepository repository;

  GetMyInvitations(this.repository);

  Stream<Either<Failure, List<EventInvitation>>> call(String userId) {
    return repository.getMyInvitations(userId);
  }
}
