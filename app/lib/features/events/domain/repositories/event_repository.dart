import 'package:app/features/events/domain/entities/event.dart';

abstract class EventRepository {
  Stream<List<Event>> getEvents();
  Future<Event> getEvent(String id);
  Future<void> createEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String id);
}
