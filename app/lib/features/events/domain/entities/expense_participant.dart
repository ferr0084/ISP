import 'package:equatable/equatable.dart';

class EventExpenseParticipant extends Equatable {
  final String id;
  final String expenseId;
  final String userId;
  final double amountOwed;
  final bool isSettled;

  const EventExpenseParticipant({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.amountOwed,
    required this.isSettled,
  });

  @override
  List<Object?> get props => [id, expenseId, userId, amountOwed, isSettled];
}
