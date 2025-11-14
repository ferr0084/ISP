import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      backgroundColor: const Color(0xFF1C2128), // Dark background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2128),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // TODO: Implement drawer functionality
          },
        ),
        title: const Text(
          'Expenses',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
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
                color: const Color(0xFF2D333B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _expenseSummary.period,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${_expenseSummary.totalExpenses.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'of \$${_expenseSummary.budget.toStringAsFixed(2)} Budget',
                            style: TextStyle(color: Colors.grey[400], fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _expenseSummary.totalExpenses / _expenseSummary.budget,
                        backgroundColor: Colors.grey[700],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
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
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all transactions
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFF2D333B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _recentTransactions.map((transaction) {
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(transaction.categoryIcon, color: Colors.white),
                      ),
                      title: Text(
                        transaction.description,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      subtitle: Text(
                        transaction.category,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '-\$${transaction.amount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${transaction.date.month}/${transaction.date.day}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}