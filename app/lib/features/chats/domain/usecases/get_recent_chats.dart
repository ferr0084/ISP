import 'package:app/core/error/failures.dart';
import 'package:app/features/chats/domain/entities/chat_with_last_message.dart';
import 'package:app/features/chats/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class GetRecentChats {
  final ChatRepository repository;

  GetRecentChats(this.repository);

  Stream<Either<Failure, List<ChatWithLastMessage>>> call() {
    return repository.getRecentChats();
  }
}
