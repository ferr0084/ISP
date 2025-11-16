import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String location;
  final String creatorId;

  const Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.creatorId,
  });

  Event copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    String? location,
    String? creatorId,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      creatorId: creatorId ?? this.creatorId,
    );
  }

  @override
  List<Object?> get props => [id, name, description, date, location, creatorId];
}
