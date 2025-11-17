import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app/core/error/failures.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/send_message.dart';

class MessageProvider extends ChangeNotifier {
  final GetMessages _getMessages;
  final SendMessage _sendMessage;
  final String chatId;

  List<Message> _messages = [];
  bool _isLoading = false;
  Failure? _error;

  StreamSubscription? _messagesSubscription;

  MessageProvider(this._getMessages, this._sendMessage, this.chatId) {
    _init();
  }

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  Failure? get error => _error;

  void _init() {
    _isLoading = true;
    notifyListeners();

    _messagesSubscription = _getMessages(GetMessagesParams(chatId: chatId)).listen(
      (result) {
        result.fold(
          (failure) {
            // Ignore failures, show empty list
            _messages = [];
            _error = null;
            _isLoading = false;
            notifyListeners();
          },
          (messages) {
            _messages = messages;
            _error = null;
            _isLoading = false;
            notifyListeners();
          },
        );
      },
      onError: (error) {
        // Ignore stream errors, show empty list
        _messages = [];
        _error = null;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty) return false;

    final result = await _sendMessage(SendMessageParams(chatId: chatId, content: content));
    return result.fold(
      (failure) {
        _error = failure;
        notifyListeners();
        return false;
      },
      (_) {
        // The stream will update the list
        _error = null;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}