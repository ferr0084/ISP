import 'package:app/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/entities/event.dart';

class GetEvents {
  final EventRepository repository;
  GetEvents(this.repository);

  Stream<Either<Failure, List<Event>>> call() => repository.getEvents();
}
