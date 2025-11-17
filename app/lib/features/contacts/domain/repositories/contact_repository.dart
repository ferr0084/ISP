import 'package:app/features/contacts/domain/entities/contact.dart';

abstract class ContactRepository {
  Stream<List<Contact>> getContacts();
  Future<Contact> getContact(String id); // Added
  Future<void> addExistingContact(
    String contactUserId, {
    String? nickname,
    String? email,
  });
  Future<List<Contact>> searchUsers(String query);
  Future<void> updateContact(Contact contact); // Added
  String? getCurrentUserId();
}
