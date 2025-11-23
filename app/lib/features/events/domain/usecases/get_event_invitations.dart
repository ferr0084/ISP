import '../../domain/repositories/event_repository.dart';
import '../../domain/entities/event_invitation.dart';

class GetEventInvitations {
  final EventRepository repository;
  GetEventInvitations(this.repository);

  Future<List<EventInvitation>> call(String eventId) =>
      repository.getEventInvitations(eventId);
}