import 'package:app/core/error/failures.dart';
import 'package:app/features/chats/domain/entities/message.dart';
import 'package:app/features/chats/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetMessages {
  final ChatRepository repository;

  GetMessages(this.repository);

  Stream<Either<Failure, List<Message>>> call(GetMessagesParams params) {
    return repository.getMessages(params.chatId);
  }
}

class GetMessagesParams extends Equatable {
  final String chatId;

  const GetMessagesParams({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}
