import 'package:flutter/material.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';

class GroupProvider with ChangeNotifier {
  final GroupRepository _groupRepository;

  GroupProvider(this._groupRepository);

  List<Group> _groups = [];
  List<Group> get groups => _groups;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchGroups() async {
    _isLoading = true;
    notifyListeners();
    _groups = await _groupRepository.getGroups();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createGroup(Group group) async {
    await _groupRepository.createGroup(group);
    fetchGroups();
  }

  Future<void> updateGroup(Group group) async {
    await _groupRepository.updateGroup(group);
    fetchGroups();
  }

  Future<void> deleteGroup(String id) async {
    await _groupRepository.deleteGroup(id);
    fetchGroups();
  }
}
