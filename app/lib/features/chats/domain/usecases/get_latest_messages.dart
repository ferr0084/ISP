import 'package:app/core/error/failures.dart';
import 'package:app/features/chats/domain/entities/message_with_sender.dart';
import 'package:app/features/chats/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class GetLatestMessages {
  final ChatRepository repository;

  GetLatestMessages(this.repository);

  Future<Either<Failure, List<MessageWithSender>>> call(
    GetLatestMessagesParams params,
  ) {
    return repository.getLatestMessages(params.chatId);
  }
}

class GetLatestMessagesParams {
  final String chatId;

  GetLatestMessagesParams({required this.chatId});
}
