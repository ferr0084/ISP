import '../entities/expense.dart';
import '../repositories/event_expense_repository.dart';

class CreateExpense {
  final EventExpenseRepository repository;

  CreateExpense(this.repository);

  Future<EventExpense> call({
    required String eventId,
    required String payerId,
    required double amount,
    required String description,
    required Map<String, double> participants,
  }) async {
    return await repository.createExpense(
      eventId: eventId,
      payerId: payerId,
      amount: amount,
      description: description,
      participants: participants,
    );
  }
}
