import 'dart:async';
import 'package:app/features/chats/domain/entities/message_with_sender.dart';
import 'package:app/features/chats/domain/usecases/get_latest_messages.dart';
import 'package:flutter/material.dart';
import 'package:app/features/groups/domain/entities/group.dart';
import 'package:app/features/groups/domain/repositories/group_repository.dart';

class GroupDetailProvider with ChangeNotifier {
  final GroupRepository _groupRepository;
  final GetLatestMessages _getLatestMessages;
  final String groupId;

  GroupDetailProvider(
    this._groupRepository,
    this._getLatestMessages,
    this.groupId,
  );

  Group? _group;
  Group? get group => _group;

  List<MessageWithSender> _latestMessages = [];
  List<MessageWithSender> get latestMessages => _latestMessages;

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
        _errorMessage = failure.message;
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
      },
    );
  }

  void _fetchLatestMessages(String chatId) async {
    final failureOrMessages = await _getLatestMessages(
      GetLatestMessagesParams(chatId: chatId),
    );
    failureOrMessages.fold(
      (failure) {
        // Ignore failures for latest messages
      },
      (messages) {
        _latestMessages = messages;
        notifyListeners();
      },
    );
  }
}
