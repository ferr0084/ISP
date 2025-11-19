import 'package:app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class InvitationRepository {
  Future<Either<Failure, void>> sendGroupInvite({
    required String inviterId,
    required String inviteeEmail,
    required String groupId,
  });

  Future<void> acceptInvite(String token, String userId);
}
