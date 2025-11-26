import '../../domain/entities/payment_method.dart';

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.name,
    super.cardBrand,
    super.cardLast4,
    super.cardExpiryMonth,
    super.cardExpiryYear,
    super.bankName,
    super.bankAccountLast4,
    super.bankRoutingNumber,
    required super.isDefault,
    required super.isVerified,
    required super.createdAt,
    required super.updatedAt,
  });

  static PaymentMethodType _typeFromJson(String type) {
    switch (type) {
      case 'card':
        return PaymentMethodType.card;
      case 'bank_account':
        return PaymentMethodType.bankAccount;
      default:
        throw ArgumentError('Invalid payment method type: $type');
    }
  }

  static String _typeToJson(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.bankAccount:
        return 'bank_account';
    }
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      userId: json['user_id'],
      type: _typeFromJson(json['type']),
      name: json['name'],
      cardBrand: json['card_brand'],
      cardLast4: json['card_last4'],
      cardExpiryMonth: json['card_expiry_month'],
      cardExpiryYear: json['card_expiry_year'],
      bankName: json['bank_name'],
      bankAccountLast4: json['bank_account_last4'],
      bankRoutingNumber: json['bank_routing_number'],
      isDefault: json['is_default'] ?? false,
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': _typeToJson(type),
      'name': name,
      'card_brand': cardBrand,
      'card_last4': cardLast4,
      'card_expiry_month': cardExpiryMonth,
      'card_expiry_year': cardExpiryYear,
      'bank_name': bankName,
      'bank_account_last4': bankAccountLast4,
      'bank_routing_number': bankRoutingNumber,
      'is_default': isDefault,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}