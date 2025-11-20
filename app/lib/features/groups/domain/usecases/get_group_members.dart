import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/groups/domain/entities/group_member.dart';
import 'package:app/features/groups/domain/repositories/group_members_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetGroupMembers
    implements UseCase<List<GroupMember>, GetGroupMembersParams> {
  final GroupMembersRepository repository;

  GetGroupMembers(this.repository);

  @override
  Future<Either<Failure, List<GroupMember>>> call(
    GetGroupMembersParams params,
  ) async {
    return await repository.getGroupMembers(params.groupId);
  }
}

class GetGroupMembersParams extends Equatable {
  final String groupId;

  const GetGroupMembersParams({required this.groupId});

  @override
  List<Object> get props => [groupId];
}
