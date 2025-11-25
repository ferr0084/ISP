import '../entities/settlement.dart';
import '../repositories/event_expense_repository.dart';

class CreateSettlement {
  final EventExpenseRepository repository;

  CreateSettlement(this.repository);

  Future<EventSettlement> call({
    required String eventId,
    required String payerId,
    required String payeeId,
    required double amount,
  }) async {
    return await repository.createSettlement(
      eventId: eventId,
      payerId: payerId,
      payeeId: payeeId,
      amount: amount,
    );
  }
}
