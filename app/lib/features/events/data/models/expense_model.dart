import '../../domain/entities/expense.dart';
import 'expense_participant_model.dart';

class EventExpenseModel extends EventExpense {
  const EventExpenseModel({
    required super.id,
    required super.eventId,
    required super.payerId,
    required super.amount,
    required super.description,
    required super.createdAt,
    super.participants,
  });

  factory EventExpenseModel.fromJson(Map<String, dynamic> json) {
    return EventExpenseModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      payerId: json['payer_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      participants: json['participants'] != null
          ? (json['participants'] as List<dynamic>)
                .map(
                  (e) => EventExpenseParticipantModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'payer_id': payerId,
      'amount': amount,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      if (participants != null)
        'participants': participants!
            .map((e) => (e as EventExpenseParticipantModel).toJson())
            .toList(),
    };
  }
}
