import '../../domain/entities/event_invitation.dart';
import '../../domain/repositories/event_repository.dart';

class RespondToInvitation {
  final EventRepository repository;
  RespondToInvitation(this.repository);

  Future<void> call(String invitationId, InvitationStatus status, {DateTime? suggestedDate}) =>
      repository.respondToInvitation(invitationId, status, suggestedDate: suggestedDate);
}