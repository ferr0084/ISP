import 'package:flutter/material.dart';

// Data Models
class ExpenseSummary {
  final double totalExpenses;
  final double budget;
  final String period;

  ExpenseSummary({
    required this.totalExpenses,
    required this.budget,
    required this.period,
  });
}

class Transaction {
  final String description;
  final String category;
  final double amount;
  final DateTime date;
  final IconData categoryIcon;

  Transaction({
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    required this.categoryIcon,
  });
}

class ExpensesHomeScreen extends StatelessWidget {
  const ExpensesHomeScreen({super.key});

  // Dummy Data
  static final ExpenseSummary _expenseSummary = ExpenseSummary(
    totalExpenses: 750.50,
    budget: 1200.00,
    period: 'This Month',
  );

  static final List<Transaction> _recentTransactions = [
    Transaction(
      description: 'Groceries',
      category: 'Food',
      amount: 75.20,
      date: DateTime.now().subtract(const Duration(days: 1)),
      categoryIcon: Icons.fastfood,
    ),
    Transaction(
      description: 'Movie Tickets',
      category: 'Entertainment',
      amount: 25.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      categoryIcon: Icons.movie,
    ),
    Transaction(
      description: 'Gas Refill',
      category: 'Transport',
      amount: 40.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      categoryIcon: Icons.directions_car,
    ),
    Transaction(
      description: 'Dinner with friends',
      category: 'Food',
      amount: 60.00,
      date: DateTime.now().subtract(const Duration(days: 4)),
      categoryIcon: Icons.restaurant,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () {
            // TODO: Implement drawer functionality
          },
        ),
        title: Text(
          'Expenses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              // TODO: Implement filter/sort functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expense Summary Card
              Card(
                color: Theme.of(context).cardTheme.color,
                shape: Theme.of(context).cardTheme.shape,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _expenseSummary.period,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface
                              .withAlpha(178), // 0.7 * 255 = 178.5
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${_expenseSummary.totalExpenses.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          Text(
                            'of \$${_expenseSummary.budget.toStringAsFixed(2)} Budget',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withAlpha(178), // 0.7 * 255 = 178.5
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value:
                            _expenseSummary.totalExpenses /
                            _expenseSummary.budget,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Transactions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all transactions
                    },
                    child: Text(
                      'View All',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).cardTheme.color,
                shape: Theme.of(context).cardTheme.shape,
                child: Column(
                  children: _recentTransactions.map((transaction) {
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          transaction.categoryIcon,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      title: Text(
                        transaction.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        transaction.category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface
                              .withAlpha(178), // 0.7 * 255 = 178.5
                        ),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '-\$${transaction.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${transaction.date.month}/${transaction.date.day}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withAlpha(178), // 0.7 * 255 = 178.5
                                ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // TODO: View transaction details
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new expense functionality
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
