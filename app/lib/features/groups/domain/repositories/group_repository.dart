import '../entities/group.dart';

abstract class GroupRepository {
  Future<List<Group>> getGroups();
  Future<Group> getGroup(String id);
  Future<void> createGroup(Group group);
  Future<void> updateGroup(Group group);
  Future<void> deleteGroup(String id);
}
