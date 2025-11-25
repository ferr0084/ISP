import 'package:equatable/equatable.dart';

class EventSettlement extends Equatable {
  final String id;
  final String eventId;
  final String payerId;
  final String payeeId;
  final double amount;
  final DateTime createdAt;

  const EventSettlement({
    required this.id,
    required this.eventId,
    required this.payerId,
    required this.payeeId,
    required this.amount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, eventId, payerId, payeeId, amount, createdAt];
}
