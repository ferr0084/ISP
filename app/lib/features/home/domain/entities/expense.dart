enum ExpenseType { owedByYou, owedToYou }

class Expense {
  final ExpenseType type;
  final String description; // e.g., "You owe Maria", "David owes you"
  final String forWhat; // e.g., "For 'Team Lunch'"
  final double amount;

  Expense({
    required this.type,
    required this.description,
    required this.forWhat,
    required this.amount,
  });
}
