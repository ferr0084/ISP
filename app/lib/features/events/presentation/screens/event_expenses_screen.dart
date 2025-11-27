import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../providers/event_expense_provider.dart';
import 'add_expense_screen.dart';
import 'expense_details_screen.dart';
import 'settle_up_screen.dart';

class EventExpensesScreen extends StatelessWidget {
  final String eventId;

  const EventExpensesScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<EventExpenseProvider>()..loadExpenses(eventId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expenses'),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(
                    IconData(0xe047, fontFamily: 'MaterialIcons'),
                  ), // attach_money
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: context.read<EventExpenseProvider>(),
                              child: SettleUpScreen(eventId: eventId),
                            ),
                          ),
                        )
                        .then((_) {
                          if (context.mounted) {
                            context.read<EventExpenseProvider>().loadExpenses(
                              eventId,
                            );
                          }
                        });
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<EventExpenseProvider>(),
                        child: AddExpenseScreen(eventId: eventId),
                      ),
                    ),
                  )
                  .then((_) {
                    if (context.mounted) {
                      context.read<EventExpenseProvider>().loadExpenses(
                        eventId,
                      );
                    }
                  });
            },
            child: const Icon(Icons.add),
          ),
        ),
        body: Consumer<EventExpenseProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text('Error: ${provider.error}'));
            }

            if (provider.expenses.isEmpty && provider.settlements.isEmpty) {
              return const Center(child: Text('No expenses yet.'));
            }

            return ListView(
              children: [
                _buildBalancesSection(context, provider),
                const Divider(),
                _buildExpensesList(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalancesSection(
    BuildContext context,
    EventExpenseProvider provider,
  ) {
    final balances = provider.balances;
    if (balances.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balances',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...balances.entries.map((entry) {
            final amount = entry.value;
            final isPositive = amount > 0;
            final userName =
                provider.getUserName(entry.key) ??
                'User ${entry.key.substring(0, 4)}';
            return Text(
              '$userName: ${isPositive ? '+' : ''}${amount.toStringAsFixed(2)}',
              style: TextStyle(color: isPositive ? Colors.green : Colors.red),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExpensesList(
    BuildContext context,
    EventExpenseProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...provider.expenses.map((expense) {
          return ListTile(
            title: Text(expense.description),
            subtitle: Text(
              'Paid by ${provider.getUserName(expense.payerId) ?? expense.payerId.substring(0, 4)}',
            ),
            trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: provider,
                    child: ExpenseDetailsScreen(expense: expense),
                  ),
                ),
              );
            },
          );
        }),
        ...provider.settlements.map((settlement) {
          return ListTile(
            title: const Text('Settlement'),
            subtitle: Text(
              '${provider.getUserName(settlement.payerId) ?? settlement.payerId.substring(0, 4)} paid ${provider.getUserName(settlement.payeeId) ?? settlement.payeeId.substring(0, 4)}',
            ),
            trailing: Text('\$${settlement.amount.toStringAsFixed(2)}'),
            leading: const Icon(Icons.check_circle, color: Colors.green),
          );
        }),
      ],
    );
  }
}
