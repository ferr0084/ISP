import 'package:app/features/groups/domain/entities/group_member.dart';

abstract class GroupMembersRemoteDataSource {
  Future<List<GroupMember>> getGroupMembers(String groupId);
}
