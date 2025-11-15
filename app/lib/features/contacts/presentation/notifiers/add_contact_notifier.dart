import 'package:app/features/contacts/domain/entities/contact.dart';
import 'package:app/features/contacts/domain/repositories/contact_repository.dart';
import 'package:flutter/material.dart';

class AddContactNotifier extends ChangeNotifier {
  final ContactRepository contactRepository;

  AddContactNotifier({required this.contactRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  List<Contact> _searchResults = [];
  List<Contact> get searchResults => _searchResults;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setSuccess(bool success) {
    _isSuccess = success;
    notifyListeners();
  }

  void _setSearchResults(List<Contact> results) {
    _searchResults = results;
    notifyListeners();
  }

  Future<void> searchUsers(String query) async {
    _setLoading(true);
    _setErrorMessage(null);
    _setSearchResults([]);

    try {
      final results = await contactRepository.searchUsers(query);
      _setSearchResults(results);
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addExistingContact(
    String contactUserId, {
    String? nickname,
    String? email,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    _setSuccess(false);

    try {
      await contactRepository.addExistingContact(
        contactUserId,
        nickname: nickname,
        email: email,
      );
      _setSuccess(true);
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
