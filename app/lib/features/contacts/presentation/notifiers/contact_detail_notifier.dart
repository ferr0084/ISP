import 'package:flutter/material.dart';
import 'package:app/features/contacts/domain/entities/contact.dart';
import 'package:app/features/contacts/domain/repositories/contact_repository.dart';

class ContactDetailNotifier extends ChangeNotifier {
  final ContactRepository _contactRepository;

  Contact? _contact;
  bool _isLoading = false;
  String? _errorMessage;

  ContactDetailNotifier(this._contactRepository);

  Contact? get contact => _contact;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  Future<void> fetchContact(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _contact = await _contactRepository.getContact(id);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching contact: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateContact(Contact updatedContact) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _contactRepository.updateContact(updatedContact);
      _contact = updatedContact; // Update local contact after successful update
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating contact: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
