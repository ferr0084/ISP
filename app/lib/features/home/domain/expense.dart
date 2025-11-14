enum ExpenseType { owed, owes }

class Expense {
  final String description;
  final double amount;
  final ExpenseType type;

  Expense({
    required this.description,
    required this.amount,
    required this.type,
  });
}
