import '../../domain/repositories/event_repository.dart';

class SendEventInvitations {
  final EventRepository repository;
  SendEventInvitations(this.repository);

  Future<void> call(String eventId, List<String> inviteeIds) =>
      repository.sendEventInvitations(eventId, inviteeIds);
}