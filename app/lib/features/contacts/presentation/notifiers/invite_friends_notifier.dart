import 'package:flutter/material.dart';
import 'package:app/features/contacts/data/repositories/invitation_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InviteFriendsNotifier extends ChangeNotifier {
  final InvitationRepository _invitationRepository;
  final SupabaseClient _supabaseClient;

  InviteFriendsNotifier(this._invitationRepository, this._supabaseClient);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> sendInvites(List<String> inviteeEmails) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final currentUserId = _supabaseClient.auth.currentUser?.id;
    if (currentUserId == null) {
      _errorMessage = 'User not logged in.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      for (final email in inviteeEmails) {
        await _invitationRepository.sendInvite(currentUserId, email);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
