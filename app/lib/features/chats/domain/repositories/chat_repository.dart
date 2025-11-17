import 'package:app/core/error/failures.dart';
import 'package:app/features/chats/domain/entities/chat.dart';
import 'package:app/features/chats/domain/entities/chat_member.dart';
import 'package:app/features/chats/domain/entities/message.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepository {
  Stream<Either<Failure, List<Chat>>> getChats();
  Future<Either<Failure, Chat>> getChat(String id);
  Future<Either<Failure, Chat>> createChat(String? name, List<String> memberIds);
  Future<Either<Failure, Unit>> updateChat(Chat chat);
  Future<Either<Failure, Unit>> deleteChat(String id);

  Stream<Either<Failure, List<Message>>> getMessages(String chatId);
  Future<Either<Failure, Unit>> sendMessage(String chatId, String content);

  Future<Either<Failure, List<ChatMember>>> getChatMembers(String chatId);
  Future<Either<Failure, Unit>> addChatMember(String chatId, String userId);
  Future<Either<Failure, Unit>> removeChatMember(String chatId, String userId);
}
