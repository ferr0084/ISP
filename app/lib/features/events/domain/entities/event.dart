import 'package:equatable/equatable.dart';
import 'event_invitation.dart';

class Event extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String location;
  final String creatorId;
  final String? groupId;
  final List<EventInvitation>? invitations;

  const Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.creatorId,
    this.groupId,
    this.invitations,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String? ?? '',
      creatorId: json['creator_id'] as String,
      groupId: json['group_id'] as String?,
      invitations: json['invitations'] != null
          ? (json['invitations'] as List<dynamic>)
                .map((e) => EventInvitation.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id.isNotEmpty) 'id': id,
    'name': name,
    'description': description,
    'date': date.toIso8601String(),
    'location': location,
    'creator_id': creatorId,
    if (groupId != null && groupId!.isNotEmpty) 'group_id': groupId,
    if (invitations != null)
      'invitations': invitations!.map((e) => e.toJson()).toList(),
  };

  Event copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    String? location,
    String? creatorId,
    String? groupId,
    List<EventInvitation>? invitations,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      creatorId: creatorId ?? this.creatorId,
      groupId: groupId ?? this.groupId,
      invitations: invitations ?? this.invitations,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    date,
    location,
    creatorId,
    groupId,
    invitations,
  ];
}
