import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app/core/error/failures.dart';
import '../../domain/entities/chat.dart';
import '../../domain/usecases/create_chat.dart';
import '../../domain/usecases/get_chats.dart';

class ChatProvider extends ChangeNotifier {
  final GetChats _getChats;
  final CreateChat _createChat;

  List<Chat> _chats = [];
  bool _isLoading = false;
  Failure? _error;

  StreamSubscription? _chatsSubscription;

  ChatProvider(this._getChats, this._createChat) {
    _init();
  }

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  Failure? get error => _error;

  void _init() {
    _isLoading = true;
    notifyListeners();

    _chatsSubscription = _getChats().listen(
      (result) {
        result.fold(
          (failure) {
            // Ignore failures, show empty list
            _chats = [];
            _error = null;
            _isLoading = false;
            notifyListeners();
          },
          (chats) {
            _chats = chats;
            _error = null;
            _isLoading = false;
            notifyListeners();
          },
        );
      },
      onError: (error) {
        // Ignore stream errors, show empty list
        _chats = [];
        _error = null;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> createChat(String? name, List<String> memberIds) async {
    _isLoading = true;
    notifyListeners();

    final result = await _createChat(CreateChatParams(name: name, memberIds: memberIds));
    result.fold(
      (failure) {
        _error = failure;
        _isLoading = false;
        notifyListeners();
      },
      (chat) {
        // The stream will update the list
        _error = null;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    super.dispose();
  }
}