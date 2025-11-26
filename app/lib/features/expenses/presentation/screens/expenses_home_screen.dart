import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../events/presentation/providers/expense_summary_provider.dart';
import '../providers/expense_transaction_provider.dart';

class ExpensesHomeScreen extends StatefulWidget {
  const ExpensesHomeScreen({super.key});

  @override
  State<ExpensesHomeScreen> createState() => _ExpensesHomeScreenState();
}

class _ExpensesHomeScreenState extends State<ExpensesHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        context.read<ExpenseTransactionProvider>().fetchUserExpenseTransactions(userId);
        context.read<ExpenseSummaryProvider>().fetchUserPendingExpenses(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<ExpenseTransactionProvider>();
    final summaryProvider = context.watch<ExpenseSummaryProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Expenses Dashboard',
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
      body: transactionProvider.isLoading || summaryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactionProvider.error != null || summaryProvider.error != null
              ? Center(
                  child: Text(
                    'Error: ${transactionProvider.error ?? summaryProvider.error}',
                  ),
                )
               : _buildDashboardBody(transactionProvider, summaryProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/events');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildDashboardBody(
    ExpenseTransactionProvider transactionProvider,
    ExpenseSummaryProvider summaryProvider,
  ) {
    final totalExpenses = transactionProvider.totalExpenses;
    final totalOwed = transactionProvider.totalOwed;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expense Summary Block
            Card(
              color: Theme.of(context).cardTheme.color,
              shape: Theme.of(context).cardTheme.shape,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You Owe',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withAlpha(178),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${totalExpenses.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Owed to You',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withAlpha(178),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${totalOwed.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pending Payments Section
            if (summaryProvider.pendingExpenses.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pending Payments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all pending payments
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
                  children: summaryProvider.pendingExpenses.take(5).map((pending) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: pending.netAmount >= 0
                            ? Colors.green.withAlpha(100)
                            : Colors.red.withAlpha(100),
                        child: Icon(
                          pending.netAmount >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                          color: pending.netAmount >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        pending.otherUserName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        pending.eventName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                        ),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${pending.netAmount >= 0 ? '+' : ''}\$${pending.netAmount.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              color: pending.netAmount >= 0 ? Colors.green : Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            pending.netAmount >= 0 ? 'Owes you' : 'You owe',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // TODO: Navigate to settle up screen
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Recent Transactions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
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
            if (transactionProvider.transactions.isEmpty)
              Card(
                color: Theme.of(context).cardTheme.color,
                shape: Theme.of(context).cardTheme.shape,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No recent activity'),
                  ),
                ),
              )
            else
              Card(
                color: Theme.of(context).cardTheme.color,
                shape: Theme.of(context).cardTheme.shape,
                child: Column(
                  children: transactionProvider.transactions.take(10).map((transaction) {
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          transaction.isOwed ? Icons.arrow_upward : Icons.arrow_downward,
                          color: transaction.isOwed ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        transaction.expenseDescription,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.eventName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                            ),
                          ),
                          Text(
                            transaction.isOwed
                                ? '${transaction.payerName} paid'
                                : 'You paid',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: transaction.isOwed ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${transaction.isOwed ? '+' : '-'}\$${transaction.amount.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              color: transaction.isOwed ? Colors.green : Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${transaction.transactionDate.month}/${transaction.transactionDate.day}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
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
    );
  }
}
