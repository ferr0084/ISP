import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  // Mock data for now
  final List<Group> _groups = [
    Group(
      id: '1',
      name: 'Project Phoenix',
      avatarUrl: 'assets/images/group_project_phoenix.png',
      memberIds: ['1', '2', '3'],
      lastMessage: 'Alex: Sounds good, let\'s sync up tomorrow.',
      time: '10:42 AM',
      unreadCount: 2,
    ),
    Group(
      id: '2',
      name: 'Family Chat',
      avatarUrl: 'assets/images/group_weekend_trip.png',
      memberIds: ['1', '4', '5'],
      lastMessage: 'You have a new mention',
      time: '9:15 AM',
      unreadCount: 1,
    ),
    Group(
      id: '3',
      name: 'Weekend Gamers',
      avatarUrl: 'assets/images/group_design_team.png',
      memberIds: ['1', '6', '7'],
      lastMessage: 'Sarah: Anyone online for a match?',
      time: 'Yesterday',
    ),
    Group(
      id: '4',
      name: 'Book Club',
      avatarUrl: 'assets/images/globe.png',
      memberIds: ['1', '8', '9'],
      lastMessage: 'Reminder: Chapter 5 discussion tonight!',
      time: 'Tuesday',
    ),
  ];

  @override
  Future<List<Group>> getGroups() async {
    // In a real implementation, this would fetch data from a database or API
    return _groups;
  }

  @override
  Future<Group> getGroup(String id) async {
    // In a real implementation, this would fetch data from a database or API
    return _groups.firstWhere((group) => group.id == id);
  }

  @override
  Future<void> createGroup(Group group) async {
    // In a real implementation, this would save the data to a database or API
    _groups.add(group);
  }

  @override
  Future<void> updateGroup(Group group) async {
    // In a real implementation, this would update the data in a database or API
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
    }
  }

  @override
  Future<void> deleteGroup(String id) async {
    // In a real implementation, this would delete the data from a database or API
    _groups.removeWhere((group) => group.id == id);
  }
}
