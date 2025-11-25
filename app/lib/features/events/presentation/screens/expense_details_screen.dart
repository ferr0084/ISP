import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/expense.dart';
import '../providers/event_expense_provider.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  final EventExpense expense;

  const ExpenseDetailsScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.description,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Paid by ${context.read<EventExpenseProvider>().getUserName(expense.payerId) ?? 'User ${expense.payerId.substring(0, 4)}'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${expense.createdAt.toLocal().toString().split('.')[0]}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const Text(
              'Split with:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (expense.participants != null)
              ...expense.participants!.map((participant) {
                return ListTile(
                  title: Text(
                    context.read<EventExpenseProvider>().getUserName(
                          participant.userId,
                        ) ??
                        'User ${participant.userId.substring(0, 4)}',
                  ),
                  trailing: Text(
                    '\$${participant.amountOwed.toStringAsFixed(2)}',
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
