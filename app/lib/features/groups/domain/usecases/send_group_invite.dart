import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/groups/domain/repositories/invitation_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SendGroupInvite implements UseCase<void, SendGroupInviteParams> {
  final InvitationRepository repository;

  SendGroupInvite(this.repository);

  @override
  Future<Either<Failure, void>> call(SendGroupInviteParams params) async {
    return await repository.sendGroupInvite(
      inviterId: params.inviterId,
      inviteeEmail: params.inviteeEmail,
      groupId: params.groupId,
    );
  }
}

class SendGroupInviteParams extends Equatable {
  final String inviterId;
  final String inviteeEmail;
  final String groupId;

  const SendGroupInviteParams({
    required this.inviterId,
    required this.inviteeEmail,
    required this.groupId,
  });

  @override
  List<Object> get props => [inviterId, inviteeEmail, groupId];
}
