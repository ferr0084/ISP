import '../../domain/entities/expense_participant.dart';

class EventExpenseParticipantModel extends EventExpenseParticipant {
  const EventExpenseParticipantModel({
    required super.id,
    required super.expenseId,
    required super.userId,
    required super.amountOwed,
    required super.isSettled,
  });

  factory EventExpenseParticipantModel.fromJson(Map<String, dynamic> json) {
    return EventExpenseParticipantModel(
      id: json['id'] as String,
      expenseId: json['expense_id'] as String,
      userId: json['user_id'] as String,
      amountOwed: (json['amount_owed'] as num).toDouble(),
      isSettled: json['is_settled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_id': expenseId,
      'user_id': userId,
      'amount_owed': amountOwed,
      'is_settled': isSettled,
    };
  }
}
