import 'package:app/core/error/failures.dart';
import 'package:app/features/chats/domain/entities/chat.dart';
import 'package:app/features/chats/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class GetChats {
  final ChatRepository repository;

  GetChats(this.repository);

  Stream<Either<Failure, List<Chat>>> call() {
    return repository.getChats();
  }
}
