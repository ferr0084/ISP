import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/expenses/domain/repositories/expense_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteExpense implements UseCase<void, String> {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteExpense(params);
  }
}
