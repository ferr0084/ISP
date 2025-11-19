import 'package:app/features/profile/domain/entities/user_profile.dart';
import 'package:dartz/dartz.dart';
import '../entities/group.dart';
import '../failures/group_failure.dart';

abstract class GroupRepository {
  Future<Either<GroupFailure, List<Group>>> getGroups();
  Future<Either<GroupFailure, Group>> getGroup(String id);
  Future<Either<GroupFailure, Unit>> createGroup(Group group);
  Future<Either<GroupFailure, Unit>> updateGroup(Group group);
  Future<Either<GroupFailure, Unit>> deleteGroup(String id);
  Stream<List<Group>> getGroupsStream();
  Future<List<UserProfile>> searchUsersNotInGroup(String query, String groupId);
}
