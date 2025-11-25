import 'package:equatable/equatable.dart';
import 'expense_participant.dart';

class EventExpense extends Equatable {
  final String id;
  final String eventId;
  final String payerId;
  final double amount;
  final String description;
  final DateTime createdAt;
  final List<EventExpenseParticipant>? participants;

  const EventExpense({
    required this.id,
    required this.eventId,
    required this.payerId,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.participants,
  });

  @override
  List<Object?> get props => [
    id,
    eventId,
    payerId,
    amount,
    description,
    createdAt,
    participants,
  ];
}
