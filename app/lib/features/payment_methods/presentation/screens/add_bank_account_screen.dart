import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/presentation/providers/user_provider.dart';
import '../../domain/entities/payment_method.dart';
import '../providers/payment_method_provider.dart';

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _accountHolderNameController.dispose();
    super.dispose();
  }



  Future<void> _addBankAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    final cleanAccountNumber = _accountNumberController.text.replaceAll(RegExp(r'\D'), '');

    final paymentMethod = PaymentMethod(
      id: const Uuid().v4(),
      userId: userId,
      type: PaymentMethodType.bankAccount,
      name: '${_bankNameController.text.trim()} ****${cleanAccountNumber.substring(cleanAccountNumber.length - 4)}',
      bankName: _bankNameController.text.trim(),
      bankAccountLast4: cleanAccountNumber.substring(cleanAccountNumber.length - 4),
      bankRoutingNumber: _routingNumberController.text.trim(),
      isDefault: false, // Will be set by the database trigger if it's the first one
      isVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await context.read<PaymentMethodProvider>().addPaymentMethod(paymentMethod);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank account added successfully!')),
        );
        context.go('/payment-methods');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<PaymentMethodProvider>().error ?? 'Failed to add bank account')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
              context.go('/payment-methods');
            }
          },
        ),
        title: Text(
          'Add Bank Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Bank Name
            TextFormField(
              controller: _bankNameController,
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                hintText: 'Chase, Bank of America, etc.',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter bank name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Account Holder Name
            TextFormField(
              controller: _accountHolderNameController,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name',
                hintText: 'John Doe',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter account holder name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Routing Number
            TextFormField(
              controller: _routingNumberController,
              decoration: const InputDecoration(
                labelText: 'Routing Number',
                hintText: '9-digit routing number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter routing number';
                }
                if (value.length != 9) {
                  return 'Routing number must be 9 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Account Number
            TextFormField(
              controller: _accountNumberController,
              decoration: InputDecoration(
                labelText: 'Account Number',
                hintText: 'Enter your account number',
                border: const OutlineInputBorder(),
                helperText: 'Your account number will be securely stored',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(17), // Max account number length
              ],
              obscureText: true, // Hide account number for security
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter account number';
                }
                final cleanNumber = value.replaceAll(RegExp(r'\D'), '');
                if (cleanNumber.length < 4 || cleanNumber.length > 17) {
                  return 'Invalid account number length';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Info Card
            Card(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your bank account information is encrypted and securely stored. We only store the last 4 digits for display purposes.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Add Bank Account Button
            ElevatedButton(
              onPressed: _isLoading ? null : _addBankAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Bank Account'),
            ),
          ],
        ),
      ),
    );
  }
}