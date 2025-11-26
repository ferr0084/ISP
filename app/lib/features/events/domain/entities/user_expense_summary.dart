import 'package:equatable/equatable.dart';

class UserExpenseSummary extends Equatable {
  final String otherUserId;
  final String otherUserName;
  final double netAmount;
  final String eventName;
  final String expenseDescription;

  const UserExpenseSummary({
    required this.otherUserId,
    required this.otherUserName,
    required this.netAmount,
    required this.eventName,
    required this.expenseDescription,
  });

  @override
  List<Object?> get props => [
    otherUserId,
    otherUserName,
    netAmount,
    eventName,
    expenseDescription,
  ];
}