import '../../domain/entities/expense.dart';
import '../../domain/entities/settlement.dart';
import '../../domain/repositories/event_expense_repository.dart';
import '../datasources/event_expense_remote_data_source.dart';

class EventExpenseRepositoryImpl implements EventExpenseRepository {
  final EventExpenseRemoteDataSource remoteDataSource;

  EventExpenseRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<EventExpense>> getEventExpenses(String eventId) async {
    return await remoteDataSource.getEventExpenses(eventId);
  }

  @override
  Future<List<EventSettlement>> getEventSettlements(String eventId) async {
    return await remoteDataSource.getEventSettlements(eventId);
  }

  @override
  Future<EventExpense> createExpense({
    required String eventId,
    required String payerId,
    required double amount,
    required String description,
    required Map<String, double> participants,
  }) async {
    return await remoteDataSource.createExpense(
      eventId: eventId,
      payerId: payerId,
      amount: amount,
      description: description,
      participants: participants,
    );
  }

  @override
  Future<EventSettlement> createSettlement({
    required String eventId,
    required String payerId,
    required String payeeId,
    required double amount,
  }) async {
    return await remoteDataSource.createSettlement(
      eventId: eventId,
      payerId: payerId,
      payeeId: payeeId,
      amount: amount,
    );
  }
}
