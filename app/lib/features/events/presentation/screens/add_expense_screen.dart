import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_invitation.dart';
import '../../domain/usecases/get_event.dart';
import '../providers/event_expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final String eventId;

  const AddExpenseScreen({super.key, required this.eventId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  // Map of userId -> isSelected
  final Map<String, bool> _selectedParticipants = {};
  Event? _event;
  bool _isLoadingEvent = true;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      final event = await sl<GetEvent>().call(widget.eventId);
      setState(() {
        _event = event;
        _isLoadingEvent = false;
        // Initialize all participants as selected
        if (event.invitations != null) {
          for (final invite in event.invitations!) {
            // Only include accepted or pending? Probably accepted.
            if (invite.status == InvitationStatus.accepted) {
              _selectedParticipants[invite.inviteeId] = true;
            }
          }
        }
        // Also add creator if not in invitations (usually creator is implicit)
        // But creator might not be in invitations list depending on implementation.
        // Let's assume creator is always a participant.
        _selectedParticipants[event.creatorId] = true;

        // Fetch user names
        final provider = context.read<EventExpenseProvider>();
        if (event.invitations != null) {
          for (final invite in event.invitations!) {
            provider.fetchUserName(invite.inviteeId);
          }
        }
        provider.fetchUserName(event.creatorId);
      });
    } catch (e) {
      // Handle error
      setState(() {
        _isLoadingEvent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.user?.id;

    if (_isLoadingEvent) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_event == null) {
      return const Scaffold(body: Center(child: Text('Event not found')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (double.tryParse(value) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Split with:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._selectedParticipants.keys.map((userId) {
              final userName = context
                  .watch<EventExpenseProvider>()
                  .getUserName(userId);
              return CheckboxListTile(
                title: Text(
                  userId == currentUserId
                      ? 'Me'
                      : (userName ?? 'User ${userId.substring(0, 4)}'),
                ),
                value: _selectedParticipants[userId],
                onChanged: (value) {
                  setState(() {
                    _selectedParticipants[userId] = value ?? false;
                  });
                },
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final description = _descriptionController.text;
    final amount = double.parse(_amountController.text);
    final selectedUserIds = _selectedParticipants.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one person to split with'),
        ),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final payerId = userProvider.user!.id;

    // Simple even split
    final splitAmount = amount / selectedUserIds.length;
    final participants = <String, double>{};
    for (final userId in selectedUserIds) {
      // If I pay $100 and split with you, I owe 0 (or rather I paid my share), you owe $50.
      // Wait, if I pay $100 for both of us (even split):
      // Total: 100. Participants: Me, You.
      // My share: 50. Your share: 50.
      // I paid 100.
      // I am owed: 100 - 50 = 50.
      // You owe: 50.

      // The API expects `participants` map: userId -> amountOwed.
      // `amountOwed` usually means "how much this person is responsible for".
      // OR "how much this person owes the payer".

      // Let's check `EventExpenseRemoteDataSourceImpl`:
      // 'amount_owed': entry.value
      // And balances calculation in Provider:
      // balances[participant.userId] -= participant.amountOwed;
      // balances[payerId] += expense.amount;

      // If I pay 100.
      // Payer balance += 100.
      // Me (participant) balance -= 50.
      // You (participant) balance -= 50.
      // Net: Me = +50. You = -50. Correct.

      // So `amountOwed` here represents the "share" of the expense.
      participants[userId] = splitAmount;
    }

    try {
      await context.read<EventExpenseProvider>().addExpense(
        eventId: widget.eventId,
        payerId: payerId,
        amount: amount,
        description: description,
        participants: participants,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
