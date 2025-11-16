import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String userId;

  const Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, description, amount, date, userId];
}
