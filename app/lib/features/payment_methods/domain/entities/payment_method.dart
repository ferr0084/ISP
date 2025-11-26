import 'package:equatable/equatable.dart';

enum PaymentMethodType {
  card,
  bankAccount,
}

class PaymentMethod extends Equatable {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String name;

  // Card-specific fields
  final String? cardBrand;
  final String? cardLast4;
  final int? cardExpiryMonth;
  final int? cardExpiryYear;

  // Bank account-specific fields
  final String? bankName;
  final String? bankAccountLast4;
  final String? bankRoutingNumber;

  // Common fields
  final bool isDefault;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.cardBrand,
    this.cardLast4,
    this.cardExpiryMonth,
    this.cardExpiryYear,
    this.bankName,
    this.bankAccountLast4,
    this.bankRoutingNumber,
    required this.isDefault,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  bool get isCard => type == PaymentMethodType.card;
  bool get isBankAccount => type == PaymentMethodType.bankAccount;

  String get displayName {
    switch (type) {
      case PaymentMethodType.card:
        return cardBrand != null ? '$cardBrand **** $cardLast4' : name;
      case PaymentMethodType.bankAccount:
        return bankName != null ? '$bankName **** $bankAccountLast4' : name;
    }
  }

  String get maskedNumber {
    switch (type) {
      case PaymentMethodType.card:
        return cardLast4 != null ? '**** **** **** $cardLast4' : '';
      case PaymentMethodType.bankAccount:
        return bankAccountLast4 != null ? '****$bankAccountLast4' : '';
    }
  }

  PaymentMethod copyWith({
    String? id,
    String? userId,
    PaymentMethodType? type,
    String? name,
    String? cardBrand,
    String? cardLast4,
    int? cardExpiryMonth,
    int? cardExpiryYear,
    String? bankName,
    String? bankAccountLast4,
    String? bankRoutingNumber,
    bool? isDefault,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      cardBrand: cardBrand ?? this.cardBrand,
      cardLast4: cardLast4 ?? this.cardLast4,
      cardExpiryMonth: cardExpiryMonth ?? this.cardExpiryMonth,
      cardExpiryYear: cardExpiryYear ?? this.cardExpiryYear,
      bankName: bankName ?? this.bankName,
      bankAccountLast4: bankAccountLast4 ?? this.bankAccountLast4,
      bankRoutingNumber: bankRoutingNumber ?? this.bankRoutingNumber,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    name,
    cardBrand,
    cardLast4,
    cardExpiryMonth,
    cardExpiryYear,
    bankName,
    bankAccountLast4,
    bankRoutingNumber,
    isDefault,
    isVerified,
    createdAt,
    updatedAt,
  ];
}