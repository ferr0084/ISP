import 'dart:async';
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

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription? _groupsSubscription;

  Future<void> fetchGroups() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    _groupsSubscription?.cancel(); // Cancel previous subscription if any
    _groupsSubscription = _groupRepository.getGroupsStream().listen(
      (groups) {
        _groups = groups;
        _isLoading = false;
        _hasError = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _hasError = true;
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
      onDone: () {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> createGroup(Group group) async {
    _hasError = false;
    _errorMessage = null;
    final failureOrUnit = await _groupRepository.createGroup(group);
    failureOrUnit.fold((failure) {
      _hasError = true;
      _errorMessage = failure.message;
      notifyListeners();
    }, (_) {});
  }

  Future<void> updateGroup(Group group) async {
    _hasError = false;
    _errorMessage = null;
    final failureOrUnit = await _groupRepository.updateGroup(group);
    failureOrUnit.fold((failure) {
      _hasError = true;
      _errorMessage = failure.message;
      notifyListeners();
    }, (_) {});
  }

  Future<void> deleteGroup(String id) async {
    _hasError = false;
    _errorMessage = null;
    final failureOrUnit = await _groupRepository.deleteGroup(id);
    failureOrUnit.fold((failure) {
      _hasError = true;
      _errorMessage = failure.message;
      notifyListeners();
    }, (_) {});
  }

  Group? getGroup(String id) {
    try {
      return _groups.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _groupsSubscription?.cancel();
    super.dispose();
  }
}
