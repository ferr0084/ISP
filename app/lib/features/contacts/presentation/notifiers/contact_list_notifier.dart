import 'package:app/features/contacts/domain/entities/contact.dart';
import 'package:app/features/contacts/domain/repositories/contact_repository.dart';
import 'package:flutter/material.dart';

class ContactListNotifier extends ChangeNotifier {
  final ContactRepository _contactRepository;
  List<Contact> _contacts = [];
  bool _isLoading = false;

  ContactListNotifier(this._contactRepository) {
    _fetchContacts();
  }

  List<Contact> get contacts => _contacts;
  bool get isLoading => _isLoading;

  void _fetchContacts() {
    _isLoading = true;
    notifyListeners();

    _contactRepository.getContacts().listen((contacts) {
      _contacts = contacts;
      _isLoading = false;
      notifyListeners();
    });
  }
}
