import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/presentation/providers/user_provider.dart';
import '../../domain/entities/payment_method.dart';
import '../providers/payment_method_provider.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();

  bool _isLoading = false;
  String? _cardBrand;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
  }

  String? _detectCardBrand(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');

    // Visa: starts with 4
    if (cleanNumber.startsWith('4')) {
      return 'visa';
    }
    // Mastercard: starts with 5[1-5] or 2[2-7]
    if (cleanNumber.startsWith('5') && cleanNumber.length >= 2 && '12345'.contains(cleanNumber[1])) {
      return 'mastercard';
    }
    if (cleanNumber.startsWith('2') && cleanNumber.length >= 2 && '234567'.contains(cleanNumber[1])) {
      return 'mastercard';
    }
    // American Express: starts with 34 or 37
    if (cleanNumber.startsWith('34') || cleanNumber.startsWith('37')) {
      return 'amex';
    }
    // Discover: starts with 6011, 622126-622925, 644-649, or 65
    if (cleanNumber.startsWith('6011') ||
        (cleanNumber.startsWith('622') && cleanNumber.length >= 6 &&
         int.parse(cleanNumber.substring(3, 6)) >= 126 && int.parse(cleanNumber.substring(3, 6)) <= 925) ||
        (cleanNumber.startsWith('64') && cleanNumber.length >= 4 && '456789'.contains(cleanNumber[3])) ||
        cleanNumber.startsWith('65')) {
      return 'discover';
    }

    return null;
  }

  String _formatCardNumber(String value) {
    final cleanValue = value.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < cleanValue.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanValue[i]);
    }

    return buffer.toString();
  }

  String _formatExpiry(String value) {
    final cleanValue = value.replaceAll(RegExp(r'\D'), '');
    if (cleanValue.length >= 2) {
      return '${cleanValue.substring(0, 2)}/${cleanValue.substring(2, cleanValue.length > 4 ? 4 : cleanValue.length)}';
    }
    return cleanValue;
  }

  Future<void> _addCard() async {
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

    final cleanCardNumber = _cardNumberController.text.replaceAll(RegExp(r'\s+'), '');
    final expiryParts = _expiryController.text.split('/');
    final expiryMonth = int.parse(expiryParts[0]);
    final expiryYear = int.parse('20${expiryParts[1]}');

    final paymentMethod = PaymentMethod(
      id: const Uuid().v4(),
      userId: userId,
      type: PaymentMethodType.card,
      name: '**** **** **** ${cleanCardNumber.substring(cleanCardNumber.length - 4)}',
      cardBrand: _cardBrand,
      cardLast4: cleanCardNumber.substring(cleanCardNumber.length - 4),
      cardExpiryMonth: expiryMonth,
      cardExpiryYear: expiryYear,
      isDefault: false, // Will be set by the database trigger if it's the first one
      isVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await context.read<PaymentMethodProvider>().addPaymentMethod(paymentMethod);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully!')),
        );
        context.go('/payment-methods');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<PaymentMethodProvider>().error ?? 'Failed to add card')),
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
          'Add Credit Card',
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
            // Card Number
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                border: const OutlineInputBorder(),
                prefixIcon: _cardBrand != null
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _getCardBrandIcon(_cardBrand!),
                      )
                    : null,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19), // Max 16 digits + 3 spaces
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card number';
                }
                final cleanNumber = value.replaceAll(RegExp(r'\s+'), '');
                if (cleanNumber.length < 13 || cleanNumber.length > 19) {
                  return 'Invalid card number length';
                }
                // Luhn algorithm validation would go here
                return null;
              },
              onChanged: (value) {
                final formatted = _formatCardNumber(value);
                if (formatted != value) {
                  _cardNumberController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
                setState(() {
                  _cardBrand = _detectCardBrand(value);
                });
              },
            ),
            const SizedBox(height: 16),

            // Expiry Date and CVV
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: const InputDecoration(
                      labelText: 'MM/YY',
                      hintText: '12/25',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final parts = value.split('/');
                      if (parts.length != 2) {
                        return 'Invalid format';
                      }
                      final month = int.tryParse(parts[0]);
                      final year = int.tryParse('20${parts[1]}');
                      if (month == null || month < 1 || month > 12) {
                        return 'Invalid month';
                      }
                      if (year == null || year < DateTime.now().year) {
                        return 'Expired';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final formatted = _formatExpiry(value);
                      if (formatted != value) {
                        _expiryController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (value.length < 3 || value.length > 4) {
                        return 'Invalid CVV';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cardholder Name
            TextFormField(
              controller: _cardholderNameController,
              decoration: const InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'John Doe',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter cardholder name';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Add Card Button
            ElevatedButton(
              onPressed: _isLoading ? null : _addCard,
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
                  : const Text('Add Card'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCardBrandIcon(String brand) {
    IconData iconData;
    switch (brand) {
      case 'visa':
        iconData = Icons.credit_card;
        break;
      case 'mastercard':
        iconData = Icons.credit_card;
        break;
      case 'amex':
        iconData = Icons.credit_card;
        break;
      case 'discover':
        iconData = Icons.credit_card;
        break;
      default:
        iconData = Icons.credit_card;
    }

    return Icon(iconData, size: 24);
  }
}