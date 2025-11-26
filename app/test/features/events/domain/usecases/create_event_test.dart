import 'package:app/features/events/domain/entities/event.dart';
import 'package:app/features/events/domain/failures/event_failure.dart';
import 'package:app/features/events/domain/repositories/event_repository.dart';
import 'package:app/features/events/domain/usecases/create_event.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_event_test.mocks.dart';

@GenerateMocks([EventRepository])
void main() {
  late CreateEvent usecase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    usecase = CreateEvent(mockRepository);
  });

  final tEvent = Event(
    id: '1',
    name: 'Test Event',
    description: 'Test Description',
    date: DateTime.now().add(const Duration(days: 1)),
    location: 'Test Location',
    creatorId: 'creator1',
    groupId: null,
  );

  group('CreateEvent validation', () {
    test('should validate event date is not in the past', () async {
      // Arrange
      final pastEvent = Event(
        id: '',
        name: 'Past Event',
        description: 'Test Description',
        date: DateTime.now().subtract(const Duration(days: 1)),
        location: 'Test Location',
        creatorId: 'creator1',
        groupId: null,
      );

      // Act
      final result = await usecase(pastEvent);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidEventDateFailure>()),
        (event) => fail('Should have returned failure'),
      );
    });

    test('should validate invitee limit', () async {
      // Arrange
      final inviteeIds = List.generate(51, (index) => 'user$index'); // 51 invitees

      // Act
      final result = await usecase(tEvent, inviteeIds: inviteeIds);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<TooManyInviteesFailure>()),
        (event) => fail('Should have returned failure'),
      );
    });

    test('should validate event name is not empty', () async {
      // Arrange
      final invalidEvent = Event(
        id: '',
        name: '   ', // whitespace only
        description: 'Test Description',
        date: DateTime.now().add(const Duration(days: 1)),
        location: 'Test Location',
        creatorId: 'creator1',
        groupId: null,
      );

      // Act
      final result = await usecase(invalidEvent);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<EventValidationFailure>()),
        (event) => fail('Should have returned failure'),
      );
    });

    test('should validate event location is not empty', () async {
      // Arrange
      final invalidEvent = Event(
        id: '',
        name: 'Test Event',
        description: 'Test Description',
        date: DateTime.now().add(const Duration(days: 1)),
        location: '', // empty location
        creatorId: 'creator1',
        groupId: null,
      );

      // Act
      final result = await usecase(invalidEvent);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<EventValidationFailure>()),
        (event) => fail('Should have returned failure'),
      );
    });
  });

  test('should create event when validation passes', () async {
    // Arrange
    when(
      mockRepository.createEvent(tEvent, inviteeIds: ['user1', 'user2']),
    ).thenAnswer((_) async => tEvent);

    // Act
    final result = await usecase(tEvent, inviteeIds: ['user1', 'user2']);

    // Assert
    expect(result, Right(tEvent));
    verify(mockRepository.createEvent(tEvent, inviteeIds: ['user1', 'user2']));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    when(
      mockRepository.createEvent(tEvent, inviteeIds: []),
    ).thenThrow(Exception('Repository error'));

    // Act
    final result = await usecase(tEvent);

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<EventValidationFailure>()),
      (event) => fail('Should have returned failure'),
    );
  });
}