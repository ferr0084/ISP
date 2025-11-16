import 'package:dartz/dartz.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/expenses/domain/entities/expense.dart';
import 'package:app/features/expenses/domain/repositories/expense_repository.dart';

class GetExpenses implements UseCase<List<Expense>, NoParams> {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(NoParams params) async {
    return await repository.getExpenses();
  }
}
