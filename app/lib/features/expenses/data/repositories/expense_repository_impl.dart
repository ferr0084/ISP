import 'package:app/core/error/failures.dart';
import 'package:app/features/expenses/domain/entities/expense.dart';
import 'package:app/features/expenses/domain/entities/expense_transaction.dart';
import 'package:app/features/expenses/domain/repositories/expense_repository.dart';
import 'package:dartz/dartz.dart';

import '../datasources/expense_remote_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Expense>>> getExpenses() async {
    // TODO: Implement when needed
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> addExpense(Expense expense) async {
    // TODO: Implement when needed
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateExpense(Expense expense) async {
    // TODO: Implement when needed
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    // TODO: Implement when needed
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<ExpenseTransaction>>> getUserExpenseTransactions(String userId) async {
    try {
      final models = await remoteDataSource.getUserExpenseTransactions(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}