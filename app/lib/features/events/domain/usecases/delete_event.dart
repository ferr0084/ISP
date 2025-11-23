import '../../domain/repositories/event_repository.dart';

class DeleteEvent {
  final EventRepository repository;
  DeleteEvent(this.repository);

  Future<void> call(String id) => repository.deleteEvent(id);
}