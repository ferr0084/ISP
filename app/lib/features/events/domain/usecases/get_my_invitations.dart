import '../entities/event_invitation.dart';
import '../repositories/event_repository.dart';

class GetMyInvitations {
  final EventRepository repository;

  GetMyInvitations(this.repository);

  Stream<List<EventInvitation>> call(String userId) {
    return repository.getMyInvitations(userId);
  }
}
