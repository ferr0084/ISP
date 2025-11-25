import '../entities/expense.dart';
import '../entities/settlement.dart';
import '../repositories/event_expense_repository.dart';

class GetEventExpenses {
  final EventExpenseRepository repository;

  GetEventExpenses(this.repository);

  Future<({List<EventExpense> expenses, List<EventSettlement> settlements})>
  call(String eventId) async {
    final expenses = await repository.getEventExpenses(eventId);
    final settlements = await repository.getEventSettlements(eventId);
    return (expenses: expenses, settlements: settlements);
  }
}
