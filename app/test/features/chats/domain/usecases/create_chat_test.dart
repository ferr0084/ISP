import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/features/chats/domain/entities/chat.dart';
import 'package:app/features/chats/domain/repositories/chat_repository.dart';
import 'package:app/features/chats/domain/usecases/create_chat.dart';

// Mock class
class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late CreateChat usecase;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    usecase = CreateChat(mockRepository);
  });

  final tChat = Chat(
    id: '1',
    name: 'Test Chat',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tParams = CreateChatParams(name: 'Test Chat', memberIds: ['user1', 'user2']);

  test('should create chat from repository', () async {
    // Arrange
    when(mockRepository.createChat('Test Chat', ['user1', 'user2']))
        .thenAnswer((_) async => Right(tChat));

    // Act
    final result = await usecase(tParams);

    // Assert
    expect(result, Right(tChat));
    verify(mockRepository.createChat('Test Chat', ['user1', 'user2']));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    when(mockRepository.createChat('Test Chat', ['user1', 'user2']))
        .thenAnswer((_) async => Left(ServerFailure()));

    // Act
    final result = await usecase(tParams);

    // Assert
    expect(result, Left(ServerFailure()));
    verify(mockRepository.createChat('Test Chat', ['user1', 'user2']));
    verifyNoMoreInteractions(mockRepository);
  });
}