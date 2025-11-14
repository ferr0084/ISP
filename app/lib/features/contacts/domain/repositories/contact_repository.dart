import 'package:app/features/contacts/domain/entities/contact.dart';

abstract class ContactRepository {
  Stream<List<Contact>> getContacts();
}
