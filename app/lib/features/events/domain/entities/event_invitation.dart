import 'package:equatable/equatable.dart';

enum InvitationStatus { pending, accepted, declined }

class EventInvitation extends Equatable {
  final String id;
  final String eventId;
  final String inviteeId;
  final String inviterId;
  final InvitationStatus status;
  final DateTime? suggestedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventInvitation({
    required this.id,
    required this.eventId,
    required this.inviteeId,
    required this.inviterId,
    required this.status,
    this.suggestedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventInvitation.fromJson(Map<String, dynamic> json) {
    return EventInvitation(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      inviteeId: json['invitee_id'] as String,
      inviterId: json['inviter_id'] as String,
      status: InvitationStatus.values.firstWhere(
        (e) => e.name == json['status'] as String,
        orElse: () => InvitationStatus.pending,
      ),
      suggestedDate: json['suggested_date'] != null
          ? DateTime.parse(json['suggested_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'event_id': eventId,
    'invitee_id': inviteeId,
    'inviter_id': inviterId,
    'status': status.name,
    'suggested_date': suggestedDate?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  EventInvitation copyWith({
    String? id,
    String? eventId,
    String? inviteeId,
    String? inviterId,
    InvitationStatus? status,
    DateTime? suggestedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventInvitation(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      inviteeId: inviteeId ?? this.inviteeId,
      inviterId: inviterId ?? this.inviterId,
      status: status ?? this.status,
      suggestedDate: suggestedDate ?? this.suggestedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    eventId,
    inviteeId,
    inviterId,
    status,
    suggestedDate,
    createdAt,
    updatedAt,
  ];
}