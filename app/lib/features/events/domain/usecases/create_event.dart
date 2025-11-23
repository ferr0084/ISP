import '../../domain/repositories/event_repository.dart';
import '../../domain/entities/event.dart';

class CreateEvent {
  final EventRepository repository;
  CreateEvent(this.repository);

  Future<Event> call(Event event, {List<String> inviteeIds = const []}) =>
      repository.createEvent(event, inviteeIds: inviteeIds);
}
