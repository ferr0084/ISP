import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';

class UpdateEvent {
  final EventRepository repository;
  UpdateEvent(this.repository);

  Future<void> call(Event event) => repository.updateEvent(event);
}