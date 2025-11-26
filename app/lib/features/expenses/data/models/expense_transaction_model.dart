import '../../domain/entities/expense_transaction.dart';

class ExpenseTransactionModel {
  final String expenseId;
  final String eventName;
  final String expenseDescription;
  final String payerName;
  final double amount;
  final DateTime transactionDate;
  final bool isOwed;

  ExpenseTransactionModel({
    required this.expenseId,
    required this.eventName,
    required this.expenseDescription,
    required this.payerName,
    required this.amount,
    required this.transactionDate,
    required this.isOwed,
  });

  factory ExpenseTransactionModel.fromJson(Map<String, dynamic> json) {
    return ExpenseTransactionModel(
      expenseId: json['expense_id'] as String,
      eventName: json['event_name'] as String,
      expenseDescription: json['expense_description'] as String,
      payerName: json['payer_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      isOwed: json['is_owed'] as bool,
    );
  }

  ExpenseTransaction toEntity() {
    return ExpenseTransaction(
      expenseId: expenseId,
      eventName: eventName,
      expenseDescription: expenseDescription,
      payerName: payerName,
      amount: amount,
      transactionDate: transactionDate,
      isOwed: isOwed,
    );
  }
}