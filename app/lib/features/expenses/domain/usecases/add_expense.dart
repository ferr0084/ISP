import 'package:dartz/dartz.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/expenses/domain/entities/expense.dart';
import 'package:app/features/expenses/domain/repositories/expense_repository.dart';

class AddExpense implements UseCase<void, Expense> {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(Expense params) async {
    return await repository.addExpense(params);
  }
}
