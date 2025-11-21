import 'package:equatable/equatable.dart';

class ChatWithLastMessage extends Equatable {
  final String chatId;
  final String? chatName;
  final String lastMessageContent;
  final DateTime lastMessageCreatedAt;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final int unreadCount;

  const ChatWithLastMessage({
    required this.chatId,
    this.chatName,
    required this.lastMessageContent,
    required this.lastMessageCreatedAt,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [
        chatId,
        chatName,
        lastMessageContent,
        lastMessageCreatedAt,
        senderId,
        senderName,
        senderAvatarUrl,
        unreadCount,
      ];
}
