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

  Future<void> addContact(String phoneNumber) async {
    _setLoading(true);
    _setErrorMessage(null);
    _setSuccess(false);

    try {
      await contactRepository.addContact(phoneNumber);
      _setSuccess(true);
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
