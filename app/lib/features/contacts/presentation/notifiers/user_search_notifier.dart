import 'package:app/features/contacts/domain/entities/contact.dart';
import 'package:app/features/contacts/domain/repositories/contact_repository.dart';
import 'package:flutter/material.dart';

class UserSearchNotifier extends ChangeNotifier {
  final ContactRepository _contactRepository;

  UserSearchNotifier(this._contactRepository);

  List<Contact> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  List<Contact> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  Future<void> searchUsers(String query, List<Contact> existingContacts) async {
    if (query.isEmpty) {
      _searchResults = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allResults = await _contactRepository.searchUsers(query);

      // Filter out users who are already contacts
      final existingContactIds = existingContacts.map((c) => c.id).toSet();
      _searchResults = allResults.where((user) => !existingContactIds.contains(user.id)).toList();

      // Also filter out the current user if they're in the results
      final currentUserId = _contactRepository.getCurrentUserId();
      if (currentUserId != null) {
        _searchResults = _searchResults.where((user) => user.id != currentUserId).toList();
      }
    } catch (e) {
      _errorMessage = 'Error searching users: $e';
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _errorMessage = null;
    _isSearching = false;
    notifyListeners();
  }
}