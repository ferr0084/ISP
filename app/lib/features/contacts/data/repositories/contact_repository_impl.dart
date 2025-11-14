import 'package:app/features/contacts/domain/entities/contact.dart';
import 'package:app/features/contacts/domain/repositories/contact_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactRepositoryImpl implements ContactRepository {
  final SupabaseClient supabaseClient;

  ContactRepositoryImpl({required this.supabaseClient});

  @override
  Stream<List<Contact>> getContacts() {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    return supabaseClient
        .from('contacts')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((contacts) async {
          if (contacts.isEmpty) {
            return [];
          }

          final contactIds = contacts.map((c) => c['contact_id']).toList();
          final profiles = await supabaseClient
              .from('profiles')
              .select()
              .in_('id', contactIds);

          return profiles
              .map((profile) => Contact.fromProfile(profile: profile))
              .toList();
        });
  }
}
