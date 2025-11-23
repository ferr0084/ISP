import '../../domain/repositories/event_repository.dart';
import '../../domain/entities/event.dart';

class GetEvents {
  final EventRepository repository;
  GetEvents(this.repository);

  Stream<List<Event>> call() => repository.getEvents();
}
