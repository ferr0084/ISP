import 'dart:async';

import 'package:app/core/error/failures.dart'; // Import failures
import 'package:app/features/chats/domain/entities/message_with_sender.dart';
import 'package:app/features/chats/domain/usecases/get_latest_messages.dart';
import 'package:app/features/events/domain/entities/group_expense_summary.dart';
import 'package:app/features/events/domain/usecases/get_group_expense_summary.dart';
import 'package:app/features/groups/domain/entities/group.dart';
import 'package:app/features/groups/domain/entities/group_member.dart';
import 'package:app/features/groups/domain/repositories/group_repository.dart';
import 'package:app/features/groups/domain/usecases/get_group_members.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupDetailProvider with ChangeNotifier {
  final GroupRepository _groupRepository;
  final GetLatestMessages _getLatestMessages;
  final GetGroupMembers _getGroupMembers;
  final GetGroupExpenseSummary _getGroupExpenseSummary;
  final String groupId;

  GroupDetailProvider(
    this._groupRepository,
    this._getLatestMessages,
    this._getGroupMembers,
    this._getGroupExpenseSummary,
    this.groupId,
  );

  Group? _group;
  Group? get group => _group;

  List<MessageWithSender> _latestMessages = [];
  List<MessageWithSender> get latestMessages => _latestMessages;

  List<GroupMember> _members = [];
  List<GroupMember> get members => _members;

  GroupExpenseSummary? _expenseSummary;
  GroupExpenseSummary? get expenseSummary => _expenseSummary;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchGroupDetails() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    final failureOrGroup = await _groupRepository.getGroup(groupId);
    failureOrGroup.fold(
      (failure) {
        _hasError = true;
        if (failure is ServerFailure) {
          _errorMessage = failure.message;
        } else if (failure is GroupNotFoundFailure) {
          _errorMessage = failure.message;
        } else {
          _errorMessage = 'An unexpected error occurred.';
        }
        _isLoading = false;
        notifyListeners();
      },
      (group) {
        _group = group;
        _isLoading = false;
        _hasError = false;
        _errorMessage = null;
        notifyListeners();

        if (group.chatId != null) {
          _fetchLatestMessages(group.chatId!);
        }
        _fetchGroupMembers();
        _fetchGroupExpenseSummary();
      },
    );
  }

  void _fetchLatestMessages(String chatId) async {
    final failureOrMessages = await _getLatestMessages(
      GetLatestMessagesParams(chatId: chatId),
    );
    failureOrMessages.fold(
      (failure) {
        // Ignore failures for latest messages for now
      },
      (messages) {
        _latestMessages = messages;
        notifyListeners();
      },
    );
  }

  void _fetchGroupMembers() async {
    final failureOrMembers = await _getGroupMembers(
      GetGroupMembersParams(groupId: groupId),
    );
    failureOrMembers.fold(
      (failure) {
        _hasError = true;
        if (failure is ServerFailure) {
          _errorMessage = failure.message;
        } else {
          _errorMessage = 'Failed to fetch group members.';
        }
        notifyListeners();
      },
      (members) {
        _members = members;
        notifyListeners();
      },
    );
  }

  void _fetchGroupExpenseSummary() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final failureOrSummary = await _getGroupExpenseSummary(
          GetGroupExpenseSummaryParams(userId: userId, groupId: groupId),
        );
        failureOrSummary.fold(
          (failure) {
            // Don't set error for expense summary, just leave it null
            _expenseSummary = null;
          },
          (summary) {
            _expenseSummary = summary;
            notifyListeners();
          },
        );
      }
    } catch (e) {
      _expenseSummary = null;
    }
  }
}
