import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/chats/domain/repositories/chat_repository.dart';

class SendMessage implements UseCase<Unit, SendMessageParams> {
  final ChatRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SendMessageParams params) async {
    return await repository.sendMessage(params.chatId, params.content);
  }
}

class SendMessageParams extends Equatable {
  final String chatId;
  final String content;

  const SendMessageParams({required this.chatId, required this.content});

  @override
  List<Object?> get props => [chatId, content];
}
