import 'package:dartz/dartz.dart';

import '../failures/event_failure.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';

class CreateEvent {
  final EventRepository repository;
  static const int maxInvitees = 50;

  CreateEvent(this.repository);

  Future<Either<EventFailure, Event>> call(Event event, {List<String> inviteeIds = const []}) async {
    // Validate event date - cannot be in the past
    if (event.date.isBefore(DateTime.now())) {
      return const Left(InvalidEventDateFailure());
    }

    // Validate invitee limit
    if (inviteeIds.length > maxInvitees) {
      return Left(TooManyInviteesFailure(maxInvitees, 'Cannot invite more than $maxInvitees people to an event'));
    }

    // Validate event name is not empty
    if (event.name.trim().isEmpty) {
      return const Left(EventValidationFailure('Event name cannot be empty'));
    }

    // Validate location is not empty
    if (event.location.trim().isEmpty) {
      return const Left(EventValidationFailure('Event location cannot be empty'));
    }

    try {
      final createdEvent = await repository.createEvent(event, inviteeIds: inviteeIds);
      return Right(createdEvent);
    } catch (e) {
      return Left(EventValidationFailure('Failed to create event: ${e.toString()}'));
    }
  }
}
