import '../entities/expense.dart';
import '../entities/settlement.dart';

abstract class EventExpenseRepository {
  Future<List<EventExpense>> getEventExpenses(String eventId);
  Future<List<EventSettlement>> getEventSettlements(String eventId);
  Future<EventExpense> createExpense({
    required String eventId,
    required String payerId,
    required double amount,
    required String description,
    required Map<String, double> participants, // userId -> amountOwed
  });
  Future<EventSettlement> createSettlement({
    required String eventId,
    required String payerId,
    required String payeeId,
    required double amount,
  });
}
