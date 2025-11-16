import 'package:supabase_flutter/supabase_flutter.dart';

class InvitationRepository {
  final SupabaseClient _supabaseClient;

  InvitationRepository(this._supabaseClient);

  Future<void> sendInvite(String inviterId, String inviteeEmail) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'send-invite',
        body: {'inviter_id': inviterId, 'invitee_email': inviteeEmail},
      );
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to send invitation');
      }
    } catch (e) {
      throw Exception('Error sending invitation: $e');
    }
  }

  Future<void> acceptInvite(String token, String userId) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'accept-invite',
        body: {'token': token, 'user_id': userId},
      );
      if (response.status != 200) {
        throw Exception(
          response.data['error'] ?? 'Failed to accept invitation',
        );
      }
    } catch (e) {
      throw Exception('Error accepting invitation: $e');
    }
  }
}
