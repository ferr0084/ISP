import 'package:app/core/error/failures.dart';
import 'package:app/features/groups/domain/entities/group_member.dart';
import 'package:dartz/dartz.dart';

abstract class GroupMembersRepository {
  Future<Either<Failure, List<GroupMember>>> getGroupMembers(String groupId);
}
