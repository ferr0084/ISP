import 'package:app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/event_invitation.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/events_remote_data_source.dart';

class EventRepositoryImpl implements EventRepository {
  final EventsRemoteDataSource remote;
  EventRepositoryImpl({required this.remote});

  @override
  Stream<Either<Failure, List<Event>>> getEvents() => remote.getEvents();

  @override
  Future<Event> getEvent(String id) => remote.getEvent(id);

  @override
  Future<Event> createEvent(
    Event event, {
    List<String> inviteeIds = const [],
  }) => remote.createEvent(event, inviteeIds: inviteeIds);

  @override
  Future<void> updateEvent(Event event) => remote.updateEvent(event);

  @override
  Future<void> deleteEvent(String id) => remote.deleteEvent(id);

  @override
  Future<List<EventInvitation>> getEventInvitations(String eventId) =>
      remote.getEventInvitations(eventId);

  @override
  Future<void> sendEventInvitations(String eventId, List<String> inviteeIds) =>
      remote.sendEventInvitations(eventId, inviteeIds);

  @override
  Future<void> respondToInvitation(
    String invitationId,
    InvitationStatus status, {
    DateTime? suggestedDate,
  }) => remote.respondToInvitation(
    invitationId,
    status,
    suggestedDate: suggestedDate,
  );

  @override
  Stream<Either<Failure, List<EventInvitation>>> getMyInvitations(String userId) =>
      remote.getMyInvitations(userId);
}
