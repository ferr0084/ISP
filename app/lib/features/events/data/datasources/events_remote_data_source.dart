import '../../domain/entities/event.dart';
import '../../domain/entities/event_invitation.dart';

abstract class EventsRemoteDataSource {
  Stream<List<Event>> getEvents();
  Future<Event> getEvent(String id);
  Future<Event> createEvent(Event event, {List<String> inviteeIds = const []});
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String id);

  // Invitation methods
  Future<List<EventInvitation>> getEventInvitations(String eventId);
  Future<void> sendEventInvitations(String eventId, List<String> inviteeIds);
  Future<void> respondToInvitation(
    String invitationId,
    InvitationStatus status, {
    DateTime? suggestedDate,
  });
}
