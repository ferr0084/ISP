import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/chats/domain/entities/chat.dart';
import 'package:app/features/chats/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class CreateChat implements UseCase<Chat, CreateChatParams> {
  final ChatRepository repository;

  CreateChat(this.repository);

  @override
  Future<Either<Failure, Chat>> call(CreateChatParams params) async {
    return await repository.createChat(params.name, params.memberIds);
  }
}

class CreateChatParams extends Equatable {
  final String? name;
  final List<String> memberIds;

  const CreateChatParams({this.name, required this.memberIds});

  @override
  List<Object?> get props => [name, memberIds];
}
