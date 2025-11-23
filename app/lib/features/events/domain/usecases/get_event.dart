import '../../domain/repositories/event_repository.dart';
import '../../domain/entities/event.dart';

class GetEvent {
  final EventRepository repository;
  GetEvent(this.repository);

  Future<Event> call(String id) => repository.getEvent(id);
}