import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_invitation.dart';
import '../../domain/usecases/get_event.dart';
import '../providers/event_expense_provider.dart';

class SettleUpScreen extends StatefulWidget {
  final String eventId;

  const SettleUpScreen({super.key, required this.eventId});

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String? _selectedPayeeId;
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

    // Get list of potential payees (everyone involved in the event except me)
    final potentialPayees = <String>{};
    if (_event!.invitations != null) {
      for (final invite in _event!.invitations!) {
        if (invite.status == InvitationStatus.accepted &&
            invite.inviteeId != currentUserId) {
          potentialPayees.add(invite.inviteeId);
        }
      }
    }
    if (_event!.creatorId != currentUserId) {
      potentialPayees.add(_event!.creatorId);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settle Up')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedPayeeId,
              decoration: const InputDecoration(labelText: 'Pay to'),
              items: potentialPayees.map((userId) {
                final userName = context
                    .watch<EventExpenseProvider>()
                    .getUserName(userId);
                return DropdownMenuItem(
                  value: userId,
                  child: Text(userName ?? 'User ${userId.substring(0, 4)}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPayeeId = value;
                });
              },
              validator: (value) => value == null ? 'Required' : null,
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
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Record Payment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final payeeId = _selectedPayeeId!;
    final userProvider = context.read<UserProvider>();
    final payerId = userProvider.user!.id;

    try {
      await context.read<EventExpenseProvider>().settleUp(
        eventId: widget.eventId,
        payerId: payerId,
        payeeId: payeeId,
        amount: amount,
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
