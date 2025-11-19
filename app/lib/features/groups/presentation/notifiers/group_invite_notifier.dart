import 'package:app/features/groups/domain/repositories/invitation_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/features/profile/domain/entities/user_profile.dart'; // Ensure this path is correct
import 'package:app/features/groups/domain/repositories/group_repository.dart';

class GroupInviteNotifier extends ChangeNotifier {
  final InvitationRepository _invitationRepository;
  final GroupRepository _groupRepository;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  GroupInviteNotifier(this._invitationRepository, this._groupRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<UserProfile> _searchResults = [];
  List<UserProfile> get searchResults => _searchResults;

  Future<void> sendGroupInvites(
      List<String> inviteeEmails, String groupId) async {
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
        await _invitationRepository.sendGroupInvite(
            inviterId: currentUserId, inviteeEmail: email, groupId: groupId);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchUsers(String query, String groupId) async {
    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Assuming GroupRepository has a method to search users not in the group
      final users = await _groupRepository.searchUsersNotInGroup(query, groupId);
      _searchResults = users;
    } catch (e) {
      _errorMessage = 'Failed to search for users: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _errorMessage = null;
    notifyListeners();
  }
}
