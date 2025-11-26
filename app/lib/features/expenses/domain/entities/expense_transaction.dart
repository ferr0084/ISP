import 'package:equatable/equatable.dart';

class ExpenseTransaction extends Equatable {
  final String expenseId;
  final String eventName;
  final String expenseDescription;
  final String payerName;
  final double amount;
  final DateTime transactionDate;
  final bool isOwed; // true if user is owed this money, false if user owes

  const ExpenseTransaction({
    required this.expenseId,
    required this.eventName,
    required this.expenseDescription,
    required this.payerName,
    required this.amount,
    required this.transactionDate,
    required this.isOwed,
  });

  @override
  List<Object?> get props => [
    expenseId,
    eventName,
    expenseDescription,
    payerName,
    amount,
    transactionDate,
    isOwed,
  ];
}