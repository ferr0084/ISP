import 'package:app/features/home/domain/expense.dart';
import 'package:flutter/material.dart';

class PendingExpensesList extends StatelessWidget {
  const PendingExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    final expenses = [
      Expense(
        description: 'You owe Maria for "Team Lunch"',
        amount: 15.50,
        type: ExpenseType.owed,
      ),
      Expense(
        description: 'David owes you for "Movie Tickets"',
        amount: 25.00,
        type: ExpenseType.owes,
      ),
      Expense(
        description: 'You owe Chris for "Coffee Run"',
        amount: 8.75,
        type: ExpenseType.owed,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pending Expenses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return ListTile(
              leading: Icon(
                expense.type == ExpenseType.owed
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: expense.type == ExpenseType.owed
                    ? Colors.red
                    : Colors.green,
              ),
              title: Text(
                expense.description,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: expense.type == ExpenseType.owed
                      ? Colors.orange
                      : Colors.blue,
                ),
                child: Text('\$${expense.amount.toStringAsFixed(2)}'),
              ),
              onTap: () {},
            );
          },
        ),
      ],
    );
  }
}
