import 'package:equatable/equatable.dart';

class ChatMember extends Equatable {
  final String id;
  final String chatId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatMember({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, chatId, userId, createdAt, updatedAt];
}
