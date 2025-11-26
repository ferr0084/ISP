import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/expenses/domain/entities/expense_transaction.dart';
import 'package:app/features/expenses/domain/repositories/expense_repository.dart';
import 'package:dartz/dartz.dart';

class GetUserExpenseTransactions implements UseCase<List<ExpenseTransaction>, String> {
  final ExpenseRepository repository;

  GetUserExpenseTransactions(this.repository);

  @override
  Future<Either<Failure, List<ExpenseTransaction>>> call(String userId) async {
    try {
      final result = await repository.getUserExpenseTransactions(userId);
      return result;
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}