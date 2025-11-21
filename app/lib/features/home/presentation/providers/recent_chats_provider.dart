import 'dart:async';

import 'package:app/features/chats/domain/entities/chat_with_last_message.dart';
import 'package:app/features/chats/domain/usecases/get_recent_chats.dart';
import 'package:flutter/material.dart';

class RecentChatsProvider with ChangeNotifier {
  final GetRecentChats _getRecentChats;
  late StreamSubscription<dynamic> _recentChatsSubscription;

  RecentChatsProvider({required GetRecentChats getRecentChats})
    : _getRecentChats = getRecentChats {
    _subscribeToRecentChats();
  }

  List<ChatWithLastMessage> _recentChats = [];
  List<ChatWithLastMessage> get recentChats => _recentChats;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void _subscribeToRecentChats() {
    _recentChatsSubscription = _getRecentChats().listen((either) {
      either.fold(
        (failure) {
          _error = failure.toString();
          _isLoading = false;
          notifyListeners();
        },
        (chats) {
          _recentChats = chats;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
      );
    });
  }

  @override
  void dispose() {
    _recentChatsSubscription.cancel();
    super.dispose();
  }
}
