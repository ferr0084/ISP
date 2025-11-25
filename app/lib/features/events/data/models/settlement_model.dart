import '../../domain/entities/settlement.dart';

class EventSettlementModel extends EventSettlement {
  const EventSettlementModel({
    required super.id,
    required super.eventId,
    required super.payerId,
    required super.payeeId,
    required super.amount,
    required super.createdAt,
  });

  factory EventSettlementModel.fromJson(Map<String, dynamic> json) {
    return EventSettlementModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      payerId: json['payer_id'] as String,
      payeeId: json['payee_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'payer_id': payerId,
      'payee_id': payeeId,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
