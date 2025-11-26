import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_expense_summary.dart';
import '../repositories/expense_summary_repository.dart';

class GetUserPendingExpenses implements UseCase<List<UserExpenseSummary>, String> {
  final ExpenseSummaryRepository repository;

  GetUserPendingExpenses(this.repository);

  @override
  Future<Either<Failure, List<UserExpenseSummary>>> call(String userId) async {
    try {
      final expenses = await repository.getUserPendingExpenses(userId);
      return Right(expenses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}