import 'dart:async';

import 'package:app/core/di/service_locator.dart';
import 'package:app/core/error/failures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    _messagesSubscription = _getMessages(GetMessagesParams(chatId: chatId))
        .listen(
          (result) {
            result.fold(
              (failure) {
                // Propagate failures to the UI
                _messages = [];
                _error = failure;
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
            // Propagate stream errors to the UI
            _messages = [];
            _error = const ServerFailure(
              'Failed to fetch messages',
            ); // Changed to instantiate with arguments
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty) return false;

    final senderId = sl<SupabaseClient>().auth.currentUser?.id;
    if (senderId == null) {
      _error = const ServerFailure(
        'User not authenticated',
      ); // Or some other appropriate failure
      notifyListeners();
      return false;
    }

    // Optimistic update
    final optimisticMessage = Message(
      id: DateTime.now().toIso8601String(), // Temporary ID
      chatId: chatId,
      senderId: senderId,
      content: content.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _messages.add(optimisticMessage);
    notifyListeners();

    final result = await _sendMessage(
      SendMessageParams(chatId: chatId, content: content.trim()),
    );

    return result.fold(
      (failure) {
        // Revert optimistic update on failure
        _messages.removeWhere((msg) => msg.id == optimisticMessage.id);
        _error = failure;
        notifyListeners();
        return false;
      },
      (_) {
        // The stream will eventually replace the optimistic message with the real one
        _error = null;
        // No need to call notifyListeners() here, as the stream will do it.
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
