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
              .inFilter('id', contactIds);

          return profiles
              .map((profile) => Contact.fromProfile(profile: profile))
              .toList();
        });
  }

  @override
  Future<Contact> getContact(String id) async {
    final response = await supabaseClient
        .from('profiles')
        .select()
        .eq('id', id)
        .single();
    return Contact.fromProfile(profile: response);
  }

  @override
  Future<void> updateContact(Contact contact) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    // Ensure the user is only updating their own contact (if it's their profile)
    // or a contact they have added (if it's a contact entry)
    // For now, we'll assume the RLS policies handle this.

    final updates = {
      'full_name': contact.name,
      'avatar_url': contact.avatarUrl,
      'phone_number': contact.phoneNumber,
      'email': contact.email,
      'nickname': contact.nickname,
    };

    await supabaseClient.from('profiles').update(updates).eq('id', contact.id);
  }

  @override
  Future<void> addExistingContact(
    String contactUserId, {
    String? nickname,
    String? email,
  }) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    await supabaseClient.from('contacts').insert({
      'user_id': userId,
      'contact_id': contactUserId,
      'nickname': nickname,
      'email': email,
    });
  }

  @override
  Future<List<Contact>> searchUsers(String query) async {
    final response = await supabaseClient
        .from('profiles')
        .select()
        .or(
          'full_name.ilike.%$query%,email.ilike.%$query%,phone_number.ilike.%$query%',
        )
        .limit(10); // Limit search results

    return response
        .map((profile) => Contact.fromProfile(profile: profile))
        .toList();
  }
}
