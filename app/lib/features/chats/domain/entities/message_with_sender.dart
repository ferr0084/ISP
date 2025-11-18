import 'package:app/features/chats/domain/entities/message.dart';

class MessageWithSender {
  final Message message;
  final String senderName;
  final String? senderAvatar;

  MessageWithSender({
    required this.message,
    required this.senderName,
    this.senderAvatar,
  });
}
